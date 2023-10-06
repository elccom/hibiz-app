import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/controller/member_controller.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view/nickname_view.dart';
import 'package:wisemonster/view/tagplus_view.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';
import 'package:wisemonster/view_model/camera_view_model.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'dart:io' as i;

import '../api/api_services.dart';
import '../controller/camera_controller.dart';
import '../controller/profile_controller.dart';
import 'login_view.dart';
import 'messageplus_view.dart';

class member_edit_view extends GetView<MemberEditController> {
  // Build UI
  String userName = '';

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MemberEditController>(
      init: MemberEditController(),
      builder: (MemberEditController) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            resizeToAvoidBottomInset : false,
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              iconTheme: const IconThemeData(color: Color.fromARGB(255, 87, 132, 255)),
              title: Text(
                '구성원',
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
            ),
            body:MemberEditController.isClear == false ? Center(child: CircularProgressIndicator(),):
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
                        height: 230,
                        color: Color.fromARGB(255, 255, 255, 255),
                        child: Column(
                          children: [
                            Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 161, 161, 161),
                                ),
                                child: MemberEditController.listData['lists'][Get.arguments[0]]['userObj']['picture']['url'] != null
                                    ? CircleAvatar(
                                    backgroundImage: Image.network('http://api.hizib.watchbook.tv${MemberEditController.listData['lists'][Get.arguments[0]]['userObj']['picture']['url']}').image
                                )
                                    : Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 30,
                                )
                      ),
                            Container(
                              height: 12,
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              (MemberEditController.listData['lists'][Get.arguments[0]]['userObj']['name'] != '')?
                              Text(
                                '${MemberEditController.listData['lists'][Get.arguments[0]]['userObj']['name']} 님',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Color.fromARGB(255, 43, 43, 43),
                                ),
                              ): Text(
                                '',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Color.fromARGB(255, 43, 43, 43),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          H1(changeValue: '메세지 작성', size: 14),
                          IconButton(
                            onPressed: () {
                              Get.to(MessagePlus_view(), arguments:MemberEditController.listData['lists'][Get.arguments[0]]['user_id'] );
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
                        height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height - 420,
                        child: new ListView.builder(
                          itemCount:
                          MemberEditController.messageData?.length == null ? 0 : MemberEditController.messageData?.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 3.0,
                              child: SizedBox(
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
                                  title: Text('${MemberEditController.messageData[index]['msg']}'),
                                  trailing: IconButton(
                                    onPressed: () {
                                      MemberEditController.deleteMesaage(index);
                                    },
                                    icon: Icon(Icons.delete),
                                  ),
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
class MemberEditController extends GetxController{
  var listData;
  var messageData;
  ApiServices api = ApiServices();
  bool isClear = false;
  requestMessage(idx){
    print('메세지조회구간');
    api.get('/SmartdoorMessage/lists').then((value) {
      if(value.statusCode == 200) {
        print('받은 user_id : ${idx}');
        print(json.decode(value.body)['lists'].length);
        List k = [];
        for(int i = 0; i < json.decode(value.body)['lists'].length; i++){
          print('값 : ${json.decode(value.body)['lists'][i]['to_user_id']}');
          if(json.decode(value.body)['lists'][i]['to_user_id'].toString() == idx.toString()){
            print(json.decode(value.body)['lists'][i]);
            k.add(json.decode(value.body)['lists'][i]);
          }
        }
        messageData = k;
        print(messageData);
        isClear = true;
        update();
      } else if(value.statusCode == 401) {
        Get.offAll(login_view());
        Get.snackbar(
          '알림',
          utf8.decode(value.reasonPhrase!.codeUnits)
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          '알림',
          utf8.decode(value.reasonPhrase!.codeUnits)
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      }
    });
  }

  deleteMesaage(index){
    print('메세지삭제');
    print(index);
    print(index.runtimeType);
    // print(int.parse(index));
    print(messageData.length);
    var smartdoor_message_id = messageData[index]['smartdoor_message_id'];
    print(smartdoor_message_id);
    api.delete('/SmartdoorMessage/${smartdoor_message_id}').then((value) {
      if (value.statusCode == 200) {
        Get.back();
        Get.snackbar(
          '알림',
          '삭제가 완료되었습니다.'
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      } else if (value.statusCode == 401) {
        Get.offAll(login_view());
        Get.snackbar(
          '알림',
          utf8.decode(value.reasonPhrase!.codeUnits)
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          '알림',
          utf8.decode(value.reasonPhrase!.codeUnits)
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
        update();
      }
        //requestMessage();

    });
  }

  requestMember() {
    api.get('/SmartdoorUser/lists').then((value) {
      print(value.statusCode);
      if(value.statusCode == 200) {
        listData = json.decode(value.body);
        update();
      }else if(value.statusCode == 401) {
        Get.offAll(login_view());
        Get.snackbar(
          '알림',
          utf8.decode(value.reasonPhrase!.codeUnits)
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      }else {
        print('ddddddddfdf');
        Get.snackbar(
          '알림',
          utf8.decode(value.reasonPhrase!.codeUnits)
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      }
    });
  }

  @override
  void onInit() {
    requestMember();
    requestMessage(Get.arguments[1]);
    print('답');
    super.onInit();
  }
}
