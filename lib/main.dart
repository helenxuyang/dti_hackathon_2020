import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'CreateRecipePage.dart';
import 'Login.dart';
import 'RecipesPage.dart';
import 'Kitchen.dart';
import 'PostsPage.dart';
import 'SavedPage.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'UserInfo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp();
  final FirebaseStorage storage = FirebaseStorage(
      app: app, storageBucket: 'gs://flutter-firebase-plugins.appspot.com');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Color primary = Color.fromRGBO(0x98, 0xD0, 0xD0, 1.0);
    return ChangeNotifierProvider(
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            fontFamily: 'Proxima-Nova',
            primaryColor: primary,
            accentColor: Color.fromRGBO(0xFF, 0xC5, 0x99, 1.0),
            buttonColor: primary,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            textTheme: TextTheme(
              headline1: TextStyle(
                  fontFamily: 'Proxima-Nova',
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: primary),
              headline2: TextStyle(
                  fontFamily: 'Proxima-Nova',
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.black),
            ),
          ),
          home: LoginPage(),
        ),
        create: (context) => CurrentUserInfo());
  }
}

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  static const int KITCHEN = 0;
  static const int EXPLORE = 1;
  static const int SAVED = 2;
  static const int SOCIAL = 3;
  static const int PROFILE = 4;

  Widget getPage(BuildContext context, int index) {
    switch (index) {
      case KITCHEN:
        return KitchenPage();
        break;
      case EXPLORE:
        return RecipesPage();
        break;
      case SAVED:
        return SavedPage();
        break;
      case SOCIAL:
        return PostsPage();
        break;
      case PROFILE:
        return Column();
      default:
        return Column();
    }
  }

  Widget buildFAB(BuildContext context) {
    switch (_selectedIndex) {
      case KITCHEN:
        return SpeedDial(
            backgroundColor: Theme.of(context).primaryColor,
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            children: [
              SpeedDialChild(
                  child: Icon(Icons.fastfood, color: Colors.white),
                  backgroundColor: Theme.of(context).primaryColor,
                  label: 'Add ingredient',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateIngredientPage()))),
              SpeedDialChild(
                  child: Icon(Icons.restaurant, color: Colors.white),
                  backgroundColor: Theme.of(context).primaryColor,
                  label: 'Add material',
                  onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('materials')
                              .snapshots(),
                          builder: (context, materialsSnapshot) {
                            if (!materialsSnapshot.hasData) {
                              return Scaffold();
                            }
                            String userID = Provider.of<CurrentUserInfo>(
                                    context,
                                    listen: false)
                                .id;
                            return StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userID)
                                    .snapshots(),
                                builder: (context, userSnapshot) {
                                  if (!userSnapshot.hasData) {
                                    return Scaffold();
                                  }
                                  return EditMaterialsPage(
                                      List<String>.from(
                                          userSnapshot.data.get('materials')),
                                      materialsSnapshot.data.docs[0]);
                                });
                          },
                        );
                      })))
            ]);
      case SAVED:
        return FloatingActionButton(
            child: Icon(Icons.add, color: Colors.white),
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => CreateRecipePage())));
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: buildFAB(context),
      body: SafeArea(child: getPage(context, _selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).buttonColor,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu), title: Text('Kitchen')),
            BottomNavigationBarItem(
                icon: Icon(Icons.explore), title: Text('Explore')),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), title: Text('Saved')),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat), title: Text('Social')),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), title: Text('Profile'))
          ],
          currentIndex: _selectedIndex,
          onTap: (int index) => setState(() {
                _selectedIndex = index;
              })),
    );
  }
}
