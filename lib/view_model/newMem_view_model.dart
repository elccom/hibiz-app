import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/newMember4_view.dart';
import 'package:wisemonster/view/newMember5_view.dart';
import 'package:wisemonster/view/widgets/AlertWidget.dart';
import 'package:wisemonster/view/widgets/InitialWidget.dart';
import 'package:wisemonster/view/widgets/QuitWidget.dart';
import 'package:wisemonster/view/widgets/SendWidget.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';

import '../view/home_view.dart';

class NewMemberViewModel extends GetxController{
  ApiServices api = ApiServices();

  //최종
  late String joinId,joinPw,joinRepasswd,joinName,joinPhone;


  //약관 동의
  bool isAgree = false;
  bool isAgree2 = false;

  //인증페이지

  String phone = '';
  String phoneAuth = '';
  String name = '';
  var phoneController = TextEditingController();
  var phoneAuthController = TextEditingController();
  var nameController = TextEditingController();
  var idController = TextEditingController();
  var placeController = TextEditingController();
  var response;
  bool error = false;
  String msg = '';
  var timedisplay = "00:00".obs;
  int timeForTimer = 300;
  RxString min = '0'.obs;
  RxString sec = '0'.obs;
  bool started = true;
  Timer timer = Timer(const Duration(milliseconds: 1), () {});
  bool nullCheck = false;
  bool auth = false;
  bool idChk = false;
  RxInt txt = 0.obs; // 0일때는 숨기기 1일때는 인증완료 2일때는 인증번호틀림
  String id = '';
  int isUse = 0; //1은 사용가능할때 2는 이미 있을때
  int isUse2 = 0;
  RxBool isObscure = true.obs;
  RxBool isObscure2 = true.obs;
  var passwdController = TextEditingController();
  var pwcheckController = TextEditingController();

  String passwd= '';
  String pwcheck = '';
  String place = '';
  bool _allPass = false;
  int send = 2; //보냈는지 여부 확인 1은 보냄

  agreeChange(){
    if(isAgree && isAgree2 ){
      isAgree = false;
      isAgree2 = false;
    }else{
      isAgree = true;
      isAgree2 = true;
    }
    update();
  }

  agreeChange2(){
    isAgree = !isAgree;
    update();
  }

  agreeChange3(){
    isAgree2 = !isAgree2;
    update();
  }


  void dialog() {
    Get.dialog(
        AlertWidget(serverMsg: '필수 이용약관에 동의해주세요.', error: true,)
    );
  }
  @override
  void onClose() {
    timer.cancel();
    super.onClose();
  }
  void timerStart() {
    timer = Timer.periodic(
        const Duration(
          seconds: 1,
        ), (Timer t) {
        // if(mounted){
          if(started == false){
            t.cancel();
            timeForTimer = timeForTimer;
          }else{
            if (timeForTimer < 1) {
              min.value = '0';
              sec.value = '0';
              t.cancel();
              if (timeForTimer == 0) {
                min.value = '0';
                sec.value = '0';
                t.cancel();
              }
              Get.back();
            } else {
              print('타이머');
              int h = timeForTimer ~/ 3600;
              int t = timeForTimer - (3600 * h);
              int m = (t ~/ 60);
              int s = (t - (60 * m));
              min.value = m.toString();
              sec.value = s.toString();
              print(min.value);
              print(sec);
              // timedisplay =
              //     m.toString().padLeft(2, '0') +
              //         ":" +
              //         s.toString().padLeft(2, '0');
              timeForTimer = timeForTimer - 1;

            }
          }
        // }
     });

  }
  void snackbar(msg) {
    Get.snackbar(
      '알림',
      msg,
      duration: Duration(seconds: 3),
      backgroundColor: const Color.fromARGB(
          255, 39, 161, 220),
      icon: Icon(Icons.info_outline, color: Colors.white),
      forwardAnimationCurve: Curves.easeOutBack,
      colorText: Colors.white,
    );
  }

  void timerRestart() {
    timer.cancel();
    timeForTimer = 300;
    update();
    timerStart();
  }

  requestValueUpdate() {
    txt.value = 0;
    msg = '';
    update();
  }

  requestJoinProcess() async{
    joinName = nameController.text.trim();
    joinId = idController.text.trim();
    joinPw = passwdController.text.trim();
    joinPhone = phoneController.text.trim();
    joinRepasswd = pwcheckController.text.trim();
    List all = [];
    all.add(joinId);
    all.add(joinPw);
    all.add(joinRepasswd);
    all.add(joinName);
    all.add(joinPhone);
    // all.add(joinPhone);
    String? fcm_token = await FirebaseMessaging.instance.getToken();

    api.qRestApi("post", "/User", {'id':joinId,'passwd':joinPw,'repasswd':joinRepasswd,'name':joinName,'fcm_token':fcm_token,'handphone':joinPhone}, false).then((res) {
      if(res['statusCode'] == 200) {
        Get.offAll(newMember5_view());
      } else {
        snackbar(res['body']['message']);
      }
     });
  }

  void authDialog(value) {
    Get.dialog(
        AlertWidget(serverMsg: msg, error: error)
    );
  }  void initDialog(value) {
    Get.dialog(
        QuitWidget(serverMsg: msg)
    );
  }
  void sendDialog(value) {
    Get.dialog(
        SendWidget(serverMsg: msg, send: send)
    );
    send == 2 ? timerStart() :
    timerRestart();
  }
}