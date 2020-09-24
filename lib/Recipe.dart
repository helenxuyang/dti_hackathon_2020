import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dti_hackathon_2020/Login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Recipe {
  Recipe(this.name, this.imageURL, this.categories, this.ingredients, this.materials, this.steps);
  String name;
  String imageURL;
  List<String> categories;
  List<String> ingredients;
  List<String> materials;
  List<String> steps;
// double rating;
}

class RecipeCard extends StatefulWidget {
  RecipeCard(this.recipe);
  factory RecipeCard.fromDoc(DocumentSnapshot doc) {
    Recipe recipe = Recipe(
        doc.get('name'),
        doc.get('imageURL'),
        List<String>.from(doc.get('categories')),
        List<String>.from(doc.get('ingredients')),
        List<String>.from(doc.get('materials')),
        List<String>.from(doc.get('steps')));
    return RecipeCard(recipe);
  }
  final Recipe recipe;

  @override
  _RecipeCardState createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {

  bool viewInstructions = false;

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

  @override
  Widget build(BuildContext context) {
    Color greenBack = Color.fromRGBO(0xDF, 0xFC, 0xE2, 1.0);
    Color redBack = Color.fromRGBO(0xFC, 0xDF, 0xDF, 1.0);
    Color greenText = Color.fromRGBO(0x0C, 0x8D, 0x09, 1.0);
    Color redText = Color.fromRGBO(0x8D, 0x09, 0x09, 1.0);
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
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
                                      image: NetworkImage(widget.recipe.imageURL)
                                  )
                              )
                          )
                      )
                  ),
                  SizedBox(height: 8),
                  Text(widget.recipe.name, style: Theme.of(context).textTheme.headline2),
                  //SizedBox(height: 4),
                  //buildStars(context),
                  Wrap(
                      children: widget.recipe.categories.map((cat) {
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
                  ),
                  SizedBox(height: 8),
                  Text('Ingredients:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Wrap(
                    children: widget.recipe.ingredients.map((ingredient) {
                      return FutureBuilder(
                          future: userHasIngredient(context, ingredient),
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
                                    color: Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(8))
                              ),
                              padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                              child: Text(
                                  ingredient,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: userHas ? greenText : redText
                                  )
                              ),
                            );
                          }
                      );
                    }).toList(),
                    spacing: 4,
                  ),
                  SizedBox(height: 8),
                  Text('Materials:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Wrap(
                      children: widget.recipe.materials.map((material) {
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
                  ),
                  FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Instructions'),
                        viewInstructions ? Icon(Icons.keyboard_arrow_up) : Icon(Icons.keyboard_arrow_down)
                      ],
                    ),
                    onPressed: () {
                      setState(() {
                        viewInstructions = !viewInstructions;
                      });
                    },
                  ),
                  if (viewInstructions)
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.recipe.steps.length,
                        itemBuilder: (context, index) {
                          return Text((index+1).toString() + ') ' + widget.recipe.steps[index]);
                        }
                    )
                ]
            ),
          ),
        )
    );
  }
}
