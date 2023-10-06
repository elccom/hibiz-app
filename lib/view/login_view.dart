import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wisemonster/view/findId_view.dart';
import 'package:wisemonster/view/findPw_view.dart';
import 'package:wisemonster/view/newMember1_view.dart';
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';
import 'package:wisemonster/view_model/login_view_model.dart';

class login_view extends GetView<LoginViewModel>{
  login_view({Key? key}) : super(key: key);
  bool _isKakaoTalkInstalled = false;

  String id = '';
  String passwd = '';

  final _id = TextEditingController();
  final _passwd = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent
          //color set to transperent or set your own color
        ));
    return GetBuilder<LoginViewModel>(
        init: LoginViewModel(),
        builder: (LoginViewModel) =>
            WillPopScope(
              onWillPop: () => _goBack(context),
              child: Scaffold(
                body: InkWell(
                    onTap: () => _isKakaoTalkInstalled,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      constraints:
                      BoxConstraints(minHeight: MediaQuery.of(context).size.height
                        //set minimum height equal to 100% of VH
                      ),
                      width:
                      MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                          .size
                          .width,
                      //make width of outer wrapper to 100%
                      //show linear gradient background of page
                      child: SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width:
                                MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                                    .size
                                    .width,
                                height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                                    .size
                                    .height-20,
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        height: 70,
                                      ),
                                      Container(
                                          width: 202,
                                          height: 32,
                                          child:Image.asset(
                                            'images/default/logo.png',
                                            fit: BoxFit.contain,
                                            alignment: Alignment.center,
                                          )//title text
                                      ),
                                      Container(
                                        height: 50,
                                      ),
                                      Container(
                                        width: 264,
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '로그인',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Color.fromARGB(255, 84, 99, 172)
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            TextFieldWidget(tcontroller: _id, changeValue: id, hintText: '아이디를 입력해주세요.',),
                                            Container(height: 30),
                                  TextFormField(
                                    keyboardType: TextInputType.text,
                                    controller: _passwd,
                                    obscureText: LoginViewModel.passwordVisible,//This will obscure text dynamically
                                    decoration: InputDecoration(
                                      hintText: '비밀번호를 입력해주세요.',
                                      hintStyle: TextStyle(
                                          fontSize: 17,
                                          color: Color.fromARGB(255, 222, 222, 222)
                                      ),
                                      // Here is key idea
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                          LoginViewModel.passwordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Theme.of(context).primaryColorDark,
                                        ),
                                        onPressed: () {
                                          // Update the state i.e. toogle the state of passwordVisible variable
                                            LoginViewModel.changeObscure();
                                        },
                                      ),
                                    ),
                                  ),
                                            Container(height: 20),
                                            // Row(
                                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            //   mainAxisSize: MainAxisSize.max,
                                            //   children: [
                                            //     Expanded(
                                            //       flex:1,
                                            //       child: Obx(() =>
                                            //           Transform.scale(
                                            //               scale: 0.8,
                                            //               child:
                                            //               ListTileTheme(
                                            //                   horizontalTitleGap: 0,
                                            //                   child:
                                            //               CheckboxListTile(
                                            //                 contentPadding: EdgeInsets.zero,
                                            //                 title: Text('아이디 저장',
                                            //                   style: TextStyle(
                                            //                       fontSize: 18
                                            //                   ),
                                            //                 ),
                                            //                 controlAffinity: ListTileControlAffinity.leading,
                                            //                 value: LoginViewModel.isObscure.isTrue,
                                            //                 onChanged: (value) {
                                            //                   LoginViewModel.changeObscure();
                                            //                 },
                                            //               )
                                            //             // Checkbox(
                                            //             //
                                            //             //   side: BorderSide(width: 1, color: Color.fromARGB(255, 43, 43, 43)),
                                            //             //   checkColor: Colors.white,
                                            //             //   value: LoginViewModel.isObscure.isTrue,
                                            //             //   onChanged: (value) {
                                            //             //     LoginViewModel.changeObscure();
                                            //             //   },
                                            //             //
                                            //             // ),
                                            //           ),
                                            //       ),)
                                            //     ),
                                            //     Expanded(
                                            //       flex:1,
                                            //       child: Obx(() =>
                                            //           Transform.scale(
                                            //               scale: 0.8,
                                            //               child:
                                            //               ListTileTheme(
                                            //                   horizontalTitleGap: 0,
                                            //                   child:
                                            //               CheckboxListTile(
                                            //                 contentPadding: EdgeInsets.zero,
                                            //                 title: Text('자동 로그인',
                                            //                 style: TextStyle(
                                            //                   fontSize: 18
                                            //                 ),
                                            //                 ),
                                            //                 controlAffinity: ListTileControlAffinity.leading,
                                            //                 value: LoginViewModel.isAuto.isTrue,
                                            //                 onChanged: (value) {
                                            //                   LoginViewModel.autoLogin();
                                            //                 },
                                            //               )
                                            //             // Checkbox(
                                            //             //   side: BorderSide(width: 1, color: Color.fromARGB(255, 43, 43, 43)),
                                            //             //   checkColor: Colors.white,
                                            //             //   value: LoginViewModel.isAuto.isTrue,
                                            //             //   onChanged: (value) {
                                            //             //     LoginViewModel.autoLogin();
                                            //             //   },
                                            //             // ),
                                            //           ),
                                            //       ),)
                                            //     ),
                                            //   ],
                                            // ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(0, 80, 0, 10),
                                        width: 328,
                                        child: SizedBox(
                                          height: 48,
                                          width: double.infinity,
                                          child: ElevatedButton(
                                              onPressed: () {
                                                LoginViewModel.login(_id, _passwd,);
                                              },
                                              child: const Text(
                                                "로그인",
                                                style:
                                                TextStyle(fontSize: 19, color: Colors.white),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                shadowColor: Colors.white,
                                                backgroundColor: const Color.fromARGB(255, 39, 161, 220),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              )
                                          ),
                                        ),
                                      ),
                                      Container(
                                          width: 400,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              TextButton(
                                                child: const Text(
                                                  '아이디 찾기',
                                                  style: TextStyle(
                                                    color: Color.fromARGB(255, 43, 43, 43),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Get.to(findId_view());
                                                },
                                              ),
                                              Container(
                                                width: 1,
                                                height: 14,
                                                color: Color.fromARGB(255, 43, 43, 43),
                                              ),
                                              TextButton(
                                                child: const Text(
                                                  '비밀번호 찾기',
                                                  style: TextStyle(
                                                    color: Color.fromARGB(255, 43, 43, 43),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Get.to(findPw_view());
                                                },
                                              ),
                                              Container(
                                                width: 1,
                                                height: 14,
                                                color: Color.fromARGB(255, 43, 43, 43),
                                              ),
                                              TextButton(
                                                child: const Text(
                                                  '회원가입',
                                                  style: TextStyle(
                                                    color: Color.fromARGB(255, 43, 43, 43),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Get.to(newMember1_view());
                                                },
                                              )
                                            ],
                                          )),
                                      // Container(
                                      //   width: 320,
                                      //   margin: const EdgeInsets.only(bottom: 45.00),
                                      //   child: Column(
                                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      //     children: <Widget>[
                                      //       SizedBox(
                                      //         width: MediaQuery.of(context).size.width,
                                      //         height: 48,
                                      //         child: RaisedButton(
                                      //             onPressed:(){
                                      //               LoginViewModel.kakaoLoginButtonPressed();
                                      //             },
                                      //             color: Colors.yellow,
                                      //             child: Row(
                                      //               crossAxisAlignment:
                                      //               CrossAxisAlignment.center,
                                      //               children: <Widget>[
                                      //                 Image.network(
                                      //                   'https://watchbook.tv/image/app/login/kakao.png',
                                      //                   width: 36,
                                      //                   height: 36,
                                      //                   alignment: Alignment.bottomLeft,
                                      //                 ),
                                      //                 const Expanded(
                                      //                     child: Padding(
                                      //                       padding: EdgeInsets.only(right: 36),
                                      //                       child: Text(
                                      //                         '카카오로 시작하기',
                                      //                         textAlign: TextAlign.center,
                                      //                         style: TextStyle(
                                      //                           fontSize: 14,
                                      //                           color: Colors.black87,
                                      //                         ),
                                      //                       ),
                                      //                     )),
                                      //               ],
                                      //             )),
                                      //       ),
                                      //       Container(
                                      //         height: 10,
                                      //       ),
                                      //       SizedBox(
                                      //         width: MediaQuery.of(context).size.width,
                                      //         height: 48,
                                      //         child: RaisedButton(
                                      //             onPressed: (){
                                      //               LoginViewModel.facebookLoginButtonPressed();
                                      //             },
                                      //             color: const Color.fromARGB(255, 60, 90, 154),
                                      //             child: Row(
                                      //               crossAxisAlignment:
                                      //               CrossAxisAlignment.center,
                                      //               children: <Widget>[
                                      //                 Image.network(
                                      //                   'https://watchbook.tv/image/app/login/facebook.png',
                                      //                   width: 36,
                                      //                   height: 36,
                                      //                   alignment: Alignment.bottomLeft,
                                      //                 ),
                                      //                 const Expanded(
                                      //                     child: Padding(
                                      //                       padding: EdgeInsets.only(right: 36),
                                      //                       child: Text(
                                      //                         '페이스북으로 시작하기',
                                      //                         textAlign: TextAlign.center,
                                      //                         style: TextStyle(
                                      //                           fontSize: 14,
                                      //                           color: Colors.white,
                                      //                         ),
                                      //                       ),
                                      //                     )),
                                      //               ],
                                      //             )),
                                      //       ),
                                      //       Container(
                                      //         height: 10,
                                      //       ),
                                      //       SizedBox(
                                      //         width: MediaQuery.of(context).size.width,
                                      //         height: 48,
                                      //         child: RaisedButton(
                                      //             onPressed: () {
                                      //               LoginViewModel.naverLoginButtonPressed();
                                      //             },
                                      //             color: const Color.fromARGB(255, 6, 190, 52),
                                      //             child: Row(
                                      //               crossAxisAlignment:
                                      //               CrossAxisAlignment.center,
                                      //               children: <Widget>[
                                      //                 Image.network(
                                      //                   'https://watchbook.tv/image/app/login/naver.png',
                                      //                   width: 36,
                                      //                   height: 36,
                                      //                   alignment: Alignment.bottomLeft,
                                      //                 ),
                                      //                 const Expanded(
                                      //                     child: Padding(
                                      //                       padding: EdgeInsets.only(right: 36),
                                      //                       child: Text(
                                      //                         '네이버로 시작하기',
                                      //                         textAlign: TextAlign.center,
                                      //                         style: TextStyle(
                                      //                           fontSize: 14,
                                      //                           color: Colors.white,
                                      //                         ),
                                      //                       ),
                                      //                     )),
                                      //               ],
                                      //             )),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                    ]),
                              ),
                            ]),
                      ),
                    )),
              )
            )
    );
  }

  Widget errmsg(String text) {
    //에러 메세지 위젯
    return Container(
      padding: const EdgeInsets.all(10.00),
      margin: const EdgeInsets.only(bottom: 5.00),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.red,
          border: Border.all(color: Colors.red[300]!, width: 2)),
      child: Row(children: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 6.00),
          child: const Icon(Icons.info, color: Colors.white),
        ), // icon for error message
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
        //show error message text
      ]),
    );
  }

  Future<bool> _goBack(BuildContext context) async {
    return true;
  }

}