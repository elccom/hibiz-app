import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:wisemonster/controller/newMember_controller.dart';
import 'package:wisemonster/routes/app_pages.dart';
import 'package:wisemonster/view/newMember3_view.dart';
import 'package:wisemonster/view/newMember4_view.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/H2.dart';
import 'package:wisemonster/view/widgets/NormalTextWidget.dart';
import 'package:wisemonster/view_model/newMem_view_model.dart';

class newMember2_view extends GetView<NewMemberController>{

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
                      title:Text('실명 인증')
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQueryData.fromWindow(
                                    WidgetsBinding.instance!.window)
                                    .size
                                    .width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        NormalTextWidget(changeValue: '※ ',),
                                        Expanded(child: NormalTextWidget(changeValue: '원활한 서비스 이용과 익명 사용자로 인한 피해를 방지하기 위하여 본인 인증을 통한 회원가입을 원칙으로 하고 있습니다.',))
                                      ],
                                    ),
                                    Container(height: 20,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        NormalTextWidget(changeValue: '※ ',),
                                        Expanded(child: NormalTextWidget(changeValue: '수집된 정보는 비밀번호 찾기 등의 본인 확인 용도 외에는 사용되지 않으며, 개인정보 보호법과 개인정보 취급 방침에 의해 보호됩니다.',))
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )),
                      Container(
                          height: 60,
                          child:SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.to(newMember4_view());
                              },
                              child: const Text(
                                "본인 인증",
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