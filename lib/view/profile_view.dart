import 'dart:convert';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view/nickname_view.dart';
import 'package:wisemonster/view/tagplus_view.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';
import 'package:wisemonster/view_model/camera_view_model.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'dart:io' as i;

import '../controller/camera_controller.dart';
import '../controller/profile_controller.dart';

class profile_view extends GetView<ProfileController> {
  // Build UI

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      init: ProfileController(),
      builder: (ProfileController) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            resizeToAvoidBottomInset : false,
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              iconTheme: const IconThemeData(color: Color.fromARGB(255, 87, 132, 255)),
              title: Text(
                '내 프로필',
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
            ),
            body:
            ProfileController.isclear == false ? Center(child: CircularProgressIndicator(),) :
            Container(
                padding: const EdgeInsets.fromLTRB(30, 40, 30, 16),
                width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width,
                //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
                height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height - 56,
                color: Colors.white,
                child: SingleChildScrollView(
                    child: Column(
                        children: [
                      Container(
                        height: 270,
                        color: Color.fromARGB(255, 255, 255, 255),
                        child: Column(
                          children: [
                            TextButton(
                              onPressed: () {
                                ProfileController.getImage();
                              },
                              child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromARGB(255, 161, 161, 161),
                                  ),
                                  child:
                                  ProfileController.imageUrl != '' || ProfileController.imageUrl != null
                                      ? CircleAvatar(
                                      backgroundImage: Image.network('https://api.hizib.wikibox.kr${ProfileController.imageUrl}').image
                                  )
                                      :
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 30,
                                  )),
                            ),
                            Container(
                              height: 12,
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              (ProfileController.nickname.isNotEmpty)?
                              Text(
                                '${ProfileController.nickname} 님',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Color.fromARGB(255, 43, 43, 43),
                                ),
                              ): Text(
                                '닉네임을 등록해주세요.',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Color.fromARGB(255, 43, 43, 43),
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    Get.to(nickname_view());
                                  },
                                  icon: Icon(
                                    Icons.edit_note,
                                    size: 25,
                                  )),

                            ]),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          H1(changeValue: '외출 소지품', size: 14),
                          IconButton(
                            onPressed: () {
                              Get.to(TagPlus_view());
                            },
                            color: Color.fromARGB(255, 18, 136, 248),
                            icon: Icon(
                              Icons.edit_note,
                              size: 25,
                            ),
                          )
                        ],
                      ),
                      Container(
                        width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width,
                        height: 30,
                        child: new ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: ProfileController.listData['lists']?.length,
                          itemBuilder: (BuildContext context, int index) {
                            return new Card(
                              margin: EdgeInsets.only(right: 10),
                              color: Color.fromARGB(255, 234, 234, 234),
                              child:
                              // new Text(ProfileController.Tagdata![1]),
                              new Padding(
                                padding: EdgeInsets.all(7),
                                child: Center(
                                  child: Text('${ProfileController.listData['lists'][index]['name']}'),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ])))
        ),
      ),
    );
  }
}
