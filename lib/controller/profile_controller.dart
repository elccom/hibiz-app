import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/profile_view.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:wisemonster/view/widgets/InitialWidget.dart';
import 'package:http/http.dart' as http;

class ProfileController extends GetxController with WidgetsBindingObserver {
  List<String> lifeCycle = [];
  var nicknameController = TextEditingController();
  var tagController = TextEditingController();
  Map<String, dynamic> userObj = {};
  Map<String, dynamic> smartdoorObj = {};
  Map<String, dynamic> listData = {"total": 0, "totalPages": 0, "page": 1, "rowsPerPage": 10, "sort": "a_smartdoor_item_id", "desc": "desc", "keyword": "", "lists": []};
  String nickname = '';
  String tag = '';
  ApiServices api = ApiServices();
  List? Tagdata;
  String readurl = ''; //리스트 값 얻을 서버 url 입력
  String deleteurl = '';
  String sendurl = '';
  bool isclear = false;

  final ImagePicker _picker = ImagePicker();
  File? image;
  String imageUrl = '';

  @override
  void onInit() async {
    requestTag();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? userStr = sharedPreferences.getString('user')!;
    userObj = jsonDecode(userStr);

    String? smartdoorStr = sharedPreferences.getString('smartdoor')!;
    smartdoorObj = jsonDecode(smartdoorStr);

    nickname =  userObj['nickname'];
    if(userObj.containsKey('picture') && userObj['picture'].containsKey('url')) imageUrl = userObj['picture']['url'];

    print("imageUrl : ${imageUrl}");
    update();
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void addPref(String key, String value ) async {
    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.setString(key, value);
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

  Future getImage() async {
    getPermission().then((value) async {
      print("카메라 사용 권한 : ${value}");

      if (!value)
        Get.dialog(
            InitialWidget(serverMsg: '카메라 사용 권한이 없습니다. 권한 설정 후 이용해 주세요.'));
      else {
        print('프로필 이미지업로드 getImage');
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        final XFile? pickImage = await _picker.pickImage(source: ImageSource.gallery);
        if (pickImage != null){
          image = File(pickImage.path);
          final bytes = image?.readAsBytesSync();
          String base64Image =  "data:image/png;base64," + base64Encode(bytes!);
          print(base64Image);
          api.qRestApi("post", "/User/pictureUpload", {"file":base64Image}, true).then((value){
            print('프로필 이미지업로드 결과');
            print(value);

            if (value['statusCode'] == 200) {
              api.qRestApi("get", "/User/me", {}, true).then((res) {
                if (res['statusCode'] == 200) {
                  snackbar('사진 등록이 완료되었습니다.');
                  addPref("user", jsonEncode(res['body']));
                  imageUrl =  '${res['body']['picture']['url']}?ver=${DateTime.now().toString()}';
                  print("imageUrl : ${imageUrl}");
                  update();
                  Get.offAll(profile_view());
                } else {
                  snackbar(res['body']['message']);
                }
              });
            } else {
              snackbar(value['body']['message']);
            }
          });
          update();
        }
      }
    });
  }

  requestTag(){
    print('프로필조회구간');
    api.qRestApi("get", "/SmartdoorItem/lists", {}, true).then((res) {
      if (res['statusCode'] == 200) {
        listData = res['body'];
        isclear = true;
      } else {
        snackbar(res['body']['message']);
      }
      update();
    });
  }

  void sendNickname() {
    api.qRestApi("post", "/User/nickname", {"nickname": nicknameController.text.trim()}, true).then((res) async {
      if(res['statusCode'] == 200) {
        snackbar('닉네임이 변경되었습니다.');
        nickname = nicknameController.text.trim();
        userObj['nickname'] = nickname;
        addPref("user", jsonEncode(userObj));
        update();
        Get.offAll(profile_view());
      } else {
        snackbar(res['body']['message']);
      }
    });
  }

  //소지품등록
  void sendTag() async {
    print("소지품등록 sendTag");

    api.qRestApi("post", "/SmartdoorItem", {"nickname": nicknameController.text.trim(), "name": tagController.text.trim()}, true).then((res) async {
      if(res['statusCode'] == 200) {
        snackbar('소지품 등록이 완료되었습니다.');
        requestTag();
        update();
        Get.offAll(profile_view());
      } else {
        snackbar(res['body']['message']);
      }
    });
  }

  //소지품삭제
  void deleteTag(index) {
    print("소지품삭제 deleteTag ${index}");

    String smartdoor_item_id = listData['lists'][index]['smartdoor_item_id'];
    print('smartdoor_item_id : ${smartdoor_item_id}');

    api.qRestApi("delete", "/SmartdoorItem/${smartdoor_item_id}", {}, true).then((res) async {
      if(res['statusCode'] == 200) {
        snackbar('소지품 삭제가 완료되었습니다.');
        requestTag();
        update();
        Get.offAll(profile_view());
      } else {
        snackbar(res['body']['message']);
      }
    });
  }

  //권한검사
  Future<bool>getPermission()async{
    if(Platform.isIOS) {
      return Future.value(false);
    } else {
      Map<Permission, PermissionStatus>statuses = await [Permission.camera].request();

      print("카메라 권한설정");
      print(statuses);

      if(statuses[Permission.camera]!.isGranted) {
        return Future.value(true);
      } else {
        return Future.value(false);
      }
    }
  }


}