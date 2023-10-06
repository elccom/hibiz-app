import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/view/notice_view.dart';
import 'package:wisemonster/view/profile_view.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:http/http.dart' as http;

import '../view/login_view.dart';

class EntranceController extends GetxController{
  ApiServices api = ApiServices();
  Map<String, dynamic> listData = {"total": 0, "totalPages": 0, "page": 1, "rowsPerPage": 10, "sort": "a_smartdoor_item_id", "desc": "desc", "keyword": "", "lists": []};

  var titleController = TextEditingController();
  var pickController = TextEditingController();
  var commentController = TextEditingController();

  DateTime? pickedDate;
  String comment = '';
  String title = '';
  int index = 0;

  List timeData = [];
  List elements = [];
  @override
  void onInit() {
    requestEntrance();
    update();
    super.onInit();
  }

  @override
  void onClose() {
    print('출입기록종료');
    super.onClose();
  }

  requestEntrance(){
    print('requestEntrance');
    print(index);

    api.qRestApi("get", "/SmartdoorLog/lists", {}, true).then((res) {
      if(res['statusCode'] == 200) {
        listData = res['body'];

        elements = [
          //type 0:게스트 키, 1:번호키, 2: 앱, 3:안면인식
          for(int i = 0; i< listData['lists'].length; i++) {
            'name': listData['lists'][i]['name'] == '' ? '' : '${listData['lists'][i]['name']}',
            'group': DateFormat('yyyy-MM-dd').format(listData['lists'][i]['regDate'] == '' ? DateTime.utc(1900,1,1) : DateTime.parse(listData['lists'][i]['regDate'])),
            'type': listData['lists'][i]['type']
          },
        ];

        for(int i = 0; i< listData['lists'].length; i++) {
          timeData.add(DateFormat('a h:mm').format(DateTime.parse(listData['lists'][i]['regDate'])));
        }

        print("timeData : ${timeData}");
        print("elements : ${elements}");

        update();

      } else if (res['statusCode'] == 401) {
        Get.offAll(login_view());
        Get.dialog(SnackBarWidget(serverMsg: res['body']['message'],));
      } else {
        Get.dialog(SnackBarWidget(serverMsg: res['body']['message'],));
      }
    });

    update();
  }

  void allUpdate(value) {
    index = value;
    print('${index} 인덱스값');
    update();
  }
}