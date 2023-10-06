import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/main.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/widgets/QuitWidget.dart';
import 'package:wisemonster/view/widgets/InitialWidget.dart';
import '../api/api_services.dart';
import '../controller/camera_controller.dart';
import '../view_model/home_view_model.dart';
import 'home_view.dart';

class camera_view extends StatefulWidget {
  camera_view({Key? key}) : super(key: key);

  // Build UI

  @override
  State<StatefulWidget> createState() => cameraState();
}

class cameraState extends State<camera_view> {
  ApiServices api = ApiServices();

  var home = Get.put(HomeViewModel());
  bool door = true;
  late String channelName;
  String random = Random().nextInt(999999).toString();
  late SharedPreferences sharedPreferences;
  String appid = "8a8331548d8c4b88a76952d9b103cbad";
  late String token;
  late int agoratokenid;
  // String token2 = '007eJxTYBA3zVB8ujLi2fzDgd8Pif5mvL7K/4/Eyh1vZq2KqFrtK5OgwGBqapJikpqSmmRmamBiYZJsaZSWYplolmpikZZmZp6U9nn7rOSGQEaGfGFZJkYGCATxWRhKUotLGBgAxYMhCQ==';
  int uid = 0;
  // Random().nextInt(100); // uid of the local user

  int? _remoteUid; // uid of the remote user
  bool isJoined = false; // Indicates if the local user has joined the channel
  late RtcEngine agoraEngine; // Agora engine instance


  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

  @override
  Widget build(BuildContext context) {
    return
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home:

        Scaffold(
          appBar:  AppBar(
            elevation: 0,
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            iconTheme: const IconThemeData(color: Color.fromARGB(255, 44, 95, 233)),
            centerTitle: true,
            title: Text('영상통화',
                style: TextStyle(
                    color: Color.fromARGB(255, 44, 95, 233), fontWeight: FontWeight.bold, fontSize: 20)),
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_outlined),
              onPressed: () {
                Get.offAll(home_view());
              },
            ),
          ),
            body: ListView(
              children: [
                Container(
                  height: 30,
                  color: Color.fromARGB(255, 204, 204, 204),
                ),
                Container(
                  height: (MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height - 162)/2,
                  decoration: BoxDecoration(border: Border.all()),
                  child: Center(child: remoteVideo()),
                ),
                Container(
                  height:  (MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height - 162)/2,
                  decoration: BoxDecoration(border: Border.all()),
                  child: Center(child: localPreview()),
                ),
                // Container for the local video
                //Container for the Remote video
                Container(
                  height: 76,
                  color: Color.fromARGB(255, 204, 204, 204),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          flex: 29,
                          child: Container()
                      ),
                      // TextButton(
                      //   onPressed: isJoined ? (){} : () => {join()},
                      //   child: Container(
                      //       width: 36,
                      //       height: 36,
                      //       decoration: BoxDecoration(
                      //         shape: BoxShape.circle,
                      //         color: Color.fromARGB(255, 44, 233, 94),
                      //       ),
                      //       child: Icon(
                      //         Icons.call,
                      //         color: Colors.white,
                      //         size: 24,
                      //       )),),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: ()
                        // isJoined ? () => {leave()} : null
                        {Navigator.pop(context);}
                        ,
                        child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: Icon(
                              Icons.call_end,
                              color: Colors.white,
                              size: 24,
                            )),),
                      TextButton(
                        onPressed: (){control();},
                        child: Container(
                            width: 84,
                            height: 36,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color.fromARGB(255, 87, 132, 255)
                            ),
                            child: Center(child: Text(
                              '열기',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14
                              ),
                            ),) ),),
                      Expanded(
                          flex: 29,
                          child: Container()
                      ),
                    ],
                  ),
                )
                // Button Row
                // Button Row ends
              ],
            ))
        ,
      );
  }


