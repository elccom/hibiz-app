import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswdFieldWidget extends StatelessWidget {
  String changeValue = '';
  var tcontroller = TextEditingController();
  String hintText = '';
  PasswdFieldWidget({
    required this.tcontroller,
    required this.changeValue,
    required this.hintText
  });
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return TextField(
        obscureText: true,
        controller: tcontroller, //set id controller
        style: const TextStyle(
            color: Color.fromARGB(255, 43, 43, 43), fontSize: 17),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
              fontSize: 17,
              color: Color.fromARGB(255, 222, 222, 222)
          ),
          enabledBorder: UnderlineInputBorder(
              borderSide:
              BorderSide(color: Color.fromARGB(255, 43, 43, 43))),
        ),
        onChanged: (value) {
          //변화된 id값 감지
          changeValue = value;
          print(changeValue);
        });
  }
}