import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Post.dart';

class PostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Posts', style: Theme.of(context).textTheme.headline1),
          StreamBuilder(
              stream: FirebaseFirestore.instance.collection('posts').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('error when retrieving all posts: ${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                List<DocumentSnapshot> postDocs = snapshot.data.documents;
                return Expanded(
                  child: ListView.builder(
                    itemCount: postDocs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = postDocs[index];
                      Post post = Post(doc.id, doc.get('title'), doc.get('description'), doc.get('posterID'), doc.get('upvotes'));
                      return PostCard(post);
                    },
                  ),
                );
              }
          ),
        ],
      ),
    );
  }
}