import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Recipe.dart';

class RecipesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Recipes'),
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
            return Expanded(
              child: ListView.builder(
                itemCount: recipeDocs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = recipeDocs[index];
                  Recipe recipe = Recipe(doc.get('name'), List<String>.from(doc.get('ingredients')), List<String>.from(doc.get('steps')));
                  return RecipeCard(recipe);
                },
              ),
            );
          }
        ),
      ],
    );
  }
}