import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dti_hackathon_2020/Recipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

import 'Login.dart';
import 'UserInfo.dart';

class Ingredient {
  Ingredient(this.name, this.type);
  String name;
  String type;
}

class CreateIngredientPage extends StatefulWidget {
  _CreateIngredientPageState createState() => _CreateIngredientPageState();
}

class _CreateIngredientPageState extends State<CreateIngredientPage> {
  TextEditingController ctrl = TextEditingController();
  String selectedType = 'grains';

  Widget buildListTile(String type) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = type;
        });
      },
      child: ListTile(
          title: Text(type),
          leading: Radio(
            groupValue: selectedType,
            value: type,
            onChanged: (str) {
              setState(() {
                selectedType = str;
              });
            },
          )
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    String userID = Provider.of<CurrentUserInfo>(context, listen: false).id;
    GlobalKey<FormState> key = GlobalKey();

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    alignment: Alignment.topLeft,
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Text('Add an ingredient', style: Theme.of(context).textTheme.headline1),
                  SizedBox(height: 8),
                  Text('Name', style: Theme.of(context).textTheme.headline2),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('ingredients').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        List<DocumentSnapshot> allIngredientDocs = snapshot.data.documents;
                        List<Ingredient> allIngredients = allIngredientDocs.map((doc) => Ingredient(doc.get('name'), doc.get('type'))).toList();

                        return TypeAheadFormField(
                          noItemsFoundBuilder: (context) {
                            return Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('No matching results, hit enter key to add!'),
                            );
                          },
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: ctrl,
                          ),
                          validator: (input) {
                            if (input.isEmpty) {
                              return 'Enter a name.';
                            }
                            return null;
                          },
                          suggestionsCallback: (pattern) {
                            List<String> starts = allIngredients.where((Ingredient ing) =>
                                ing.name.toLowerCase().startsWith(pattern)).map((ing) => ing.name).toList();
                            List<String> contains = allIngredients.where((Ingredient ing) =>
                                ing.name.toLowerCase().contains(pattern)).map((ing) => ing.name).toList();
                            List<String> noDups = LinkedHashSet<String>.from(
                                starts + contains).toList();
                            return noDups;
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              leading: Icon(Icons.restaurant),
                              title: Text(suggestion),
                            );
                          },
                          onSuggestionSelected: (suggestion) async {
                            ctrl.text = suggestion;
                            QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('ingredients').where('name', isEqualTo: ctrl.text).get();
                            List<DocumentSnapshot> docs = querySnapshot.docs;
                            if (docs.isNotEmpty) {
                              setState(() {
                                selectedType = docs[0].get('type');
                              });
                            }
                          },
                        );
                      }
                  ),
                  SizedBox(height: 16),
                  Text('Type', style: Theme.of(context).textTheme.headline2),
                  buildListTile('grains'),
                  buildListTile('vegetables'),
                  buildListTile('fruit'),
                  buildListTile('protein'),
                  buildListTile('dairy'),
                  buildListTile('condiments'),
                  buildListTile('spices/herbs'),
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    child: FlatButton(
                        padding: EdgeInsets.all(16),
                        child: Text('Add', style: TextStyle(color: Colors.white, fontSize: 16)),
                        color: Theme.of(context).primaryColor,
                        onPressed: () async {
                          if (key.currentState.validate()) {
                            DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userID);
                            QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('ingredients').where('name', isEqualTo: ctrl.text).get();
                            List<DocumentSnapshot> docs = querySnapshot.docs.where((doc) => doc.get('type') == selectedType).toList();
                            if (docs.isNotEmpty) {
                              FirebaseFirestore.instance.runTransaction((transaction) async {
                                DocumentSnapshot userSnap = await transaction.get(userDoc);
                                transaction.update(
                                    userSnap.reference,
                                    {'ingredients': userSnap.get('ingredients')..add(docs[0].id)});
                              });
                            }
                            else {
                              DocumentReference doc = await FirebaseFirestore.instance.collection('ingredients').add({
                                'name': ctrl.text,
                                'type': selectedType
                              });
                              FirebaseFirestore.instance.runTransaction((transaction) async {
                                DocumentSnapshot userSnap = await transaction.get(userDoc);
                                transaction.update(
                                    userSnap.reference,
                                    {'ingredients': userSnap.get('ingredients')..add(doc.id)});
                              });
                            }
                            Navigator.of(context).pop();
                          }
                        }
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class KitchenPage extends StatelessWidget {

  Future<Ingredient> retrieveIngredient(String ingredientDocID) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('ingredients').doc(ingredientDocID).get();
    return Ingredient(doc.get('name'), doc.get('type'));
  }

  Future<Widget> buildFoodGroups(BuildContext context, List<String> ingredientDocIDs) async {
    Map<String, List<Ingredient>> groups = {
      'grains': [],
      'vegetables': [],
      'fruit': [],
      'protein': [],
      'dairy': [],
      'condiments': [],
      'spices/herbs': []
    };
    Map<String, Color> groupColors = {
      'grains': Colors.amber[200],
      'vegetables': Colors.green[200],
      'fruit': Colors.red[200],
      'protein': Colors.brown[200],
      'dairy': Colors.blue[200],
      'condiments': Colors.purple[200],
      'spices/herbs': Colors.pink[100]
    };

    for (String id in ingredientDocIDs) {
      Ingredient ing = await retrieveIngredient(id);
      groups[ing.type].add(ing);
    }

    List<Widget> columnChildren = [];
    for (String group in groups.keys) {
      columnChildren.add(buildFoodGroup(context, group, groups[group], groupColors[group]));
      columnChildren.add(Divider());
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columnChildren
    );

  }

  Widget buildFoodGroup(BuildContext context, String type, List<Ingredient> ingredients, Color color) {
    String userID = Provider.of<CurrentUserInfo>(context, listen: false).id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(type, style: TextStyle(fontSize: 20)),
        SizedBox(height: 4),
        StreamBuilder(
            stream: FirebaseFirestore.instance.collection('ingredients').snapshots(),
            builder: (context, snapshot) {
              if (ingredients.isEmpty) {
                return Text('None yet!');
              }
              return Wrap(
                spacing: 4,
                runSpacing: 4,
                children: ingredients.map((ing) {
                  return GestureDetector(
                    onTap: () async {
                      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userID);
                      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('ingredients').where('name', isEqualTo: ing.name).get();
                      List<DocumentSnapshot> docs = querySnapshot.docs;
                      FirebaseFirestore.instance.runTransaction((transaction) async {
                        DocumentSnapshot userSnap = await transaction.get(userDoc);
                        transaction.update(
                            userSnap.reference,
                            {'ingredients': userSnap.get('ingredients')..remove(docs[0].id)});
                      });
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                                color: color
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                        padding: EdgeInsets.all(4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.highlight_off, size: 12),
                            SizedBox(width: 4),
                            Text(ing.name),
                          ],
                        )
                    ),
                  );
                }).toList(),
              );
            }
        )
      ],
    );
  }

  Widget buildMaterialGroup(BuildContext context, String type) {
    String userID = Provider.of<CurrentUserInfo>(context, listen: false).id;
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('materials').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        List<String> allMaterials = List<String>.from(snapshot.data.docs[0].get(type));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(type, style: TextStyle(fontSize: 20)),
            SizedBox(height: 4),
            FutureBuilder(
                future: FirebaseFirestore.instance.collection('users').doc(userID).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  List<String> materials = allMaterials.where((mat) => List<String>.from(snapshot.data.get('materials')).contains(mat)).toList();
                  if (materials.isEmpty) {
                    return Text('None yet!');
                  }
                  return Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: materials.map((mat) {
                      return GestureDetector(
                        onTap: () async {
                          FirebaseFirestore.instance.runTransaction((transaction) async {
                            transaction.update(
                                snapshot.data.reference,
                                {'ingredients': snapshot.data.get('ingredients')..remove(mat)});
                          });
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).accentColor,
                                border: Border.all(
                                    color: Colors.transparent
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(8))
                            ),
                            padding: EdgeInsets.all(4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.highlight_off, size: 12),
                                SizedBox(width: 4),
                                Text(mat),
                              ],
                            )
                        ),
                      );
                    }).toList(),
                  );
                }
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    String userID = Provider.of<CurrentUserInfo>(context, listen: false).id;

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(userID).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return CircularProgressIndicator();
        }
        List<String> ingredientDocIDs = List<String>.from(userSnapshot.data.get('ingredients'));

        return Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kitchen', style: Theme.of(context).textTheme.headline1),
                    SizedBox(height: 16),
                    Text('Ingredients', style: Theme.of(context).textTheme.headline2),
                    SizedBox(height: 8),
                    FutureBuilder(
                      future: buildFoodGroups(context, ingredientDocIDs),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        return snapshot.data;
                      },
                    ),
                    Text('Materials', style: Theme.of(context).textTheme.headline2),
                    SizedBox(height: 8),
                    buildMaterialGroup(context, 'appliances'),
                    Divider(),
                    buildMaterialGroup(context, 'cookware'),
                    Divider(),
                    buildMaterialGroup(context, 'utensils'),
                  ]
              ),
            ),
          ),
        );
      },
    );
  }
}

