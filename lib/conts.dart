import 'package:flutter/material.dart';

const kMainColor = Color(0xFF1A1A1B);

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter value',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(5.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(5.0)),
  ),
);

const kPostTitleStyle = TextStyle(
  color: Colors.white,
  fontSize: 22.0,
  fontWeight: FontWeight.w800,
);

const kAddCommentBorder = OutlineInputBorder(
  borderSide: BorderSide(
    width: 0.0,
  ),
);

const kAddCommentDecoration = InputDecoration(
  hintText: 'Yorumuzunu giriniz.',
  filled: true,
  fillColor: Color(0xFF403f3f),
  border: kAddCommentBorder,
  focusedBorder: kAddCommentBorder,
  enabledBorder: kAddCommentBorder,
);

const kRegisterLogInTextField = InputDecoration(
  filled: true,
  fillColor: Colors.black12,
  hintText: 'enter a value',
  border: kRegisterLogInTextFieldBorder,
  enabledBorder: kRegisterLogInTextFieldBorder,
  focusedBorder: kRegisterLogInTextFieldBorder,
);

const kRegisterLogInTextFieldBorder = OutlineInputBorder(
  borderSide: BorderSide(width: 3.0, color: Colors.black38),
);
