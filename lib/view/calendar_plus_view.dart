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
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';
import 'package:wisemonster/view_model/camera_view_model.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'dart:io' as i;

import '../api/api_services.dart';
import '../controller/calendar_controller.dart';
import '../controller/camera_controller.dart';
import '../controller/profile_controller.dart';
import 'calendar_view.dart';

class calendar_plus_view extends GetView<PlusController> {
  // Build UI
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlusController>(
        init: PlusController(),
        builder: (PlusController) => MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                appBar: AppBar(
                    elevation: 0,
                    centerTitle: true,
                    backgroundColor: Color.fromARGB(255, 255, 255, 255),
                    iconTheme: const IconThemeData(color: Color.fromARGB(255, 87, 132, 255)),
                    title: Text(
                      '일정 등록',
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
                            PlusController.sendSchedule(Get.arguments);
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
                        changeValue: '일정 내용',
                        size: 14,
                      ),
                      TextFieldWidget(
                        tcontroller: PlusController.nameController,
                        changeValue: PlusController.name,
                        hintText:'일정 내용을 입력해주세요.',
                      ),
                      Container(
                        height: 30,
                      ),
                      H1(
                        changeValue: '일정 날짜',
                        size: 14,
                      ),
                      TextField(
                        controller: PlusController.ddayController, //editing controller of this TextField
                        decoration: InputDecoration(
                            icon: Icon(Icons.calendar_month_outlined), //icon of text field
                            labelText:  "일정 날짜를 선택해주세요."
                            ),
                        readOnly: true, //set it true, so that user will not able to edit text
                        onTap: () async {
                          PlusController.pickedStartDate = (await showDatePicker(
                              initialEntryMode: DatePickerEntryMode.calendarOnly,
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                              lastDate: DateTime(2101)))!;
                          PlusController.selectDate(0);
                        },
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

  DateTime? pickedStartDate;
  var nameController = TextEditingController();
  var ddayController = TextEditingController();

  String name = '';
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

  sendSchedule(argument) {
    if(nameController.text != null&&ddayController.isBlank != null){
      if(pickedStartDate == null) pickedStartDate = DateTime.now();

      api.qRestApi("post", "/SmartdoorSchedule", {'name':nameController.text.trim(),'dday':DateFormat('yyyy-MM-dd HH:mm:ss').format(pickedStartDate!)}, true).then((res) async {
        if(res['statusCode'] == 200) {
          con.readToday();
          dialog('스케줄이 등록되었습니다.');
        } else if(res['statusCode'] == 401) {
          Get.offAll(login_view());
          snackbar(res['body']['message']);
        } else {
          snackbar(res['body']['message']);
        }
      });
    } else {
      snackbar('미완료된 설정이 있습니다. 전부 설정해주세요.');
    }
  }

  selectDate(type) {
    if(pickedStartDate != null && type == 0){
      print("selectDate : ${pickedStartDate}");
      String formattedDate = DateFormat('yyyy년 MM월 dd일').format(pickedStartDate!);
      print(formattedDate);
      ddayController.text = formattedDate; //set output date to TextField value.
      update();
    } else {
      snackbar('날짜가 선택되지 않았습니다.');
    }
  }
}
