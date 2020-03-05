import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'post_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:alfa_advices_app/user.dart';

class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

//String imageUrl;

class _AddPostState extends State<AddPost> {
  File _image;
  String newPostTitle;
  String newPostText;
  bool clickedUploadPhoto = false;

  Widget controlPhoto(BuildContext context) {
    if (_image != null) {
      return Center(
        child: Container(
          child: Column(
            children: <Widget>[
              Text('Fotoğraf eklendi.'),
              GestureDetector(
                child: Text(
                  'Görüntülemek için tıklayınız.',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.blue,
                  ),
                ),
                onTap: () {
                  showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return SafeArea(
                          child: Container(
                            child: Image.file(_image),
                          ),
                        );
                      });
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return Center(child: Text('Fotoğraf eklenmedi.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isBlockedSpaceInTitle = false;
    bool isBlockedSpaceInText = false;

    Future getImage() async {
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);

      setState(() {
        _image = image;
      });
    }

    Future<String> uploadImage() async {
      final fileName = basename(_image.path);
      StorageReference storageReference =
          FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask storageUploadTask = storageReference.putFile(_image);
      await storageUploadTask.onComplete;

      return fileName;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Text(
            'Konu Ekleme',
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'Lütfen kurallara uygun bir şekilde konu ekleyiniz aksi takdirde kaldırmak zorunda kalınabilir.',
            style: TextStyle(fontSize: 13.0),
            textAlign: TextAlign.center,
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              PostTextField(
                  maxLength: 70,
                  uiPostInfo: 'Konu Başlığı',
                  uiHintText: 'Lütfen! konu başlığı giriniz.',
                  onChangedFunction: (newValue) {
                    setState(() {
                      isBlockedSpaceInTitle =
                          newValue.toString().endsWith(' ') ? true : false;
                    });
                    newPostTitle = newValue;

                    print('newposttitle = $newPostTitle');
                    print(isBlockedSpaceInTitle);
                  },
                  regExp: RegExp(isBlockedSpaceInTitle ? '[\\ ]' : '[\\.]')),
              PostTextField(
                maxLength: 200,
                uiPostInfo: 'Konu Açıklaması',
                uiHintText: 'Lütfen! konu açıklaması giriniz.',
                regExp:
                    isBlockedSpaceInText ? RegExp('[\\ ]') : RegExp('[\\.]'),
                onChangedFunction: (newValue) {
                  setState(() {
                    isBlockedSpaceInText =
                        newValue.toString().endsWith(' ') ? true : false;
                  });
                  newPostText = newValue;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    child: Text('Fotoğraf seç'),
                    color: Colors.grey.shade700,
                    onPressed: () {
                      getImage();
                      setState(() {
                        clickedUploadPhoto = true;
                      });
                    },
                  ),
                  SizedBox(
                    width: 30.0,
                  ),
                  controlPhoto(context),
                ],
              ),
              SizedBox(
                height: 30.0,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FlatButton(
                  color: Colors.grey.shade700,
                  child: Text('Paylaş'),
                  onPressed: () async {
                    final String sender = await User.getCurrentUserAnonID();

                    final String _imageUrl =
                        clickedUploadPhoto ? await uploadImage() : null;

                    final postDocuments = await Firestore.instance
                        .collection('posts')
                        .getDocuments();

                    final postId = (postDocuments.documents.length + 1)
                        .toString()
                        .padLeft(5, '0');

                    Firestore.instance
                        .collection('posts')
                        .document(
                            'post-${(postDocuments.documents.length + 1).toString().toString().padLeft(5, '0')}')
                        .setData({
                      'timestamp': Timestamp.now()
                          .toDate()
                          .add(Duration(hours: 3))
                          .millisecondsSinceEpoch,
                      'postTitle': newPostTitle,
                      'postText': newPostText,
                      'postImage': _imageUrl,
                      'postId': postId,
                      'postSender': sender,
                      '${sender}vote': 2,
                      'like': 1,
                      'dislike': 0,
                    });

                    setState(() {
                      clickedUploadPhoto = false;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
