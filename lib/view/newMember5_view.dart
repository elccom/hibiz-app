import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:wisemonster/controller/newMember_controller.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view_model/newMem_view_model.dart';

class newMember5_view extends GetView<NewMemberController>{

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return GetBuilder<NewMemberViewModel>(
        init: NewMemberViewModel(),
        builder: (NewMemberViewModel) =>
            WillPopScope(
                onWillPop: () => _goBack(context),
                child: Scaffold(
                  appBar: AppBar(
                      centerTitle: true,
                      backgroundColor: Color.fromARGB(255, 42, 66, 91),
                      iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
                      title:
                      Container(
                        width: 132,
                        height: 20,
                        child: Image.asset(
                          'images/default/w_logo.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                        ),
                      )
                  ),
                  resizeToAvoidBottomInset: false,
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
                          width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                              .size
                              .width,
                          //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
                          height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                              .size
                              .height- 186,
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              H1(changeValue: '제품 등록',size: 20,),
                              Container(height: 15,),
                              Text('회원가입이 완료되었습니다.\n로그인 후 서비스를 이용해 주세요.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      height: 1.5,
                                      fontSize: 15,
                                      color: Color.fromARGB(255, 43, 43, 43))),
                            ],
                          )),
                      Container(
                          height: 60,
                          child:SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.offAll(login_view());
                              },
                              child: const Text(
                                "로그인",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                    255, 39, 161, 220),
                              ),
                            ),
                          )
                      )
                    ],
                  ),
                ))
    );
  }
  Future<bool> _goBack(BuildContext context) async {
    return true;
  }


}