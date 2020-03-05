import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  final _firestore = Firestore.instance;

  static Future<String> getCurrentUserID() async {
    final _auth = FirebaseAuth.instance;
    FirebaseUser loggedInUser = await _auth.currentUser();
    return loggedInUser.uid;
  }

  static Future<String> getCurrentUserAnonID() async {
    String userAnonId;

    final _firestore = Firestore.instance;
    String uid = await getCurrentUserID();

    var document = await _firestore.collection('users').document(uid).get();

    userAnonId = document.data['userAnonId'];

    return userAnonId;
  }

  Future<int> currentRegisteredUsers(var userId) async {
    var userDocument = await _firestore.collection('users').getDocuments();

    if (userDocument == null) {
      _firestore.collection('users').document(userId).setData({
        'userAnonId': 'anon-0001',
      });
    }

    int registeredUser = userDocument.documents.length;

    return registeredUser;
  }

  void registerUser(var userId) async {
    final int currentRegisteredUser = await currentRegisteredUsers(userId);

    _firestore.collection('users').document(userId).setData({
      'userAnonId':
          'anon-${(currentRegisteredUser + 1).toString().padLeft(4, '0')}',
    });
  }

  Map<String, String> errorTypes = {
    'badlyFormatted':
        'PlatformException(ERROR_INVALID_EMAIL, The email address is badly formatted., null',
    'alreadyInUse':
        'PlatformException(ERROR_EMAIL_ALREADY_IN_USE, The email address is already in use by another account., null',
  };

  String whatErrorIs() {
    String error;

    switch (errorTypes.keys.toString()) {
      case 'badlyFormatted':
        error = 'Lütfen geçerli bir E-posta giriniz.';
        break;
      case 'alreadyInUse':
        error = 'Bu E-posta zaten kullanımda.';
    }
    return error;
  }
}
