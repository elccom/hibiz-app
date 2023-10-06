import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:encrypt/encrypt.dart' as en;
import '../models/mqtt.dart';
import '../view/widgets/QuitWidget.dart';
import 'SData.dart';

class Solity extends GetxController{
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  bool isScanning = false;
  var scanResultList = [];
  List<BluetoothService> bluetoothService = [];
  // 연결 상태 리스너 핸들 화면 종료시 리스너 해제를 위함
  StreamSubscription<BluetoothDeviceState>? stateListener;
  // 현재 연결 상태 저장용
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

  late List<BluetoothService> services;
  var subscription;
  List<int> appkey = [];
  ApiServices api = ApiServices();
  Mqtt mqtt =  Mqtt();
  String stateText = 'Connecting';
  bool isSend = false;
  bool isAuth = false;
  bool isCom = false;
  bool trigger = false;
  String door = '-2';
  var encrypter;
  var encrypted;
  var decrypted;

  doorOpenByAppProcess() async {
    print(await flutterBlue.isOn);
    await flutterBlue.isOn.then((value){
      print(value);
      if(value == true){
        if (!isScanning) {
          // 스캔 중이 아니라면
          // 기존에 스캔된 리스트 삭제
          scanResultList.clear();
          // 스캔 시작, 제한 시간 4초
          flutterBlue.startScan(timeout: Duration(seconds: 20));
          // 스캔 결과 리스너

          flutterBlue.scanResults.listen((results) {
            results.forEach((element) async {
              //찾는 장치명인지 확인
              if (element.advertisementData.serviceUuids.length >= 2) {
                if (element.advertisementData.serviceUuids[1] == "48400001-b5a3-f393-e0a9-e50e24dcca9e"
                ) {
                  // 장치의 ID를 비교해 이미 등록된 장치인지 확인
                  if (scanResultList
                      .indexWhere((e) => e.device.id == element.device.id) <
                      0) {
                    // 찾는 장치명이고 scanResultList에 등록된적이 없는 장치라면 리스트에 추가
                    scanResultList.add(element);
                    print('찾음');
                    flutterBlue.stopScan();
                    print('scanResultList: ${scanResultList[0]}');
                    await flutterBlue.connectedDevices.whenComplete(() {
                      for (int i = 0; i < scanResultList.length; i++) {
                        scanResultList[i].device.disconnect();
                      }
                    });
                    stateListener = await scanResultList[0].device.state.listen((event) {
                      debugPrint('event :  $event');
                      print('$event 블루투스상태');
                      if (deviceState == event) {
                        // 상태가 동일하다면 무시
                        return;
                      }
                      // 연결 상태 정보 변경
                      setBleConnectionState(event);
                    });
                    if (deviceState == BluetoothDeviceState.disconnected) {
                      Future<bool>? returnValue;
                      scanResultList[0].device.connect(autoConnect: false)
                          .timeout(Duration(milliseconds: 15000), onTimeout: () {
                        //타임아웃 발생
                        //returnValue를 false로 설정
                        returnValue = Future.value(false);
                        print('타임아웃');
                        publish();
                        //연결 상태 disconnected로 변경
                        deviceState = BluetoothDeviceState.disconnected;
                        update();
                        setBleConnectionState(BluetoothDeviceState.disconnected);
                      }).then((data) async {

                        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                        if (returnValue == null) {
                          services = await scanResultList[0].device.discoverServices();
                          print('서비스 ${services}');
                          bluetoothService = services;
                          print('Service UUID: ${services[2].uuid}');
                          print('Service UUID: ${services[2].characteristics[0]}');
                          print('Service UUID: ${services[2].characteristics[0].uuid}');
                          print('Service UUID: ${services[2].characteristics[1].uuid}');
                          print('Service descriptors: ${services[2].characteristics[1].descriptors}');
                          isCom = false;
                          print(services[2].characteristics[1].deviceId);
                          print('주소 값 : ${sharedPreferences.getString('address')}');
                          if(!services[2].characteristics[1].isNotifying) {
                            try {
                              await services[2].characteristics[1].setNotifyValue(true);
                              if(isSend == false){
                                send(services[2], 0x48, 0x10);
                              }
                              subscription = services[2].characteristics[1].value.listen((value) {
                                // 데이터 읽기 처리!
                                if (services[2].characteristics[1].uuid.toString() ==
                                    '48400003-b5a3-f393-e0a9-e50e24dcca9e'
                                    && sharedPreferences.getString('address') ==
                                        services[2].characteristics[1].deviceId.toString()
                                ) {
                                  print('같음');

                                  print('${services[2].characteristics[1].uuid}: 리턴값 $value');
                                  // 받은 데이터 저장 화면 표시용
                                  if (value.length != 0) {
                                    if (
                                    value[2] == 144
                                    ) {
                                      update();
                                      appkey =
                                      [value[3], value[4], value[5], value[6], value[7], value[8], value[9], value[10]];
                                      print('appkey 값 : ${appkey}');
                                      auth(services[2], 0x48, 0x11);


                                    } else {
                                      List<int> com = AESdecode(value);
                                      print('인증 디코딩');

                                      if (com[3] == 0 && com[2] == 0x91 && isAuth == true) {
                                        print('문열기 전송');
                                        update();
                                        open(services[2], 0x48, 0x21);
                                      }
                                      else if (com[3] == 1 && com[2] == 0x91 && isAuth == true) {
                                        print('인증실패');
                                        isSend = false;
                                        isAuth = false;
                                        isCom = true;
                                        print(isCom);
                                        update();
                                        subscription?.cancel();
                                        publish();
                                      }
                                      if (com[3] == 1 && com[2] == 0xA1) {
                                        Get.back();
                                        print('문열림');
                                        Get.dialog(QuitWidget(serverMsg: '닫기는 지원하지않습니다.'));
                                        isSend = false;
                                        isAuth = false;
                                        isCom = true;
                                        subscription?.cancel();
                                      } else if (com[3] == 0 && com[2] == 0xA1) {
                                        Get.back();
                                        Get.dialog(QuitWidget(serverMsg: '문이 열렸습니다.'));
                                        isSend = false;
                                        isAuth = false;
                                        isCom = true;
                                        subscription?.cancel();
                                      }

                                      // else {
                                      //   print('문열기실패');
                                      //   update();
                                      //   publish();
                                      // }
                                    }
                                  }
                                  // else{
                                  //   event.value = '블루투스 값 받기 실패';
                                  //   update();
                                  //   // subscription?.cancel();
                                  //   publish();
                                  // }
                                }
                              });
                              await Future.delayed(const Duration(milliseconds: 500));
                            } catch (e){
                              print('에러발생 $e');
                              subscription?.cancel();
                              publish();
                            }
                          }
                        }
                      }
                      )
                      ;
                      return returnValue ?? Future.value(false);
                    } else {
                      print(deviceState);
                      scanResultList[0].device.disconnect();
                      deviceState = BluetoothDeviceState.disconnected;
                      print('이미 연결됨');
                      publish();
                    }
                  }
                }
              }

            });
          })
          ;

        } else {
          // 스캔 중이라면 스캔 정지
          flutterBlue.stopScan();
          // Get.back();
          // Get.dialog(QuitWidget(serverMsg: '스캔중이거나 블루투스가 연결되어있지않습니다. \n 확인 후 다시 시도해주세요.'));

          publish();
        }
      }else{
        // Get.dialog(QuitWidget(serverMsg: '블루투스설정을 활성화 해주세요.',));
        print('블루투스꺼져있음 mqtt진입');
        trigger = false;
        door = '-3';
        update();
        publish();
      }
    }
    );
  }

