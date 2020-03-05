import 'dart:async';

import 'package:alfa_advices_app/conts.dart';
import 'package:alfa_advices_app/current_time.dart';
import 'package:alfa_advices_app/screens/add_comment_screen.dart';
import 'package:alfa_advices_app/vote_system.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:alfa_advices_app/user.dart';

class PostScreen extends StatefulWidget {
  final postId;
  final String postTitle;
  final String postText;
  final String postImage;

  PostScreen({this.postId, this.postTitle, this.postImage, this.postText});

  static const id = 'post_screen';
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommentStream(),
    );
  }
}

class CommentStream extends StatelessWidget {
  Future<Widget> _buildCommentStream(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) async {
    final String userAnonID = await User.getCurrentUserAnonID();
    final commentDocuments = snapshot.data.documents;

    List<Widget> commentWidgets = [];

    for (var comment in commentDocuments) {
      final String userComment = comment.data['comment'];
      final int alpha = comment.data['alpha'];
      final int beta = comment.data['beta'];
      final timestamp = comment.data['timestamp'];

      int userVote;

      if (commentWidgets != null) {
        userVote = comment.data['${userAnonID}vote'];
        if (userVote == null) {
          comment.reference.setData(
            {
              '${userAnonID}vote': 0,
            },
            merge: true,
          );
        }
      }

      final Widget commentWidget = Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1.0, color: Colors.grey),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('gönderen: ${comment.data['sender']}'),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(userComment),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              //Vote Up 0 null 1 false 2 true
                              comment.reference.updateData({
                                '${userAnonID}vote':
                                    Vote.vote(alpha, beta, userVote, 'VoteUp')
                                        .first,
                                'alpha': Vote.vote(
                                    alpha, beta, userVote, 'VoteUp')[1],
                                'beta':
                                    Vote.vote(alpha, beta, userVote, 'VoteUp')
                                        .last,
                              });
                            },
                            child: Icon(
                              Icons.thumb_up,
                              size: 14.0,
                              color: userVote == 2 ? Colors.blue : Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text((alpha - beta).toString()),
                          SizedBox(
                            width: 10.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              //Vote Down 0 null 1 false 2 true
                              comment.reference.updateData({
                                '${userAnonID}vote':
                                    Vote.vote(alpha, beta, userVote, 'VoteDown')
                                        .first,
                                'alpha': Vote.vote(
                                    alpha, beta, userVote, 'VoteDown')[1],
                                'beta':
                                    Vote.vote(alpha, beta, userVote, 'VoteDown')
                                        .last,
                              });
                            },
                            child: Icon(
                              Icons.thumb_down,
                              size: 14.0,
                              color:
                                  userVote == 1 ? Colors.orange : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: Text(CurrentTime.currentTime(timestamp)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      commentWidgets.add(commentWidget);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: commentWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    final PostScreen args = ModalRoute.of(context).settings.arguments;

    Future<String> downloadImage() async {
      final ref = FirebaseStorage.instance.ref().child(args.postImage);
      var downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    }

    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('posts')
            .document('post-${args.postId}')
            .collection('post-comments-${args.postId}')
            .orderBy('timestamp')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator(
              backgroundColor: Colors.blue,
            );
          }
          return FutureBuilder(
            future: _buildCommentStream(context, snapshot),
            builder: (context, asyncSnapshot) {
              return FutureBuilder(
                future: downloadImage(),
                builder: (context, async) {
                  return ListView(
                    children: <Widget>[
                      PostSection(
                        commentL: snapshot.data.documents.length,
                        args: args,
                        asyncSnapShot: async,
                      ),
                      AddCommentSection(
                        args: args,
                      ),
                      asyncSnapshot.data != null
                          ? asyncSnapshot.data
                          : Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.blue,
                              ),
                            ),
                    ],
                  );
                },
              );
            },
          );
        });
  }
}

class PostSection extends StatefulWidget {
  final asyncSnapShot;
  final args;
  final int commentL;

  PostSection({
    this.asyncSnapShot,
    this.args,
    this.commentL,
  });

  @override
  _PostSectionState createState() => _PostSectionState();
}

class _PostSectionState extends State<PostSection> {
  IconData icon;

  Future<DocumentSnapshot> getSavedPostData() async {
    final String uid = await User.getCurrentUserID();
    final String anonid = await User.getCurrentUserAnonID();

    var existPath = Firestore.instance
        .collection('users')
        .document(uid)
        .collection('${anonid}savedposts')
        .document('${widget.args.postId}post');

    var stillExist = await existPath.get();

    setState(() {
      icon = stillExist.exists ? Icons.bookmark : Icons.bookmark_border;
    });

    return stillExist;
  }

