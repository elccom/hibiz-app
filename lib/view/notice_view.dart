import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view/notice_plus_view.dart';
import 'package:wisemonster/view/widgets/CalendarWidget.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/LeftSlideWidget.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import '../controller/calendar_controller.dart';
import 'dart:io' as i;

import '../controller/notice_controller.dart';
import '../controller/notice_controller.dart';
import 'calendar_plus_view.dart';
import 'key_view.dart';
import 'notice_edit_view.dart';

class notice_view extends GetView<NoticeController> {
  final controller = Get.put(NoticeController());
  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 87, 132, 255)),
        centerTitle: true,
        title: Text(
          '공지사항',
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
        actions: [
          TextButton(
              onPressed: (){
                Get.to(() => notice_plus_view());
              },
              child: Text(
                '추가',
                style: TextStyle(
                  fontSize: 17,
                  color: Color.fromARGB(255, 87, 132, 255),
                ),
              ))
        ],
      ),
      body:
      controller.isclear.value?
      Container(
        margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
        width: MediaQueryData
            .fromWindow(WidgetsBinding.instance!.window)
            .size
            .width - 32,
        height: MediaQueryData
            .fromWindow(WidgetsBinding.instance!.window)
            .size
            .height,
        child: Column(
          children: [
            // CalendarWidget(),
            Container(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('등록된 글 수 : ${controller.listData?.length}개',style: TextStyle(
                    color: Colors.red
                )),
              ],
            ),
            Expanded(
                child:Column(
                  children: [
                    Container(height: 20,),
                    Expanded(
                      flex: 1,
                      child: ListView.builder(

                        itemCount:
                        controller.listData['lists'].length == 0 ? 0 :
                        controller.listData['lists'].length
                        ,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                              margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                              color: Color.fromARGB(255, 255, 255, 255),
                              child:
                              // new Text(ProfileController.Tagdata![1]),
                              ListTile(
                                contentPadding: EdgeInsets.only(right: 10 ),
                                leading: Container(
                                  width: 6,
                                  color: Colors.red,
                                ),
                                title: Text(controller.listData[index]['title']),
                                subtitle: Text(controller.listData[index]['comment']),
                                trailing: Text(DateFormat('yyyy년 MM월 dd일').format(DateTime.parse(controller.listData[index]['updateDate']))),
                                onTap: (){
                                  print(controller.listData[index]['title']);
                                  print(index);
                                  print('kkkkkkkkk');
                                  Get.to(notice_edit_view(),arguments: index-1);
                                },
                              )
                          );
                        },
                      ),
                    ),
                    Container(height: 58,),
                  ],
                )
            ),
          ],
        ),
      ):Center(child: CircularProgressIndicator(),),

    ))
    ;
  }
}