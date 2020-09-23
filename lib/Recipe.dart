import 'package:flutter/material.dart';

class Recipe {
  Recipe(this.name, this.ingredients, this.steps);
  String name;
  List<String> ingredients;
  List<String> steps;
}

class RecipeCard extends StatelessWidget {
  RecipeCard(this.recipe);
  final Recipe recipe;
  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(recipe.name),
              Text('Ingredients: ' + recipe.ingredients.join(', ')),
              Text('Steps'),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: recipe.steps.length,
                  itemBuilder: (context, index) {
                    return Text((index + 1).toString() + '. ' + recipe.steps[index]);
                  }
              )
            ]
        )
    );
  }
}
