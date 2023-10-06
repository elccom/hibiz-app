import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/controller/qna_controller.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/nickname_view.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';
import 'package:wisemonster/view_model/camera_view_model.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'dart:io' as i;

import '../api/api_services.dart';

class qna_edit_view extends GetView<EditController> {
  // Build UI
  String userName = '';
  ApiServices api = ApiServices();
  final controller = Get.put(EditController());
  @override
  Widget build(BuildContext context) {
    return Obx(() =>
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            appBar: AppBar(
                elevation: 0,
                centerTitle: true,
                backgroundColor: Color.fromARGB(255, 255, 255, 255),
                iconTheme: const IconThemeData(color: Color.fromARGB(255, 87, 132, 255)),
                title: Text(
                  '문의 수정',
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
                            controller.editQna(Get.arguments);
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
            body:controller.isclear.value? Container(
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
                        changeValue: '글 제목',
                        size: 14,
                      ),
                      TextField(
                          controller: controller.titleController, //set id controller
                          style: const TextStyle(
                              color: Color.fromARGB(255, 43, 43, 43), fontSize: 17),
                          decoration: InputDecoration(
                            hintText: '수정할 제목을 입력해주세요',
                            hintStyle: TextStyle(
                                fontSize: 17,
                                color: Color.fromARGB(255, 222, 222, 222)
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                BorderSide(color: Color.fromARGB(255, 43, 43, 43))),
                          ),
                          onChanged: (value) {
                            //변화된 id값 감지
                            controller.title = value;

                          }),
                      Container(
                        height: 30,
                      ),
                      H1(
                        changeValue: '등록 날짜',
                        size: 14,
                      ),
                      Container(
                        height: 20,
                      ),
                      Text(controller.listData['lists'][Get.arguments]['updateDate'] == null ? '' :DateFormat('yyyy년 MM월 dd일').format(DateTime.parse(controller.listData['lists'][Get.arguments]['updateDate']))),
                      Container(
                        height: 30,
                      ),
                      H1(
                        changeValue: '내용',
                        size: 14,
                      ),
                      Container(
                        height: 20,
                      ),
                      TextField(
                          controller: controller.commentController,
                          maxLines: 7, //or null
                          decoration: InputDecoration(
                            hintText:
                            '수정할 내용을 입력해주세요',
                            hintStyle: TextStyle(fontSize: 17, color: Color.fromARGB(255, 222, 222, 222)),
                            enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 43, 43, 43))),
                          ),
                          onChanged: (value) {
                            //변화된 id값 감지
                            controller.comment = value;
                          }),
                    ],
                  )),
            ) : Center(child: CircularProgressIndicator(),),
          ),
        )
    );
  }
}
class EditController extends GetxController{
  var titleController = TextEditingController();
  var commentController = TextEditingController();

  String comment = '';
  String title = '';
  final isclear = false.obs;
  var listData;
  ApiServices api = ApiServices();

  @override
  void onInit() {
    print('컴');
    requestEntrance();
    update();
    super.onInit();
  }

  requestEntrance(){
    print('초기 인덱스');
    api.get('/Qna/lists').then((value) {
      if(value.statusCode == 200) {
        listData = json.decode(value.body);
        print('요청한 리스트값 ${json.decode(value.body)}');
        titleController.text = listData['lists'][Get.arguments]['title'];
        commentController.text = listData['lists'][Get.arguments]['comment'];
        print(titleController.text);
        isclear.value = true;
        refresh();
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
    update();
  }


  editQna(index){
    api.put(json.encode({'title':title,'comment':comment}),'/Qna/${listData['lists'][index]['qna_id']}').then((value) {
      if(value.statusCode == 200) {
        Get.back();
        Get.snackbar(
          '알림',
          '수정이 완료되었습니다.',
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
        requestEntrance();
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
}
