import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view_model/newMem_view_model.dart';

class SendWidget extends StatelessWidget {
  final String serverMsg;
  final int send;
  SendWidget({
    required this.send,
    required this.serverMsg,
  });
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
          send == 2 ?
          const Text(
            "인증번호 전송을 실패하였습니다.\n관리자에게 문의해주세요.",
          ):
          const Text(
            "핸드폰 번호로 인증번호를 발송했습니다.\n인증번호 입력 후 하단의 '확인' 버튼을 눌러주세요.",
          )
        ],
      ),
      actions: <Widget>[
      ],
    );
  }
}