  publish(){
    if(mqtt.client?.connectionStatus?.state == MqttConnectionState.disconnected){
      mqtt.connect();
      print('커넥실패');
    }

    api.doorControl('/ProductSncode/doorlockAppOpenProcess').then((val){
      if (val['result'] == false) {
        Get.dialog(QuitWidget(serverMsg: val['message'],));
      }else{
        print('mqtt로 문열기');
        var i = 0;
        print('시작');
        Timer.periodic(Duration(seconds: 1), (timer) {
          print(i);
          print(trigger);
          if(trigger == true){
            print('mqtt 연결 성공ㅐ');
            trigger= false;
            timer.cancel();
            refresh();
          }else if (trigger == false && i == 15){
            print('mqtt 연결 실패ㅐ');
            Get.back();
            door = '-2';
            Get.dialog(QuitWidget(serverMsg: '시간이 초과되었습니다 다시 시도해주세요.',));
            timer.cancel();
            refresh();
          }
          i++;
        });
      }
    }
    );
  }

  //키교환
  send(service,int STX,int cmd) async {
    update();
    List<int> send;
    var now = new DateTime.now();
    List<int> Date = [
      0xff & (now.year >> 8),
      0xff & now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second
    ];
    for (int i in Date) {
      print('${i} 날짜값');
    }

    List<int> Data //종류에따라 값이 다름
    =
    [
      for(int i in Date)
        i,
      61,62,63,64,65,66,67,68
    ];
    int Length = 1 + Data.length;

    int sum = 0; //data값 합계

    for (int i = 0; i < Data.length; i++) {
      sum += Data[i];
    }

    int ADD = (Length + cmd + sum)&0xff;
    print(ADD);
    print('비교' );
    send = [STX, Length, cmd,
      for(int i in Data)
        i,
      ADD];
    print('총 데이터 : ${send}');
    print(service);
    print(service.characteristics[0]);
    var characteristics = service.characteristics;
    if(characteristics[0].uuid.toString() =='48400002-b5a3-f393-e0a9-e50e24dcca9e') {
      await characteristics[0].write(
          send
          , withoutResponse: true);
    }
    print('키교환 전송');
    isSend = true;
    return true;

  }

