import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/models/user_model.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:wisemonster/view/login_view.dart';

class ApiServices extends GetxController {
  var authresponse;

  String server = 'https://api.hizib.wikibox.kr';

  //restapi
  Future<dynamic> qRestApi(String method, String url, Map<String, dynamic> body, bool isToken) async {
    /*
    try {
      if(Get.isDialogOpen == null || !Get.isDialogOpen!) Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false);
    } catch (e) {}
     */

    Map<String, String> headers = {"Content-type":"application/json"};

    if(!url.startsWith(server)) url = '${server+url}';

    if(isToken) {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String? token = sharedPreferences.getString('token');
      headers[HttpHeaders.authorizationHeader] = "Bearer ${token}";
    }

    print("qRestApi url:${url} method:${method.toUpperCase()} headers:${jsonEncode(headers)}");
    if(method.toUpperCase() != "GET") print("body:${body}");
    
    http.Response res;

    if(method.toUpperCase() == "GET") res = await http.get(Uri.parse(url), headers: headers);
    else if(method.toUpperCase() == "POST") res = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));
    else if(method.toUpperCase() == "PUT") res = await http.put(Uri.parse(url), headers: headers, body: jsonEncode(body));
    else if(method.toUpperCase() == "DELETE") res = await http.delete(Uri.parse(url), headers: headers, body: jsonEncode(body));
    else throw Exception("요청 Method가 없습니다.");

    print("qRestApi url:${url} result:${res.statusCode}");
    print(res.body);
    //if(Get.isDialogOpen != null && Get.isDialogOpen!) Get.back();

    return qRestApiResult(res);
  }

  //restapi
  Future<Map> restapi(Map jsonMap) async {
    Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false);

    String method = "GET";
    String url;
    bool isToken = true;
    String? token;

    if(!jsonMap.containsKey('url')) throw Exception("URL을 입력해 주세요.");
    else url = jsonMap['url'];

    if(jsonMap.containsKey('method')) method = jsonMap['method'];
    if(jsonMap.containsKey('isToken')) isToken = jsonMap['isToken'];

    if(!url.startsWith(server)) url = '${server+url}';

    Map<String, String> headers = {"Content-type":"application/json"};

    if(isToken) {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      token = sharedPreferences.getString('token');
      headers[HttpHeaders.authorizationHeader] = "Bearer ${token}";
    }

    Map<String, dynamic> bodyData = Map<String, dynamic>();

    var res;
    var body = {};
    if(jsonMap.containsKey('body')) body = jsonMap['body'];

    print("restapi url:${url} method:${method.toUpperCase()} headers:${jsonEncode(headers)} body:${body}");

    if(method.toUpperCase() == "GET") res = await http.get(Uri.parse(url), headers: headers);
    else if(method.toUpperCase() == "POST") res = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));
    else if(method.toUpperCase() == "PUT") res = await http.put(Uri.parse(url), headers: headers, body: jsonEncode(body));
    else if(method.toUpperCase() == "DELETE") res = await http.delete(Uri.parse(url), headers: headers, body: jsonEncode(body));
    else throw Exception("요청 Method가 없습니다.");

    print("restapi url:${url} result:${res.statusCode} ${utf8.decode(res.bodyBytes).trim()}");

    return restapiResult(res);
  }

  //restapi
  restapiResult(var res) {
    Map<String, dynamic> jsonData = json.decode(res.body);
    Map resultData = Map<String, dynamic>();

    //print("response body : ${res.body}");

    if(res.statusCode == 200) {
      resultData['result'] = true;
      resultData['params'] = jsonData;
    } else {
      resultData['result'] = false;
      resultData['statusCode'] = res.statusCode;
      resultData['errorCode'] = jsonData['code'];
      resultData['message'] = jsonData['message'];
    }

    return resultData;
  }

  //restapi result처리
  qRestApiResult(var res) {
    int statusCode = res.statusCode;
    String resultBody = utf8.decode(res.bodyBytes).trim();

    Map<String, dynamic> resultData = {};
    resultData['statusCode'] = statusCode;

    if(resultBody.startsWith('\[')) resultData['body'] = json.decode(resultBody);
    else resultData['body'] = jsonDecode(resultBody);

    print(resultData['body']);

    return resultData;
  }
  //프로필 사진 등록
  requestImageProcess(route,base64Image) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String url = '${server+route}';
    String? tokenValue = sharedPreferences.getString('token');
    print('헤더 토큰 ${tokenValue}');
    var response = await http.post(Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: "Bearer ${tokenValue}"},//넣어야 로그인 인증댐
        body: {
          // 'picture[data]': base64Image,
          // 'person_id' : sharedPreferences.getString('person_id'),
          // 'isDelPicture' : '1',
          // 'resultType' : 'json'
          'file':base64Image
        }
    );
    print(utf8.decode(response.reasonPhrase!.codeUnits));
    print(response.statusCode);
    return response;
  }

  //faceid 등록
  requestFaceProcess(route,base64Image, count) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? tokenValue = sharedPreferences.getString('token');
    String url = '${server+route}';
    print(count.toString());
    var response = await http.post(Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: "Bearer ${tokenValue}"},//넣어야 로그인 인증댐
        body: {
          'idx' : '${count}',
          'file': base64Image,
          'isDel' : 'false'
        }
    );
    return response;
  }

  requestDateRead(route,date) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
    String? familyId = sharedPreferences.getString('family_id');
    String? familyPersonId = sharedPreferences.getString('family_person_id');
    String url = '${server+route}';
    var response = await http.post(Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: "Bearer ${token}"},
        body:{
          'family_id' : familyId,
          'family_person_id' : familyPersonId,
          'startDate' : date.toString(),
          'stopDate' : date.toString(),
        }
    );
    // print(response.body);

    if (response.statusCode == 200) {

      List<dynamic> jsondata = json.decode(response.body);
      return jsondata;
    }else{
      return false;
    }
  }

  requestNoticeDelete(route,familyScheduleId) async{
    String url = '${server+route}';
    var response = await http.post(Uri.parse(url),
        body:{
          'family_notice_id' : familyScheduleId,
        }
    );
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsondata = json.decode(response.body);
      return jsondata;
    }else{
      return false;
    }
  }


  // 로그인 토큰 가져오기
  Future login(_id, _passwd) async {
    String url = '${server}/User/login'; //토큰요청
    String id = _id.text.trim();
    String passwd = _passwd.text.trim();

    var body = {
      'id' : id,
      'passwd': passwd
    };

    Map<String, dynamic> jsonData = {
      "url": url,
      "method": "POST",
      "isToken": false,
      "body":body
    };

    var response = await this.restapi(jsonData);
    return response;
  }

  Future findId(_name, _phone) async {
    Get.dialog(Center(child: CircularProgressIndicator()),
        barrierDismissible: false);
    String apiurl = '${server}/User/findIdProcess'; //토큰요청
    print(_name);
    print(_phone);
    var response = await http.post(Uri.parse(apiurl),
        body: {
          'name': _name,
          'handphone': _phone,
          'type' : 'handphone'
        }
    );
    return response;
  }

  Future findPw(_id, _phone) async {
    Get.dialog(Center(child: CircularProgressIndicator()),
        barrierDismissible: false);
    String apiurl = '${server}/User/watchbookfindPasswdProcess'; //토큰요청
    print(_id);
    print(_phone);
    var response = await http.post(Uri.parse(apiurl),
        body: {
          'id': _id.text.trim(),
          'handphone': _phone.text.trim(),
          'type' : 'handphone'
        }
    );
    if (response.statusCode == 200) {
      //정상신호 일때
      print(response.body);
      Map<String, dynamic> jsondata = json.decode(response.body);
      return jsondata;
    } else {
      return false;
    }
  }

  //구성원 초대
  Future SmartdoorUserInvite(url) async {
    print(url);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? tokenValue = sharedPreferences.getString('token');
    print('헤더 토큰 ${tokenValue}');
    String val = '';
    var response = await http.get(Uri.parse(server+url),
      headers: {HttpHeaders.authorizationHeader: "Bearer ${tokenValue}"},//넣어야 로그인 인증댐
    );
    print('restAPI 바디값 : ${response.body}');
    if (response.statusCode == 200) {
      //정상신호 일때
      // print('restAPI 바디값 : ${response.body}');
      // // Map<String, dynamic> jsondata = json.decode(response.body);
      // var jsondata = json.decode(response.body);
      val = '200';
      return val;
    }else if (response.statusCode == 400){
      print('인증에러');
      val = '400';
      return val;
    }else if (response.statusCode == 401){
      print('인증에러');
      val = '401';
      return val;
    }
  }

  // 로그인 토큰 발급전 post 함수
  Future join(json, url) async {
    var response = await http.post(Uri.parse(server+url),
        body: json
    );
    print(utf8.decode(response.reasonPhrase!.codeUnits));
    print(response.statusCode);
    return response;
  }

  //get 공통함수
  Future get(url) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? tokenValue = sharedPreferences.getString('token');
    print(url);
    print('헤더 토큰 ${tokenValue}');
    var response = await http.get(Uri.parse(server+url),
        headers: {HttpHeaders.authorizationHeader: "Bearer ${tokenValue}"},//넣어야 로그인 인증댐
    );
    print(response.statusCode);
    print(utf8.decode(response.reasonPhrase!.codeUnits));
    print(response.statusCode);
    return response;
  }

  // post 공통함수
  Future post(json, url) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? tokenValue = sharedPreferences.getString('token');
    print('헤더 토큰 ${tokenValue}');
    print('json 값 : ${json}');
    var response = await http.post(Uri.parse(server+url),
        headers: {HttpHeaders.authorizationHeader: "Bearer ${tokenValue}"},//넣어야 로그인 인증댐
        body: json
    );
    print(utf8.decode(response.reasonPhrase!.codeUnits));
    print(response.statusCode);
    return response;
  }

  //put 공통함수
  Future put(json, url) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? tokenValue = sharedPreferences.getString('token');
    print('헤더 토큰 ${tokenValue}');
    print(url);
    var response = await http.put(Uri.parse(server+url),
        headers: {HttpHeaders.authorizationHeader: "Bearer ${tokenValue}"},//넣어야 로그인 인증댐
        body: json
    );
    print(utf8.decode(response.reasonPhrase!.codeUnits));

    return response;
  }

  //delete 공통함수
  delete(url) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? tokenValue = sharedPreferences.getString('token');
    print('헤더 토큰 ${tokenValue}');
    print(url);
    var response = await http.delete(Uri.parse(server+url),
        headers: {HttpHeaders.authorizationHeader: "Bearer ${tokenValue}"},//넣어야 로그인 인증댐
    );
    print(utf8.decode(response.reasonPhrase!.codeUnits));
    print(response.statusCode);
    return response;
  }

  doorControl(con) async {
    String apiurl = '${server+con}';
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print(sharedPreferences.getString('person_id').toString());
    var response = await http.post(Uri.parse(apiurl),
        body: {
          'product_sncode_id':sharedPreferences.getString('product_sncode_id').toString(),
          'person_id':sharedPreferences.getString('person_id').toString(),
          'family_id':sharedPreferences.getString('family_id').toString(),
          'resultType':'json'
        }
    );
    print(response.body);

    if (response.statusCode == 200) {

      return  json.decode(response.body);;
    }else{
      return false;
    }
  }


  requestRTCToken(route,random) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String url = '${server+route}';
    String? sncode =  sharedPreferences.getString('scode');
    print(random);
    var response = await http.post(Uri.parse(url),
        body:{
          'channelName': random,
        }
    );
    print(response.body);

    if (response.statusCode == 200) {
      // List<dynamic> jsondata = json.decode(response.body);
      //jsonDecode(response.body)
      return json.decode(response.body);
    }else{
      return false;
    }
  }

  requestRTCinit(agoratokenid) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? sncode =  sharedPreferences.getString('scode');
    String url = '${server}/AgoraToken/sendMqtt';
    var response = await http.post(Uri.parse(url),
        body:{
          'family_id' : sharedPreferences.getString('family_id').toString(),
          'person_id' : sharedPreferences.getString('person_id'),
          'agora_token_id': agoratokenid.toString(),
          'topic': 'smartdoor/SMARTDOOR/${sncode}',
        }
    );
    print(response.body);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return false;
    }
  }




}
