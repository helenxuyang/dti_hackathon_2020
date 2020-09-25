import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dti_hackathon_2020/Login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'UserInfo.dart';

Color greenBack = Color.fromRGBO(0xDF, 0xFC, 0xE2, 1.0);
Color redBack = Color.fromRGBO(0xFC, 0xDF, 0xDF, 1.0);
Color greenText = Color.fromRGBO(0x0C, 0x8D, 0x09, 1.0);
Color redText = Color.fromRGBO(0x8D, 0x09, 0x09, 1.0);

Future<bool> userHasMaterial(BuildContext context, String material) async {
  String userID = Provider.of<CurrentUserInfo>(context, listen: false).id;
  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userID).get();
  List<String> materials = List<String>.from(userDoc.get('materials'));
  return materials.contains(material);
}

Future<bool> userHasIngredient(BuildContext context, String ingredient) async {
  String userID = Provider.of<CurrentUserInfo>(context, listen: false).id;
  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userID).get();
  List<String> ingredientIDs = List<String>.from(userDoc.get('ingredients'));
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('ingredients').where('name', isEqualTo: ingredient).get();
  List<DocumentSnapshot> docs = querySnapshot.docs;
  for (DocumentSnapshot doc in docs) {
    if (ingredientIDs.contains(doc.id)) {
      return true;
    }
  }
  return false;
}

class Recipe {
  Recipe(this.name, this.creator, this.imageURL, this.categories, this.ingredients, this.materials, this.instructions);
  String name;
  String creator;
  String imageURL;
  List<String> categories;
  List<String> ingredients;
  List<String> materials;
  List<String> instructions;
// double rating;

  Widget buildCategories(BuildContext context) {
    return Wrap(
        spacing: 4,
        runSpacing: 4,
        children: categories.map((cat) {
          return Container(
            decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                border: Border.all(
                    color: Colors.transparent
                ),
                borderRadius: BorderRadius.all(Radius.circular(8))
            ),
            padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
            child: Text(
                cat,
                style: TextStyle(fontSize: 14)
            ),
          );
        }).toList()
    );
  }

  Widget buildIngredients(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: ingredients.map((ingredient) {
        return FutureBuilder(
            future: userHasIngredient(context, ingredient),
            builder: (context, snapshot) {
              bool userHas = snapshot.data;
              return Container(
                decoration: BoxDecoration(
                    color: userHas == null ? Colors.grey[200] : userHas ? greenBack : redBack,
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8))
                ),
                padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                child: Text(
                    ingredient,
                    style: TextStyle(
                        fontSize: 14,
                        color: userHas == null ? Colors.grey[600] : userHas ? greenText : redText
                    )
                ),
              );
            }
        );
      }).toList(),
    );
  }

  Widget buildMaterials(BuildContext context) {
    if (materials.isEmpty) {
      return Text('None!');
    }
    return Wrap(
        spacing: 4,
        runSpacing: 4,
        children: materials.map((material) {
          return FutureBuilder(
              future: userHasMaterial(context, material),
              builder: (context, snapshot) {
                bool userHas;
                if (!snapshot.hasData) {
                  userHas = false;
                }
                else {
                  userHas = snapshot.data;
                }
                return Container(
                  decoration: BoxDecoration(
                      color: userHas ? greenBack : redBack,
                      border: Border.all(
                        color: userHas ? greenBack : redBack,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8))
                  ),
                  padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                  child: Text(
                      material,
                      style: TextStyle(
                          fontSize: 14,
                          color: userHas ? greenText : redText
                      )
                  ),
                );
              }
          );
        }).toList()
    );
  }
}

class RecipeCard extends StatelessWidget {
  RecipeCard(this.recipe);
  factory RecipeCard.fromDoc(DocumentSnapshot doc) {
    Recipe recipe = Recipe(
        doc.get('name'),
        doc.get('creator'),
        doc.get('imageURL'),
        List<String>.from(doc.get('categories')),
        List<String>.from(doc.get('ingredients')),
        List<String>.from(doc.get('materials')),
        List<String>.from(doc.get('instructions')));
    return RecipeCard(recipe);
  }
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => RecipePage(recipe)));
      },
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.25),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.fitWidth,
                                      image: NetworkImage(recipe.imageURL)
                                  )
                              )
                          )
                      )
                  ),
                  SizedBox(height: 8),
                  Text(recipe.name, style: Theme.of(context).textTheme.headline2),
                  Text('Recipe by: ' + recipe.creator),
                  //SizedBox(height: 4),
                  //buildStars(context),
                  SizedBox(height: 8),
                  recipe.buildCategories(context),
                  SizedBox(height: 8),
                  Text('Ingredients:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  recipe.buildIngredients(context),
                  SizedBox(height: 8),
                  Text('Materials:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  recipe.buildMaterials(context)
                ]
            ),
          )
      ),
    );
  }
}

class RecipePage extends StatelessWidget {
  final Recipe recipe;
  RecipePage(this.recipe);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
                          constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.4),
                          child: Image.network(recipe.imageURL, fit: BoxFit.fitWidth)
                      ),
                      Positioned(
                        left: 5, top: 5,
                        child: RawMaterialButton(
                          constraints: BoxConstraints(minWidth: 36.0, maxWidth: 36.0, minHeight: 36.0, maxHeight: 36.0),
                          child: Icon(Icons.close, color: Colors.white),
                          fillColor: Colors.black,
                          shape: CircleBorder(),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(recipe.name, style: Theme.of(context).textTheme.headline1),
                          Text('Recipe by: ' + recipe.creator, style: TextStyle(fontSize: 16)),
                          SizedBox(height: 6),
                          recipe.buildCategories(context),
                          SizedBox(height: 8),
                          Text('Ingredients:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          recipe.buildIngredients(context),
                          SizedBox(height: 8),
                          Text('Materials:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          recipe.buildMaterials(context),
                          SizedBox(height: 8),
                          Text('Instructions:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: recipe.instructions.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 2, bottom: 2),
                                  child: Text((index+1).toString() + ') ' + recipe.instructions[index]),
                                );
                              }
                          ),
                          SizedBox(height: 8),
                          FlatButton(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.chevron_left),
                                    SizedBox(width: 8),
                                    Text('Back')
                                  ]
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }
                          )
                        ]
                    ),
                  )
                ]
            ),
          ),
        )
    );
  }
}
