import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dti_hackathon_2020/Login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'Kitchen.dart';

class CreateRecipePage extends StatefulWidget {
  @override
  _CreateRecipePageState createState() => _CreateRecipePageState();
}

class _CreateRecipePageState extends State<CreateRecipePage> {
  GlobalKey<FormState> key = GlobalKey();
  File _image;
  final picker = ImagePicker();
  TextEditingController nameCtrl = TextEditingController();
  List<String> categories = [];
  TextEditingController ingredientCtrl = TextEditingController();
  List<String> ingredients = [];
  TextEditingController materialCtrl = TextEditingController();
  List<String> materials = [];
  TextEditingController instructionCtrl = TextEditingController();
  List<String> instructions = [];

  Future getCameraImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getGalleryImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadImageToGCS() async {
    if (_image == null) {
      print('image is null!');
    } else {
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('recipe_pics/${Path.basename(_image.path)}}}');
      StorageUploadTask uploadTask = storageReference.putFile(_image);
      await uploadTask.onComplete;
      print('file uploaded');
    }
  }

  Widget buildWrap(BuildContext context, List<String> list) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: list.map((str) {
        return GestureDetector(
          onTap: () {
            setState(() {
              list.remove(str);
            });
          },
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                border: Border.all(
                  color: Colors.transparent,
                ),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
            child: Text(str, style: TextStyle(fontSize: 14)),
          ),
        );
      }).toList(),
    );
  }

  Widget buildIngredientsField() {
    return StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('ingredients').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          List<DocumentSnapshot> allIngredientDocs = snapshot.data.documents;
          List<Ingredient> allIngredients = allIngredientDocs
              .map((doc) => Ingredient(doc.get('name'), doc.get('type')))
              .toList();

          return TypeAheadFormField(
            autoFlipDirection: true,
            noItemsFoundBuilder: (context) {
              return Padding(
                padding: const EdgeInsets.all(8),
                child: Text('No matching results, hit enter key to add!'),
              );
            },
            textFieldConfiguration: TextFieldConfiguration(
              controller: ingredientCtrl,
              onSubmitted: (input) {
                ingredientCtrl.clear();
                setState(() {
                  ingredients.add(input);
                });
              },
            ),
            suggestionsCallback: (pattern) {
              List<String> starts = allIngredients
                  .where((Ingredient ing) =>
                      ing.name.toLowerCase().startsWith(pattern))
                  .map((ing) => ing.name)
                  .toList();
              List<String> contains = allIngredients
                  .where((Ingredient ing) =>
                      ing.name.toLowerCase().contains(pattern))
                  .map((ing) => ing.name)
                  .toList();
              List<String> noDups =
                  LinkedHashSet<String>.from(starts + contains).toList();
              return noDups;
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                leading: Icon(Icons.restaurant),
                title: Text(suggestion),
              );
            },
            validator: (input) {
              if (ingredients.isEmpty) {
                return 'Please enter at least one ingredient!';
              }
              return null;
            },
            onSuggestionSelected: (suggestion) {
              ingredientCtrl.clear();
              setState(() {
                ingredients.add(suggestion);
              });
            },
          );
        });
  }

  Widget buildMaterialsField() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('materials')
            .doc('materials')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          DocumentSnapshot doc = snapshot.data;
          List<String> allMaterials = [
            List<String>.from(doc.get('appliances')),
            List<String>.from(doc.get('cookware')),
            List<String>.from(doc.get('utensils')),
          ].expand((x) => x).toList();

          return TypeAheadFormField(
            autoFlipDirection: true,
            noItemsFoundBuilder: (context) {
              return Padding(
                padding: const EdgeInsets.all(8),
                child: Text('No matching results, hit enter key to add!'),
              );
            },
            textFieldConfiguration: TextFieldConfiguration(
              controller: materialCtrl,
            ),
            suggestionsCallback: (pattern) {
              List<String> starts = allMaterials
                  .where((String mat) => mat.toLowerCase().startsWith(pattern))
                  .toList();
              List<String> contains = allMaterials
                  .where((String mat) => mat.toLowerCase().contains(pattern))
                  .toList();
              List<String> noDups =
                  LinkedHashSet<String>.from(starts + contains).toList();
              return noDups;
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                leading: Icon(Icons.restaurant),
                title: Text(suggestion),
              );
            },
            onSaved: (input) {
              materialCtrl.clear();
              setState(() {
                materials.add(input);
              });
            },
            onSuggestionSelected: (suggestion) {
              materialCtrl.clear();
              setState(() {
                materials.add(suggestion);
              });
            },
          );
        });
  }

  Future<String> retrieveCreatorName(BuildContext context) async {
    String userID = Provider.of<CurrentUserInfo>(context, listen: false).id;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userID).get();
    return userDoc.get('firstName') + ' ' + userDoc.get('lastName');
  }

  @override
  Widget build(BuildContext context) {
    List<String> allDietaryRestrictions = [
      'vegan',
      'vegetarian',
      'pescatarian',
      'kosher',
      'halal',
      'paleo',
      'tree nuts',
      'soy',
      'dairy',
      'shellfish',
      'eggs',
      'gluten'
    ];
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: key,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconButton(
              alignment: Alignment.topLeft,
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Text('Create Recipe', style: Theme.of(context).textTheme.headline1),
            _image == null
                ? Text('Take a photo or upload an image.')
                : Container(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.25),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.fitWidth,
                                    image: FileImage(_image)))))),
            Row(
              children: [
                IconButton(
                    icon: Icon(Icons.add_a_photo), onPressed: getCameraImage),
                IconButton(
                  icon: Icon(Icons.photo_library),
                  onPressed: getGalleryImage,
                ),
              ],
            ),
            Text('Recipe name', style: Theme.of(context).textTheme.headline2),
            SizedBox(height: 4),
            TextFormField(
              textCapitalization: TextCapitalization.sentences,
              controller: nameCtrl,
              validator: (input) {
                if (input.isEmpty) {
                  return 'Please enter a recipe name!';
                }
                return null;
              },
            ),
            SizedBox(height: 8),
            Text('Dietary Restrictions/Allergies',
                style: Theme.of(context).textTheme.headline2),
            Wrap(
              spacing: 4,
              children: allDietaryRestrictions.map((elem) {
                return ChoiceChip(
                  label: Text(elem),
                  labelStyle: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  selected: categories.contains(elem),
                  selectedColor: Theme.of(context).accentColor,
                  onSelected: (selected) {
                    setState(() {
                      if (selected)
                        categories.add(elem);
                      else
                        categories.remove(elem);
                    });
                  },
                );
              }).toList(),
            ),
            Text('Ingredients', style: Theme.of(context).textTheme.headline2),
            SizedBox(height: 4),
            buildIngredientsField(),
            SizedBox(height: 4),
            buildWrap(context, ingredients),
            SizedBox(height: 8),
            Text('Materials', style: Theme.of(context).textTheme.headline2),
            SizedBox(height: 4),
            buildMaterialsField(),
            SizedBox(height: 4),
            buildWrap(context, materials),
            SizedBox(height: 8),
            Text('Instructions', style: Theme.of(context).textTheme.headline2),
            SizedBox(height: 4),
            TextFormField(
              textCapitalization: TextCapitalization.sentences,
              validator: (input) {
                if (instructions.isEmpty) {
                  return 'Please enter instructions for making this recipe!';
                }
                return null;
              },
              controller: instructionCtrl,
              onFieldSubmitted: (input) {
                setState(() {
                  instructions.add(input);
                });
                instructionCtrl.clear();
              },
            ),
            SizedBox(height: 4),
            ListView(shrinkWrap: true, children: [
              for (int i = 0; i < instructions.length; i++)
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 2),
                  child: Text((i + 1).toString() + ') ' + instructions[i]),
                )
            ]),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              child: FlatButton(
                  padding: EdgeInsets.all(16),
                  child: Text('Save',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  color: Theme.of(context).primaryColor,
                  onPressed: () async {
                    if (key.currentState.validate()) {
                      FirebaseFirestore.instance.collection('recipes').add({
                        'categories': categories,
                        'creator': await retrieveCreatorName(context),
                        //TODO: replace with actual imageURL
                        'imageURL':
                            'https://i.kym-cdn.com/entries/icons/mobile/000/034/800/Get_Stick_Bugged_Banner.jpg',
                        'ingredients': ingredients,
                        'instructions': instructions,
                        'materials': materials,
                        'name': nameCtrl.text,
                      });
                      Navigator.of(context).pop();
                    }
                  }),
            )
          ]),
        ),
      ),
    )));
  }
}
