import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as en;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';
import 'package:byte_util/byte_util.dart';
import 'package:convert/convert.dart';
import 'package:hex/hex.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:crypto/crypto.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/widgets/InitialWidget.dart';
import 'package:permission_handler/permission_handler.dart';


import '../api/api_services.dart';
import '../models/user_model.dart';
import '../view/afterQr_view.dart';

class QRController extends GetxController {
  Barcode? result;
  QRViewController? qrcontroller;
  ApiServices api = ApiServices();
  // late SharedPreferences sharedPreferences;

  void onQRViewCreated(QRViewController controller) async {
    if (await Permission.camera.isGranted) {
      this.qrcontroller = controller;

      controller.scannedDataStream.listen((scanData) {
        if(scanData.code != null){
          this.qrcontroller?.pauseCamera();
          result = scanData;
          print(scanData.code);
          sendCode(result);
        }
      });
    } else {
      Get.dialog(InitialWidget(serverMsg: '카메라 사용 권한이 없습니다. 권한 설정 후 이용해 주세요.'));
    }
  }

  void snackbar(String msg) {
    Get.snackbar(
      '알림',
      msg,
      duration: const Duration(seconds: 5),
      backgroundColor: const Color.fromARGB(
          255, 39, 161, 220),
      icon: const Icon(Icons.info_outline, color: Colors.white),
      forwardAnimationCurve: Curves.easeOutBack,
      colorText: Colors.white,
    );
  }

  sendCode (Barcode? result) async {
    print(result?.code);
    api.qRestApi("get", "/Smartdoor/findByCode?code=${result?.code}", {}, true).then((value) async {
      if(value['statusCode'] == 200) {
        if(value['body']['smartdoor_id'] == null || value['body']['smartdoor_id'] == ""){
          snackbar("다른 QR코드를 촬영하셨거나 도어의 정보가 다릅니다.\n다시 촬영해주세요.");
          qrcontroller!.dispose();
        } else {
          SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
          String userStr = sharedPreferences.getString("user")!;
          Map<String, dynamic> userObj = jsonDecode(userStr);

          api.qRestApi("get", "/SmartdoorUserInvite/lists?name=${userObj['name']}&handphone=${userObj['handphone']}&smartdoor_id=${value['body']['smartdoor_id']}&isAll=1", {}, true).then((res) {
            int isOwner = 1;
            if(res['body']['total'] == "0") isOwner = 1;
            else isOwner = 0;

            api.qRestApi("post", "/SmartdoorUser", {"smartdoor_id":value['body']['smartdoor_id'],'user_id':userObj['user_id'],'isOwner':isOwner}, true).then((res1) async {
              if(res1['statusCode'] == 200) {
                sharedPreferences.setString("smartdoor", jsonEncode(value['body']));
                sharedPreferences.setString("smartdooruser", jsonEncode(res1['body']));
                Get.offAll(home_view());
              } else {
                snackbar(res['body']['message']);
              }
            });
          });
        }
      } else {
        snackbar(value['body']['message']);
      }
    });

    refresh();
  }

  void onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      //Get.back();
      /*ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR 코드 촬영 권한이 없습니다.')),
      );*/
    }
  }

  @override
  onInit() {
    print("qr_controller onInit");
    super.onInit();
  }

  @override
  onClose() {
    // 상태 리스터 해제
    qrcontroller?.dispose();
    super.onClose();
  }

  @override
  void onResumed() {
    print("qr_controller onResumed");
    // TODO: implement onResumed
  }
}