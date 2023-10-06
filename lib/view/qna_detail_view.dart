import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/controller/qna_controller.dart';
import 'package:wisemonster/view/nickname_view.dart';
import 'package:wisemonster/view/qna_edit_view.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/H2.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';
import 'package:wisemonster/view_model/camera_view_model.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'dart:io' as i;

import '../api/api_services.dart';
import '../controller/calendar_controller.dart';
import '../controller/camera_controller.dart';
import '../controller/notice_controller.dart';
import '../controller/profile_controller.dart';
import '../controller/notice_controller.dart';

class qna_detail_view extends GetView<QnaController> {
  // Build UI
  String userName = '';
  ApiServices api = ApiServices();
  var controller = Get.put(QnaController());
  @override
  Widget build(BuildContext context) {
    return Obx(() =>
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            appBar: AppBar(
                elevation: 0,
                centerTitle: true,
                backgroundColor: Color.fromARGB(255, 255, 255, 255),
                iconTheme: const IconThemeData(color: Color.fromARGB(255, 87, 132, 255)),
                title: Text(
                  '1:1 문의',
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
                            controller.deleteQna(Get.arguments);
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
                            Get.to(qna_edit_view(),arguments: Get.arguments);
                          },
                          child: Text(
                            '수정',
                            style: TextStyle(
                              fontSize: 17,
                              color: Color.fromARGB(255, 87, 132, 255),
                            ),
                          ))
                    ],
                  ),
                ]),
            body:controller.isclear.value? Container(
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
                      Container(
                        height: 20,
                      ),
                      Text('${controller.listData['lists'][Get.arguments]['title']}',
                        style: TextStyle(
                            fontSize: 18
                        ),
                      ),
                      Container(
                        height: 30,
                      ),
                      H1(
                        changeValue: '등록 날짜',
                        size: 14,
                      ),
                      Container(
                        height: 20,
                      ),
                      Text(
                          controller.listData['lists'][Get.arguments]['updateDate'] == null ? '' :DateFormat('yyyy년 MM월 dd일').format(DateTime.parse(controller.listData['lists'][Get.arguments]['updateDate'])),
                        style: TextStyle(
                          fontSize: 18
                        ),
                      ),
                      Container(
                        height: 30,
                      ),
                      H1(
                        changeValue: '내용',
                        size: 14,
                      ),
                      Container(
                        height: 20,
                      ),
                      Text('${controller.listData['lists'][Get.arguments]['comment']}'
                          ,style: TextStyle(
                            fontSize: 18
                        ),
                      ),
                      Container(
                        height: 30,
                      ),
                      H1(
                        changeValue: '답변',
                        size: 14,
                      ),
                      Container(
                        height: 20,
                      ),
                      controller.listData['lists'][Get.arguments]['memo'] == '' ?
                      Text('답변을 기다리고있습니다.', style: TextStyle(
                          fontSize: 18
                      ),):
                      Text('${controller.listData['lists'][Get.arguments]['memo']}', style: TextStyle(
                          fontSize: 18
                      ),),
                    ],
                  )),
            ) : Center(child: CircularProgressIndicator(),),
          ),
        )
    );
  }
}
