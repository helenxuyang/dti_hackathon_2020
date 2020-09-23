import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'RecipesPage.dart';

class CurrentUserInfo with ChangeNotifier {
  String id;

  void setID(String id) {
    this.id = id;
    notifyListeners();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User> _handleSignIn() async {
    User user;
    bool isSignedIn = await _googleSignIn.isSignedIn();

    if (isSignedIn) {
      user = _auth.currentUser;
    } else {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final AuthCredential cred = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
      user = (await _auth.signInWithCredential(cred)).user;
    }
    return user;
  }

  void signIn(BuildContext context) async {
    User user = await _handleSignIn();
    setID(user.uid);
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((snapshot) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => RecipesPage()));
    });
  }

  Future<void> signOut() async {
    await _auth.signOut().then((_) {
      _googleSignIn.signOut();
    });
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body:
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border),
                  Text("Less than Three", style: Theme.of(context).textTheme.headline1),
                  SignInButton(),
                  SignOutButton()
                ]
            )
        )
    );
  }
}

class SignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CurrentUserInfo userInfo = Provider.of<CurrentUserInfo>(context);
    return Center(
      child: OutlineButton(
        highlightColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Image.asset('assets/google_logo.png', width: 20),
            SizedBox(width: 20),
            Text('Sign in with Google', style: TextStyle(fontSize: 16))
          ]),
        ),
        onPressed: () {
          userInfo.signIn(context);
        },
      ),
    );
  }
}

class SignOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CurrentUserInfo userInfo = Provider.of<CurrentUserInfo>(context);
    return RaisedButton(
      child: Text('Sign out'),
      onPressed: () {
        userInfo.signOut();
      },
    );
  }
}
