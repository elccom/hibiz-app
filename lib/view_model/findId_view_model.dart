import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/view/widgets/AlertWidget.dart';

enum UserEnums { Error, Initial, Waiting }

class FindIdViewModel extends GetxController {
  ApiServices api = ApiServices();
  UserEnums userEnums = UserEnums.Initial;

  String serverMsg = '';
  bool error = false;

  final GlobalKey<FormState> findIdFormKey = GlobalKey<FormState>();

  void findId(apiName, apiPhone) {
    userEnums = UserEnums.Waiting;
    update();
    api.findId(apiName, apiPhone).then((value) {
      Get.back();
      if (value == false) {
        userEnums = UserEnums.Error;
        serverMsg = "서버 연결에 실패하였습니다.";
        error = true;
        update();
      } else {
        if (kDebugMode) {
          print(value);
        }
        if(value.statusCode == 200) {
          error = false;
          serverMsg = '등록된 번호로 아이디를 전송했습니다.';
          update();
        } else {
          userEnums = UserEnums.Error;
          error = true;
          serverMsg = utf8.decode(value.reasonPhrase!.codeUnits);
          update();
        }
        //user = UserModel.fromJson(value);
      }
      dialog(value);
    });
  }

  void dialog(value) {
    Get.dialog(
      AlertWidget(serverMsg: serverMsg, error: error)
    );
  }
}
