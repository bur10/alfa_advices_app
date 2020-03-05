import 'dart:async';
import 'post_screen.dart';
import 'package:alfa_advices_app/vote_system.dart';
import 'package:alfa_advices_app/user.dart';
import 'package:flutter/material.dart';
import 'package:alfa_advices_app/conts.dart';
import 'package:alfa_advices_app/current_time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class PostStream extends StatefulWidget {
  @override
  _PostStreamState createState() => _PostStreamState();
}

class _PostStreamState extends State<PostStream>
    with AutomaticKeepAliveClientMixin {
  final _firestore = Firestore.instance;

  bool refresh = false;
  Future<List<Widget>> _buildPostPage() async {
    final postDocuments = await _firestore.collection('posts').getDocuments();
    List<Widget> posts = [];
    for (var postDocument in postDocuments.documents) {
      final String postId = postDocument.data['postId'];
      final String postTitle = postDocument.data['postTitle'];
      final String postText = postDocument.data['postText'];
      final String postImage = postDocument.data['postImage'];
      final String postSender = postDocument.data['postSender'];

      final String voteSender = await User.getCurrentUserAnonID();

      int like = postDocument.data['like'];
      int dislike = postDocument.data['dislike'];
      int userVote = postDocument.data['${voteSender}vote'];

      if (userVote == null) {
        postDocument.reference.setData(
          {
            '${voteSender}vote': 0,
          },
          merge: true,
        );
      }

      final timestamp = postDocument.data['timestamp'];

      var postCommentDocuments = await postDocument.reference
          .collection('post-comments-$postId')
          .getDocuments();
      var commentLength = postCommentDocuments.documents.length;

      Future<String> downloadImage() async {
        final ref = FirebaseStorage.instance.ref().child(postImage);
        var downloadUrl = await ref.getDownloadURL();
        return downloadUrl;
      }

      final Widget post = FutureBuilder(
          future: downloadImage(),
          builder: (context, AsyncSnapshot<String> asyncSnapshot) {
            return GestureDetector(
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
                    bottom: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('gönderen: $postSender'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          postImage != null
                              ? Container(
                                  padding: EdgeInsets.all(8.0),
                                  width:
                                      asyncSnapshot.data != null ? 100.0 : 50.0,
                                  height:
                                      asyncSnapshot.data != null ? 75.0 : 50.0,
                                  child: asyncSnapshot.data != null
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
                                                        child: Image(
                                                          image: NetworkImage(
                                                              asyncSnapshot
                                                                  .data),
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: Image(
                                              image: NetworkImage(
                                                  asyncSnapshot.data),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        )
                                      : CircularProgressIndicator(
                                          strokeWidth: 1.0,
                                          backgroundColor: Colors.blue,
                                        ),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: Row(
                                children: <Widget>[
                                  GestureDetector(
                                    child: Icon(
                                      Icons.thumb_up,
                                      size: 20.0,
                                      color: userVote == 2
                                          ? Colors.blue
                                          : Colors.white,
                                    ),
                                    onTap: () async {
                                      postDocument.reference.updateData({
                                        '${voteSender}vote': Vote.vote(like,
                                                dislike, userVote, 'VoteUp')
                                            .first,
                                        'like': Vote.vote(like, dislike,
                                            userVote, 'VoteUp')[1],
                                        'dislike': Vote.vote(like, dislike,
                                                userVote, 'VoteUp')
                                            .last,
                                      });
                                      var voteDocument =
                                          await postDocument.reference.get();
                                      setState(() {
                                        userVote = voteDocument
                                            .data['${voteSender}vote'];
                                      });
                                      print(userVote);
                                    },
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text((like - dislike).toString()),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  GestureDetector(
                                    child: Icon(
                                      Icons.thumb_down,
                                      size: 20.0,
                                      color: userVote == 1
                                          ? Colors.orange
                                          : Colors.white,
                                    ),
                                    onTap: () async {
                                      print('userVote = $userVote');
                                      postDocument.reference.updateData({
                                        '${voteSender}vote': Vote.vote(like,
                                                dislike, userVote, 'VoteDown')
                                            .first,
                                        'like': Vote.vote(like, dislike,
                                            userVote, 'VoteDown')[1],
                                        'dislike': Vote.vote(like, dislike,
                                                userVote, 'VoteDown')
                                            .last,
                                      });
                                      var voteDocument =
                                          await postDocument.reference.get();
                                      setState(() {
                                        userVote = voteDocument
                                            .data['${voteSender}vote'];
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.comment,
                                    size: 20.0,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(commentLength.toString()),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            CurrentTime.currentTime(timestamp),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });

      posts.add(post);
    }

    return posts;
  }

  //Sayfa yenilenecek
  Future<Null> _refreshList() async {
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _buildPostPage();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: _refreshList,
      child: ModalProgressHUD(
        inAsyncCall: refresh,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text('neye göre sıralansın'),
                )),
                Text(refresh.toString()),
                FlatButton(
                  child: Text('yenile'),
                  onPressed: () async {
                    setState(() {
                      refresh = true;
                      build(context);
                    });
                    await Future.delayed(Duration(seconds: 3));
                    setState(() {
                      refresh = false;
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder(
                future: _buildPostPage(),
                builder: (context, data) {
                  return ListView(
                    children: data.data,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
