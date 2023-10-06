import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:wisemonster/view/login_view.dart';

class UpdateWidget extends StatelessWidget {
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
          children: const [Text("새로운 버전 출시")],
        ),
      ),
      //
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            '업데이트를 하고 새로운 기능을 만나보세요.',
          )
        ],
      ),
      actions: <Widget>[
    TextButton(
    child: const Text("취소"),
    onPressed: () {
      Get.back();
    },
    ),
    TextButton(
          child: const Text("확인"),
          onPressed: () {
            StoreRedirect.redirect(androidAppId: 'com.wikibox.wisemonster', iOSAppId: '1622131384' );
          },
        ),
      ],
    );
  }
}