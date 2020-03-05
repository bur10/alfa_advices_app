import 'package:alfa_advices_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:alfa_advices_app/widgets/add_post.dart';
import 'post_stream_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();

  static const id = 'main_screen';
}

class _MainScreenState extends State<MainScreen> {
  FirebaseUser loggedInUser;

  void getCurrentUser() async {
    loggedInUser = await FirebaseAuth.instance.currentUser();
  }

  String message;

  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = [
    PostStream(),
    AddPost(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
//        actions: <Widget>[
//          _selectedIndex == 1
//              ? Icon(
//                  Icons.send,
//                  color: Colors.blue,
//                )
//              : SizedBox(),
//        ],
        title: Text('Alfa Tavsiyeleri'),
      ),
      body: Center(
        child: _widgetOptions[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Başlıklar'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            title: Text('Konu Aç'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('Profil'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        iconSize: 32.0,
        onTap: _onItemTapped,
      ),
    );
  }
}
