import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'Login.dart';
import 'RecipesPage.dart';
import 'Ingredients.dart';
import 'PostsPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
                  color: primary
              ),
              headline2: TextStyle(
                  fontFamily: 'Proxima-Nova',
                  fontSize: 22,
                  color: Colors.black
              ),
            ),
          ),
          home: LoginPage(),
        ),
        create: (context) => CurrentUserInfo()
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {

  int _selectedIndex = 0;

  Widget getPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        return Ingredients();
        break;
      case 1:
        return RecipesPage();
        break;
      case 2:
        return Column();
        break;
      case 3:
        return PostsPage();
        break;
      default:
        return Column();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: getPage(context, _selectedIndex)
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).buttonColor,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu), title: Text('Kitchen')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.explore), title: Text('Explore')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), title: Text('Saved')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat), title: Text('Social')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), title: Text('Profile')
          )
        ],
        currentIndex: _selectedIndex,
        onTap: (int index) => setState(() {
          _selectedIndex = index;
        })
      ),
    );
  }
}