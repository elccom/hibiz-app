import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/controller/qna_controller.dart';
import 'package:wisemonster/view/nickname_view.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';
import 'package:wisemonster/view_model/camera_view_model.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'dart:io' as i;

import '../api/api_services.dart';
import '../controller/calendar_controller.dart';
import '../controller/camera_controller.dart';
import '../controller/profile_controller.dart';

class qna_plus_view extends GetView<QnaController> {
  // Build UI
  String userName = '';
  ApiServices api = ApiServices();



  @override
  Widget build(BuildContext context) {
    return GetBuilder<QnaController>(
        init: QnaController(),
        builder: (QnaController) => MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                appBar: AppBar(
                    elevation: 0,
                    centerTitle: true,
                    backgroundColor: Color.fromARGB(255, 255, 255, 255),
                    iconTheme: const IconThemeData(color: Color.fromARGB(255, 87, 132, 255)),
                    title: Text(
                      '1:1문의',
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
                            QnaController.requestSend();
                          },
                          child: Text(
                            '등록',
                            style: TextStyle(
                              fontSize: 17,
                              color: Color.fromARGB(255, 87, 132, 255),
                            ),
                          ))
                    ]),
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
                        changeValue: '제목',
                        size: 14,
                      ),
                      TextFieldWidget(
                        tcontroller: QnaController.titleController,
                        changeValue: QnaController.title,
                        hintText: '제목을 입력해주세요.',
                      ),
                      Container(
                        height: 30,
                      ),
                      H1(
                        changeValue: '문의 내용',
                        size: 14,
                      ),
                      Container(
                        height: 30,
                      ),
                      TextField(
                        controller: QnaController.commentController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 4,

                      )
                    ],
                  )),
                ),
              ),
            ));
  }
}
