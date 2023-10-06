import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/view/login_view.dart';

import '../api/api_services.dart';

class Item {
  Item({
    required this.isExpanded,
    required this.id,
    required this.name,
    required this.answer,
  });
  bool isExpanded;
  var id;
  String name;
  String answer;
}

class FaqController extends GetxController{
  ApiServices api = ApiServices();
  late List<Item> items;
  late Map listData = {};
  bool toggle = false;
  List<Item> _generateItems(list) {
    return List.generate(
        list['lists'].length
        , (int index) {
      return Item(
        id: index,
        name: '${list['lists'][index]['question']}',
        isExpanded: false,
        answer: '${list['lists'][index]['answer']}',
      );
    });
  }

  ExpansionPanel buildExpansionPanel(Item item) {
    return ExpansionPanel(
      isExpanded: item.isExpanded,
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(
          title: Text(item.name),
        );
      },
      body:
      Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Text('${item.answer}'),
      )
    );
  }

  @override
  void onInit() {
    super.onInit();
    api.get('/Faq/lists').then((value) async {
      if(value.statusCode == 200) {
        print(value.body);
        items = _generateItems(json.decode(value.body));
        toggle = true;
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