import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dti_hackathon_2020/Login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Recipe {
  Recipe(this.name, this.ingredients, this.steps, this.rating);
  String name;
  List<String> ingredients;
  List<String> steps;
  double rating;
}

class RecipeCard extends StatelessWidget {
  RecipeCard(this.recipe);
  final Recipe recipe;

  Widget buildStars(BuildContext context) {
    List<Icon> stars = [];
    double rating = recipe.rating;
    Color starColor = Theme.of(context).accentColor;
    for (int i = 0; i < 5; i++) {
      if (rating > 0.5) {
        stars.add(Icon(Icons.star, color: starColor));
      }
      else if (rating == 0.5) {
        stars.add(Icon(Icons.star_half, color: starColor));
      }
      else {
        stars.add(Icon(Icons.star_border, color: starColor));
      }
      rating--;
    }
    stars.forEach((element) {
      return Padding(
        padding: EdgeInsets.only(left: 2, right: 2),
        child: element
      );
    });
    return Row(children: stars);
  }

  Future<bool> retrieveUserHas(BuildContext context, String ingredient) async {
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
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network('https://www.simplyrecipes.com/wp-content/uploads/2018/07/Add-ins-for-tuna-salad-2.jpg'),
                SizedBox(height: 8),
                Text(recipe.name, style: Theme.of(context).textTheme.headline2),
                SizedBox(height: 4),
                buildStars(context),
                SizedBox(height: 8),
                Wrap(
                  children: recipe.ingredients.map((ingredient) {
                    //TODO: replace with whether user has ingredient
                    Color greenBack = Color.fromRGBO(0xDF, 0xFC, 0xE2, 1.0);
                    Color redBack = Color.fromRGBO(0xFC, 0xDF, 0xDF, 1.0);
                    Color greenText = Color.fromRGBO(0x0C, 0x8D, 0x09, 1.0);
                    Color redText = Color.fromRGBO(0x8D, 0x09, 0x09, 1.0);
                    return FutureBuilder(
                      future: retrieveUserHas(context, ingredient),
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
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: recipe.steps.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 2),
                        child: Text((index + 1).toString() + '. ' + recipe.steps[index], style: TextStyle(fontSize: 14)),
                      );
                    }
                )
              ]
          ),
        )
    );
  }
}