  auth(service,int STX,int Cmd) async{
    print('인증문 전송');
    List<int> send;
    var now = new DateTime.now();
    List<int> Date = [
      0xff & (now.year >> 8),
      0xff & now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second
    ];
    for (int i in Date) {
      print('${i} 날짜값');
    }

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? scode =  sharedPreferences.getString('scode');
    List<int> Data //종류에따라 값이 다름
    =
    [
      for(int i in Date)
        i,
      // for(String i in split)
      //   int.parse(i),
      71,72,73,74,75,76,77,78
    ];
    int Length = 1 + Data.length;

    int sum = 0; //data값 합계

    for (int i = 0; i < Data.length; i++) {
      sum += Data[i];
    }

    int ADD = (Length + Cmd + sum)&0xff;
    print(ADD);
    print('비교');
    send = [STX, Length, Cmd,
      for(int i in Data)
        i,
      ADD
    ];
    print('총 데이터 : ${send}');

    final rdata = encrypt(send);
    var characteristics = service.characteristics;
    if(characteristics[0].uuid.toString() =='48400002-b5a3-f393-e0a9-e50e24dcca9e') {
      await characteristics[0].write(
          rdata
          , withoutResponse: true);
    }
    isAuth = true;
  }

  open(service,int STX,int cmd ) async{
    update();
    var now = new DateTime.now();
    List<int> Date = [
      0xff & (now.year >> 8),
      0xff & now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second
    ];
    for (int i in Date) {
      print('${i} 날짜값');
    }
    late List<int> Data;
    late List<int> open ;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? scode =  sharedPreferences.getString('scode');
    List<String>? spl = scode?.split('-');
    var fst = int.parse(spl![0]);
    assert(fst is int);
    var scd = int.parse(spl![1]);
    assert(scd is int);
    print(fst);
    print(scd);
    print(fst+scd);
    int sum2 =fst+scd;
    List<String> split = sum2.toString().split('');
    if(appkey != null){
      Data = [
        for(int i in Date)
          i,
        // for(String i in split)
        //   int.parse(i),
        71,72,73,74,75,76,77,78,
        0,0,7
      ];
      var obj = SData(cmd,Data);
      int Length = 1 + Data.length;
      int sum = 0;
      for (int i = 0; i < Data.length; i++) {
        sum += Data[i];
      }
      int ADD = (Length + cmd + sum)&0xff;
      print(ADD);
      print(obj.calcuChecksum(cmd, Data));
      print('비교');
      open = [STX, Data.length+1, cmd,
        for(int i in Data)
          i
        ,obj.calcuChecksum(cmd, Data)+1];
    }
    print(open);
    print(base64.encode(open));

    late List<int> rdata = encrypt(open);

    var characteristics = service.characteristics;
    if(characteristics[0].uuid.toString() =='48400002-b5a3-f393-e0a9-e50e24dcca9e') {
      await characteristics[0].write(
          rdata
          , withoutResponse: true);
    }
    print('문열기문 전송');
    // for (BluetoothCharacteristic c in characteristics) {
    //   print(c.uuid);
    //   if (c.uuid.toString() == '48400002-b5a3-f393-e0a9-e50e24dcca9e') {
    //     await c.write(
    //         rdata
    //         , withoutResponse: true);
    //     print('암호화 된 문 전송');
    //     print('${rdata} 보낸거');
    //   }
    // }
  }

