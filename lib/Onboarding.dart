import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'Login.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {

  GlobalKey<FormState> key = GlobalKey<FormState>();
  FocusNode focusNode = FocusNode();
  TextEditingController firstCtrl = TextEditingController();
  TextEditingController lastCtrl = TextEditingController();
  List<String> allDietaryRestrictions = ['vegan', 'vegetarian', 'pescatarian', 'kosher', 'halal', 'paleo'];
  List<String> allAllergies = ['tree nuts', 'soy', 'dairy', 'shellfish', 'eggs', 'gluten'];
  List<String> dietaryRestrictions = [];
  List<String> allergies = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      key: key,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hello!', style: Theme.of(context).textTheme.headline1),
                            SizedBox(height: 8),
                            Text('What should we call you?', style: Theme.of(context).textTheme.headline2),
                            SizedBox(height: 8),
                            Text('First name', style: TextStyle(fontSize: 18)),
                            SizedBox(height: 8),
                            TextFormField(
                                controller: firstCtrl,
                                textCapitalization: TextCapitalization.sentences,
                                focusNode: focusNode,
                                textInputAction: TextInputAction.next,
                                validator: (input) {
                                  if (input.isEmpty) {
                                    return 'Please enter your first name!';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (value) => FocusScope.of(context).nextFocus()
                            ),
                            SizedBox(height: 8),
                            Text('Last name', style: TextStyle(fontSize: 18)),
                            TextFormField(
                              controller: lastCtrl,
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.done,
                              validator: (input) {
                                if (input.isEmpty) {
                                  return 'Please enter your last name!';
                                }
                                return null;
                              },
                            ),
                          ]),
                    ),
                    SizedBox(height: 16),
                    Text('Any dietary restrictions?', style: Theme.of(context).textTheme.headline2),
                    Wrap(
                      children: allDietaryRestrictions.map((elem) {
                        return ChoiceChip(
                          label: Text(elem, style: TextStyle(fontSize: 14)),
                          selected: dietaryRestrictions.contains(elem),
                          onSelected: (selected) {
                            setState(() {
                              if (selected)
                                dietaryRestrictions.add(elem);
                              else
                                dietaryRestrictions.remove(elem);
                            });
                          },
                        );
                      }).toList(),
                      spacing: 4,
                    ),
                    SizedBox(height: 16),
                    Text('Any allergies/intolerances?', style: Theme.of(context).textTheme.headline2),
                    Wrap(
                      children: allAllergies.map((elem) {
                        return ChoiceChip(
                          label: Text(elem, style: TextStyle(fontSize: 14)),
                          selected: allergies.contains(elem),
                          onSelected: (selected) {
                            setState(() {
                              if (selected)
                                allergies.add(elem);
                              else
                                allergies.remove(elem);
                            });
                          },
                        );
                      }).toList(),
                      spacing: 4,
                    )
                  ]
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: FlatButton(
                padding: EdgeInsets.all(16),
                child: Text('Done', style: TextStyle(color: Colors.white, fontSize: 16)),
                color: Theme.of(context).primaryColor,
                onPressed: () async {
                  if (key.currentState.validate()) {
                    String userID = Provider
                        .of<CurrentUserInfo>(context, listen: false)
                        .id;
                    FirebaseFirestore.instance.collection('users').doc(userID).set({
                      'firstName': firstCtrl.text,
                      'lastName': lastCtrl.text,
                      'dietaryRestrictions': dietaryRestrictions,
                      'allergies': allergies,
                      'savedRecipes': [],
                      'ingredients': [],
                      'materials': []
                    });
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => MainPage()));
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}