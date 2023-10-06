import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class H2 extends StatelessWidget {
  String changeValue = '';

  String hintText = '';
  H2({
    required this.changeValue,
  });
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Text(
      changeValue,
      textAlign: TextAlign.left,
      style: TextStyle(
          fontSize: 15,
          color: Color.fromARGB(255, 43, 43, 43)
      ),
    );
  }
}