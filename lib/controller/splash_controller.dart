import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:wisemonster/view/registration1_view.dart';
import 'package:wisemonster/view/splash_view.dart';
import 'package:wisemonster/view/widgets/InitialWidget.dart';
import 'package:wisemonster/view/widgets/QuitWidget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:wisemonster/view/widgets/UpdateWidget.dart';

import '../main.dart';
import '../models/user_model.dart';

Future<ConnectivityResult> checkConnectionStatus() async {
  var result = await (Connectivity().checkConnectivity());
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

  return result;  // wifi, mobile
}

class SplashController extends GetxController {
  ApiServices api = ApiServices();
  String value = '';
  RxDouble progress = 0.0.obs;

  updateProgress() {
    const oneSec = Duration(seconds: 1);
    Timer.periodic(oneSec, (Timer t) {
      progress.value += 0.33;
      if (progress.toStringAsFixed(1) == '0.99') {
        t.cancel();
        return;
      }
      update();
    });
  }

  Future<bool>getPermission()async{
    if(Platform.isIOS) {
      return Future.value(false);
    } else {
      Map<Permission, PermissionStatus>statuses = await [
        Permission.camera,
        Permission.location,
        Permission.microphone,
        //Permission.storage,
        Permission.photos,
        Permission.videos,
        Permission.audio,
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise].request();

      print("권한설정");
      print(statuses);

      if(statuses[Permission.camera]!.isGranted
          && statuses[Permission.location]!.isGranted
          && statuses[Permission.microphone]!.isGranted
          && statuses[Permission.photos]!.isGranted
          && statuses[Permission.videos]!.isGranted
          && statuses[Permission.audio]!.isGranted
      ) {
        return Future.value(true);
      } else {
        return Future.value(false);
      }
    }
  }

  Future<String> _getAndroidStoreVersion(PackageInfo packageInfo) async {
    print('안드로이드 버전 호출');
    final id = packageInfo.packageName;
    final uri =
    Uri.parse("https://play.google.com/store/apps/details?id=${id}");
    final response = await http.get(uri);
    //print('${response.body} : 바디');
    if (response.statusCode != 200) {
      debugPrint('Can\'t find an app in the Play Store with the id: $id');
      return "";
    }
    final document = json.decode(response.body);
    final elements = document.getElementsByClassName('hAyfc');
    final versionElement = elements.firstWhere(
          (elm) => elm.querySelector('.BgcNfc').text == 'Current Version',
    );
    return versionElement.querySelector('.htlgb').text;
  }

  Future<dynamic> _getiOSStoreVersion(PackageInfo packageInfo) async {
    final id = packageInfo.packageName;

    final parameters = {"bundleId": "$id"};

    var uri = Uri.https("itunes.apple.com", "/lookup", parameters);
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      debugPrint('Can\'t find an app in the App Store with the id: $id');
      return "";
    }

    final jsonObj = json.decode(response.body);

    /* 일반 print에서 일정 길이 이상의 문자열이 들어왔을 때,
     해당 길이만큼 문자열이 출력된 후 나머지 문자열은 잘린다.
     debugPrint의 경우 일반 print와 달리 잘리지 않고 여러 행의 문자열 형태로 출력된다. */