// Display local video preview
  Widget localPreview() {
    print("localPreview : ${isJoined}");
    if (isJoined == true) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(uid: 0),
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
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: channelName),
        ),
      );
    } else {
      return Text(
        '유저연결을 기다리는 중 입니다.',
        textAlign: TextAlign.center,
      );
    }
  }

  // void join() async {
  //   await agoraEngine.startPreview();
  //   await agoraEngine.setRemoteVideoStreamType(uid: uid, streamType: VideoStreamType.videoStreamLow);
  //   // Set channel options including the client role and channel profile
  //   ChannelMediaOptions options = const ChannelMediaOptions(
  //     defaultVideoStreamType: VideoStreamType.videoStreamLow,
  //     clientRoleType: ClientRoleType.clientRoleBroadcaster,
  //     channelProfile: ChannelProfileType.channelProfileCommunication,
  //   );
  //
  //   print(token);
  //   print(channelName);
  //   print(uid);
  //   print('유저저저저저저');
  //
  //   await agoraEngine.joinChannel(
  //     token: token,
  //     channelId:
  //     channelName
  //     // 'test'
  //     ,
  //     options: options,
  //     uid: uid,
  //   );
  // }

  void leave() {
    setState(() {
      isJoined = false;
      _remoteUid = null;
    });
    agoraEngine.leaveChannel();
    Navigator.pop(context);
  }

  snackbar(String message) {
    Get.snackbar(
      '알림',
      message,
      duration: Duration(seconds: 5),
      backgroundColor: const Color.fromARGB(
          255, 39, 161, 220),
      icon: Icon(Icons.info_outline, color: Colors.white),
      forwardAnimationCurve: Curves.easeOutBack,
      colorText: Colors.white,
    );
  }

  Future<bool> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
    await [Permission.microphone, Permission.camera].request();
    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(RtcEngineContext(
      appId: this.appid,
    ));

    await agoraEngine.enableVideo();
    // Register the event handler

    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          snackbar("Local user uid:${connection.localUid} joined the channel");
          print('로컬진입완료 ${connection.localUid}');
          setState(() {
            this.uid = connection.localUid!;
            isJoined = true;
          });
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          // ➍ 채널을 퇴장했을 때 실행
          print('채널 퇴장');
          setState(() {
            this.uid = 0;
            //isJoined = false;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          snackbar("Remote user uid:$remoteUid joined the channel");
          print('리모트조인완료');
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          snackbar("Remote user uid:$remoteUid left the channel");
          setState(() {
            _remoteUid = null;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          snackbar('[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await agoraEngine.enableVideo();
    await agoraEngine.startPreview();
    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    print(token);
    print(channelName);
    print(uid);
    print('유저저저저저저');

    await agoraEngine.setParameters(
        '{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}'
    );

    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: 0,
    );

    return true;
  }

  control(){
    home.doorRequest = '';
    home.scan();
  }

  @override
  void initState() {
    super.initState();

    getPermission().then((value) async {
      print("카메라와 마이크 사용 권한 : ${value}");

      if(!value)
        Get.dialog(InitialWidget(serverMsg: '카메라와 마이크 사용 권한이 없습니다. 권한 설정 후 이용해 주세요.'));
      else {
        Map<String, dynamic> jsonData = {
          "url": "/Smartdoor/channelJoinProcess",
          "method": "POST",
          "isToken": true,
          "body":{'channelName':random}
        };

        api.qRestApi("post", "/Smartdoor/channelJoinProcess", {'channelName':random}, true).then((res) async {
          if(res['statusCode'] == 200) {
            print(res['body']);
            setState(() {
              channelName = random;
              token = res['body']['token'];
              appid = res['body']['appID'];
              uid = res['body']['uid'];
            });

            print('채널아디 : ${channelName}');
            print('토큰 : ${token}');

            setupVideoSDKEngine().then((value) {
              print(value);
              print('내꺼완료');
              // api.requestRTCinit(agoratokenid).then((val){
              //   if(val != null){
              //     print('완료');
              //   }
              // });
            });
          } else {
            snackbar(res['body']['message']);
          }
        });

        print('아고라 실행');
        print('엔진');
      }
    });
  }

  @override
  void dispose() {
    // destroy sdk
    isJoined = false;
    _remoteUid = null;
    uid = 0;
    agoraEngine.leaveChannel(options: LeaveChannelOptions(
      stopAudioMixing: true,
      stopMicrophoneRecording: true,
      stopAllEffect: true));
    agoraEngine.release();
    super.dispose();
  }

  Future<bool>getPermission()async{
    if(Platform.isIOS) {
      return Future.value(false);
    } else {
      Map<Permission, PermissionStatus>statuses = await [Permission.camera,Permission.microphone].request();

      print("카메라 권한설정");
      print(statuses);

      if(statuses[Permission.camera]!.isGranted && statuses[Permission.microphone]!.isGranted) {
        return Future.value(true);
      } else {
        return Future.value(false);
      }
    }
  }
}
