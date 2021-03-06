import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Post {
  Post(this.id, this.title, this.description, this.posterID, this.timePosted, this.upvotes);
  String id;
  String title;
  String description;
  String posterID;
  DateTime timePosted;
  int upvotes;
}

class Comment {
  Comment(this.id, this.text, this.posterID, this.timePosted);
  String id;
  String text;
  String posterID;
  DateTime timePosted;
  int upvotes;
}

class PostCard extends StatefulWidget {
  PostCard(this.post);
  final Post post;
  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int voteValue = 0;

  void increaseUpvotes() {
    DocumentReference postDoc = FirebaseFirestore.instance.collection('posts').doc(widget.post.id);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot postSnap = await transaction.get(postDoc);
      transaction.update(
          postSnap.reference, {'upvotes': postSnap.get('upvotes') + 1});
    });
  }

  void decreaseUpvotes() {
    DocumentReference postDoc = FirebaseFirestore.instance.collection('posts').doc(widget.post.id);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot postSnap = await transaction.get(postDoc);
      transaction.update(
          postSnap.reference, {'upvotes': postSnap.get('upvotes') - 1});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PostPage(widget.post)));
      },
      child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(),
                      SizedBox(width: 8),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StreamBuilder(
                              stream: FirebaseFirestore.instance.collection('users').doc(widget.post.posterID).snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Container();
                                }
                                DocumentSnapshot userDoc = snapshot.data;
                                return Text(userDoc.get('firstName') + ' ' + userDoc.get('lastName'), style: TextStyle(fontSize: 16));
                              },
                            ),
                            Text(DateFormat('jm').format(widget.post.timePosted))
                          ]
                      ),
                      Spacer(),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance.collection('posts').doc(widget.post.id).collection('comments').snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            int numComments = snapshot.data.documents.length;
                            if (numComments > 0) return Text('Answered', style: TextStyle(color: Colors.green));
                            return Text('Unanswered', style: TextStyle(color: Colors.red));
                          }
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(widget.post.title, style: Theme.of(context).textTheme.headline2),
                  SizedBox(height: 4),
                  Text(widget.post.description),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.keyboard_arrow_up),
                        color: voteValue == 1 ? Theme.of(context).accentColor : Colors.black,
                        onPressed: () {
                          setState(() {
                            if (voteValue == 1) {
                              decreaseUpvotes();
                              voteValue = 0;
                            }
                            else if (voteValue == 0){
                              increaseUpvotes();
                              voteValue = 1;
                            }
                            else {
                              increaseUpvotes();
                              increaseUpvotes();
                              voteValue = 1;
                            }
                          });
                        },
                      ),
                      SizedBox(width: 4),
                      SizedBox(child: Text(widget.post.upvotes.toString())),
                      SizedBox(width: 4),
                      IconButton(
                        icon: Icon(Icons.keyboard_arrow_down),
                        color: voteValue == -1 ? Theme.of(context).accentColor : Colors.black,
                        onPressed: () {
                          setState(() {
                            if (voteValue == -1) {
                              increaseUpvotes();
                              voteValue = 0;
                            }
                            else if (voteValue == 0){
                              decreaseUpvotes();
                              voteValue = -1;
                            }
                            else {
                              decreaseUpvotes();
                              decreaseUpvotes();
                              voteValue = -1;
                            }
                          });
                        },
                      ),
                      Spacer(),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance.collection('posts').doc(widget.post.id).collection('comments').snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            int numComments = snapshot.data.documents.length;
                            return Row(
                              children: [
                                Icon(Icons.chat_bubble, size: 12, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(numComments.toString() + ' comment' + (numComments != 1 ? 's' : ''), style: TextStyle(color: Colors.grey)),
                              ],
                            );
                          }
                      ),

                    ],
                  )
                ]
            ),
          )
      ),
    );
  }
}

class PostPage extends StatefulWidget {
  PostPage(this.post);
  final Post post;

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  int voteValue = 0;

  void increaseUpvotes(DocumentReference doc) {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot postSnap = await transaction.get(doc);
      transaction.update(
          postSnap.reference, {'upvotes': postSnap.get('upvotes') + 1});
    });
  }

  void decreaseUpvotes(DocumentReference doc) {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot postSnap = await transaction.get(doc);
      transaction.update(
          postSnap.reference, {'upvotes': postSnap.get('upvotes') - 1});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      alignment: Alignment.topLeft,
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    PostCard(widget.post),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('posts').doc(widget.post.id).collection('comments').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        }
                        List<DocumentSnapshot> commentDocs = snapshot.data.documents;
                        return Expanded(
                          child: ListView.builder(
                            itemCount: commentDocs.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot doc = commentDocs[index];
                              Comment comment = Comment(doc.id, doc.get('text'), doc.get('posterID'), doc.get('timePosted').toDate());
                              return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                        children: [
                                          Row(
                                              children: [
                                                CircleAvatar(),
                                                SizedBox(width: 8),
                                                Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      StreamBuilder(
                                                        stream: FirebaseFirestore.instance.collection('users').doc(comment.posterID).snapshots(),
                                                        builder: (context, snapshot) {
                                                          if (!snapshot.hasData) {
                                                            return Container();
                                                          }
                                                          DocumentSnapshot userDoc = snapshot.data;
                                                          return Text(userDoc.get('firstName') + ' ' + userDoc.get('lastName'), style: TextStyle(fontSize: 16));
                                                        },
                                                      ),
                                                      Text(DateFormat('jm').format(comment.timePosted))
                                                    ]
                                                ),
                                              ]
                                          ),
                                          Text(comment.text),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.keyboard_arrow_up),
                                                color: voteValue == 1 ? Theme.of(context).accentColor : Colors.black,
                                                onPressed: () {
                                                  setState(() {
                                                    if (voteValue == 1) {
                                                      decreaseUpvotes(doc.reference);
                                                      voteValue = 0;
                                                    }
                                                    else if (voteValue == 0){
                                                      increaseUpvotes(doc.reference);
                                                      voteValue = 1;
                                                    }
                                                    else {
                                                      increaseUpvotes(doc.reference);
                                                      increaseUpvotes(doc.reference);
                                                      voteValue = 1;
                                                    }
                                                  });
                                                },
                                              ),
                                              SizedBox(width: 4),
                                              SizedBox(child: Text(doc.get('upvotes').toString())),
                                              SizedBox(width: 4),
                                              IconButton(
                                                icon: Icon(Icons.keyboard_arrow_down),
                                                color: voteValue == -1 ? Theme.of(context).accentColor : Colors.black,
                                                onPressed: () {
                                                  setState(() {
                                                    if (voteValue == -1) {
                                                      increaseUpvotes(doc.reference);
                                                      voteValue = 0;
                                                    }
                                                    else if (voteValue == 0){
                                                      decreaseUpvotes(doc.reference);
                                                      voteValue = -1;
                                                    }
                                                    else {
                                                      decreaseUpvotes(doc.reference);
                                                      decreaseUpvotes(doc.reference);
                                                      voteValue = -1;
                                                    }
                                                  });
                                                },
                                              ),
                                            ],
                                          )
                                        ]
                                    ),
                                  )
                              );
                            },
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Add a comment')
                      ),
                    )
                  ]
              ),
            )
        )
    );
  }
}
