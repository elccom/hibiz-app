import 'dart:async';
import 'dart:convert';
import 'dart:io' as i;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/view/calendar_view.dart';
import 'package:wisemonster/view/cameraAuth_view.dart';
import 'package:wisemonster/view/config_view.dart';
import 'package:wisemonster/view/key_view.dart';
import 'package:wisemonster/view/member_view.dart';
import 'package:wisemonster/view/profile_view.dart';
import 'package:wisemonster/view/video_view.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/H2.dart';

import 'package:wisemonster/view/widgets/LeftSlideWidget.dart';
import 'package:wisemonster/view/widgets/QrWidget.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'camera_view.dart';
import 'entrance_view.dart';

class home_view extends GetView<HomeViewModel> {
  home_view({Key? key}) : super(key: key);
  String userName = '';
  getName() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? userStr = sharedPreferences.getString("user")!;
    Map<String, dynamic> userObj = jsonDecode(userStr);

    userName = userObj['name'];
    print('회원이름 호출[home_view/getName]');
    print(userName);
    return await userName;
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    return GetBuilder<HomeViewModel>(
      init: HomeViewModel(),
      builder: (HomeViewModel) => WillPopScope(
          onWillPop: () => _goBack(context),
          child:  Scaffold(
            resizeToAvoidBottomInset: false,
            body:
              SafeArea(
                              child: Container(
                                width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width,
                                padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 40,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(onPressed: (){
                                          Get.to(() => camera_view());
                                        },
                                            style: ButtonStyle(
                                              padding:   MaterialStateProperty.all<EdgeInsets>(
                                                  EdgeInsets.all(0)),
                                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(120.0),
                                              )),
                                            ),
                                            child:
                                        Container(
                                          width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width/2 - 12,
                                          height: 220,
                                          decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 253, 133, 1),
                                              borderRadius: BorderRadius.all(Radius.circular(20))),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Icon(Icons.camera,
                                                    size: 80, color: Color.fromARGB(
                                                        255, 255, 255, 255)),
                                                Container(height: 20,),
                                                Text('외부영상',
                                                    style: TextStyle(
                                                      fontSize: 23,
                                                      color: Color.fromARGB(255, 255, 255, 255),
                                                    ))
                                              ],
                                            ),
                                          ),
                                        )
                                        ),
                                        TextButton(onPressed: (){
                                          HomeViewModel.btn == true ?
                                              null :
                                          HomeViewModel.scan();
                                        },
                                            style: ButtonStyle(
                                              padding:   MaterialStateProperty.all<EdgeInsets>(
                                                  EdgeInsets.all(0)),
                                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(120.0),
                                              )),
                                            ),
                                            child:
                                            Container(
                                              width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width/2 - 12,
                                              height: 220,
                                              decoration: BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 87, 132, 255),
                                                  borderRadius: BorderRadius.all(Radius.circular(20))),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    HomeViewModel.door== '1' ? Icon(Icons.lock_open,
                                                        size: 80, color: Color.fromARGB(255, 255, 255, 255)):
                                                    HomeViewModel.door== '0' ?
                                                    Icon(Icons.lock,
                                                        size: 80, color: Color.fromARGB(255, 255, 255, 255)):
                                                    HomeViewModel.door== '-1' ?
                                                    Icon(Icons.search,
                                                        size: 80, color: Color.fromARGB(255, 255, 255, 255)):
                                                    HomeViewModel.door== '-3' ?
                                                    Icon(Icons.search,
                                                        size: 80, color: Color.fromARGB(255, 255, 255, 255))
                                                        :Icon(Icons.cancel,
                                                        size: 80, color: Color.fromARGB(255, 255, 255, 255))
                                                    ,
                                                    Container(height: 20,),
                                                    HomeViewModel.door == '1'?
                                                    Text('도어가 열려있습니다.',
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          color: Color.fromARGB(255, 255, 255, 255),
                                                        )):HomeViewModel.door == '0'?
                                                    Text('열기',
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          color: Color.fromARGB(255, 255, 255, 255),
                                                        )):HomeViewModel.door == '-1'?Text('문상태 조회중',
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          color: Color.fromARGB(255, 255, 255, 255),
                                                        ))
                                                        :HomeViewModel.door == '-3'?
                                                    Text('문작동중',
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          color: Color.fromARGB(255, 255, 255, 255),
                                                        ))
                                                        :Text('문상태 조회실패',
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          color: Color.fromARGB(255, 255, 255, 255),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            )
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 40,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width/2 - 12,
                                          height: 60,
                                          child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.resolveWith(
                                                      (states) {
                                                    if (states.contains(MaterialState.disabled)) {
                                                      return Colors.grey;
                                                    } else {
                                                      return Colors.white;
                                                    }
                                                  },
                                                ),
                                                shape: MaterialStateProperty.resolveWith((states) => const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(15)))),
                                              ),
                                              onPressed: () {
                                                Get.to(() => entrance_view());
                                              },
                                              child:Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Icon(Icons.list, size: 40, color: Colors.grey),
                                                  Text('출입기록',
                                                      style: TextStyle(
                                                        fontSize: 17,
                                                        color: Colors.grey,
                                                      )),
                                                ],
                                              )
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width/2-12,
                                          height: 60,
                                          child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.resolveWith(
                                                      (states) {
                                                    if (states.contains(MaterialState.disabled)) {
                                                      return Colors.grey;
                                                    } else {
                                                      return Colors.white;
                                                    }
                                                  },
                                                ),
                                                shape: MaterialStateProperty.resolveWith((states) => const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(15)))),
                                              ),
                                              onPressed: () {
                                                Get.to(() => member_view());
                                              },
                                              child:Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Icon(Icons.people, size: 40, color: Colors.grey),
                                                  Text('구성원',
                                                      style: TextStyle(
                                                        fontSize: 17,
                                                        color: Colors.grey,
                                                      )),
                                                ],
                                              )
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width/2-12,
                                          height: 60,
                                          child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.resolveWith(
                                                      (states) {
                                                    if (states.contains(MaterialState.disabled)) {
                                                      return Colors.grey;
                                                    } else {
                                                      return Colors.white;
                                                    }
                                                  },
                                                ),
                                                shape: MaterialStateProperty.resolveWith((states) => const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(15)))),
                                              ),
                                              onPressed: () {
                                                Get.to(() => calendar_view());
                                              },
                                              child:Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Icon(Icons.calendar_month, size: 40, color: Colors.grey),
                                                  Text('캘린더',
                                                      style: TextStyle(
                                                        fontSize: 17,
                                                        color: Colors.grey,
                                                      )),
                                                ],
                                              )
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width/2 - 12,
                                          height: 60,
                                          child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.resolveWith(
                                                      (states) {
                                                    if (states.contains(MaterialState.disabled)) {
                                                      return Colors.grey;
                                                    } else {
                                                      return Colors.white;
                                                    }
                                                  },
                                                ),
                                                shape: MaterialStateProperty.resolveWith((states) => const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(15)))),
                                              ),
                                              onPressed: () {
                                                Get.to(() => video_view());
                                              },
                                              child:Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Icon(Icons.playlist_play, size: 40, color: Colors.grey),
                                                  Text('녹화목록',
                                                      style: TextStyle(
                                                        fontSize: 17,
                                                        color: Colors.grey,
                                                      )),
                                                ],
                                              )
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width/2 - 12,
                                          height: 60,
                                          child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.resolveWith(
                                                      (states) {
                                                    if (states.contains(MaterialState.disabled)) {
                                                      return Colors.grey;
                                                    } else {
                                                      return Colors.white;
                                                    }
                                                  },
                                                ),
                                                shape: MaterialStateProperty.resolveWith((states) => const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(15)))),
                                              ),
                                              onPressed: () {
                                                Get.to(() => key_view());
                                              },
                                              child:Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Icon(Icons.key, size: 40, color: Colors.grey),
                                                  Text('게스트 키',
                                                      style: TextStyle(
                                                        fontSize: 17,
                                                        color: Colors.grey,
                                                      )),
                                                ],
                                              )
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width/2 - 12,
                                          height: 60,
                                          child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.resolveWith(
                                                      (states) {
                                                    if (states.contains(MaterialState.disabled)) {
                                                      return Colors.grey;
                                                    } else {
                                                      return Colors.white;
                                                    }
                                                  },
                                                ),
                                                shape: MaterialStateProperty.resolveWith((states) => const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(15)))),
                                              ),
                                              onPressed: () {
                                                Get.to(() => config_view());
                                              },
                                              child:Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Icon(Icons.settings, size: 40, color: Colors.grey),
                                                  Text('설정',
                                                      style: TextStyle(
                                                        fontSize: 17,
                                                        color: Colors.grey,
                                                      )),
                                                ],
                                              )
                                          ),
                                        ),
                                      ],
                                    ),
                              ]))),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Color.fromARGB(255, 87, 132, 255),
              iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
              actions: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Row(
                    children: [
                  //     (home.nickname != null)?
                  // Text('${home.nickname} 님',
                  //   style: TextStyle(
                  //     fontSize: 14,
                  //     color: Color.fromARGB(255, 255, 255, 255),
                  //   ),
                  // ):Text('회원님',
                  //   style: TextStyle(
                  //     fontSize: 14,
                  //     color: Color.fromARGB(255, 255, 255, 255),
                  //   ),
                  // ),
                      IconButton(
                        onPressed: () {
                          Get.to(() => cameraAuth_view());
                        },
                        icon: Icon(Icons.camera_alt, size: 19, color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      IconButton(
                        onPressed: () {
                          Get.to(() => profile_view());
                        },
                        icon: Icon(Icons.account_circle, size: 19, color: Color.fromARGB(255, 255, 255, 255)),
                      )
                    ],
                  ),
                )
              ],
            ),
            drawer:
            LeftSlideWidget()

          )),
    );
  }

  Future<bool> _goBack(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱을 종료하시겠어요?'),
        actions: <Widget>[
          TextButton(
            child: const Text('네'),
            onPressed: () => Navigator.pop(context, true),
          ),
          TextButton(
            child: const Text('아니오'),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

}
