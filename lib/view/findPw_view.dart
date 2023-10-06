import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view_model/findPw_view_model.dart';
import 'package:wisemonster/view_model/home_view_model.dart';

import '../view_model/findId_view_model.dart';

class findPw_view extends GetView<FindPwViewModel>{
  findPw_view({Key? key}) : super(key: key);
  String phone = '';
  String id = '';
  var _phone = TextEditingController();
  var _id = TextEditingController();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return GetBuilder<FindPwViewModel>(
        init: FindPwViewModel(),
        builder: (FindPwViewModel) =>
            WillPopScope(
                onWillPop: () => _goBack(context),
                child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    appBar: AppBar(
                        centerTitle: true,
                        backgroundColor: Color.fromARGB(255, 42, 66, 91),
                        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
                        title:Text('비밀번호 찾기')
                    ),
                    body: Container(
                      padding: const EdgeInsets.only(top: 90),
                      width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                          .size
                          .width,
                      //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
                      height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                          .size
                          .height,
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                              padding: const EdgeInsets.fromLTRB(0, 13, 0, 13),
                              width: MediaQueryData.fromWindow(
                                  WidgetsBinding.instance!.window)
                                  .size
                                  .width,
                              height: MediaQueryData.fromWindow(
                                  WidgetsBinding.instance!.window)
                                  .size
                                  .height - 280,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  H1(changeValue: '아이디를 입력해주세요.', size: 20,),
                                  Container(height: 20,),
                                  TextField(
                                      controller: _id, //set id controller
                                      style: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 206, 206, 206), fontSize: 16),
                                      decoration: const InputDecoration(
                                        hintText: '아이디',
                                        hintStyle: TextStyle(color: Color.fromARGB(
                                            255, 206, 206, 206)),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide:
                                            BorderSide(color: Color.fromARGB(255, 43, 43, 43))),
                                      ),
                                      onChanged: (value) {
                                        //변화된 id값 감지
                                        id = value;
                                      }),
                                  Container(height: 30,),
                                  H1(changeValue: '휴대폰 번호를 입력해주세요.', size: 20),
                                  Container(height: 20,),
                                  TextField(
                                      controller: _phone, //set id controller
                                      style: const TextStyle(
                                          color: Color.fromARGB(
                                              255, 206, 206, 206), fontSize: 16),
                                      decoration: const InputDecoration(
                                        hintText: '- 없이 입력해주세요.',
                                        hintStyle: TextStyle(color: Color.fromARGB(
                                            255, 206, 206, 206)),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide:
                                            BorderSide(color: Color.fromARGB(255, 43, 43, 43))),
                                      ),

                                      onChanged: (value) {
                                        //변화된 id값 감지
                                        phone = value;
                                      })
                                ],),),
                            Container(
                                height: 60,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      FindPwViewModel.findPw(_id.text, _phone.text);
                                    },
                                    child: const Text(
                                      "완료",
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 27, 131, 225),
                                    ),
                                  ),
                                ))
                          ])
                        ],
                      ),
                    )
                )
            )
    );
  }

  Future<bool> _goBack(BuildContext context) async {
    return true;
  }
}