  paddingRight(List<int> data, value){
    int pcount = 16 - data.length % 16;
    print(data.length);
    print(pcount);
    for(var i = 0; i < pcount; i++){
      data.add(value);
    }
    print(data);
    print(Uint8List.fromList(data));
    return data;
  }

  encrypt(input){
    var k = paddingRight(input, 0);
    print('${k} 이걸 암호화');
    var iv = en.IV.fromBase64(
        base64.encode([61, 62, 63, 64, 65, 66, 67, 68,
          // 71, 72, 73, 74, 75, 76, 77, 78
          for(int i in appkey)
            i,
        ])
    );
    encrypter = en.Encrypter(en.AES(en.Key.fromUtf8('H-GANG BLE MODE1'), mode: en.AESMode.cbc, padding: null));
    encrypted = encrypter.encryptBytes(k, iv:  iv);
    print('${encrypted.bytes} 암호화');

    // var decrypted = encrypter.decryptBytes(en.Encrypted(Uint8List.fromList(encrypted.bytes)),
    //     iv: iv);
    // print(encrypted.bytes.length);
    // print('${decrypted} 바로 복호화');
    return encrypted.bytes;
  }
  AESdecode(val2) {
    print('받은 값 : ${val2}');
    print(base64.encode(val2));
    var iv = en.IV.fromBase64(
        base64.encode(
            [61, 62, 63, 64, 65, 66, 67, 68,
              //71, 72, 73, 74, 75, 76, 77, 78
              for(int i in appkey)
                i,
            ]
        )
    );
    print(Uint8List.fromList(val2));
    final encrypted = en.Encrypted(Uint8List.fromList(val2));
    // final encrypted = en.Encrypted(val2);
    var encrypter2 = en.Encrypter(en.AES(en.Key.fromUtf8('H-GANG BLE MODE1'), mode: en.AESMode.cbc, padding: null));
    decrypted = encrypter2.decryptBytes(encrypted, iv: iv);
    print('${decrypted} 디코딩완료');
    return decrypted;
  }

  setBleConnectionState(BluetoothDeviceState event) {
    switch (event) {
      case BluetoothDeviceState.disconnected:
        stateText = 'Disconnected';
        // 버튼 상태 변경
        update();
        break;
      case BluetoothDeviceState.disconnecting:
        stateText = 'Disconnecting';
        update();
        break;
      case BluetoothDeviceState.connected:
        stateText = 'Connected';
        update();
        // 버튼 상태 변경
        break;
      case BluetoothDeviceState.connecting:
        stateText = 'Connecting';
        update();
        break;
    }
    //이전 상태 이벤트 저장
    deviceState = event;
    update();
  }
}
