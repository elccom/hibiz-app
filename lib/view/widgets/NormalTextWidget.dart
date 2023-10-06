import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NormalTextWidget extends StatelessWidget {
  String changeValue = '';

  String hintText = '';
  NormalTextWidget({
    required this.changeValue,
  });
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Text(
      changeValue,
      textAlign: TextAlign.left,
      style: TextStyle(
          fontSize: 17,
          color: Color.fromARGB(255, 42, 66, 91)
      ),
    );
  }
}