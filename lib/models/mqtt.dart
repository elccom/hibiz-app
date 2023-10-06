
import 'dart:convert';
import 'dart:math';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/view_model/home_view_model.dart';

import '../view/widgets/QuitWidget.dart';


class Mqtt extends GetxController{
  MqttServerClient? client;

  Future<MqttServerClient?> connect() async {
    Stream<List<MqttReceivedMessage<MqttMessage>>>? getMessagesStream() {
      return client?.updates;
    }

    void onConnected() {
      print('Connected');
    }

// unconnected
    void onDisconnected() {
      print('Disconnected');
    }

// subscribe to topic succeeded
    void onSubscribed(String topic) {
      print('Subscribed topic: $topic');
    }

// subscribe to topic failed
    void onSubscribeFail(String topic) {
      print('Failed to subscribe $topic');
    }

// unsubscribe succeeded
    void onUnsubscribed(String? topic) {
      print('Unsubscribed topic: $topic');
    }

    // PING response received
    void pong() {
      print('Ping response client callback invoked');
    }

    //decode
    String decodeBase64(String str) {
      String output = str.replaceAll('-', '+').replaceAll('_', '/');

      switch (output.length % 4) {
        case 0:
          break;
        case 2:
          output += '==';
          break;
        case 3:
          output += '=';
          break;
        default:
          throw Exception('Illegal base64url string!"');
      }

      return utf8.decode(base64Url.decode(output));
    }

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<int> nums = [];

    for( int i = 0; i < 9; i ++) {
      nums.add(Random().nextInt(9));
    }

    String clientId = 'hizib01_${nums[0].toString()+nums[1].toString()+
        nums[2].toString()+nums[3].toString()+nums[4].toString()+nums[5].toString()+nums[6].toString()+
        nums[7].toString()+nums[8].toString()
    }';

    print("clientId : ${clientId}");

    client = MqttServerClient.withPort('13.124.155.19', clientId, 1883);
    client?.logging(on: true);
    client?.autoReconnect = true;

    client?.onConnected = onConnected;
    client?.onDisconnected = onDisconnected;
    client?.onUnsubscribed = onUnsubscribed;
    client?.onSubscribed = onSubscribed;
    client?.onSubscribeFail = onSubscribeFail;
    client?.pongCallback = pong;

    final connMessage = MqttConnectMessage()
    // .keepAliveFor(60)
    // .withWillTopic('smartdoor/SMARTDOOR/')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client?.connectionMessage = connMessage;

    try {
      print("Mqtt 연결시도");
      await client?.connect();
      print("Mqtt 연결성공");

      String? smartdoorStr = sharedPreferences.getString('smartdoor');
      String? userStr = sharedPreferences.getString('user');
      Map<String, dynamic> smartdoorObj = json.decode(smartdoorStr!);
      Map<String, dynamic> userObj = json.decode(userStr!);

      String topic = 'hizib01/${smartdoorObj['code']}/${userObj['user_id']}'; // Not a wildcard topic
      var home = Get.put(HomeViewModel());
      print('토픽 : ${topic}');
      //if(home.subtrigger == false){
      client?.subscribe(topic, MqttQos.atLeastOnce);

      int i = 0;
      client?.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        home.subtrigger = true;
        print('리슨받음');
        print(c);
        print(home.doorRequest);
        home.trigger = true;
        print(home.trigger);
        update();
        final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
        // var result=json.decode(payload);
        var result=json.decode(payload);
        print(result);
        print(Uri.decodeComponent(result['result'].toString()));
        print(json.decode(utf8.decode(message.payload.message))['message']);
        if(json.decode(utf8.decode(message.payload.message))['result'] == false){
          home.updatedoor('false');
          Get.dialog(QuitWidget(serverMsg: '${json.decode(utf8.decode(message.payload.message))['message']}'));

        } else if(json.decode(utf8.decode(message.payload.message))['result'] == true){
          home.updatedoor('true');
          Get.dialog(QuitWidget(serverMsg: '${json.decode(utf8.decode(message.payload.message))['message']}'));
        }
        // else if(json.decode(utf8.decode(message.payload.message))['request'] == 'isDoorOpen' && json.decode(utf8.decode(message.payload.message))['response'] == 'opened'){
        //   home.updatedoor('true');
        //
        // } else if(json.decode(utf8.decode(message.payload.message))['request'] == 'isDoorOpen' && json.decode(utf8.decode(message.payload.message))['response'] == 'closed'){
        //   home.updatedoor('false');
        //
        // }

        // if(home.doorRequest == '') {
        //   home.doorRequest = Uri.decodeComponent(result['request'].toString());
        //   print(home.doorRequest);
        //   if (Uri.decodeComponent(result['result'].toString()) == 'true' &&
        //       Uri.decodeComponent(result['request'].toString()) == 'doorOpenProcess') {
        //     home.updatedoor('true');
        //     Get.dialog(QuitWidget(serverMsg: '문이 열렸습니다.'));
        //     sharedPreferences.setString('door', 'true');
        //     refresh();
        //   } else if (Uri.decodeComponent(result['result'].toString()) == 'false' &&
        //       Uri.decodeComponent(result['request'].toString()) == 'doorOpenProcess') {
        //     home.updatedoor('true');
        //     Get.dialog(QuitWidget(serverMsg: Uri.decodeComponent(result['message'].toString())));
        //   }
        //   // else if (Uri.decodeComponent(result['result'].toString()) == 'true' &&
        //   //     Uri.decodeComponent(result['request'].toString()) == 'isDoorOpen') {
        //   //   print('도어상태수신완료');
        //   //   home.updatedoor('true');
        //   // }
        //   // else if (Uri.decodeComponent(result['result'].toString()) == 'false' &&
        //   //     Uri.decodeComponent(result['request'].toString()) == 'isDoorOpen') {
        //   //   print('도어상태수신완료');
        //   //   home.updatedoor('false');
        //   // }
        //    else if (Uri.decodeComponent(result['request'].toString()) == 'guestkeyJoinProcess') {
        //     Get.dialog(QuitWidget(serverMsg: Uri.decodeComponent(result['message'].toString())));
        //   }
        //   print('qos설정값 : ${message.header!.qos}');
        //   // getMessagesStream();
        // }
        // if (Uri.decodeComponent(result['result'].toString()) == 'true' &&
        //     Uri.decodeComponent(result['request'].toString()) == 'isDoorOpen') {
        //   print('도어상태수신완료');
        //   home.updatedoor('true');
        // }
        // else if (Uri.decodeComponent(result['result'].toString()) == 'false' &&
        //     Uri.decodeComponent(result['request'].toString()) == 'isDoorOpen') {
        //   print('도어상태수신완료');
        //   home.updatedoor('false');
        // }
        // if (Uri.decodeComponent(result['result'].toString()) == 'false' &&
        //     Uri.decodeComponent(result['response'].toString()) == 'webrtcMicrophoneNotFound') {
        //   Get.dialog(QuitWidget(serverMsg: '도어벨 마이크를 연결하는데 실패하여 통화가 불가능합니다.'));
        // } else if (Uri.decodeComponent(result['result'].toString()) == 'false' &&
        //     Uri.decodeComponent(result['response'].toString()) == 'webrtcCameraNotFound') {
        //   Get.dialog(QuitWidget(serverMsg: '도어벨 카메라를 연결하는데 실패하여 통화가 불가능합니다.'));
        // }
      });
    } catch (e) {
      print('Mqtt 연결실패');
      print('Exception: $e');
      client?.disconnect();
    }
  }
}
