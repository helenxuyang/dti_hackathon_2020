import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dti_hackathon_2020/Login.dart';
import 'package:dti_hackathon_2020/Recipe.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String userID = Provider.of<CurrentUserInfo>(context, listen: false).id;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saved Recipes', style: Theme.of(context).textTheme.headline1),
          SizedBox(height: 16),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').doc(userID).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              List<String> recipeIDs = List<String>.from(snapshot.data.get('savedRecipes'));
              return Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: recipeIDs.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder(
                      future: FirebaseFirestore.instance.collection('recipes').doc(recipeIDs[index]).get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        }
                        return RecipeCard.fromDoc(snapshot.data);
                      },
                    );
                  }
                ),
              );
            }
          ),
        ],
      ),
    );
  }
}