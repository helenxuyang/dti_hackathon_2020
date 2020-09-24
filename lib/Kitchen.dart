import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

import 'Login.dart';

class Ingredients extends StatelessWidget {

  Widget buildTextField(BuildContext context, String groupName) {
    String userID = Provider.of<CurrentUserInfo>(context).id;
    TextEditingController textCtrl = TextEditingController();
    SuggestionsBoxController boxCtrl = SuggestionsBoxController();
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('ingredients').doc('preset').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          List<String> presetIngredients = List<String>.from(
              snapshot.data.get('ingredients'));
          return Expanded(
            child: TypeAheadField(
              autoFlipDirection: true,
              direction: AxisDirection.up,
              noItemsFoundBuilder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('No matching results found, hit enter to add!'),
                );
              },
              textFieldConfiguration: TextFieldConfiguration(
                controller: textCtrl,
                onSubmitted: (input) {
                  textCtrl.clear();
                  if (!input.isEmpty) {
                    DocumentReference userDoc =
                    FirebaseFirestore.instance.collection('users').doc(userID);
                    FirebaseFirestore.instance.runTransaction((transaction) async {
                      DocumentSnapshot userSnap = await transaction.get(userDoc);
                      transaction.update(
                          userSnap.reference,
                          {groupName: userSnap.get(groupName)..add(input)});
                    });
                  }
                }
              ),
               suggestionsBoxController: boxCtrl,
               suggestionsCallback: (pattern) {
                List<String> starts = presetIngredients.where((String food) =>
                    food.toLowerCase().startsWith(pattern)).toList();
                List<String> contains = presetIngredients.where((String food) =>
                    food.toLowerCase().contains(pattern)).toList();
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
                textCtrl.clear();
                DocumentReference userDoc =
                FirebaseFirestore.instance.collection('users').doc(userID);
                FirebaseFirestore.instance.runTransaction((transaction) async {
                  DocumentSnapshot userSnap = await transaction.get(userDoc);
                  transaction.update(
                      userSnap.reference,
                      {groupName: userSnap.get(groupName)..add(suggestion)});
                });
              },
            ),
          );
        }
    );
  }
  Widget buildGroup(BuildContext context, String name, List<String> ingredients, Color color) {
    String userID = Provider.of<CurrentUserInfo>(context).id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: TextStyle(fontSize: 20)),
        SizedBox(height: 4),
        Wrap(
          spacing: 4,
          children: ingredients.map((str) {
            return GestureDetector(
              onTap: () {
                DocumentReference userDoc =
                FirebaseFirestore.instance.collection('users').doc(userID);
                FirebaseFirestore.instance.runTransaction((transaction) async {
                  DocumentSnapshot userSnap = await transaction.get(userDoc);
                  String collectionName = name.toLowerCase();
                  transaction.update(
                      userSnap.reference,
                      {collectionName: userSnap.get(collectionName)..remove(str)});
                });
              },
              child: Container(
                  padding: EdgeInsets.all(4),
                  color: color,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, size: 10),
                      Text(str),
                    ],
                  )
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Text('ADD: '),
            buildTextField(context, name.toLowerCase())
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String userID = Provider.of<CurrentUserInfo>(context).id;

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').doc(userID).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return CircularProgressIndicator();
        }
        List<String> grains = List<String>.from(userSnapshot.data.get('grains'));
        List<String> vegetables = List<String>.from(userSnapshot.data.get('vegetables'));
        List<String> fruit = List<String>.from(userSnapshot.data.get('fruit'));
        List<String> protein = List<String>.from(userSnapshot.data.get('protein'));
        List<String> dairy = List<String>.from(userSnapshot.data.get('dairy'));
        List<List<String>> groups = [grains, vegetables, fruit, protein, dairy];
TextStyle subtitleStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
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
                    Text('Foods', style: subtitleStyle),
                    SizedBox(height: 8),
                    buildGroup(context, 'Grains', grains, Colors.amber[200]),
                    Divider(),
                    buildGroup(context, 'Vegetables', vegetables, Colors.green[200]),
                    Divider(),
                    buildGroup(context, 'Fruit', fruit, Colors.red[200]),
                    Divider(),
                    buildGroup(context, 'Protein', protein, Colors.brown[200]),
                    Divider(),
                    buildGroup(context, 'Dairy', dairy, Colors.blue[200]),
                  ]
              ),
            ),
          ),
        );
      },
    );
  }
}