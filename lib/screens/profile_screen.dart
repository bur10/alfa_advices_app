import 'package:alfa_advices_app/conts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:alfa_advices_app/user.dart';
import 'post_screen.dart';

class ProfileScreen extends StatelessWidget {
  Future<Widget> _buildSavedPost(BuildContext context) async {
    Future<String> downloadImage(String postImage) async {
      final ref = FirebaseStorage.instance.ref().child(postImage);
      var downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    }

    final String uid = await User.getCurrentUserID();
    final String anonid = await User.getCurrentUserAnonID();

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('users')
          .document(uid)
          .collection('${anonid}savedposts')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator(
            backgroundColor: Colors.blue,
          );
        }

        List<Widget> postWidgets = [];
        final posts = snapshot.data.documents;

        for (var post in posts) {
          final postId = post.data['postId'];
          final String postTitle = post.data['postTitle'];
          final String postText = post.data['postText'];
          final String postImage = post.data['postImage'];

          final Widget postWidget = GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, PostScreen.id,
                    arguments: PostScreen(
                      postId: postId,
                      postTitle: postTitle,
                      postImage: postImage,
                      postText: postText,
                    ));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: kMainColor,
                  border: Border(
                    top: postWidgets.length < 1
                        ? BorderSide(width: 1.0, color: Colors.grey)
                        : BorderSide(width: 0.0),
                    bottom: BorderSide(width: 1.0, color: Colors.grey),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  postTitle.toUpperCase(),
                                  style: kPostTitleStyle,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  postText,
                                  maxLines: 4,
                                  style: TextStyle(
                                    color: Color(0xFFD7DADC),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      FutureBuilder(
                          future: downloadImage(postImage),
                          builder: (context, photo) {
                            return Container(
                                width: 100.0,
                                height: 100.0,
                                child: photo.data != null
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            showDialog(
                                                barrierDismissible: true,
                                                context: context,
                                                builder: (context) {
                                                  return SafeArea(
                                                    child: Container(
                                                      child: Image.network(
                                                          photo.data),
                                                    ),
                                                  );
                                                });
                                          },
                                          child: Image(
                                            image: NetworkImage(photo.data),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: CircularProgressIndicator(
                                          backgroundColor: Colors.blue,
                                        ),
                                      ));
                          })
                    ],
                  ),
                ),
              ));

          postWidgets.add(postWidget);
        }

        return FutureBuilder(
            future: User.getCurrentUserAnonID(),
            builder: (context, async) {
              return ListView(
                children: <Widget>[
                  UserSection(
                    async: async,
                  ),
                  TabsSection(),
                  SavedPostsSection(
                    postWidgets: postWidgets,
                  ),
                ],
              );
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _buildSavedPost(context),
      builder: (context, asyncSnapshot) {
        return asyncSnapshot.data != null
            ? asyncSnapshot.data
            : Center(
                child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ));
      },
    );
  }
}

class UserSection extends StatelessWidget {
  final async;
  UserSection({this.async});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kMainColor,
        border: Border(
          bottom: BorderSide(width: 4.0, color: Colors.black12),
        ),
      ),
      child: Column(
        children: <Widget>[
          CircleAvatar(
            child: Icon(
              Icons.person,
              size: 32.0,
              color: Colors.blue,
            ),
            radius: 50.0,
            backgroundColor: Colors.black26,
          ),
          async.data != null
              ? Text(async.data)
              : CircularProgressIndicator(
                  backgroundColor: Colors.blue,
                ),
        ],
      ),
    );
  }
}

class TabsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Icon(Icons.bookmark),
    );
  }
}

class SavedPostsSection extends StatelessWidget {
  final List<Widget> postWidgets;

  SavedPostsSection({this.postWidgets});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: postWidgets,
    );
  }
}
