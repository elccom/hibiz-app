import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wisemonster/view/widgets/InitialWidget.dart';

import '../api/api_services.dart';
import '../view/login_view.dart';

class CameraAuthController extends GetxController{
  final ImagePicker _picker = ImagePicker();
  File? image;
  ApiServices api = ApiServices();
  int count = 0;
  XFile? file;

  List<CameraDescription> cameras = [];
  CameraController? controller;
  bool isCameraInitialized = false;

  Future<XFile?> takePicture() async {

    final CameraController? cameraController = controller;
    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      // sleep(Duration(seconds: 2));
      file = await cameraController.takePicture();
      if (file != null) {
        image = File(file!.path);
        final bytes = image?.readAsBytesSync();
        String base64Image = "data:image/png;base64," + base64Encode(bytes!);
        print(base64Image);
        api.requestFaceProcess('/User/faceUpload', base64Image, count+1).then((value) {
          if(value.statusCode == 200) {
            print(value.body);
            print('${count} : 카운트 수');
            if (count == 19){
              print('끝끝끝');
              // sleep(Duration(seconds: 1));
              Get.back();
              Get.snackbar(
                '알림',
                '페이스 아이디 등록이 완료되었습니다.'
                ,
                duration: Duration(seconds: 5),
                backgroundColor: const Color.fromARGB(
                    255, 39, 161, 220),
                icon: Icon(Icons.info_outline, color: Colors.white),
                forwardAnimationCurve: Curves.easeOutBack,
                colorText: Colors.white,
              );
            } else {
              count++;
            }
            update();

          } else if(value.statusCode == 401) {
            Get.offAll(login_view());
            Get.snackbar(
              '알림',
              utf8.decode(value.reasonPhrase!.codeUnits)
              ,
              duration: Duration(seconds: 5),
              backgroundColor: const Color.fromARGB(
                  255, 39, 161, 220),
              icon: Icon(Icons.info_outline, color: Colors.white),
              forwardAnimationCurve: Curves.easeOutBack,
              colorText: Colors.white,
            );
          } else {
            Get.snackbar(
              '알림',
              utf8.decode(value.reasonPhrase!.codeUnits)
              ,
              duration: Duration(seconds: 5),
              backgroundColor: const Color.fromARGB(
                  255, 39, 161, 220),
              icon: Icon(Icons.info_outline, color: Colors.white),
              forwardAnimationCurve: Curves.easeOutBack,
              colorText: Colors.white,
            );
          }
        });

      return file;}
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller

        controller = cameraController;
        update();

    // Update UI if controller updated
    cameraController.addListener(() {
      update();
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the Boolean
    isCameraInitialized = controller!.value.isInitialized;
    update();
  }


  @override
  void onInit() async{
    getPermission().then((value) async {
      print("카메라와 마이크 사용 권한 : ${value}");

      if (!value)
        Get.dialog(
            InitialWidget(serverMsg: '카메라와 마이크 사용 권한이 없습니다. 권한 설정 후 이용해 주세요.'));
      else {
        print("CameraAuthController init!");
        // api.requestFaceDelete('/Person/faceDeleteAllProcess').then((value) {
        //   if (value['result'] == true) {
        //       Get.snackbar(
        //         '알림',
        //         '촬영 버튼을 눌러 등록해주십시오.\n얼굴을 돌려 다양한 각도에서 촬영해주세요.'
        //         ,
        //         duration: Duration(seconds: 5),
        //         backgroundColor: const Color.fromARGB(
        //             255, 39, 161, 220),
        //         icon: Icon(Icons.info_outline, color: Colors.white),
        //         forwardAnimationCurve: Curves.easeOutBack,
        //         colorText: Colors.white,
        //       );
        //     print(value);
        //     update();
        //   } else {
        //     Get.snackbar(
        //       '알림',
        //       value['massage']
        //       ,
        //       duration: Duration(seconds: 5),
        //       backgroundColor: const Color.fromARGB(
        //           255, 39, 161, 220),
        //       icon: Icon(Icons.info_outline, color: Colors.white),
        //       forwardAnimationCurve: Curves.easeOutBack,
        //       colorText: Colors.white,
        //     );
        //   }
        //
        // });

        try {
          WidgetsFlutterBinding.ensureInitialized();
          cameras = await availableCameras();
        } on CameraException catch (e) {
          print('Error in fetching the cameras: $e');
        }
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
        onNewCameraSelected(cameras[1]);
        super.onInit();
        print('엔진');
      }
    });
  }
  @override
  void onClose() {

    controller?.dispose();
    super.onClose();

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  //권한검사
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