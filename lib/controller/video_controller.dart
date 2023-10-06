import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/notice_view.dart';
import 'package:wisemonster/view/profile_view.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:http/http.dart' as http;

class VideoController extends GetxController{
  var titleController = TextEditingController();
  var pickController = TextEditingController();
  var commentController = TextEditingController();

  DateTime? pickedDate;
  String comment = '';
  String title = '';
  int index = 0;

  ApiServices api = ApiServices();
  var listData;
  List elements = [];
  @override
  void onInit() {

    requestEntrance();
    update();
    super.onInit();
  }

  void snackbar(String msg) {
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

  requestEntrance(){
    print('초기 인덱스');
    print(index);
    api.get('/SmartdoorVod/lists').then((value) {
      if(value.statusCode == 200) {
        listData = json.decode(value.body);
        print('요청한 리스트값 ${json.decode(value.body)}');
        // print(value[index]['title']);
        // print(value[index]['familyObj']);
        // json.decode(value).cast<Map<String, dynamic>>().toList();
        elements = [
          // type 0:게스트 키, 1:번호키, 2: 앱, 3:안면인식
          for(int i = 0; i < listData['lists'].length; i++)
            {
              'smartdoor_vod_id': listData['lists'][i]['smartdoor_vod_id'],
              'name': listData['lists'][i]['comment'],
              'group': DateFormat('yyyy-MM-dd').format(DateTime.parse(listData['lists'][i]['regDate'])),
              'fileurl': listData['lists'][i]['fileurl']
            },
        ];
        print(elements);
        update();
      } else {
        snackbar(value['body']['message']);
      }
    });

    update();
  }

  void allUpdate() {
    update();
  }

}