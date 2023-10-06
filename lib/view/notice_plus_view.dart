import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/view/calendar_view.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/nickname_view.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';
import 'package:wisemonster/view_model/camera_view_model.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'dart:io' as i;

import '../api/api_services.dart';
import '../controller/calendar_controller.dart';

class notice_plus_view extends GetView<PlusController> {
  // Build UI
  Map<String, dynamic> userObj = {};
  String userName = '';
  ApiServices api = ApiServices();
  getName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? userStr = sharedPreferences.getString('user')!;
    userObj = jsonDecode(userStr);

    userName = userObj['name'];
    print('회원이름 호출');
    print(userName);
    return await userName;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlusController>(
        init: PlusController(),
        builder: (PlusController) => MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                    elevation: 0,
                    centerTitle: true,
                    backgroundColor: Color.fromARGB(255, 255, 255, 255),
                    iconTheme: const IconThemeData(color: Color.fromARGB(255, 87, 132, 255)),
                    title: Text(
                      '공지 등록',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 87, 132, 255),
                      ),
                    ),
                    automaticallyImplyLeading: true,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_outlined),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            PlusController.sendNotice();
                          },
                          child: Text(
                            '등록',
                            style: TextStyle(
                              fontSize: 17,
                              color: Color.fromARGB(255, 87, 132, 255),
                            ),
                          ))]

                    ),
                body: Container(
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                  width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width,
                  //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
                  height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height - 50,
                  color: Colors.white,
                  child: SingleChildScrollView(
                      physics: ClampingScrollPhysics(),
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      H1(
                        changeValue: '글 제목',
                        size: 14,
                      ),
                      TextFieldWidget(
                        tcontroller:PlusController.titleController,
                        changeValue: PlusController.title,
                        hintText:
                        '제목을 입력해주세요.'
                            ,
                      ),
                      Container(
                        height: 30,
                      ),
                    ],
                  )),
                ),
              ),
            ));
  }
}
class PlusController extends GetxController{
  ApiServices api = ApiServices();
  var titleController = TextEditingController();
  String title = '';
  var con = Get.put(CalendarController());

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

  void dialog(String msg) {
    Get.dialog(
      AlertDialog(
        title: Text('알림'),
        content: Text(msg),
        actions: [
          TextButton(
            child: const Text("닫기"),
            onPressed: () => Get.offAll(calendar_view()),
          ),
        ],
      ),
    );
  }

  sendNotice() {
    api.qRestApi("POST", "/SmartdoorNotice", {'title':titleController.text.trim()}, true).then((res) async {
      if(res['statusCode'] == 200) {
        //refresh();
        //titleController.clear();
        //Get.back();
        con.readToday();
        dialog('작성되었습니다.');
      } else if(res['statusCode'] == 401) {
        Get.offAll(login_view());
        snackbar(res['body']['message']);
      } else {
        snackbar(res['body']['message']);
      }
    });
    /*
    api.post(json.encode({'title':titleController.text.trim()}), '/SmartdoorNotice').then((value) async {
      if(value.statusCode == 200) {
        refresh();
        titleController.clear();
        Get.back();
        con.readToday();
        Get.snackbar(
          '알림',
          '작성되었습니다.'
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
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

     */
  }
}
