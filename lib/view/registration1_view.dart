import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:wisemonster/controller/newMember_controller.dart';
import 'package:wisemonster/view/registration2_view.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/H2.dart';
import 'package:wisemonster/view_model/login_view_model.dart';

class registration1_view extends GetView<NewMemberController>{
  final login = Get.put(LoginViewModel());
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
            return WillPopScope(
                onWillPop: () => _goBack(context),
                child: Scaffold(
                appBar: AppBar(
                    leading: IconButton(
                      onPressed: () {
                        login.logoutProcess();

                      },
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.fromLTRB(0, 22, 0, 22),
                          backgroundColor: Color.fromARGB(255, 255, 255, 255)),
                      icon: Icon(Icons.logout, color: Colors.white,),
                    ),
                    automaticallyImplyLeading: false,
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
                  body: Container(
                      width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width,
                      height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height - 20,
                      child:
                      Column(
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
                                  .height - 146,

                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: MediaQueryData.fromWindow(
                                        WidgetsBinding.instance!.window)
                                        .size
                                        .width,

                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            H1(changeValue: '제품 등록',size: 20,),
                                          ],
                                        ),
                                        Container(height: 20,),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            H2(changeValue: '1. ',),
                                            Expanded(child: H2(changeValue: '미러 앞에서 전원을 켜고 설치를 진행합니다.',))
                                          ],
                                        ),
                                        Container(height: 15,),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            H2(changeValue: '2. ',),
                                            Expanded(child: H2(changeValue: '미러 안내 화면에서 QR 등록 화면이 보이면\n아래 다음을 누르고 진행해주세요.',))
                                          ],
                                        ),
                                        Container(height: 30,),
                                        Container(height: 30,),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('※ ',
                                              style: TextStyle(
                                                  color: Color.fromARGB(255, 255, 0, 0),
                                                  fontSize: 15
                                              ),),
                                            Expanded(child: Text('위 화면이 보이지 않는다면 이미 마스터가 존재하는 제품입니다. 구성원에게 확인 후 마스터가 없다면 제품의 초기화 버튼을 통해 초기화 진행 후 다시 시도해주세요.',
                                              style: TextStyle(
                                                  color: Color.fromARGB(255, 255, 0, 0),
                                                  fontSize: 15
                                              ),
                                            ))
                                          ],
                                        ),
                                        Container(height: 30,),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                          Container(
                            height: 60,
                            child:
                            SizedBox(
                              width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width,
                              height: 60,
                              child: ElevatedButton(
                                  onPressed: () {
                                    Get.to(registration2_view());
                                  },
                                  child: Text(
                                    '다음',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 87, 132, 255),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero))
                              ),
                            ),


                          )
                        ],
                      )
                  ),
                ));

  }
  Future<bool> _goBack(BuildContext context) async {
    return true;
  }


}