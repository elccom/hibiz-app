import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/view/login_view.dart';

import '../api/api_services.dart';

class ConfigController extends GetxController{
  Map<String, dynamic> deviceData = <String, dynamic>{};

  ApiServices api = ApiServices();

  final info = NetworkInfo();

  var wifiName;
  var listData;

  bool isDoorbell = false;
  bool isAccessRecord = false;
  bool isMotionDetect = false;
  String? token;
  var k = TextEditingController();
  String test = '';

  Future<Map<String, dynamic>> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidDeviceInfo(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } catch(error) {
      deviceData = {
        "Error": "Failed to get platform version."
      };
    }

    return deviceData;
  }

  Map<String, dynamic> _readAndroidDeviceInfo(AndroidDeviceInfo info) {
    var release = info.version.release;
    var sdkInt = info.version.sdkInt;
    var manufacturer = info.manufacturer;
    var model = info.model;

    return {
      "OS 버전": "Android $release (SDK $sdkInt)",
      "기기": "$manufacturer $model"
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo info) {
    var systemName = info.systemName;
    var version = info.systemVersion;
    var machine = info.utsname.machine;

    return {
      "OS 버전": "$systemName $version",
      "기기": "$machine"
    };
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

  toggle(value,type) async {
    print('토글 값');
    print(value);
    String? toggleValue;
    if(value == true){
      toggleValue = '1';
    } else {
      toggleValue = '0';
    }
    late SharedPreferences sharedPreferences;
    sharedPreferences = await SharedPreferences.getInstance();
    print(type);
    print(toggle);
    print(toggleValue);

    if(type == 'isDoorbell') {
      api.qRestApi("put", "/SmartdoorUser", {'isDoorbell':toggleValue}, true).then((res) async {
        if(res['statusCode'] == 200) {
          snackbar('도어벨 알림이 재설정 되었습니다.');
        } else if(res['statusCode'] == "401") {
          Get.offAll(login_view());
        } else {
          snackbar(res['body']['message']);
        }
      });
    } else if(type == 'isAccessRecord') {
      api.qRestApi("put", "/SmartdoorUser", {'isAccessRecord':toggleValue}, true).then((res) async {
        if(res['statusCode'] == 200) {
          snackbar('출입 알림이 재설정 되었습니다.');
        } else if(res['statusCode'] == "401") {
          Get.offAll(login_view());
        } else {
          snackbar(res['body']['message']);
        }
      });
    } else if(type == 'isMotionDetect') {
      api.qRestApi("put", "/SmartdoorUser", {'isMotionDetect':toggleValue}, true).then((res) async {
        if(res['statusCode'] == 200) {
          snackbar('모션감지 알림이 재설정 되었습니다.');
        } else if(res['statusCode'] == "401") {
          Get.offAll(login_view());
        } else {
          snackbar(res['body']['message']);
        }
      });
    }

    update();
  }

  allupdate(){
    update();
  }

  @override
  void onInit() async{
    token = await FirebaseMessaging.instance.getToken();
    test = token!;
    k.text = token!;
    update();
    wifiName = await info.getWifiName(); // "FooNetwork"
    getDeviceInfo();
    late SharedPreferences sharedPreferences;
    sharedPreferences = await SharedPreferences.getInstance();

    api.qRestApi("get", "/SmartdoorUser/me", {}, true).then((res) async {
      if(res['statusCode'] == 200) {
        listData = res['body'];

        print('설정데이타');
        print(listData);
        print(listData['isDoorbell']);
        print(listData['isAccessRecord']);
        print(listData['isMotionDetect']);

        if(listData['isDoorbell'] == 1) isDoorbell = true;
        else isDoorbell = false;

        if(listData['isAccessRecord'] == 1) isAccessRecord = true;
        else isAccessRecord = false;

        if(listData['isMotionDetect'] == 1) isMotionDetect = true;
        else isMotionDetect = false;

        update();
      } else if(res['statusCode'] == "401") {
        Get.offAll(login_view());
      } else {
        snackbar(res['body']['message']);
      }
    });

    super.onInit();
  }
}