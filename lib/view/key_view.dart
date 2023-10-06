import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:wisemonster/view/addkey_view.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/widgets/AlertWidget.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/home_view.dart';

import '../api/api_services.dart';

class key_view extends GetView<KeyView> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<KeyView>(
        init: KeyView(),
    builder: (KeyView) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home:Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 44, 95, 233)),
        centerTitle: true,
        title: Text('게스트 키', style: TextStyle(
            color: Color.fromARGB(255, 44, 95, 233),
            fontWeight: FontWeight.bold,
            fontSize: 20)),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Get.offAll(home_view());
          },
        ),
        actions: [
          TextButton(
              onPressed: () {
                Get.to(addkey_view(),arguments: 'create');
              },
              child: Text(
                '추가',
                style: TextStyle(color: Color.fromARGB(255, 44, 95, 233), fontSize: 17),
              ))
        ],
      ),
      body:KeyView.isclear == false ? Center(child: CircularProgressIndicator(),)
    : Container(
        margin: EdgeInsets.fromLTRB(16, 40, 16, 0),
        width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width - 32,
        height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '발급된 게스트 키',
              style: TextStyle(color: Color.fromARGB(255, 87, 132, 255), fontSize: 14),
            ),
            Expanded(
                child:ListView.builder(
                    itemCount: KeyView.listData['lists'].length == 0 ? 0 : KeyView.listData['lists'].length,
                    itemBuilder: (BuildContext context, int index){
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 0,
                                blurRadius: 1,
                                offset: Offset(0, 2), // changes position of shadow
                              )
                            ],
                            borderRadius: BorderRadius.all(Radius.circular(100))),
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Container(
                                  width: 50,
                                  height: 50,
                                  child: Icon(Icons.pattern_sharp,
                                      size: 32,
                                      color: Color.fromARGB(255, 255, 255, 255)
                                  ),
                                  decoration: BoxDecoration(
                                      color: KeyView.listData['lists'][index]['status'] == 0 ? Colors.grey : KeyView.listData['lists'][index]['status'] == 0 ? Colors.blue : Colors.red,
                                      borderRadius: BorderRadius.all(Radius.circular(120))
                                  )
                              ),
                             Container(width: 10,),
                              Expanded(
                                flex: 40,
                                  child:Text(
                                    '일회용 게스트 키',
                                    style: TextStyle(
                                      fontSize: 14,

                                    ),
                                  )
                              )
                              ,
                              Expanded(
                                flex: 20,
                                  child: Container(
                                width: 0,
                                height:50,
                                child: Row(
                                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(onPressed: (){
                                      Get.dialog(
                                          AlertDialog(
                                            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                            //Dialog Main Title
                                            //
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                H1(
                                                  changeValue: '시작 일시',
                                                  size: 12,
                                                ),
                                                Text(
                                                  '${KeyView.listData['lists'][index]['startDate'].toString()}',
                                                ),
                                                Container(
                                                  height: 10,
                                                ),
                                                H1(
                                                  changeValue: '종료 일시',
                                                  size: 12,
                                                ),
                                                Text(
                                                  '${KeyView.listData['lists'][index]['stopDate'].toString()}',
                                                ),
                                                Container(
                                                  height: 10,
                                                ),
                                                H1(
                                                  changeValue: '비밀번호',
                                                  size: 12,
                                                ),
                                                Text(
                                                  '${KeyView.listData['lists'][index]['passwd'].toString()}',
                                                ),
                                                Container(
                                                  height: 10,
                                                ),
                                                H1(
                                                  changeValue: '상태',
                                                  size: 12,
                                                ),
                                                KeyView.listData['lists'][index]['status'] == 0 ?
                                                Text('발급 신청'): KeyView.listData['lists'][index]['status'] == 1 ?
                                                Text('발급 성공'):
                                                Text('발급 실패'),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text("확인"),
                                                onPressed: () {
                                                  Get.back();
                                                },
                                              ),
                                            ],
                                          )
                                      );
                                    },
                                        icon:Icon(Icons.info_outline,
                                            size: 32, color: Color.fromARGB(255, 44, 95, 233))
                                    //),
                                    // IconButton(onPressed: (){},
                                    //     icon:Image.asset(
                                    //       'images/icon/pencil.png',
                                    //       fit: BoxFit.contain,
                                    //       alignment: Alignment.center,
                                    //     )
                                    // ),
                                    //IconButton(onPressed: (){
                                    //  KeyView.deleteKey(index);
                                    //},
                                    //    icon:Icon(Icons.cancel_outlined,
                                    //        size: 32, color: Color.fromARGB(255, 44, 95, 233))
                                    )
                                  ],
                                ),
                              ))
                              ,
                            ],
                          ),
                      );
                    }
                )
            ),
          ],
        ),
      ),
    )));
  }
}

class KeyView extends GetxController{
  Map<String, dynamic> listData = {"total": 0, "totalPages": 0, "page": 1, "rowsPerPage": 10, "sort": "a_smartdoor_item_id", "desc": "desc", "keyword": "", "lists": []};

  ApiServices api = ApiServices();

  bool isclear = false;

  @override
  void onInit() {
    requestKey();
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
            onPressed: () => Get.offAll(key_view()),
          ),
        ],
      ),
    );
  }

  deleteKey(index){
    print(listData['lists'][index]['smartdoor_guestkey_id']);
    api.qRestApi("delete", "/SmartdoorGuestKey/${listData['lists'][index]['smartdoor_guestkey_id']}", {}, true).then((res) {
      if (res['statusCode'] == 200) {
        requestKey();
        dialog('삭제되었습니다.');
      } else {
        snackbar(res['body']['message']);
      }
    });
  }

  requestKey() {
    print(Get.arguments);
    api.qRestApi("get", "/SmartdoorGuestkey/lists", {}, true).then((res) async {
      if(res['statusCode'] == 200) {
        listData = res['body'];
        isclear = true;
        update();
      } else if(res['statusCode'] == 401) {
        Get.offAll(login_view());
        snackbar(res['body']['message']);
      }else {
        snackbar(res['body']['message']);
      }
    });
  }
}