class EditMaterialsPage extends StatefulWidget {
  EditMaterialsPage(this.origMaterials, this.materialDoc);
  final List<String> origMaterials;
  final DocumentSnapshot materialDoc;
  @override
  _EditMaterialsPageState createState() => _EditMaterialsPageState();
}

class _EditMaterialsPageState extends State<EditMaterialsPage> {
  List<String> newMaterials;

  @override
  initState() {
    super.initState();
    newMaterials = widget.origMaterials;
  }

  Widget createMaterialList(BuildContext context, String type) {
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(type, style: Theme.of(context).textTheme.headline2),
      children: List<String>.from(widget.materialDoc.get(type)).map((mat) {
        return CheckboxListTile(
          title: Text(mat),
          value: newMaterials.contains(mat),
          onChanged: (bool value) async {
            if (value) {
                setState(() {
                  newMaterials.add(mat);
                });
            }
            else {
              setState(() {
                newMaterials.remove(mat);
              });
            }
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit materials', style: Theme.of(context).textTheme.headline1),
                  SizedBox(height: 16),
                  createMaterialList(context, 'appliances'),
                  createMaterialList(context, 'cookware'),
                  createMaterialList(context, 'utensils'),
                  Container(
                    width: double.infinity,
                    child: FlatButton(
                        padding: EdgeInsets.all(16),
                        child: Text('Save', style: TextStyle(color: Colors.white, fontSize: 16)),
                        color: Theme.of(context).primaryColor,
                        onPressed: () async {
                          String userID = Provider.of<CurrentUserInfo>(context, listen: false).id;
                          await FirebaseFirestore.instance.collection('users').doc(userID).update({'materials': newMaterials});
                          Navigator.of(context).pop();
                        }
                    ),
                  )
                ]
            ),
          ),
        ),
      ),
    );
  }
}