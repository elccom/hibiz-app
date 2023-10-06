import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/controller/profile_controller.dart';
import 'package:wisemonster/view/addkey_view.dart';
import 'package:wisemonster/view/calendar_view.dart';
import 'package:wisemonster/view/config_view.dart';
import 'package:wisemonster/view/entrance_view.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view/key_view.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/nickname_view.dart';
import 'package:wisemonster/view/profile_view.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'package:wisemonster/view_model/login_view_model.dart';
import 'dart:io' as i;

import '../../models/user_model.dart';
import '../notice_view.dart';
import '../video_view.dart';

class LeftSlideWidget extends StatelessWidget {
  Map<String, dynamic> userObj = {};
  String userName = '';
  String pictureUrl = '';
  final home = Get.put(HomeViewModel());
  final login = Get.put(LoginViewModel());
  final con = Get.put(ProfileController());

  getName() async {
    if(!userObj.containsKey("name")) {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String? userStr = sharedPreferences.getString('user')!;
      userObj = jsonDecode(userStr);
    }

    userName = userObj['name'];
    print('회원이름 호출');
    print(userName);
    return await userName;
  }

  getImage() async {
    if(!userObj.containsKey("picture")) {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String? userStr = sharedPreferences.getString('user')!;
      userObj = jsonDecode(userStr);
    }

    if(userObj.containsKey("picture") && userObj["picture"].containsKey("url")) pictureUrl = userObj['picture']['url'];
    print('프로필사진 주소');
    print(pictureUrl);
    return pictureUrl;
  }

  // LeftSlideWidget({
  //   required this.serverMsg,
  //   required this.error,
  // });
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 288,
        child: Drawer(
          child: ListView(
            //메모리 문제해결
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
            padding: EdgeInsets.zero, // 여백x
            children: [
              Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
              Container(
              width: MediaQueryData
                  .fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .width,
              height: MediaQueryData
                  .fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .height - 60,
              color: Color.fromARGB(255, 255, 255, 255),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => Get.offAll(profile_view()),
                          color: Color.fromARGB(255, 18, 136, 248),
                          icon: Icon(
                            Icons.edit,
                            size: 25,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          color: Color.fromARGB(255, 18, 136, 248),
                          icon: Icon(
                            Icons.arrow_back_ios_new_outlined,
                            size: 20,
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                      height: 152,
                      color: Color.fromARGB(255, 255, 255, 255),
                      child: Column(
                        children: [
                          TextButton(onPressed: () {}, child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromARGB(255, 161, 161, 161),
                            ),
                            child:
                            FutureBuilder(
                                future: getImage(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return CircleAvatar(
                                        backgroundImage: Image
                                            .network('https://api.hizib.wikibox.kr${pictureUrl}')
                                            .image
                                    );
                                  } else {
                                    return Icon(
                                      Icons.image,
                                      color: Colors.white,
                                      size: 30,
                                    );
                                  }
                                }))),
                            Container(
                              height: 12,
                            ),
                            FutureBuilder(
                                future: getName(),
                                builder: (context, snapshot) {
                                  if (snapshot.data != null && snapshot.data != '') {
                                    return
                                      Text('${snapshot.data} 님',
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Color.fromARGB(255, 43, 43, 43),
                                        ),);
                                  } else {
                                    return Text('닉네임을 등록해주세요.',
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Color.fromARGB(255, 43, 43, 43),
                                      ),
                                    );
                                  }
                                })
                            ,
                            ],
                          ),
                          ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('준비물 목록',
                          style: TextStyle(
                              color: Color.fromARGB(255, 161, 161, 161),
                              fontSize: 18
                          ),
                        ),
                        Container(
                          height: 10,
                        ),
                        Container(
                          width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width - 40,
                          height: 30,
                          child: new ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: con.listData['lists']?.length,
                            itemBuilder: (BuildContext context, int index) {
                              return new Card(
                                margin: EdgeInsets.fromLTRB(0, 1, 10, 1),
                                color: Color.fromARGB(255, 255, 255, 255),
                                child:
                                // new Text(ProfileController.Tagdata![1]),
                                new Padding(
                                  padding: EdgeInsets.all(7),
                                  child: Center(
                                    child: Text('${con.listData['lists'][index]['name']}',
                                      style: TextStyle(
                                          color: Color.fromARGB(255, 161, 161, 161)
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                        ],
                      )),
                  TextButton(
                    onPressed: () {
                      login.logoutProcess();
                    },
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.fromLTRB(0, 22, 0, 22),
                        backgroundColor: Color.fromARGB(255, 255, 255, 255)),
                    child: Text(
                      '로그아웃',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 161, 161, 161),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}