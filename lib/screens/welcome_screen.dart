import 'package:alfa_advices_app/conts.dart';
import 'package:alfa_advices_app/screens/main_screen.dart';
import 'package:alfa_advices_app/user.dart';
import 'package:flutter/material.dart';
import 'package:alfa_advices_app/widgets/rounded_button.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();

  static const id = 'welcome_screen';
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;

  User user = User();

  bool showSpinner = false;
  String email;
  String password;

  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        duration: Duration(seconds: 1), vsync: _WelcomeScreenState());
    animation =
        ColorTween(begin: Colors.grey, end: kMainColor).animate(controller);

    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Hero(
                    tag: 'logo',
                    child: Container(
                      width: 54.0,
                      height: 54.0,
                      child: Image.asset(
                        'resources/logo.png',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    'Alfa Tavsiyeleri',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35.0,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    email = value;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      kRegisterLogInTextField.copyWith(hintText: 'E-posta'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    password = value;
                  },
                  obscureText: true,
                  decoration:
                      kRegisterLogInTextField.copyWith(hintText: 'Şifre'),
                ),
              ),
              RoundedButton(
                color: Colors.black87,
                text: 'Giriş Yap',
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });

                  try {
                    final existUser = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    if (existUser != null) {
                      Navigator.pushNamed(context, MainScreen.id);
                    }
                  } catch (e) {
                    setState(() {
                      showSpinner = false;
                    });
                    print(e);
                  }

                  setState(() {
                    showSpinner = false;
                  });
                },
              ),
              RoundedButton(
                color: Colors.black87,
                text: 'Kayıt Ol',
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });

                  try {
                    final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                    if (newUser != null) {
                      user.registerUser(newUser.user.uid);
                      Navigator.pushNamed(context, MainScreen.id);
                    }
                    setState(() {
                      showSpinner = false;
                    });
                  } catch (e) {
                    setState(() {
                      showSpinner = false;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
