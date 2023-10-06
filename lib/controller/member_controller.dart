
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/member_edit_view.dart';

import '../view/member_view.dart';
import '../view/widgets/SnackBarWidget.dart';

class MemberController extends GetxController{
  ApiServices api = ApiServices();

  Map<String, dynamic> userObj = {};
  Map<String, dynamic> smartdoorObj = {};
  Map<String, dynamic> listData = {"total": 0, "totalPages": 0, "page": 1, "rowsPerPage": 10, "sort": "a_smartdoor_item_id", "desc": "desc", "keyword": "", "lists": []};

  var namecontroller = TextEditingController();
  var phonecontroller = TextEditingController();
  var mesaagecontroller = TextEditingController();

  String massage = '';
  String phone = '';
  String name = '';
  bool isclear = false;
  var messageData;

  updateContact(value){
    phonecontroller.text = value;
    phone = value;
    Get.back();
    update();
  }

  void snackbar(msg) {
    Get.snackbar(
      '알림',
      msg,
      duration: Duration(seconds: 5),
      backgroundColor: const Color.fromARGB(
          255, 39, 161, 220),
      icon: Icon(Icons.info_outline, color: Colors.white),
      forwardAnimationCurve: Curves.easeOutBack,
      colorText: Colors.white,
    );
  }

  requestMember() {
    print('맴버조회구간');
    api.qRestApi("get", "/SmartdoorUser/lists", {}, true).then((res) {
      if (res['statusCode'] == 200) {
        listData = res['body'];
        isclear = true;
        update();
      } else if (res['statusCode'] == 401) {
        Get.offAll(login_view());
        snackbar(res['body']['message']);
      } else {
        Get.back();
        snackbar(res['body']['message']);
      }
    });
  }

  void sendMessage(user_id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? userStr = sharedPreferences.getString('user')!;
    userObj = jsonDecode(userStr);

    String? smartdoorStr = sharedPreferences.getString('smartdoor')!;
    smartdoorObj = jsonDecode(smartdoorStr);

    Map<String, dynamic> jsonData = {
      "url": "/SmartdoorMessage",
      "method": "POST",
      "isToken": true,
      "body":{'smartdoor_id':smartdoorObj['smartdoor_id'],'to_user_id':userObj['user_id'],'msg':mesaagecontroller.text}
    };

    api.restapi(jsonData).then((res) async {
      if(res['result']) {
        Get.back();
        snackbar('메세지작성이 완료되었습니다.');
      } else if(res['statusCode'] == 401) {
        Get.offAll(login_view());
        //snackbar(res['message']);
        update();
      } else {
        Get.back();
        snackbar(res['message']);
        update();
      }
    });
  }

  requestMessage(idx){
    print('메세지조회구간');
    api.get('/SmartdoorMessage/lists').then((value) {
      if(value.statusCode == 200) {
        print('받은 user_id : ${idx}');
        print(json.decode(value.body)['lists'].length);
        List k = [];
        for(int i = 0; i < json.decode(value.body)['lists'].length; i++){
          print('값 : ${json.decode(value.body)['lists'][i]['to_user_id']}');
          if(json.decode(value.body)['lists'][i]['to_user_id'].toString() == idx.toString()){
            print(json.decode(value.body)['lists'][i]);
            k.add(json.decode(value.body)['lists'][i]);
          }
        }
        print(k);
        messageData = k;
        // isClear = true;
        update();
      } else if(value.statusCode == 401) {
        Get.offAll(login_view());
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
      } else {
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

  void deleteMember(index) {
    print(index);
    print(listData['lists']);
    String smartdoor_user_invite_id = listData['lists'][index]['smartdoor_user_id'];
    print('smartdoor_item_id : ${smartdoor_user_invite_id}');
    api.delete('/SmartdoorUser/${smartdoor_user_invite_id}').then((value) {
      if(value.statusCode == 200) {
        requestMember();
        Get.snackbar(
          '알림',
          '구성원 삭제가 완료되었습니다.'
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
        update();
      } else if(value.statusCode == 401) {
        Get.offAll(login_view());
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
      } else {
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

  @override
  void onInit() {
    requestMember();
    // requestMessage();
    super.onInit();
  }


}