    // debugPrint(response.body.toString());
    return jsonObj['results'][0]['version'];
  }

  String getStoreUrlValue(String packageName, String appName) {
    if (Platform.isAndroid) {
      return "https://play.google.com/store/apps/details?id=$packageName";
    } else if (Platform.isIOS)
      return "http://apps.apple.com/kr/app/$appName/id1622131384";
    else
      return '';
  }

  addPref(String key, String value ) async {
    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.setString(key, value);
  }

  //jwt decode
  String decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  void snackbar(String msg) {
    Get.snackbar(
      '알림',
      msg,
      duration: const Duration(seconds: 5),
      backgroundColor: const Color.fromARGB(255, 39, 161, 220),
      icon: const Icon(Icons.info_outline, color: Colors.white),
      forwardAnimationCurve: Curves.easeOutBack,
      colorText: Colors.white,
    );
  }

  @override
  Future<void> onInit() async {
    print('스플래쉬 진입구간');
    var result = await checkConnectionStatus();
    if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      print(Platform.isAndroid.toString());
      var storeVersion = Platform.isAndroid ? await _getAndroidStoreVersion(packageInfo) : Platform.isIOS ? await _getiOSStoreVersion(packageInfo) : "";

      print('my device version : ${packageInfo.version}');
      print('current store version: ${storeVersion.toString()}');
      if (storeVersion.toString().compareTo(packageInfo.version) != 0 && storeVersion.toString().compareTo("") != 0) await Get.dialog(UpdateWidget());

      getPermission().then((value) async {
        print("카메라등 권한 : ${value}");
        /*
        if(!value) {
          Get.dialog(InitialWidget(serverMsg: '권한 설정을 안하시면 일부 서비스에 제한이 있을 수 있습니다.',));
        } else {
          main();
        }
        */
        main();
      });
    }
    super.onInit();
  }

  void main() async {
    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
    updateProgress();

    //저장소에 저장된 토큰 가져오기
    String? token = _sharedPreferences.getString('token');
    String? userStr = _sharedPreferences.getString('user');
    //print("토큰 : ${token}");
    //print("userstr : ${userStr} ${userStr.runtimeType}");
    //token = null;

    if(token == null || token == '' || token.startsWith('\{') || token.startsWith('\[')) {
      Timer(const Duration(seconds: 3), () =>Get.offAll(() => login_view()) );
    } else {
      Map<String, dynamic> userObj = {"user_id":0};

      try{
        //토큰 분리
        List jwt = token!.split('.');

        //유효한 토큰
        if (jwt.length == 3) {
          print("토큰 데이터 : ${jwt[1]}");
          Map<String, dynamic> jsonData = json.decode(decodeBase64(jwt[1]));
          print("jsonData : ${jsonData}");

          var unixTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          print("유효기간 : ${jsonData['exp']} 현재시간 ${unixTimestamp}");

          if(jsonData['exp'] < unixTimestamp) {
            print("유효기간 초과로 재로그인 이동");
            Get.offAll(() => login_view());
            return;
          }

          userObj['user_id'] = int.parse(jsonData['user_id']);
          //print(userObj);
        } else {
          Get.offAll(() => login_view());
          return;
        }
      } catch (e) {
        print(e);
        Get.back();
        snackbar('에러발생! 관리자에게 문의해주세요 (원인 : ${e})');
      }

      try{
        print('firebase fcm 토큰 업데이트');
        var fcmToken = await FirebaseMessaging.instance.getToken();
        print("FCM token : ${fcmToken}");

        api.qRestApi("put", "/User/${userObj['user_id']}", {"fcm_token": "${fcmToken}"}, true).then((res) async {
          if(res['statusCode'] == 200) {
            addPref('user', jsonEncode(res['body']));
          } else snackbar(res['body']['message']);
        });
      } catch (e) {
        print(e);
        snackbar('에러발생! 관리자에게 문의해주세요 (원인 : ${e})');
      }

      try {
        api.qRestApi("GET", "/Smartdoor/me", {}, true).then((res) async {
          print('스마트도어 조회');
          if (res['statusCode'] == 200) {
            addPref('smartdoor', jsonEncode(res['body']));

            try {
              api.qRestApi("GET", "/SmartdoorUser/me", {}, true).then((res1) async {
                print('스마트도어사용자 조회');
                if(res1['statusCode'] == 200) {
                  addPref('smartdooruser', jsonEncode(res1['body']));
                  update();
                  Timer(const Duration(seconds: 3), () => Get.offAll(() => home_view()));
                } else snackbar(res1['body']['message']);
              });
            } catch (e) {
              print(e);
              snackbar('에러발생! 관리자에게 문의해주세요 (원인 : ${e} )');
            }
          } else if (res['body']['code'] == "/Smartdoor/me/1") {
            //로그인이 안되어 있는 경우 로그인 페이지로 이동
            Get.offAll(() => login_view());
          } else if (res['body']['code'] == "/Smartdoor/me/2" || res['body']['code'] == "/Smartdoor/me/3") {
            //등록되지 않은 오너 정보면 오너 등록 페이지로 이동
            Get.offAll(() => registration1_view());
          } else {
            snackbar(res['body']['message']);
          }
        });
      } catch (e) {
        print(e);
        snackbar('에러발생! 관리자에게 문의해주세요 (원인 : ${e} )');
      }
    }
  }
}
