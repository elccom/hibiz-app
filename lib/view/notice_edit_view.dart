import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'calendar_view.dart';

class notice_edit_view extends GetView<EditController> {
  // Build UI
  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditController>(
        init: EditController(),
        builder: (EditController) =>
            MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                appBar: AppBar(
                    elevation: 0,
                    centerTitle: true,
                    backgroundColor: Color.fromARGB(255, 255, 255, 255),
                    iconTheme: const IconThemeData(color: Color.fromARGB(255, 87, 132, 255)),
                    title: Text(
                      '공지 수정',
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
                      Row(
                        children: [
                          TextButton(
                              onPressed: () {
                                EditController.deleteNotice();
                              },
                              child: Text(
                                '삭제',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.red,
                                ),
                              )),
                          TextButton(
                              onPressed: () {
                                EditController.editNotice();
                              },
                              child: Text(
                                '완료',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Color.fromARGB(255, 87, 132, 255),
                                ),
                              ))
                        ],
                      ),
                    ]),
                body:EditController.isclear ? Container(
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                  width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width,
                  //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
                  height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height - 50,
                  color: Colors.white,
                  child: SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      H1(
                        changeValue: '글 제목',
                        size: 14,
                      ),
                      TextField(
                          controller: EditController.titleController, //set id controller
                          style: const TextStyle(
                              color: Color.fromARGB(255, 43, 43, 43), fontSize: 17),
                          decoration: InputDecoration(
                            hintText: '${EditController.detailData['title']}',
                            hintStyle: TextStyle(
                                fontSize: 17,
                                color: Color.fromARGB(255, 222, 222, 222)
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Color.fromARGB(255, 43, 43, 43))),
                          ),
                          onChanged: (value) {
                            //변화된 id값 감지
                            EditController.title = value;

                          }),
                    ],
                  )),
                ) : Center(child: CircularProgressIndicator(),),
              ),
            ))
    ;
  }
}
class EditController extends GetxController{
  ApiServices api = ApiServices();
  var titleController = TextEditingController();
  String title = '';
  var con = Get.put(CalendarController());
  bool isclear = false;
  Map<String, dynamic> detailData = {};

  @override
  void onInit() {
    print('공지');
    readNotice();
    update();
    super.onInit();
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

  readNotice(){
    print("read notice : ${Get.arguments}");

    api.qRestApi("get", "/SmartdoorNotice/${Get.arguments}", {}, true).then((res) {
      if(res['statusCode'] == 200) {
        isclear = true;
        detailData = res['body'];
        print('달력업데이트');
        update();
      } else if(res['statusCode'] == 401) {
        Get.offAll(login_view());
        snackbar(res['body']['message']);
      } else {
        snackbar(res['body']['message']);
      }
    });
  }

  editNotice() {
    api.qRestApi("put", '/SmartdoorNotice/${Get.arguments}', {'title':titleController.text.trim()}, true).then((res) async {
      if(res['statusCode'] == 200) {
        con.readToday();
        dialog('수정되었습니다.');
      } else if(res['statusCode'] == 401) {
        Get.offAll(login_view());
        snackbar(res['body']['message']);
      } else {
        snackbar(res['body']['message']);
      }
    });
  }

  deleteNotice() {
    api.qRestApi("delete", "/SmartdoorNotice/${Get.arguments}", {}, true).then((res) {
      if(res['statusCode'] == 200) {
        con.readToday();
        dialog('삭제가 완료되었습니다.');
      } else if(res['statusCode'] == 401) {
        Get.offAll(login_view());
        snackbar(res['body']['message']);
      } else {
        snackbar(res['body']['message']);
      }

    });

  }
}
