import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wisemonster/view/login_view.dart';

class AlertWidget extends StatelessWidget {
  final String serverMsg;
  final bool error;
  AlertWidget({
    required this.serverMsg,
    required this.error,
  });
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      //Dialog Main Title
      title: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [Text("알림")],
        ),
      ),
      //
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            serverMsg,
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("확인"),
          onPressed: () {
            error == false ? Get.offAll(() => login_view()) : Get.back();
          },
        ),
      ],
    );
  }
}