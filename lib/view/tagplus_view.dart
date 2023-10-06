import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/view/nickname_view.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';
import 'package:wisemonster/view_model/camera_view_model.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'dart:io' as i;

import '../controller/camera_controller.dart';
import '../controller/profile_controller.dart';

class TagPlus_view extends GetView<ProfileController> {
  // Build UI
  String userName = '';

  getName() async {
    print('TagPlus_view getName');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userName = sharedPreferences.getString('name')!;
    print('회원이름 호출');
    print(userName);
    return await userName;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      init: ProfileController(),
      builder: (ProfileController) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              iconTheme: const IconThemeData(color: Color.fromARGB(255, 87, 132, 255)),
              title: Text(
                '외출 소지품 등록',
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
            body:
                  Container(
                      padding: const EdgeInsets.fromLTRB(16, 200, 16, 16),
                      width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width,
                      //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
                      height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height - 80,
                      color: Colors.white,
                      child: SingleChildScrollView(
                          physics: ClampingScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                        Row(
                          children: [
                            Expanded(flex: 60,child: TextFieldWidget(tcontroller: ProfileController.tagController, changeValue: ProfileController.tag, hintText: '')),
                            Container(width: 10,),
                            Expanded(flex: 25 ,child: ElevatedButton(onPressed: (){
                              ProfileController.sendTag();
                            }, child: Text('추가')))

                          ],
                        ),
                        Container(height: 30,),
                        Container(
                          width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width,
                          height: 50,
                          child: new ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                            ProfileController.listData['lists']?.length
                                ,
                            itemBuilder: (BuildContext context, int index) {
                              return new Card(
                                margin: EdgeInsets.fromLTRB(0, 5, 10, 5),
                                color: Color.fromARGB(255, 234, 234, 234),
                                child:
                                    // new Text(ProfileController.Tagdata![1]),
                                    new TextButton.icon(
                                    onPressed: (){
                                    ProfileController.deleteTag(index);
                                  },
                                      icon: Icon(
                                        Icons.cancel_outlined,
                                        size: 18,
                                        color: Colors.black,
                                      ),
                                      label:
                                        Text('${ProfileController.listData['lists'][index]['name']}',
                                            style: TextStyle(
                                            color: Colors.black
                                        )
                                        ),
                                      )
                              );
                            },
                          ),
                        )
                      ]))
                )),
      ),
    );
  }
}
