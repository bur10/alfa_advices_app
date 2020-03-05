import 'package:alfa_advices_app/conts.dart';
import 'package:alfa_advices_app/screens/add_comment_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_screen.dart';
import 'screens/post_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData.dark().copyWith(
          cursorColor: Colors.white,
          textSelectionHandleColor: Colors.black,
          highlightColor: kMainColor,
        ),
        initialRoute: WelcomeScreen.id,
        routes: {
          WelcomeScreen.id: (context) => WelcomeScreen(),
          MainScreen.id: (context) => MainScreen(),
          PostScreen.id: (context) => PostScreen(),
          AddComment.id: (context) => AddComment(),
        });
  }
}
