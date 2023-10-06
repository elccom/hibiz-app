import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:wisemonster/controller/newMember_controller.dart';
import 'package:wisemonster/view/newMember4_view.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/H2.dart';
import 'package:wisemonster/view_model/newMem_view_model.dart';

class newMember1_view extends GetView<NewMemberController>{

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
                    title:Text('이용 약관')
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
                          .height- 140,
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
                                H1(changeValue: '이용 약관', size: 20,),
                                Container(height: 10,),
                                H2(changeValue: '약관 동의 후에 회원가입을 진행해주세요.',)
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                                .size
                                .height - 300,
                            child:SingleChildScrollView(
                                child:Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(0, 30, 0, 15),
                                      padding: const EdgeInsets.fromLTRB(0, 25, 0, 25),
                                      width: MediaQueryData.fromWindow(
                                          WidgetsBinding.instance!.window)
                                          .size
                                          .width,
                                      decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                                color: Color.fromARGB(255, 42, 66, 91)
                                            ),
                                            top: BorderSide(
                                                color: Color.fromARGB(255, 42, 66, 91)
                                            ),
                                          )
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 58,
                                            child: TextButton.icon(
                                              onPressed: (){
                                                NewMemberViewModel.agreeChange2();
                                              },
                                              icon: Align(
                                                  alignment: Alignment.centerRight,
                                                  child: NewMemberViewModel.isAgree ? Image.asset('images/default/radio4.png',width: 20,) : Image.asset('images/default/radio3.png',width: 20,)
                                              ),
                                              label: const Text('(필수) 서비스 이용약관 동의',
                                                style: TextStyle(
                                                    color: Color.fromARGB(255, 42, 66, 91),
                                                    fontSize: 17
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 58,
                                            child: TextButton.icon(
                                              onPressed: (){
                                                NewMemberViewModel.agreeChange3();
                                              },
                                              icon: Align(
                                                  alignment: Alignment.centerRight,
                                                  child: NewMemberViewModel.isAgree2 ? Image.asset('images/default/radio4.png',width: 20,) : Image.asset('images/default/radio3.png',width: 20,)
                                              ),
                                              label: const Text('(필수)개인정보 이용 약관 동의',
                                                style: TextStyle(
                                                    color: Color.fromARGB(255, 42, 66, 91),
                                                    fontSize: 17
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 58,
                                      child: TextButton.icon(
                                        onPressed: (){
                                          NewMemberViewModel.agreeChange();
                                        },
                                        icon: Align(
                                            alignment: Alignment.centerRight,
                                            child: NewMemberViewModel.isAgree && NewMemberViewModel.isAgree2 ? Image.asset('images/default/radio4.png',width: 20,) : Image.asset('images/default/radio3.png',width: 20,)
                                        ),
                                        label: const Text('이용 약관 전체 동의',
                                          style: TextStyle(
                                              color: Color.fromARGB(255, 42, 66, 91)  ,
                                              fontSize: 17
                                          ),
                                        ),
                                      ),
                                    )

                                  ],
                                )
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
                            if(NewMemberViewModel.isAgree && NewMemberViewModel.isAgree2){
                              Get.to(newMember4_view());
                            } else {
                              NewMemberViewModel.dialog();
                            }
                          },
                          child: const Text(
                            "다음",
                            style: TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                          style: (NewMemberViewModel.isAgree && NewMemberViewModel.isAgree2)?ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(
                                  255, 39, 161, 220))
                            :
                              ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(
                              255, 204, 204, 204) ),
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