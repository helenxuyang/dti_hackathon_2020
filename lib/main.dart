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
    Color primary = Color.fromRGBO(0x99, 0x0D, 0x35, 1.0);
    return ChangeNotifierProvider(
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            fontFamily: 'Proxima-Nova',
            primaryColor: primary,
            accentColor: Color.fromRGBO(0xD5, 0x29, 0x41, 1.0),
            buttonColor: Color.fromRGBO(0x99, 0x0D, 0x35, 1.0),
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
        return RecipesPage();
        break;
      case 1:
        return Ingredients();
        break;
      case 2:
        return PostsPage();
        break;
      case 3:
        return Column();
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
              icon: Icon(Icons.home), title: Text('Home')),
          BottomNavigationBarItem(
              icon: Icon(Icons.explore), title: Text('Explore')),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat), title: Text('Discussion')),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), title: Text('Profile'))
        ],
        currentIndex: _selectedIndex,
        onTap: (int index) => setState(() {
          _selectedIndex = index;
        })
      ),
    );
  }
}