
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:wisemonster/view/home_view.dart';

import '../controller/cameraAuth_controller.dart';
import '../controller/camera_controller.dart';

class cameraAuth_view extends GetView<CameraAuthController> {

  // Build UI
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CameraAuthController>(
      init:CameraAuthController(),
      builder:(CameraController)=>
      MaterialApp(
          debugShowCheckedModeBanner: false,
      home:
          Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              iconTheme: const IconThemeData(color: Color.fromARGB(255, 44, 95, 233)),
              centerTitle: true,
              title: Text('페이스 아이디 등록',
                  style: TextStyle(
                      color: Color.fromARGB(255, 44, 95, 233), fontWeight: FontWeight.bold, fontSize: 20)),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_outlined),
                onPressed: () {
                  Get.offAll(home_view());
                },
              ),
            ),
            body: Container(
              margin: EdgeInsets.fromLTRB(16, 5, 16, 0),
              width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width - 32,
              height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height,
              child:
          Column(
            children: [
              Text('종료시 초기화 됩니다.',style: TextStyle(color: Colors.red),),
              Text('${CameraController.count}/20')
              ,
              Container(height: 5,),
              Container(
                height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height - 230,
                child: CameraController.isCameraInitialized
                  ? AspectRatio(
                aspectRatio: 1 / CameraController.controller!.value.aspectRatio,
                child: CameraController.controller!.buildPreview(),
              )
                  : Container(),),
              InkWell(
                onTap: () async {
                  for(int i = 0; i<20; i++){
                    sleep(Duration(seconds: 1));
                    await CameraController.takePicture();
                  }
                  // XFile? rawImage = await CameraController.takePicture();
                  // File imageFile = File(rawImage!.path);
                  //
                  // int currentUnix = DateTime.now().millisecondsSinceEpoch;
                  // final directory = await getApplicationDocumentsDirectory();
                  // String fileFormat = imageFile.path.split('.').last;
                  //
                  // await imageFile.copy(
                  //   '${directory.path}/$currentUnix.$fileFormat',
                  // );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.circle, color: Colors.red, size: 80),
                    Icon(Icons.circle, color: Colors.white, size: 65),
                  ],
                ),
              )
            ],
          ))

          )
        ,
    ));
  }



}
