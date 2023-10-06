
import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectController extends GetxController{
  StreamSubscription<ConnectivityResult>? subscription;


  @override
  void onInit() {
    print('연결상태 진단');
    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        Get.dialog(
            AlertDialog(
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
                    '인터넷 연결을 확인한 후\n앱을 다시 실행해 주세요.',
                  )
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("확인"),
                  onPressed: () {
                    print('시스템다운');
                    exit(0);
                  },
                ),
              ],
            )
        );
      }
    });
    super.onInit();
  }

  @override
  onClose() {
    // 상태 리스터 해제
    subscription?.cancel();
    // 연결 해제
    print('연결 해제');
    super.onClose();
  }
}