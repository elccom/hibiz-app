import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:wisemonster/controller/splash_controller.dart';

class splash_view extends GetView<SplashController> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final controller = Get.put(SplashController());
    return WillPopScope(
        onWillPop: () => _goBack(context),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
              width:
              MediaQueryData
                  .fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .width,
              //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
              height:
              MediaQueryData
                  .fromWindow(WidgetsBinding.instance!.window)
                  .size
                  .height,
              decoration: const BoxDecoration(
                gradient:
                LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color.fromARGB(255, 84, 99, 172),
                    Color.fromARGB(255, 39, 161, 220)
                  ],
                ),

              ),
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 71,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 202,
                          height: 56,
                          alignment: Alignment.center,
                          child: Image.asset(
                            'images/default/w_logo.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.centerLeft,
                          ), //title text
                        )
                      ],
                    ),),
                  Expanded(
                    flex: 29,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 6,
                          child: Obx(() => LinearProgressIndicator(
                            valueColor: const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 255, 255, 255)),
                            value: controller.progress.value,
                            minHeight: 6,
                          )),
                        )
                      ],
                    ),
                  )
                ],
              )),
        ));
    throw UnimplementedError();
  }

  Future<bool> _goBack(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('어플을 종료하시겠어요?'),
            actions: <Widget>[
              TextButton(
                child: const Text('네'),
                onPressed: () => Navigator.pop(context, true),
              ),
              TextButton(
                child: const Text('아니오'),
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ),
    ).then((value) => value ?? false);
  }
}
