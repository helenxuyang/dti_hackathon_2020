import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'Onboarding.dart';
import 'UserInfo.dart';
import 'main.dart';

Future<User> _handleSignIn(CurrentUserInfo userInfo) async {
  User user;
  bool isSignedIn = await userInfo.googleSignIn.isSignedIn();

  if (isSignedIn) {
    user = userInfo.auth.currentUser;
  } else {
    final GoogleSignInAccount googleUser = await userInfo.googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential cred = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    user = (await userInfo.auth.signInWithCredential(cred)).user;
  }
  return user;
}

void signIn(BuildContext context) async {
  CurrentUserInfo userInfo =
      Provider.of<CurrentUserInfo>(context, listen: false);
  User user = await _handleSignIn(userInfo);
  userInfo.setID(user.uid);
  DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if (!userDoc.exists) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => OnboardingPage()));
  } else {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MainPage()));
  }
}

Future<void> signOut(BuildContext context) async {
  CurrentUserInfo userInfo =
      Provider.of<CurrentUserInfo>(context, listen: false);
  await userInfo.auth.signOut().then((_) {
    userInfo.googleSignIn.signOut();
  });
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.favorite_border),
      Text("Less than Three", style: Theme.of(context).textTheme.headline1),
      SignInButton(),
      SignOutButton()
    ])));
  }
}

class SignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          signIn(context);
        },
      ),
    );
  }
}

class SignOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text('Sign out'),
      onPressed: () {
        signOut(context);
      },
    );
  }
}
