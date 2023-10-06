import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/notice_view.dart';
import 'package:wisemonster/view/profile_view.dart';
import 'package:wisemonster/view/qna_detail_view.dart';
import 'package:wisemonster/view/qna_edit_view.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:http/http.dart' as http;

class Item {
  Item({
    required this.isExpanded,
    required this.id,
    required this.title,
    required this.comment,
    required this.reply,
  });
  bool isExpanded;
  var id;
  String title;
  String comment;
  String reply;
}

class QnaController extends GetxController{
  var titleController = TextEditingController();
  var commentController = TextEditingController();

  late List<Item> items;
  DateTime? pickedDate;
  String comment = '';
  String title = '';

  int index = 0;
  final isclear = false.obs;

  ApiServices api = ApiServices();
  var listData;
  List elements = [];

  @override
  void onInit() {
    requestEntrance();
    update();
    super.onInit();
  }

  List<Item> _generateItems(list) {
    print("_generateItems");
    print(list['lists'].length);

    return List.generate(list['lists'].length
        , (int index) {
      return Item(
        isExpanded: false,
        id: index,
        title: '${list['lists'][index]['title']}',
        comment: '${list['lists'][index]['comment']}',
        reply: '${list['lists'][index]['reply']}',
      );
    });
  }

  ExpansionPanel buildExpansionPanel(Item item) {
    return ExpansionPanel(
        isExpanded: item.isExpanded,
        headerBuilder: (BuildContext context, bool isExpanded) {
          return ListTile(
            title: Text(item.title),
            leading: IconButton(
                onPressed: (){
                Get.to(qna_detail_view(), arguments: item.id);
                  print(item.id);
            },
                iconSize: 10,
                icon: Icon(
                    Icons.chevron_right,
                size: 30,
                )),
          );
        },
        body:
        Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: item.reply.trim().isEmpty ?Text('답변을 기다리고있습니다.') : Text('${item.reply}'),
        )
    );
  }

  //1:1문의 등록
  requestSend(){
    print('requestSend');

    String title = titleController.text.trim();
    String comment = commentController.text.trim();

    api.qRestApi("post", "/Qna", {"title": "${title}","comment": "${comment}"}, true).then((res) async {
      if(res['statusCode'] == 200) {
        Get.back();
        snackbar('등록되었습니다.');
        requestEntrance();
        update();
      } else if(res['statusCode'] == "401") {
        Get.offAll(login_view());
      } else {
        snackbar(res['body']['message']);
      }
    });
  }

  requestEntrance(){
    print('requestEntrance');

    api.qRestApi("get", "/Qna/lists", {}, true).then((res) async {
      if(res['statusCode'] == 200) {
        listData = res['body'];
        items = _generateItems(listData);
        print('요청한 리스트값 ${listData}');
        isclear.value = true;
        update();
      } else if(res['statusCode'] == "401") {
        Get.offAll(login_view());
      } else {
        snackbar(res['body']['message']);
      }
    });
    update();
  }

  //Q&A삭제
  deleteQna(index){
    api.qRestApi("delete", '/Qna/${listData['lists'][index]['qna_id']}', {}, true).then((res) async {
      if(res['statusCode'] == 200) {
        Get.back();
        requestEntrance();
        snackbar('삭제가 완료되었습니다.');
      } else if(res['statusCode'] == 401) {
        Get.offAll(login_view());
      } else {
        snackbar(res['body']['message']);
      }
    });
  }

  editQna(index){
    api.qRestApi("put", '/Qna/${listData['lists'][index]['qna_id']}', {'title':title,'comment':comment}, true).then((res) async {
      if(res['statusCode'] == 200) {
        Get.back();
        requestEntrance();
        snackbar('수정이 완료되었습니다.');
      } else if(res['statusCode'] == 401) {
        Get.offAll(login_view());
      } else {
        snackbar(res['body']['message']);
      }
    });
  }

  void snackbar(String msg) {
    Get.snackbar(
      '알림',
      msg,
      duration: const Duration(seconds: 5),
      backgroundColor: const Color.fromARGB(255, 39, 161, 220),
      icon: const Icon(Icons.info_outline, color: Colors.white),
      forwardAnimationCurve: Curves.easeOutBack,
      colorText: Colors.white,
    );
  }

  void allUpdate() {
    update();
  }

}