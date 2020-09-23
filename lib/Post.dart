import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Post {
  Post(this.id, this.title, this.description, this.posterID, this.upvotes);
  String id;
  String title;
  String description;
  String posterID;
  int upvotes;
}

class Comment {
  Comment(this.text, this.posterID);
  String text;
  String posterID;
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline),
                SizedBox(width: 4),
                Text(widget.post.title, style: TextStyle(fontSize: 20))
              ],
            ),
            SizedBox(height: 8),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').doc(widget.post.posterID).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text('Author: ' + widget.post.description, style: TextStyle(fontSize: 16));
                }
                DocumentSnapshot userDoc = snapshot.data;
                return Text(userDoc.get('firstName') + ': ' + widget.post.description, style: TextStyle(fontSize: 16));
              },
            ),
            Divider(),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_up),
                  color: voteValue == 1 ? Theme.of(context).primaryColor : Colors.black,
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
                Text(widget.post.upvotes.toString()),
                SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_down),
                  color: voteValue == -1 ? Theme.of(context).primaryColor : Colors.black,
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
                    return (Text(numComments.toString() + ' comment' + (numComments > 1 ? 's' : '')));
                  },
                )
              ],
            )
          ]
        ),
      )
    );
  }
}

class PostPage extends StatefulWidget {
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  bool upvoted = false;
  bool downvoted = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
