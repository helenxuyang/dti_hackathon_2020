import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class Ingredients extends StatefulWidget{

  @override
  _IngredientsState createState() => _IngredientsState();
}

class _IngredientsState extends State<Ingredients> {
  List<String> ingredients = List<String>();

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Text('What do you have in your fridge today?'),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('ingredients').doc('preset').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              List<String> presetIngredients = List<String>.from(snapshot.data.get('ingredients'));
              return TypeAheadField(
                suggestionsCallback: (pattern) {
                  List<String> starts = presetIngredients.where((String food) => food.toLowerCase().startsWith(pattern)).toList();
                  List<String> contains = presetIngredients.where((String food) => food.toLowerCase().contains(pattern)).toList();
                  List<String> noDups = LinkedHashSet<String>.from(starts + contains).toList();
                  noDups.removeWhere((element) => ingredients.contains(element));
                  return noDups;
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    leading: Icon(Icons.restaurant),
                    title: Text(suggestion),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    ingredients.add(suggestion);
                  });
                },
              );
            },
          ),
          Expanded(
            child: ListView.builder(
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.restaurant),
                    title: Text(ingredients[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          ingredients.removeAt(index);
                        });
                      },
                    ),
                  );
                }),
          )
        ]
    );
  }
}