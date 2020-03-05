import 'package:flutter/material.dart';
import 'package:alfa_advices_app/conts.dart';
import 'package:flutter/services.dart';

class PostTextField extends StatelessWidget {
  final String uiPostInfo;
  final String uiHintText;
  final Function onChangedFunction;
  final RegExp regExp;
  final int maxLength;

  PostTextField(
      {@required this.uiPostInfo,
      @required this.uiHintText,
      @required this.onChangedFunction,
      @required this.regExp,
      @required this.maxLength});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(uiPostInfo),
        SizedBox(
          height: 10.0,
        ),
        Container(
          height: 100.0,
          child: TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            maxLength: maxLength,
            autocorrect: false,
            onChanged: onChangedFunction,
            decoration: kTextFieldDecoration.copyWith(
              hintText: uiHintText,
            ),
            inputFormatters: [
              BlacklistingTextInputFormatter(regExp),
            ],
            style: TextStyle(
              height: 2.0,
              fontSize: 15.0,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
