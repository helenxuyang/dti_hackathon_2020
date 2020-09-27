import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Post.dart';

class PostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomLeft,
              colors: [Colors.white, Color.fromRGBO(0xE5, 0xF8, 0xF8, 1.0)]
          )
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Social', style: Theme.of(context).textTheme.headline1),
                Spacer(),
                IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      //TODO: add search bar functionality
                    }
                )
              ],
            ),
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
                        Post post = Post(doc.id, doc.get('title'), doc.get('description'), doc.get('posterID'), doc.get('timePosted').toDate(), doc.get('upvotes'));
                        return PostCard(post);
                      },
                    ),
                  );
                }
            ),
          ],
        ),
      ),
    );
  }
}