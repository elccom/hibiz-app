import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

import '../api/api_services.dart';
import '../view/widgets/SnackBarWidget.dart';
import '../view_model/camera_view_model.dart';
import '../view_model/home_view_model.dart';
class CameraController extends GetxController{
  ApiServices api = ApiServices();
  
  String appId = "554d4edeb650484c92fd9a6e48ff67bf";
  String channelName = "wisemonster";
  String token = "";
  String token2 = "007eJxTYPBqO6r2zMDy127em7Ezr8+748e5lK18kmzGg1znhLkGunsUGExNTVJMUlNSk8xMDUwsTJItjdJSLBPNUk0s0tLMzJPS7p3vS24IZGRw6sxnYIRCEJ+boTyzODU3P6+4JLWIgQEAQtMi6Q==";

  int uid = 0; // uid of the local user

  int? remoteUid; // uid of the remote user
  bool isJoined = false; // Indicates if the local user has joined the channel
  late RtcEngine agoraEngine; // Agora engine instance
  
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

// Display local video preview
  Widget localPreview() {
    if (isJoined == true) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(uid: uid),
        ),
      );
    } else {
      return Text(
        '통화 버튼을 눌러 도어와 연결해주세요.',
        textAlign: TextAlign.center,
        style:TextStyle(
            color: Color.fromARGB(255, 44, 233, 94),
            fontSize: 20
        )
      );
    }
  }

// Display remote user's video
  Widget remoteVideo() {
    if (remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(uid: remoteUid),
          connection: RtcConnection(channelId: channelName),
        ),
      );
    } else {
      String msg = '';
      if (isJoined) msg = '유저연결을 기다리는 중 입니다.';
      return Text(
        msg,
        textAlign: TextAlign.center,
      );
    }
  }

  void join() async {
    await agoraEngine.startPreview();
    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    print(token);
    print(channelName);
    print(uid);

    await agoraEngine.joinChannel(
      token: token2,
      channelId: channelName,
      options: options,
      uid: uid,
    );
  }

   void leave() async {
    isJoined = false;
    remoteUid = null;
    await agoraEngine.leaveChannel();
    update();
    Get.back();
  }

  showMessage(String message) {
    Get.snackbar(
      '알림',
      // '다른 QR코드를 촬영하셨거나 도어의 정보가 다릅니다.\n다시 촬영해주세요.'
      message
      ,
      duration: Duration(seconds: 5),
      backgroundColor: const Color.fromARGB(
          255, 39, 161, 220),
      icon: Icon(Icons.info_outline, color: Colors.white),
      forwardAnimationCurve: Curves.easeOutBack,
      colorText: Colors.white,
    );
  }

  Future<void> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
    await [Permission.microphone, Permission.camera].request();
    Get.snackbar(
      '알림',
      // '다른 QR코드를 촬영하셨거나 도어의 정보가 다릅니다.\n다시 촬영해주세요.'
      token2
      ,
      duration: Duration(seconds: 5),
      backgroundColor: const Color.fromARGB(
          255, 39, 161, 220),
      icon: Icon(Icons.info_outline, color: Colors.white),
      forwardAnimationCurve: Curves.easeOutBack,
      colorText: Colors.white,
    );
    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(
        appId: '554d4edeb650484c92fd9a6e48ff67bf',

      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    // await agoraEngine.setClientRole( role: ClientRoleType.clientRoleBroadcaster);
    await agoraEngine.enableVideo();

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          showMessage("Local user uid:${connection.localUid} joined the channel");
          isJoined = true;
          print('조인완료');
          update();
        },
        onUserJoined: (RtcConnection connection, int _remoteUid, int elapsed) {
          showMessage("Remote user uid:$_remoteUid joined the channel");
          remoteUid = _remoteUid;
          update();
        },
        onUserOffline: (RtcConnection connection, int _remoteUid,
            UserOfflineReasonType reason) {
          showMessage("Remote user uid:$_remoteUid left the channel");
          remoteUid = null;
          update();
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await agoraEngine.enableVideo();
  }

  control(){
    var home = Get.put(HomeViewModel());
    String? door =  home.sharedPreferences.getString('door');
    if(door == 'true'){
      home.publish();
    } else {
      home.publish();
    }
  }

  @override
  void onInit() {
    super.onInit();
    api.qRestApi("post", "/Smartdoor/channelJoinProcess", {"channelName":channelName}, true).then((res) {
      if(res['statusCode'] != 200){
        print(res['body']);
        update();
        setupVideoSDKEngine();
      }
    });

    print('엔진');
  }
  @override
  void onClose() {
    // destroy sdk
    print('엔진 끄기');
    agoraEngine.leaveChannel();
    // agoraEngine.leaveChannel(options: LeaveChannelOptions(stopAllEffect: true));
    super.onClose();

  }
}