  Future<Widget> _buildPostSection(
      BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) async {
    final String anonid = await User.getCurrentUserAnonID();
    final String uid = await User.getCurrentUserID();

    int likes = snapshot.data.data['like'];
    int dislikes = snapshot.data.data['dislike'];

    int userVote = snapshot.data.data['${anonid}vote'];
    if (userVote == null) {
      snapshot.data.reference.setData(
        {
          '${anonid}vote': 0,
        },
        merge: true,
      );
    }

    return FutureBuilder(
      builder: (context, asyncSnapshot) {
        return Container(
          decoration: BoxDecoration(
            color: kMainColor,
          ),
          child: Column(
            crossAxisAlignment: widget.asyncSnapShot.data != null
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                              'gönderen: ${snapshot.data.data['postSender']}'),
                        ),
                        Text(
                          CurrentTime.currentTime(
                              snapshot.data.data['timestamp']),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.args.postTitle.toUpperCase(),
                        style: kPostTitleStyle,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.args.postText,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              widget.args.postImage != null
                  ? widget.asyncSnapShot.data != null
                      ? FittedBox(
                          child: Container(
                            width: 1,
                            height: 1,
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SafeArea(
                                        child: Container(
                                          child: Image(
                                            image: NetworkImage(
                                                widget.asyncSnapShot.data),
                                          ),
                                        ),
                                      );
                                    });
                              },
                              child: Image(
                                image: NetworkImage(widget.asyncSnapShot.data),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: 50.0,
                          height: 50.0,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.blue,
                          ),
                        )
                  : SizedBox(),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: FlatButton(
                                child: Icon(
                                  Icons.thumb_up,
                                  size: 20.0,
                                  color: userVote == 2
                                      ? Colors.blue
                                      : Colors.white,
                                ),
                                onPressed: () {
                                  //Vote Up 0 null 1 false 2 true
                                  snapshot.data.reference.updateData({
                                    '${anonid}vote': Vote.vote(
                                            likes, dislikes, userVote, 'VoteUp')
                                        .first,
                                    'like': Vote.vote(
                                        likes, dislikes, userVote, 'VoteUp')[1],
                                    'dislike': Vote.vote(
                                            likes, dislikes, userVote, 'VoteUp')
                                        .last,
                                  });
                                },
                              ),
                            ),
                            Text(
                              (likes - dislikes).toString(),
                            ),
                            Expanded(
                              child: FlatButton(
                                onPressed: () {
                                  //Vote Up 0 null 1 false 2 true
                                  snapshot.data.reference.updateData({
                                    '${anonid}vote': Vote.vote(likes, dislikes,
                                            userVote, 'VoteDown')
                                        .first,
                                    'like': Vote.vote(likes, dislikes, userVote,
                                        'VoteDown')[1],
                                    'dislike': Vote.vote(likes, dislikes,
                                            userVote, 'VoteDown')
                                        .last,
                                  });
                                },
                                child: Icon(
                                  Icons.thumb_down,
                                  size: 20.0,
                                  color: userVote == 1
                                      ? Colors.orange
                                      : Colors.white,
                                ),
                              ),
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
                            Text(widget.commentL.toString()),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          child: FlatButton(
                            child: Icon(
                                icon != null ? icon : Icons.bookmark_border),
                            onPressed: () async {
                              var existPath = Firestore.instance
                                  .collection('users')
                                  .document(uid)
                                  .collection('${anonid}savedposts')
                                  .document('${widget.args.postId}post');

                              var stillExist = await existPath.get();

                              print(stillExist.exists);

                              if (!stillExist.exists) {
                                existPath.setData({
                                  'postId': widget.args.postId,
                                  'postTitle': widget.args.postTitle,
                                  'postText': widget.args.postText,
                                  'postImage': widget.args.postImage,
                                });
                                setState(() {
                                  icon = Icons.bookmark;
                                });
                              } else {
                                existPath.delete();
                                setState(() {
                                  icon = Icons.bookmark_border;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection('posts')
            .document('post-${widget.args.postId}')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator(
              backgroundColor: Colors.blue,
            );
          }

          return FutureBuilder(
            future: _buildPostSection(context, snapshot),
            builder: (context, asyncSnapshot) {
              return asyncSnapshot.data != null
                  ? asyncSnapshot.data
                  : Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.blue,
                      ),
                    );
            },
          );
        });
  }

  @override
  void initState() {
    super.initState();
    getSavedPostData();
  }
}

class AddCommentSection extends StatelessWidget {
  final args;

  AddCommentSection({this.args});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.pushNamed(context, AddComment.id,
            arguments: AddComment(
              postTitle: args.postTitle,
              postId: args.postId,
            ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: kMainColor,
          border: Border(
            top: BorderSide(width: 1.0, color: Colors.blue),
            bottom: BorderSide(width: 1.0, color: Colors.grey),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Yorum ekle',
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
