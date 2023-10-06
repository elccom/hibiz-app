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
import 'package:wisemonster/view_model/home_view_model.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:http/http.dart' as http;

import '../models/mqtt.dart';

class NoticeController extends GetxController{
  var titleController = TextEditingController();
  var pickController = TextEditingController();
  var commentController = TextEditingController();
  var home = Get.put(HomeViewModel());

  DateTime? pickedDate;
  String comment = '';
  String title = '';

  final isclear = false.obs;

  ApiServices api = ApiServices();
  RxMap listData = {}.obs;
  // Mqtt mqtt = new Mqtt();
  @override
  void onInit() {
    getDataAtSmartdoorNotice();
    update();
    super.onInit();
  }
  getDataAtSmartdoorNotice(){
    print(Get.arguments);

    api.get('/SmartdoorNotice/${Get.arguments}').then((value) async {
        if (value == false) {
          SnackBarWidget(serverMsg: value['message'],);
        } else {
          listData.value = value;
          print(listData);
          // print(listData.length);
          print('요청한 리스트값 ${value}');
          print('${value['title']} 제목');
          // print(value[index]['title']);
          // print(value[index]['familyObj']);
              // json.decode(value).cast<Map<String, dynamic>>().toList();
          update();
          isclear.value = true;
        }
    });
    // api.requestNoticeRead('/SmartdoorNotice/1').then((value){
    //   if (value == false) {
    //     SnackBarWidget(serverMsg: value['message'],);
    //   } else {
    //     listData.value = value;
    //     print(listData.length);
    //     print('요청한 리스트값 ${value}');
    //     // print(value[index]['title']);
    //     // print(value[index]['familyObj']);
    //         // json.decode(value).cast<Map<String, dynamic>>().toList();
    //     update();
    //     isclear.value = true;
    //   }
    // });
    update();
  }
  deleteNotice(index)  {
    String? familyScheduleId = listData[index!]['family_notice_id'];
    print('${familyScheduleId} : family_notice_id');
    api.requestNoticeDelete('/FamilyNotice/deleteProcess',familyScheduleId).then((value) {
      if (value['result'] == false) {
        Get.snackbar(
          '알림',
          value['message']
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      } else {
        isclear.value = false;
        getDataAtSmartdoorNotice();
        Get.back();
        // Get.offAll(notice_view());
        // refreshDoorUi();
        Get.snackbar(
          '알림',
          '완료되었습니다.'
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
  // refreshDoorUi(){
  //   if(mqtt.client?.connectionStatus?.state == MqttConnectionState.disconnected){
  //     // home.connect();
  //     print('커넥시도');
  //   }
  //   String? sncode =  home.sharedPreferences.getString('sncode');
  //   String topic = 'smartdoor/SMARTDOOR/${sncode}';
  //   var builder = MqttClientPayloadBuilder();
  //   builder.addString('{"request":"refresh"}');
  //   mqtt.client?.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  // }

}