import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/view/widgets/AlertWidget.dart';

import '../view/login_view.dart';

enum UserEnums { Error, Initial, Waiting }

class FindPwViewModel extends GetxController {
  ApiServices api = ApiServices();
  UserEnums userEnums = UserEnums.Initial;

  String serverMsg = '';
  bool error = false;

  final GlobalKey<FormState> findPwFormKey = GlobalKey<FormState>();

  findPw(id,phone){
    api.get('/User/findPasswd?id=${id}&type=1&handphone=${phone}').then((value) {
      if(value.statusCode == 200) {
        Get.snackbar(
          '알림',
          '등록된 번호로 문자를 전송하였습니다\n확인 후 다시 로그인해주세요.'
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
        Get.offAll(login_view());
      }else{
        Get.snackbar(
          '알림',
          utf8.decode(value.reasonPhrase!.codeUnits)
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      }
    });
  }

}