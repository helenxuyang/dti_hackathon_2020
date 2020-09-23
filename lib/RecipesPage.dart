import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'Recipe.dart';

class RecipesPage extends StatelessWidget {
  final CardController controller = CardController();
  @override
  Widget build(BuildContext context) {
    return Column(
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
                      Recipe recipe = Recipe(doc.get('name'), List<String>.from(doc.get('ingredients')), List<String>.from(doc.get('steps')), doc.get('rating').toDouble());
                      return RecipeCard(recipe);
                    },
                    swipeCompleteCallback: (CardSwipeOrientation orientation, int index) {
                      if (orientation == CardSwipeOrientation.LEFT) {

                      }
                      else {

                      }
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        controller.triggerLeft();
                      },
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        controller.triggerRight();
                      },
                    )
                  ],
                )
              ],
            );
          }
        ),
      ],
    );
  }
}