import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wisemonster/controller/newMember_controller.dart';
import 'package:wisemonster/view/newMember5_view.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';
import 'package:wisemonster/view/widgets/PasswdFieldWidget.dart';
import 'package:wisemonster/view_model/newMem_view_model.dart';
import 'package:wisemonster/view/widgets/AlertWidget.dart';

class newMember4_view extends GetView<NewMemberController> {
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return GetBuilder<NewMemberViewModel>(
        init: NewMemberViewModel(),
        builder: (NewMemberViewModel) =>
            WillPopScope(
                onWillPop: () => _goBack(context),
                child: Scaffold(
                  // resizeToAvoidBottomInset: false,
                  appBar: AppBar(
                      centerTitle: true,
                      backgroundColor: Color.fromARGB(255, 42, 66, 91),
                      iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
                      title:Text('회원가입')
                  ),
                  body: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child:
                      Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                          width: MediaQueryData
                              .fromWindow(WidgetsBinding.instance!.window)
                              .size
                              .width,
                          //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
                          height: MediaQueryData
                              .fromWindow(WidgetsBinding.instance!.window)
                              .size
                              .height - 140,
                          color: Colors.white,
                            child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    H1(changeValue: '이름', size: 20,),
                                    TextFieldWidget(tcontroller: NewMemberViewModel.nameController, changeValue: NewMemberViewModel.name, hintText: '이름을 입력해주세요.',),
                                    Container(height: 30,),
                                    H1(changeValue: '아이디',size: 20,),
                                    TextFieldWidget(tcontroller: NewMemberViewModel.idController, changeValue: NewMemberViewModel.id, hintText: '아이디를 입력해주세요.',),
                                    Container(height: 30,),
                                    H1(changeValue: '휴대폰 번호',size: 20,),
                                    TextFieldWidget(tcontroller: NewMemberViewModel.phoneController, changeValue: NewMemberViewModel.phone, hintText: '휴대폰 번호를 입력해주세요.',),
                                    Container(height: 30,),
                                    H1(changeValue: '비밀번호',size: 20,),
                                    PasswdFieldWidget(tcontroller: NewMemberViewModel.passwdController, changeValue: NewMemberViewModel.passwd, hintText: '영문, 숫자, 특수문자 포함 8~16자 이내',),
                                    Container(height: 30,),
                                    H1(changeValue: '비밀번호 확인',size: 20,),
                                    PasswdFieldWidget(tcontroller: NewMemberViewModel.pwcheckController, changeValue: NewMemberViewModel.pwcheck, hintText: '비밀번호를 한 번 더 입력해주세요.',),
                                  ],
                                )),
                          ),
                      Container(
                          height: 60,
                          child:SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                print('버튼');
                                NewMemberViewModel.requestJoinProcess();
                              },
                              child: const Text(
                                "회원가입",
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
                  )
                  ),
                )
            )
    );
  }

  Future<bool> _goBack(BuildContext context) async {
    return true;
  }
}
