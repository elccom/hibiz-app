import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wisemonster/view/login_view.dart';

class SnackBarWidget extends StatelessWidget {
  final String serverMsg;
  SnackBarWidget({
    required this.serverMsg,
  });
  @override
  Widget build(BuildContext context) {
    return
        SnackBar(content: Text('${serverMsg}'));

  }
}