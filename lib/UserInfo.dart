import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CurrentUserInfo with ChangeNotifier {
  String id;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  void setID(String id) {
    this.id = id;
    notifyListeners();
  }
}
