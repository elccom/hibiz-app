import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:convert/convert.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quiver/iterables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/models/mqtt.dart';
import 'package:wisemonster/view/profile_view.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:http/http.dart' as http;

class SData{
  int STX = 0x48;
  var cmd;
  var data;

  SData(cmd, data){
  }

  
  init(self, cmd, data){
    self._cmd = cmd;
    self._data = data;
  }
  parse(List rdata) {
    if (rdata[0] != STX) throw Exception('stx data error');
    int? lt = rdata[1];
    List add = [];
    if (rdata.length - 3 != lt) throw Exception('length data error');
    for (int i = 0; i < rdata.length - 1; i++) {
      add.add(rdata[i]);
    }
  }

  toPrint(cmd, data){
    print('STX: ${STX.toRadixString(16)}');
    print('LENGTH: ${data.length+1}');
    print('CMD: ${cmd.toRadixString(16)}');
    print('DATA: ${data}');
    print('ADD: ${calcuChecksum(cmd,data).toRadixString(16)}');
    print('암호화 키 교환');
  }
  
  toBytes(cmd, data){
    List<int> rdata = [];
    rdata.add(STX);
    rdata.add(data.length+1);
    rdata.add(cmd);
    rdata.addAll(data);
    print(rdata);
    print(calcuChecksum(cmd,data));
    rdata.add(calcuChecksum(cmd,data));
    print('${Uint8List.fromList(rdata)} 합체');
    return Uint8List.fromList(rdata);
  }

  paddingRight(self,List<int> data, value){
    int pcount = 16 - data.length % 16;
    for(var i = 0; i < pcount; i++){
      data.insert(i, value);
    }
    return Uint8List.fromList(data);
  }

  calcuChecksum(cmd, data){
    int add = data.length+cmd;
    for(int d in data){
      add = add + d;
    }
    return add&0xff;
  }
}