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
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';
import 'package:wisemonster/view_model/camera_view_model.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'dart:io' as i;

import '../api/api_services.dart';
import '../controller/calendar_controller.dart';
import '../controller/camera_controller.dart';
import '../controller/profile_controller.dart';

class calendar_edit_view extends GetView<EditController> {
  // Build UI
  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditController>(
        init: EditController(),
        builder: (EditController) => MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                    elevation: 0,
                    centerTitle: true,
                    backgroundColor: Color.fromARGB(255, 255, 255, 255),
                    iconTheme: const IconThemeData(color: Color.fromARGB(255, 87, 132, 255)),
                    title: Text(
                      '일정 수정',
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
                                EditController.deleteSchedule(Get.arguments);
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
                                EditController.editSchedule(Get.arguments);
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
                body:
                EditController.isclear == false ? Center(child: CircularProgressIndicator(),) :
                Container(
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
                        changeValue: '일정 제목',
                        size: 14,
                      ),
                      TextFieldWidget(
                        tcontroller: EditController.nameController,
                        changeValue: EditController.name,
                        hintText: '${EditController.detailData['lists'][Get.arguments]['name']}',
                      ),
                      Container(
                        height: 30,
                      ),
                      H1(
                        changeValue: '수정할 날짜',
                        size: 14,
                      ),
                      TextField(
                        controller: EditController.ddayController, //editing controller of this TextField
                        decoration: InputDecoration(
                            icon: Icon(Icons.calendar_month_outlined), //icon of text field
                            labelText: '${DateFormat('yyyy년 MM월 dd일').format(DateTime.parse(EditController.detailData['lists'][Get.arguments]['dday']))}'
                        ),
                        readOnly: true, //set it true, so that user will not able to edit text
                        onTap: () async {
                          EditController.pickedStartDate = (await showDatePicker(
                              initialEntryMode: DatePickerEntryMode.calendarOnly,
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                              lastDate: DateTime(2101)))!;
                          EditController.selectDate(0);
                        },
                      ),
                    ],
                  )),
                ),
              ),
            ));
  }
}

class EditController extends GetxController{
  ApiServices api = ApiServices();

  Map<String, dynamic> detailData = {"total": 0, "totalPages": 0, "page": 1, "rowsPerPage": 10, "sort": "a_smartdoor_item_id", "desc": "desc", "keyword": "", "lists": []};
  Map<String, dynamic> listData = {"total": 0, "totalPages": 0, "page": 1, "rowsPerPage": 10, "sort": "a_smartdoor_item_id", "desc": "desc", "keyword": "", "lists": []};

  var nameController = TextEditingController();
  var ddayController = TextEditingController();

  String name = '';
  DateTime? pickedStartDate;

  bool isclear = false;

  var con = Get.put(CalendarController());

  @override
  void onInit() {
    print('달력편집');
    readToday();
    update();
    super.onInit();
  }

  void snackbar(msg) {
    if(Get.isDialogOpen != null && Get.isDialogOpen!) Get.back();

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

  readToday(){
    String startDate = DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, 1));
    String stopDate = DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month+1, 0));

    api.qRestApi("get", "/SmartdoorSchedule/lists?startDate=${startDate}&stopDate=${stopDate}", {}, true).then((res) {
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

  selectDate(type) {
    if(pickedStartDate != null && type == 0){
      print(pickedStartDate);
      String formattedDate = DateFormat('yyyy년 MM월 dd일').format(pickedStartDate!);
      print(formattedDate);
      ddayController.text = formattedDate; //set output date to TextField value.
      update();
    } else {
      snackbar('날짜가 선택되지 않았습니다.');
    }
  }

  deleteSchedule(argument) {
    print("일정 삭제 ${argument}");
    print(detailData['lists'][argument]['smartdoor_schedule_id']);

    api.qRestApi("delete", "/SmartdoorSchedule/${detailData['lists'][argument]['smartdoor_schedule_id']}", {}, true).then((res) async {
      if(res['statusCode'] == 200) {
        con.readToday();
        dialog('일정이 삭제되었습니다.');
      } else if(res['statusCode'] == 401) {
        Get.offAll(login_view());
      } else {
        snackbar(res['message']);
      }
    });
  }

  editSchedule(argument) {
    if(nameController.text != null && ddayController.isBlank != null){
      if(pickedStartDate == null){
        pickedStartDate = DateTime.parse(detailData['lists'][argument]['dday']);
        print("editSchedule pickedStartDate : ${pickedStartDate}");
      }

      String url = "/SmartdoorSchedule/${detailData['lists'][argument]['smartdoor_schedule_id']}";
      String name = nameController.text.trim();
      String dday = DateFormat('yyyy-MM-dd HH:mm:ss').format(pickedStartDate!);

      api.qRestApi("PUT", url, {"name":name,"dday":dday}, true).then((res) async {
        if(res['statusCode'] == 200) {
          con.readToday();
          dialog('일정이 수정되었습니다.');
        } else if(res['statusCode'] == 401) {
          Get.offAll(login_view());
        } else {
          snackbar(res['message']);
        }
      });
    } else {
      snackbar('미완료된 설정이 있습니다. 전부 설정해주세요.');
    }
  }
}
