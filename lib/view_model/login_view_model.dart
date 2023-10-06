import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/models/user_model.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:http/http.dart' as http;
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/widgets/AlertWidget.dart';
import 'package:wisemonster/view/widgets/QuitWidget.dart';
import 'package:wisemonster/view_model/home_view_model.dart';

import '../view/registration1_view.dart';
import '../view/registration2_view.dart';

// 어떤 상태인지 열거

enum UserEnums {Logout, Error, Initial , Waiting}

class LoginViewModel extends GetxController{

  ApiServices api = ApiServices();

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  late SharedPreferences _sharedPreferences;

  UserEnums userEnums = UserEnums.Initial;
  bool passwordVisible = false;
  late UserModel user;
  String errmsg = '';
  bool error = false;
  var product_sncode;

  void logoutProcess() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    await _sharedPreferences.remove('token');
    await _sharedPreferences.remove('pictureUrl');
    print('로그아웃');
    // await Get.deleteAll(force: true); //deleting all controllers
    Phoenix.rebirth(Get.context!); // Restarting app
    Get.reset(); // resetting getx
  }

  changeObscure() {
    if(passwordVisible == true){
      passwordVisible = false;
    } else if(passwordVisible == false){
      passwordVisible = true;
    }
    print(passwordVisible);
    update();
  }
  //
  // autoLogin() {
  //   if(isAuto.value == true){
  //     isAuto.value = false;
  //   } else if(isAuto.value == false){
  //     isAuto.value = true;
  //   }
  //   print(isAuto);
  // }


  // 내부저장소(Preference에 값추가)
  addPref(String key, String value ) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.setString(key, value);
  }

  //로그인처리
  void login(apiId, apiPassword) {
    print('로그인 실행');

    api.qRestApi("post", "/User/login", {"id":apiId.text.trim(),"passwd":apiPassword.text.trim()}, false).then((value) async {
    //api.restapi(jsonData).then((res) async {
        print("로그인 결과");

        int user_id = 0;

        if(value['statusCode'] == 200){
          var user;

          try{
            String token = value['body']['token'];
            addPref('token', token);
            print('토큰 : ${token}');

            // List jwt = _decodeBase64(value['token']).replaceAll('}.', '}/!').split('/!');
            List jwt = token.split('.');
            Map<String, dynamic> tokenObj = json.decode(_decodeBase64(jwt[1]));
            print('토큰 사용자 정보 : ${tokenObj}');
            user_id = int.parse(tokenObj['user_id']);
            print('일반 로그인');
          } catch (e) {
            print(e);
            Get.back();
            snackbar('에러발생! 관리자에게 문의해주세요 (원인 : json파싱에러)');
          }

          //Fcm token 업데이트
          try {
            print('firebase fcm 토큰 받기');
            String? fcmToken = await FirebaseMessaging.instance.getToken();
            print("fcm Token : ${fcmToken}");

            api.qRestApi("PUT", "/User/${user_id}", {"fcm_token": "${fcmToken}"}, true).then((res) async {
              if(res['statusCode'] == 200) {
                addPref('user', jsonEncode(res['body']));
                print("fcm 토큰 저장 완료");
              } else snackbar(res['body']['message']);
            });
          } catch (e) {
            print(e);
            Get.back();
            snackbar('에러발생! 관리자에게 문의해주세요 (원인 : firebase fcm토큰발급)');
          }

          //스마트도어정보 업데이트
          try{
            api.qRestApi("get", "/Smartdoor/me", {}, true).then((res) async {
              print(res);
              if(res['statusCode'] == 200) {
                //print(user.smartdoor_id);
                addPref('smartdoor', jsonEncode(res['body']));
                print('스마트도어 조회 성공');
                update();
                Get.offAll(() => home_view());
              } else if(res['body']['code'] == "/Smartdoor/me/2" || res['code'] == "/Smartdoor/me/3"){
                Get.offAll(() => registration1_view());
              } else {
                snackbar(res['body']['message']);
              }
            });
          } catch (e) {
            print(e);
            Get.back();
            snackbar('에러발생! 관리자에게 문의해주세요 (원인 : 스마트도어 정보 가져오기 실패)');
          }
        } else {
          Get.back();
          snackbar(value['body']['message']);
        }
      });
  }

  //스낵바
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

  //base64 decode
  String _decodeBase64(String str) {
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

  // Future<void> kakaoLoginButtonPressed() async {
  //   final clientState = const Uuid().v4();
  //   final url = Uri.https('kauth.kakao.com', '/oauth/authorize', {
  //     'response_type': 'code',
  //     'client_id': '66bae9d5fcdbfb877a8a74edabc18f7a',
  //     'redirect_uri': 'https://www.watchbook.tv/oauth/kakao',
  //     'state': clientState,
  //   });
  //   final result = await FlutterWebAuth.authenticate(
  //       url: url.toString(), callbackUrlScheme: "webauthcallback");
  //   final body = Uri.parse(result).queryParameters;
  //   print(body);
  // }
  //
  // Future<void> naverLoginButtonPressed() async {
  //   final clientState = const Uuid().v4();
  //   final authUri = Uri.https('nid.naver.com', '/oauth2.0/authorize', {
  //     'response_type': 'code',
  //     'client_id': 'C_TAVu2tex3Yjadne2IQ',
  //     'response_mode': 'form_post',
  //     'redirect_uri': 'https://www.watchbook.tv/oauth/naver',
  //     'state': clientState,
  //   });
  //   final authResponse = await FlutterWebAuth.authenticate(
  //       url: authUri.toString(), callbackUrlScheme: "webauthcallback");
  //   final code = Uri.parse(authResponse).queryParameters['code'];
  //   final tokenUri = Uri.https('nid.naver.com', '/oauth2.0/token', {
  //     'grant_type': 'authorization_code',
  //     'client_id': 'C_TAVu2tex3Yjadne2IQ',
  //     'client_secret': 'Z3ymBZN2Rd',
  //     'code': code,
  //     'state': clientState,
  //   });
  //   var tokenResult = await http.post(tokenUri);
  //   final accessToken = json.decode(tokenResult.body)['access_token'];
  //   final response = await http.get(Uri.parse(
  //       'https://www.watchbook.tv/oauth/naver/token?accessToken=$accessToken'));
  // }
  //
  // Future<void> facebookLoginButtonPressed() async {
  //   final LoginResult result = await FacebookAuth.instance
  //       .login();
  //   // by default we request the email and the public profile
  //   // or FacebookAuth.i.login()
  //   if (result.status == LoginStatus.success) {
  //     // you are logged
  //     final AccessToken accessToken = result.accessToken!;
  //   } else {
  //     print(result.status);
  //     print(result.message);
  //   }
  // }

  @override
  void onInit() {

    print('로그인 진입구간');
    super.onInit();
  }
  @override
  void onClose() {
    print('로그인 다운');
    super.onClose();
  }
}