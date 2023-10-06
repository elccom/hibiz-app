import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/QrWidget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wisemonster/view/widgets/InitialWidget.dart';

class registration2_view extends GetView{
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    initState();

    return WillPopScope(
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
                          .height- 146,
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

                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    H1(changeValue: '제품 등록',size: 20,),
                                    Container(height: 20,),
                                    Text('아래 QR코드 촬영 버튼을 누르고 미러 안내 화면에 표시된\n제품 등록 QR코드를 촬영하여 주십시오.'
                                      ,style: TextStyle(
                                          fontSize: 15,
                                          height: 1.5
                                      ),
                                    ),
                                  ],
                                ),
                                Container(height: 82,),
                                TextButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(120.0),
                                    )),
                                  ),
                                  onPressed: () {
                                    Get.dialog(QrWidget());
                                  },
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.qr_code_scanner,
                                            size: 32, color: Color.fromARGB(255, 87, 132, 255)),
                                        Text('QR코드 촬영',style: TextStyle(
                                            fontSize: 14,
                                            height: 1.5
                                        ),),
                                      ],
                                    ),
                                    margin: EdgeInsets.fromLTRB(25, 25, 25, 25),
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color.fromARGB(255, 87, 132, 255)
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(100))),
                                  ),)
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
                            Get.back();
                          },
                          child: Text(
                            '뒤로가기',
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
              )),
        ));

  }

  Future<bool> _goBack(BuildContext context) async {
    return true;
  }

  void initState() {
   getPermission().then((value) async {
     print("카메라등 권한 : ${value}");

     if(!value)
       Get.dialog(InitialWidget(serverMsg: '카메라 사용 권한이 없습니다. 권한 설정 후 이용해 주세요.'));
   });
  }

  Future<bool>getPermission()async{
    if(Platform.isIOS) {
      return Future.value(false);
    } else {
      Map<Permission, PermissionStatus>statuses = await [Permission.camera].request();

      print("카메라 권한설정");
      print(statuses);

      if(statuses[Permission.camera]!.isGranted) {
        return Future.value(true);
      } else {
        return Future.value(false);
      }
    }
  }
}