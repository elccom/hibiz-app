import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wisemonster/view/calendar_view.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../api/api_services.dart';
import '../models/mqtt.dart';
import '../view/widgets/SnackBarWidget.dart';
import 'package:intl/intl.dart';

class CalendarController extends GetxController{
  ApiServices api = ApiServices();

  Map<String, dynamic> detailData = {"total": 0, "totalPages": 0, "page": 1, "rowsPerPage": 10, "sort": "a_smartdoor_item_id", "desc": "desc", "keyword": "", "lists": []};
  Map<String, dynamic> noticeData = {"total": 0, "totalPages": 0, "page": 1, "rowsPerPage": 10, "sort": "a_smartdoor_item_id", "desc": "desc", "keyword": "", "lists": []};

  bool isclear = false;

  var nameController = TextEditingController();
  var ddayController = TextEditingController();

  var home = Get.put(HomeViewModel());

  Map<String, dynamic> smartdoorObj = {};

  String title = '';
  String place = '';
  String comment = '';

  DateTime? roadDate;
  DateTime? pickedStartDate;
  DateTime? pickedEndDate;

  late Future<TimeOfDay?> selectedStartTime ;
  late Future<TimeOfDay?> selectedEndTime ;

  List<String> valueList = ['상', '중' ,'하'];
  var selectValue = '상';

  int index = 0;
  // Mqtt mqtt = new Mqtt();

  Map<DateTime, List<Event>> events = {};

  //초기화
  @override
  void onInit() async{
    print(DateFormat('yyyy-MM-dd').format(DateTime.now()));
    if(index == null) index = 0;
    //오늘
    readToday();
    sleep(Duration(milliseconds: 200));
    super.onInit();
  }

  @override
  void onClose() {
    ddayController.clear();
    ddayController.dispose();
    super.onClose();
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

  readToday(){
    print("Calendar readToday");
    detailData = {"total": 0, "totalPages": 0, "page": 1, "rowsPerPage": 10, "sort": "a_smartdoor_item_id", "desc": "desc", "keyword": "", "lists": []};
    events = {};

    api.qRestApi("get", "/SmartdoorSchedule/lists?startDate=${DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month, 1))}&stopDate=${DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month+1, 0))}", {}, true).then((res) {
      if(res['statusCode'] == 200) {
        detailData = res['body'];

        for(int i = 0; i < detailData['lists'].length; i++){
          print("${detailData['lists'][i]['dday']} : ${detailData['lists'][i]['name']}");

          events.addAll({DateTime.utc(
              DateTime.parse(detailData['lists'][i]['dday']).year,
              DateTime.parse(detailData['lists'][i]['dday']).month,
              DateTime.parse(detailData['lists'][i]['dday']).day
          ) : [Event('${detailData['lists'][i]['name']}')]});
        };

        print('달력업데이트');
        update();

        noticeData = {"total": 0, "totalPages": 0, "page": 1, "rowsPerPage": 10, "sort": "a_smartdoor_item_id", "desc": "desc", "keyword": "", "lists": []};

        api.qRestApi("get", "/SmartdoorNotice/lists", {}, true).then((res) {
          if(res['statusCode'] == 200) {
            isclear = true;
            noticeData = res['body'];
            update();
          } else if(res['statusCode'] == 401) {
            Get.offAll(login_view());
            snackbar(res['body']['message']);
          } else {
            snackbar(res['body']['message']);
          }
        });
      } else if(res['statusCode'] == 401) {
        Get.offAll(login_view());
        snackbar(res['body']['message']);
      } else {
        snackbar(res['body']['message']);
      }
    });
  }

  Rx<DateTime> selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ).obs;
  Rx<CalendarFormat> calendarFormat = CalendarFormat.month.obs;
  Rx<DateTime> focusedDay = DateTime.now().obs;
  // DateTime focusedDay2 = DateTime.now();

  selected(selectedDay2, focusedDay2){
    print("selected : ${selectedDay2} ${focusedDay2}");
    this.selectedDay.value = selectedDay2;
    this.focusedDay.value = focusedDay2;
    update();
  }

  focus(focusedDay) {
  }

  formatDate(){
  }

  dropdown(value){
    selectValue = value;
    update();
  }

  List<Event> roadEvent(DateTime day){
    print("roadEvent ${day} ${events[day]}");
    return events[day] ?? [];
  }

  // 날짜 선택
  selectDate(type) {
    if(pickedStartDate != null && type == 0){
      print("selectDate : ${pickedStartDate}");
      String formattedDate = DateFormat('yyyy년 MM월 dd일').format(pickedStartDate!);
      print(formattedDate);
      ddayController.text = formattedDate; //set output date to TextField value.
      update();
    } else {
      SnackBarWidget(serverMsg: '날자가 선택되지 않았습니다.',);
      print("Date is not selected");
    }
  }

  allUpdate(){
    update();
  }
}

class Event {
  String title;
  Event(this.title);
}