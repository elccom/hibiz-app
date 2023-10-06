import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wisemonster/view/calendar_edit_view.dart';
import 'package:wisemonster/view/notice_edit_view.dart';
import 'package:wisemonster/view/notice_plus_view.dart';
import 'package:wisemonster/view/widgets/CalendarWidget.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/LeftSlideWidget.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import '../controller/calendar_controller.dart';
import 'dart:io' as i;

import 'calendar_plus_view.dart';
import 'home_view.dart';
import 'key_view.dart';

class calendar_view extends GetView<CalendarController> {
  Map<DateTime, List<Event>> events = {
    DateTime.utc(2023,5,9) : [ Event('title'), Event('title2') ],
    DateTime.utc(2023,5,12) : [ Event('title3') ],
  };

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CalendarController>(
        init: CalendarController(),
        builder: (controller) =>

            Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Color.fromARGB(255, 255, 255, 255),
                iconTheme: const IconThemeData(color: Color.fromARGB(255, 87, 132, 255)),
                centerTitle: true,
                title: Text(
                  '캘린더',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 87, 132, 255),
                  ),
                ),
                  automaticallyImplyLeading: true,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_outlined),
                    onPressed: () {
                      Get.offAll(home_view());
                    },
                  ),
                // actions: [
                //   TextButton(
                //       onPressed: (){
                //         Get.to(calendar_plus_view(),arguments: 'create');
                //       },
                //       child: Text(
                //         '추가',
                //         style: TextStyle(
                //           fontSize: 17,
                //           color: Color.fromARGB(255, 87, 132, 255),
                //         ),
                //       ))
                // ],
              ),
              body: controller.isclear == false ? Center(child: CircularProgressIndicator(),) :Container(
                width: MediaQueryData
                    .fromWindow(WidgetsBinding.instance!.window)
                    .size
                    .width,
                height: MediaQueryData
                    .fromWindow(WidgetsBinding.instance!.window)
                    .size
                    .height,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // CalendarWidget(),
                      Obx(() => SizedBox(
                        height: 400,
                        child: TableCalendar(
                          eventLoader:
                          controller.roadEvent
                          //_getEventsForDay
                          ,
                          pageJumpingEnabled: false,
                          focusedDay: controller.focusedDay.value,
                          firstDay: DateTime(DateTime.now().year,DateTime.now().month,1),
                          lastDay: DateTime(DateTime.now().year,DateTime.now().month + 1, 0),
                          locale: 'ko-KR',
                          headerStyle: HeaderStyle(
                            headerMargin: EdgeInsets.all(10),
                            leftChevronVisible: false,
                            rightChevronVisible: false,
                            formatButtonShowsNext: true,
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
                          calendarStyle: CalendarStyle(
                            // tableBorder: TableBorder(
                            //   bottom: BorderSide(color: Color.fromARGB(255, 204, 204, 204)),
                            // ),
                              markerSize: 10.0,
                              markerDecoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle
                              ),
                              outsideDaysVisible: false,
                              todayDecoration: BoxDecoration(
                                color: Color.fromARGB(255, 18, 136, 248),
                                shape: BoxShape.circle,
                              ),
                              todayTextStyle: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                              selectedDecoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              )),
                          onDaySelected: (var selectedDay2,var focusedDay2) {
                            controller.selected(selectedDay2, focusedDay2);
                          },
                          // selectedDayPredicate: (day) {
                          //   // selectedDay 와 동일한 날짜의 모양을 바꿔줍니다.
                          //   return isSameDay(controller.selectedDay.value, day);
                          //
                          // },
                          onFormatChanged: (format){
                            if(controller.calendarFormat != format){
                              controller.calendarFormat = format.obs;
                            }
                          },
                          onPageChanged: (focusedDay) {
                            // No need to call `setState()` here
                            controller.focus(focusedDay);
                            print('포커스');
                          },
                        ),
                      )),
                      Container(
                        margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        height: 1,
                        color: Color.fromARGB(255, 204, 204, 204),
                      ),
                      Container(
                        width: MediaQueryData
                            .fromWindow(WidgetsBinding.instance!.window)
                            .size
                            .width,
                        height: 150,
                        margin: EdgeInsets.fromLTRB(16, 5, 16, 5),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                H1(changeValue: '스케줄', size: 17,),
                                IconButton(onPressed: (){
                                  Get.to(calendar_plus_view());
                                }, icon: Icon(
                                  Icons.add,
                                  color: Color.fromARGB(255, 87, 132, 255),
                                )),
                              ],
                            ),
                            Container(height: 20,),
                            Container(
                              height: 80,
                              child: ListView.builder(
                                itemCount:controller.detailData?['lists'].length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Card(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      child:
                                      // new Text(ProfileController.Tagdata![1]),
                                      ListTile(
                                        contentPadding: EdgeInsets.only(right: 10 ),
                                        leading: Container(
                                          width: 6,
                                          color: Colors.red,
                                        ),
                                        title: Text(controller.detailData['lists'][index]['name']),
                                        trailing: Text(DateFormat('MM월 dd일').format(DateTime.parse(controller.detailData['lists'][index]['dday']))),
                                        onTap: (){
                                          Get.to(calendar_edit_view(),arguments: index);
                                        },
                                      )
                                  );
                                },
                              ),
                            ),

                          ],
                        ),),

                      Container(
                        width: MediaQueryData
                            .fromWindow(WidgetsBinding.instance!.window)
                            .size
                            .width,
                        height: 150,
                        margin: EdgeInsets.fromLTRB(16, 5, 16, 5),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                H1(changeValue: '공지사항', size: 17,),
                                IconButton(onPressed: (){
                                  Get.to(notice_plus_view());
                                }, icon: Icon(
                                  Icons.add,
                                  color: Color.fromARGB(255, 87, 132, 255),
                                )),
                              ],
                            ),
                            Container(height: 20,),
                            Container(height: 80,
                              child: ListView.builder(
                                itemCount:controller.noticeData?['lists'].length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Card(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      child:
                                      // new Text(ProfileController.Tagdata![1]),
                                      ListTile(
                                        contentPadding: EdgeInsets.only(right: 10 ),
                                        leading: Container(
                                          width: 6,
                                          color: Colors.red,
                                        ),
                                        title: Text(controller.noticeData['lists'][index]['title']),
                                        onTap: (){
                                          print(controller.noticeData['lists'][index]['smartdoor_notice_id']);
                                          print('eeee');
                                          Get.to(notice_edit_view(),arguments: controller.noticeData['lists'][index]['smartdoor_notice_id']);
                                        },
                                      )
                                  );
                                },
                              ),
                            ),
                          ],
                        ),)
                    ],
                  ),
                ),
              ),
            )
    );
  }

}