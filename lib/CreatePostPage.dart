import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dti_hackathon_2020/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'Kitchen.dart';

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  GlobalKey<FormState> key = GlobalKey();
  TextEditingController descCtrl = TextEditingController();
  String description;
  TextEditingController titleCtrl = TextEditingController();
  String title;

  Widget buildWrap(BuildContext context, List<String> list) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: list.map((str) {
        return GestureDetector(
          onTap: () {
            setState(() {
              list.remove(str);
            });
          },
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                border: Border.all(
                  color: Colors.transparent,
                ),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
            child: Text(str, style: TextStyle(fontSize: 14)),
          ),
        );
      }).toList(),
    );
  }

  Future<String> getUserId() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    return user.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: key,
                  child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    IconButton(
                      alignment: Alignment.topLeft,
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Text('Create Post', style: Theme.of(context).textTheme.headline1),
                    SizedBox(height: 16),
                    Text('Title', style: Theme.of(context).textTheme.headline2),
                    TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: titleCtrl,
                      validator: (input) {
                        if (input.isEmpty) {
                          return 'Please enter a title for your post!';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8),
                    Text('Description', style: Theme.of(context).textTheme.headline2),
                    TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: descCtrl,
                      validator: (input) {
                        if (input.isEmpty) {
                          return 'Please enter a description for your post!';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      child: FlatButton(
                          padding: EdgeInsets.all(16),
                          child: Text('Save',
                              style: TextStyle(color: Colors.white, fontSize: 16)),
                          color: Theme.of(context).primaryColor,
                          onPressed: () async {
                            if (key.currentState.validate()) {
                              FirebaseFirestore.instance.collection('posts').add({
                                'description': descCtrl.text,
                                'posterID': await getUserId(),
                                'title': titleCtrl.text,
                                'upvotes': 0,
                                'timePosted': DateTime.now()
                              });
                              Navigator.of(context).pop();
                            }
                          }),
                    )
                  ]),
                ),
              ),
            )));
  }
}
