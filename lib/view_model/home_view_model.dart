
import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/models/Solity.dart';
import 'package:wisemonster/models/user_model.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/registration1_view.dart';
import 'package:wisemonster/view/widgets/QuitWidget.dart';
import '../controller/SData.dart';
import '../models/mqtt.dart';
import 'package:encrypt/encrypt.dart' as en;
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class HomeViewModel extends FullLifeCycleController with FullLifeCycleMixin{
  ApiServices api = ApiServices();
  late SharedPreferences sharedPreferences;
  String? id;
  String? passwd;
  String? nickname;
  String? pictureUrl;
  String? ble;
  RxString userName = ''.obs;
  String msg = '';
  bool error = false;
  List<int> appkey = [];
  var encrypter;
  var encrypted;
  var decrypted;
  String door = '-2';
  late List<int> rdata;
  bool isScanning = false;
  String place = '';
  String stateText = 'Connecting';
  bool isSend = false;
  bool isAuth = false;
  bool isCom = false;
  RxString event = ''.obs;
  RxInt event2 = 0.obs;
  bool trigger = false;
  //도어쪽
  bool isBle = true;
  bool subtrigger = false;
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  var scanResultList = [];
  late BluetoothDevice bleDevice;
  List<BluetoothService> bluetoothService = [];
  bool btn = false;

  Map<String, List<int>> notifyDatas = {};

  // 연결 상태 리스너 핸들 화면 종료시 리스너 해제를 위함
  StreamSubscription<BluetoothDeviceState>? stateListener;
  // 현재 연결 상태 저장용
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;
  late List<BluetoothService> services;
  var subscription;

  String doorRequest = '';
  
  Mqtt mqtt = new Mqtt();

  late Solity solityObj;
  late Timer _timer;
  int gap_seconds = 5;
  bool isDoorCheck = false;

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: gap_seconds), (timer) {
      isDoorCheck = true;
      //isDoorOpen();
      print("${gap_seconds}초타이머 시작");
    });
  }
  
  void _stopTimer() {
    if(isDoorCheck) {
      _timer?.cancel();
      print("${gap_seconds}초타이머 취소");
    }
  }
  
  allupdate(){
    update();
  }

  void info() {
    chk();
  }

  void snackbar(msg) {
    Get.snackbar(
      '알림',
      msg,
      duration: Duration(seconds: 5),
      backgroundColor: const Color.fromARGB(
          255, 39, 161, 220),
      icon: Icon(Icons.info_outline, color: Colors.white),
      forwardAnimationCurve: Curves.easeOutBack,
      colorText: Colors.white,
    );
  }

  model(value) async {
    Map<String, dynamic> userMap = await jsonDecode(value);
    var user = UserModel.fromJson(userMap);
    print(user.personObj['name']);
    userName.value = user.personObj['name'].toString();
    update();
  }

  void initDialog(value) {
    Get.dialog(
        QuitWidget(serverMsg: msg)
    );
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

  chk() async {
    sharedPreferences = await SharedPreferences.getInstance();
    String? userStr = sharedPreferences.getString('user');
    print("userStr : ${userStr}");
    Map<String, dynamic> userObj = jsonDecode(userStr!);
    print("userObj : ${userObj}");
    id = userObj['id'];
    passwd = userObj['passwd'];
    nickname = userObj['nickname'];
    pictureUrl = userObj['pictureUrl'];

    String? smartdoorStr = sharedPreferences.getString('smartdoor');
    print("smartdoorStr : ${smartdoorStr}");
    Map<String, dynamic> smartdoorObj = jsonDecode(smartdoorStr!);
    print("smartdoorObj : ${smartdoorObj}");
    ble = smartdoorObj['ble'];

    solityObj.find(ble!);

    print('chk');
  }

  final ImagePicker _picker = ImagePicker();
  File? image;
  //갤러리 접근 후 이미지값 인코딩
  Future getImage() async {
    final XFile? pickImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickImage != null){
      image = File(pickImage.path);
      final bytes = image?.readAsBytesSync();
      String base64Image =  "data:image/png;base64,"+base64Encode(bytes!);
      print(base64Image);
      update();
    }
  }

  //블루투스 연결 상태 표시시
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

  //ble로 문열기 (블루투스 꺼져있을시 mqtt로 문열기 호출)
  scan() async {
    _stopTimer();
    btn = true;
    update();
    // doorRequest = '';
    // print('scan 변수 ${doorRequest}');
    // update();
    print("블루투스 상태");
    print(await flutterBlue.isOn);
    Get.dialog(
      barrierDismissible: false,
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  type: MaterialType.transparency,
                  child:Obx(() =>  Text(
                    '작동중입니다. \n ${event}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15
                    ),
                  ))
                ,),
                Container(height: 10,),
                CircularProgressIndicator(),
                TextButton(onPressed: () { Get.offAll(home_view()); }, child: Text('뒤로가기', style: TextStyle(color: Colors.white, fontSize: 15),))
              ]
            ,))
          ,),
        )
    );

    await checkBluetoothOn().then((value){
      print("checkBluetoothOn : ${value}");
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
                if (element.advertisementData.serviceUuids[1] == "48400001-b5a3-f393-e0a9-e50e24dcca9e") {
                  // 장치의 ID를 비교해 이미 등록된 장치인지 확인
                  if (scanResultList.indexWhere((e) => e.device.id == element.device.id) < 0) {
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
                      scanResultList[0].device.connect(autoConnect: false).timeout(Duration(milliseconds: 15000), onTimeout: () {
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
                          // print('주소 값 : ${sharedPreferences.getString('address')}');
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
                                // && sharedPreferences.getString('address') ==
                                //     services[2].characteristics[1].deviceId.toString()
                                ) {
                                  print('같음');

                                  print('${services[2].characteristics[1].uuid}: 리턴값 $value');
                                  // 받은 데이터 저장 화면 표시용
                                  if (value.length != 0) {
                                    if (
                                    value[2] == 144
                                    ) {
                                      event.value = '키교환 완료';
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
                                        event.value = '인증완료';
                                        update();
                                        test(services[2], 0x48, 0x21);
                                      }
                                      else if (com[3] == 1 && com[2] == 0x91 && isAuth == true) {
                                        event.value = '블루투스 인증 실패';
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
                                        print('문열린 상태');
                                        Get.dialog(QuitWidget(serverMsg: '닫기는 지원하지않습니다.'));
                                        isSend = false;
                                        isAuth = false;
                                        isCom = true;
                                        subscription?.cancel();
                                        btn = false;
                                        updatedoor('true');
                                        update();
                                      } else if (com[3] == 0 && com[2] == 0xA1) {
                                        updatedoor('true');
                                        Get.back();
                                        Get.dialog(QuitWidget(serverMsg: '문이 열렸습니다.'));
                                        isSend = false;
                                        isAuth = false;
                                        isCom = true;
                                        subscription?.cancel();
                                        btn = false;
                                        update();
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
                      });
                      
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
          });
        } else {
          // 스캔 중이라면 스캔 정지
          flutterBlue.stopScan();
          // Get.back();
          // Get.dialog(QuitWidget(serverMsg: '스캔중이거나 블루투스가 연결되어있지않습니다. \n 확인 후 다시 시도해주세요.'));
          publish();
        }
      } else {
        // Get.dialog(QuitWidget(serverMsg: '블루투스설정을 활성화 해주세요.',));
        print('블루투스꺼져있음 mqtt진입');
        trigger = false;
        door = '-3';
        event.value = '';
        update();
        publish();
      }
    });
  }

  //ble찾기
  ble_find(String macaddr) async {
    print('ble_find');

    if(bleDevice == null) {
      await checkBluetoothOn().then((value) {
        print("checkBluetoothOn : ${value}");
        if (value == true) {
          print('scanResultList: ${scanResultList}');

          if (!isScanning) {
            // 스캔 중이 아니라면
            // 기존에 스캔된 리스트 삭제
            scanResultList.clear();
            // 스캔 시작, 제한 시간 4초
            flutterBlue.startScan(timeout: Duration(seconds: 20));
            // 스캔 결과 리스너

            flutterBlue.scanResults.listen((results) {
              results.forEach((element) async {
                if (element.device.id.toString() == macaddr) {
                  bleDevice = element.device;
                  print("스캔된 장치 : ${element.device.id}");
                  flutterBlue.stopScan();
                  await ble_listening();
                }
              });
            });
          } else {
            flutterBlue.stopScan();
            // 스캔 중이라면 스캔 정지
          }
        }
      });
    }
  }

  //ble 메세지 수신
  ble_listening() async {
    print('ble_listening');
    stateListener = await bleDevice.state.listen((event) {
      print('블루투스 현재상태 ${event}');
      // 상태가 동일하다면 무시
      if (deviceState == event) return;

      // 연결 상태 정보 변경
      setBleConnectionState(event);
    });

    if (deviceState == BluetoothDeviceState.disconnected) {
      bleDevice.connect(autoConnect: false).timeout(Duration(milliseconds: 15000), onTimeout: () {
        print('타임아웃');
        //연결 상태 disconnected로 변경
        setBleConnectionState(BluetoothDeviceState.disconnected);
      }).then((data) async {

      });
    }
  }

  //문열기
  test(service,int STX,int cmd ) async{
    event.value = '문작동중';
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
    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // String? scode =  sharedPreferences.getString('scode');
    // List<String>? spl = scode?.split('-');
    // var fst = int.parse(spl![0]);
    // assert(fst is int);
    // var scd = int.parse(spl![1]);
    // assert(scd is int);
    // print(fst);
    // print(scd);
    // print(fst+scd);
    // int sum2 =fst+scd;
    // List<String> split = sum2.toString().split('');
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

    rdata = encrypt(open);

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

  isDoorOpen() async {
    print('isDoorOpen');
    //solityObj.find(ble!);
  }

  send(service,int STX,int cmd) async {
    event.value = '키교환 전송중';
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

    // var obj = SData(cmd,Data);
    // print(obj.calcuChecksum(cmd, Data));

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
    // for (BluetoothCharacteristic c in characteristics) {
    //   print(c.uuid);
    //   if (c.uuid.toString() == '48400002-b5a3-f393-e0a9-e50e24dcca9e') {
    //     await c.write(
    //         send
    //         , withoutResponse: true);
    //     print('암호화 안된 문 전송');
    //     print(Data);
    //     print('${send} 보낸거');
    //     update();
    //
    //   }
    // }
    return true;

  }

  auth(service,int STX,int Cmd) async{
    event.value = '인증중';
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
    // List<String>? spl = scode?.split('-');
    // var fst = int.parse(spl![0]);
    // assert(fst is int);
    // var scd = int.parse(spl![1]);
    // assert(scd is int);
    // print(fst);
    // print(scd);
    // print(fst+scd);
    // int sum2 =fst+scd;
    // List<String> split = sum2.toString().split('');
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

    var obj = SData(Cmd,Data);
    print(obj.calcuChecksum(Cmd, Data));

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
      //ADD
      obj.calcuChecksum(Cmd, Data)+1
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

    // for (BluetoothCharacteristic c in characteristics) {
    //   print(c.uuid);
    //   if (c.uuid.toString() == '48400002-b5a3-f393-e0a9-e50e24dcca9e') {
    //     await c.write(
    //         rdata
    //         , withoutResponse: true);
    //     print(Data);
    //     print('${rdata} 보낸거');
    //     update();
    //   }
    // }
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

  //mqtt로 문열기 함수
  publish(){
    print('mqtt 상태값 : ${mqtt.client?.connectionStatus?.state}');
      if(mqtt.client?.connectionStatus?.state == MqttConnectionState.disconnected || mqtt.client?.connectionStatus?.state == null){
        mqtt.connect();
        print('커넥실패');
      }

      api.qRestApi("post", "/Smartdoor/doorOpenProcess", {}, true).then((res){
        if(res['statusCode'] == 200) {
          print('mqtt로 문열기');
          var i = 0;
          print('시작');
          Timer.periodic(Duration(seconds: 1), (timer) {
            print(i);
            print(trigger);
            if(trigger == true){
              print('mqtt 연결 성공');
              trigger= false;
              timer.cancel();
              btn = false;
              update();
            } else if (trigger == false && i == 20){
              print('mqtt 연결 실패');
              Get.back();
              door = '-2';
              Get.dialog(QuitWidget(serverMsg: '시간이 초과되었습니다 다시 시도해주세요.'));
              timer.cancel();
              btn = false;
              update();
            }
            i++;
          });
        } else if(res['statusCode'] == 401) {
          btn = false;
          update();
          Get.offAll(login_view());
        } else {
          Get.dialog(QuitWidget(serverMsg: res['body']['message']));
          btn = false;
          update();
        }
      });
  }

  push(){
    if(mqtt.client?.connectionStatus?.state == MqttConnectionState.disconnected){
      print('커넥실패');
      // connect();
    }

      String? pcode = sharedPreferences.getString('pcode');
      String? scode =  sharedPreferences.getString('scode');
      String? familyid =  sharedPreferences.getString('family_id');
      String? personid =  sharedPreferences.getString('person_id');
      print(pcode);
      print(scode);
      print(familyid);
      print(personid);
      var pubTopic = 'smartdoor/SMARTDOOR/${scode}';
      var builder = MqttClientPayloadBuilder();

      builder.addString('{"request":"productSncodeFamilyJoined","topic":"smartdoor/SMARTDOOR/${scode}","method":"input"}');
    mqtt.client?.subscribe(pubTopic, MqttQos.exactlyOnce);
    mqtt.client?.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!);


      final connMessage =
      MqttConnectMessage().startClean().withWillQos(MqttQos.exactlyOnce);
      print(connMessage);
    mqtt.client!.published!.listen((MqttPublishMessage message) {
        print('EXAMPLE::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
        print(message);

      });

  }

  // 상태값에따라 문 업데이트
  updatedoor(val){
    print('updatedoor : ${val}');

    if(val == 'true') {
      String dor = '1';
      print('현재 도어값 : ${door} 변경 : ${dor}}');
      door = dor;
      update();
    } else if(val == 'false'){
      door = '0';
      print(door);
      print('도어값 변경 : 닫힘');
      update();
    }

  }

  // BLE 스캔 상태 얻기 위한 리스너
  void initBle() async {
    print("initBle");
    solityObj = new Solity();
    //solityObj.find(ble);
  }

  Future<bool> checkBluetoothOn() async {
    return await flutterBlue.isOn;
  }

  //문상태
  requestDoorRead(){
    api.qRestApi("get", "/Smartdoor/me", {}, true).then((res) {
      if(res['statusCode'] == 200) {
        print("requestDoorRead");
        print('문상태 : ${res['body']['isDoorOpen']}');
        if(res['body']['isDoorOpen'] == 1) {
          updatedoor('true');
        } else if(res['body']['isDoorOpen'] == 0){
          updatedoor('false');
        }
      } else if (res['body']['code'] == "/Smartdoor/me/2" || res['body']['code'] == "/Smartdoor/me/3") {
        //등록되지 않은 오너 정보면 오너 등록 페이지로 이동
        Get.offAll(() => registration1_view());
      } else {
        snackbar(res['body']['message']);
      }
    });
  }

  @override
  void onInit(){
    info();
    requestDoorRead();
    //solityObj = new Solity();
    initBle();
    isDoorOpen();
    //_startTimer();
    print('메인 진입');
    super.onInit();
  }

  @override
  void onResumed() {
    print('onResumed');
    info();
    //initBle();
    //_startTimer();
    requestDoorRead();
  }

  @override
  void onPause() {
    _stopTimer();
  }

  @override
  void onClose() {

    //mqtt.client?.disconnect();
    // flutterBlue.turnOff();
    // scanResultList[0].device.disconnect();
    print('메인종료');
    super.onClose();

  }

  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
  }
}