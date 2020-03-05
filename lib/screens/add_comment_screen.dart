import 'package:alfa_advices_app/conts.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alfa_advices_app/user.dart';

class AddComment extends StatefulWidget {
  static const id = 'add_comment';

  final String postTitle;
  final postId;

  AddComment({this.postId, this.postTitle});

  @override
  _AddCommentState createState() => _AddCommentState();
}

class _AddCommentState extends State<AddComment> {
  String comment;

  @override
  Widget build(BuildContext context) {
    final AddComment args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.close)),
        actions: <Widget>[
          GestureDetector(
            onTap: () async {
              final String sender = await User.getCurrentUserAnonID();

              var pathDocuments = await Firestore.instance
                  .collection('posts')
                  .document('post-${args.postId}')
                  .collection('post-comments-${args.postId}')
                  .getDocuments();
              var pathCommentsLength = pathDocuments.documents.length;

              var path = Firestore.instance
                  .collection('posts')
                  .document('post-${args.postId}')
                  .collection('post-comments-${args.postId}')
                  .document(
                      'comment-${(pathCommentsLength + 1).toString().padLeft(5, '0')}');

              path.setData({
                'comment': comment,
                'timestamp': Timestamp.now()
                    .toDate()
                    .add(Duration(hours: 3))
                    .millisecondsSinceEpoch,
                'sender': sender,
                '${sender}vote': 2,
                'alpha': 1,
                'beta': 0,
              });
            },
            child: Icon(
              Icons.send,
              color: Colors.blue,
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              args.postTitle.toUpperCase(),
              style: kPostTitleStyle,
            ),
            Container(
              height: 1.5,
              color: Colors.grey,
            ),
            Text('#${args.postId} nolu başlığa yorum yazıyorsunuz.'),
            SizedBox(
              height: 10.0,
            ),
            Expanded(
              child: TextField(
                onChanged: (value) {
                  comment = value;
                },
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: kAddCommentDecoration,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
