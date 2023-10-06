import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';
import 'package:wisemonster/view_model/camera_view_model.dart';
import 'package:wisemonster/view_model/home_view_model.dart';

import '../controller/camera_controller.dart';
import '../controller/profile_controller.dart';

class nickname_view extends GetView<ProfileController> {
  // Build UI
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
        init: ProfileController(),
        builder: (ProfileController) => MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                resizeToAvoidBottomInset : false,
                appBar: AppBar(
                  elevation: 0,
                  centerTitle: true,
                  backgroundColor: Color.fromARGB(255, 255, 255, 255),
                  iconTheme: const IconThemeData(color: Color.fromARGB(255, 87, 132, 255)),
                  title: Text(
                    '프로필 수정',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 87, 132, 255),
                    ),
                  ),
                  automaticallyImplyLeading: true,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_outlined),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
                body: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          padding: EdgeInsets.fromLTRB(16, 40, 16, 0),
                          width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width - 32,
                          height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height - 186,
                          color: Colors.white,
                          child: SingleChildScrollView(
                              child: Column(children: [
                            H1(changeValue: '닉네임 등록', size: 20),
                            Container(
                              height: 80,
                            ),
                            TextFieldWidget(
                              tcontroller: ProfileController.nicknameController,
                              changeValue: ProfileController.nickname,
                              hintText: '변경할 닉네임을 입력해 주세요.',
                            ),
                          ]))),
                      Container(
                          height: 60,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                ProfileController.sendNickname();
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
                    ],
                  ),
                ),
              ),
            ));
  }
}
