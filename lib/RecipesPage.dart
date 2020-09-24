import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dti_hackathon_2020/Login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:provider/provider.dart';
import 'Recipe.dart';

class RecipesPage extends StatefulWidget {
  _RecipesPageState createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final CardController controller = CardController();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomLeft,
              colors: [Colors.white, Color.fromRGBO(0xE5, 0xF8, 0xF8, 1.0)]
          )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Explore', style: Theme.of(context).textTheme.headline1),
          ),
          StreamBuilder(
              stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('error when retrieving all recipes: ${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                List<DocumentSnapshot> recipeDocs = snapshot.data.documents;
                double screenWidth = MediaQuery.of(context).size.width;
                double screenHeight = MediaQuery.of(context).size.height;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      height: screenHeight * 0.6,
                      child: TinderSwapCard(
                        cardController: controller,
                        orientation: AmassOrientation.BOTTOM,
                        stackNum: 3,
                        swipeEdge: 4.0,
                        maxWidth: screenWidth * 0.9,
                        maxHeight: screenHeight * 0.6,
                        minWidth: screenWidth * 0.8,
                        minHeight: screenHeight * 0.5,
                        allowVerticalMovement: false,
                        totalNum: recipeDocs.length,
                        cardBuilder: (context, index) {
                          DocumentSnapshot doc = recipeDocs[index];
                          return RecipeCard.fromDoc(doc);
                        },
                        swipeCompleteCallback: (CardSwipeOrientation orientation, int index) {
                          if (orientation == CardSwipeOrientation.RIGHT) {
                            FirebaseFirestore.instance.runTransaction((transaction) async {
                              String userID = Provider.of<CurrentUserInfo>(context, listen: false).id;
                              DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userID).get();
                              transaction.update(
                                  userDoc.reference,
                                  {'savedRecipes': userDoc.get('savedRecipes')..add(recipeDocs[index].id)}
                              );
                            });
                          }
                          else {

                          }
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          icon: Icon(Icons.keyboard_arrow_up),
                          onPressed: () {

                          }
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          shape: CircleBorder(),
                          color: Colors.white,
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.close, color: Theme.of(context).primaryColor, size: 28),
                          onPressed: () {
                            controller.triggerLeft();
                          },
                        ),
                        MaterialButton(
                          shape: CircleBorder(),
                          color: Colors.white,
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.favorite_border, color: Theme.of(context).accentColor, size: 28),
                          onPressed: () {
                            controller.triggerRight();
                          },
                        ),
                      ],
                    )
                  ],
                );
              }
          ),
        ],
      ),
    );
  }
}