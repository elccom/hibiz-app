import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/view/key_view.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import '../api/api_services.dart';
import '../controller/SData.dart';
import '../view/widgets/QuitWidget.dart';
import 'package:encrypt/encrypt.dart' as en;

class KeyViewModel extends GetxController{

  ApiServices api = ApiServices();
  var startController = TextEditingController();
  var endController = TextEditingController();
  var startTimeController = TextEditingController();
  var endTimeController = TextEditingController();
  var passwdController = TextEditingController();
  var phonecontroller = TextEditingController();

  late DateTime pickedStartDate;

  late DateTime pickedEndDate;

  late Future<TimeOfDay?> selectedStartTime ;
  late Future<TimeOfDay?> selectedEndTime ;

  String sendStart = '';
  String sendEnd = '';

  String phone = '';
  String pw = '';

  bool isSend = false;
  bool isAuth = false;
  bool trigger1 = false;
  bool trigger2 = false;

  List<int> appkey = [];
  var encrypter;
  var encrypted;
  var decrypted;
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

  // sendSchedule(){
  //   api.requestSchedule('/FamilySchedule/saveAll',title,
  //       DateFormat('yyyy-MM-ddHH:ii:ss').format(pickedStartDate),
  //       DateFormat('yyyy-MM-ddHH:ii:ss').format(pickedEndDate),
  //       selectValue,
  //       place,
  //       comment).then((value) {
  //     if (value == false) {
  //       SnackBarWidget(serverMsg: value['message'],);
  //     } else {
  //       listData = value;
  //       update();
  //     }
  //   });
  // }

  splitDate(sendStart){
    List<String>? spl = sendStart?.split('-');
    var fst = int.parse(spl![0]);
    assert(fst is int);
    var scd = int.parse(spl![1]);
    assert(scd is int);
    var trd = int.parse(spl![2]);
    assert(trd is int);
    return [fst,scd,trd];
  }

  selectDate(type) {
    if(pickedStartDate != null && type == 0){
      print(pickedStartDate);
      String formattedDate = DateFormat('yyyy년 MM월 dd일').format(pickedStartDate);
      print(formattedDate);
      sendStart = DateFormat('yy-MM-dd').format(pickedStartDate);
      print(splitDate(DateFormat('yy-MM-dd').format(pickedStartDate)));
      startController.text = formattedDate; //set output date to TextField value.
      trigger1 = true;
      update();
    }else if(pickedEndDate != null && type == 1 ){
      print(pickedEndDate);
      String formattedDate = DateFormat('yyyy년 MM월 dd일').format(pickedEndDate);
      print(formattedDate);
      sendEnd = DateFormat('yy-MM-dd').format(pickedEndDate);
      endController.text = formattedDate; //set output date to TextField value.
      trigger2 = true;
      update();
    }else{
      SnackBarWidget(serverMsg: '날자가 선택되지 않았습니다.',);
      print("Date is not selected");
    }
  }

  selectTime(type,timeOfDay) {
    try{
      if(pickedStartDate != null && type == 0){
        startTimeController.text = '${timeOfDay.hour.toString()}시 ${timeOfDay.minute.toString()}분';
        pickedStartDate=DateTime.utc(pickedStartDate.year, pickedStartDate.month, pickedStartDate.day,
            timeOfDay.hour,timeOfDay.minute
        );
        print(pickedStartDate);

      }else if(pickedEndDate != null && type == 1){
        endTimeController.text = '${timeOfDay.hour.toString()}시 ${timeOfDay.minute.toString()}분';
        pickedEndDate=DateTime.utc(pickedEndDate.year, pickedEndDate.month, pickedEndDate.day,
            timeOfDay.hour,timeOfDay.minute
        );
        var timeData = [
          DateFormat('yy').format(pickedStartDate),
          pickedStartDate.month,
          pickedStartDate.day,
          pickedStartDate.hour,
          DateFormat('yy').format(pickedEndDate),
          pickedEndDate.month,
          pickedEndDate.day,
          pickedEndDate.hour,
          passwdController.text
        ];
        print(timeData);
        print(pickedEndDate);
      }
    }catch(e){
      Get.dialog(QuitWidget(serverMsg: '기간 설정부터 완료해주세요.',));
      print("Date is not selected");
    }
    update();
  }

  updateContact(value){
    phonecontroller.text = value;
    phone = value;
    Get.back();
    update();
  }
  Future<bool> checkBluetoothOn() async {
    return await flutterBlue.isOn;
  }
  send(service,int STX,int cmd) async {
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
  scan() async {
    print(await flutterBlue.isOn);
    await checkBluetoothOn().then((value){
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
                      deviceState = event;
                      update();
                    });
                    if (deviceState == BluetoothDeviceState.disconnected) {
                      Future<bool>? returnValue;
                      scanResultList[0].device.connect(autoConnect: false)
                          .timeout(Duration(milliseconds: 15000), onTimeout: () {
                        //타임아웃 발생
                        //returnValue를 false로 설정
                        returnValue = Future.value(false);
                        print('타임아웃');

                        //연결 상태 disconnected로 변경
                        deviceState = BluetoothDeviceState.disconnected;
                        update();
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
                          print(services[2].characteristics[1].deviceId);
                          print('주소 값 : ${sharedPreferences.getString('address')}');
                          if(!services[2].characteristics[1].isNotifying) {
                            try {
                              await services[2].characteristics[1].setNotifyValue(true);
                              print(isSend);
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
                                      appkey =
                                      [value[3], value[4], value[5], value[6], value[7], value[8], value[9], value[10]];
                                      print('appkey 값 : ${appkey}');
                                      auth(services[2], 0x48, 0x11);
                                    } else {
                                      List<int> com = AESdecode(value);
                                      print('인증 디코딩');

                                      if (com[3] == 0 && com[2] == 0x91 && isAuth == true) {
                                        print('인증완료');
                                        test(services[2], 0x48, 0x28);
                                      }else if (com[3] == 1 && com[2] == 0x91 && isAuth == true){
                                        isSend = false;
                                        isAuth = false;
                                        update();
                                        subscription?.cancel();
                                        print('앱키 지워짐 인증실패');
                                      }
                                      else if (com[2] == 254) {
                                        isSend = false;
                                        isAuth = false;
                                        update();
                                        subscription?.cancel();
                                      }
                                      if (com[3] == 1 && com[2] == 0xA8) {
                                        // Get.back();
                                        print('문열림');
                                        Get.dialog(QuitWidget(serverMsg: '문이 이미 열려있습니다'));
                                        isSend = false;
                                        isAuth = false;
                                        subscription?.cancel();
                                      } else if (com[3] == 0 && com[2] == 0xA8) {
                                        // Get.back();
                                        Get.dialog(QuitWidget(serverMsg: '문이 열렸습니다.'));
                                        isSend = false;
                                        isAuth = false;
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
        }
      }else{
        Get.dialog(QuitWidget(serverMsg: '블루투스설정을 활성화 해주세요.',));
      }
    }
    );
  }

  test(service,int STX,int cmd) async {
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
    List<int> timeData;
    try{
    timeData = [
      int.parse(DateFormat('yy').format(pickedStartDate)),
      pickedStartDate.month,
      pickedStartDate.day,
      pickedStartDate.hour,
      int.parse(DateFormat('yy').format(pickedEndDate)),
      pickedEndDate.month,
      pickedEndDate.day,
      pickedEndDate.hour,
      int.parse(passwdController.text)
    ];
    List<int> Data //종류에따라 값이 다름
    =
    [
      for(int i in Date)
        i,
      71,72,73,74,75,76,77,78,
      // for(int i in appkey)
      //   i,
      for(int i in timeData)
        i,
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
    var rdata = encrypt(send);
    var characteristics = service.characteristics;
    if(characteristics[0].uuid.toString() =='48400002-b5a3-f393-e0a9-e50e24dcca9e') {
      await characteristics[0].write(
          rdata
          , withoutResponse: true);
    }

    print('키교환 전송');
    return true;
    }catch(e){

    }
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

  createKey(){
    if(phonecontroller.text != null && passwdController.text != null && trigger1 == true && trigger2 == true){
      api.post(
        json.encode({'handphone':phonecontroller.text,'passwd' : passwdController.text,'startDate' : DateFormat('yyyy-MM-dd HH:m:ss').format(pickedStartDate), 'stopDate' : DateFormat('yyyy-MM-dd HH:m:ss').format(pickedEndDate)}),
        '/SmartdoorGuestkey'
      ).then((value) {
        if (value == false) {
          Get.dialog(
              QuitWidget(serverMsg: "에러가 발생했습니다. 관리자에게 문의해주세요.",)
          );
          update();
        } else {
          print('서버성공');
          Get.offAll(key_view());
          Get.snackbar(
            '알림',
            '키 발급에 성공하였습니다.'
            ,
            duration: const Duration(seconds: 5),
            backgroundColor: const Color.fromARGB(
                255, 39, 161, 220),
            icon: const Icon(Icons.info_outline, color: Colors.white),
            forwardAnimationCurve: Curves.easeOutBack,
            colorText: Colors.white,
          );
        }
      });
    }else{
      Get.dialog(
          QuitWidget(serverMsg: '값을 전부 설정해주세요.',)
      );
    }

  }
  void initBle() async {
    // BLE 스캔 상태 얻기 위한 리스너
    flutterBlue.scanResults.listen((event) {
      print(event);
    });
    flutterBlue.isScanning.listen((value) {
      isScanning = value;
      print('${isScanning} : 블루투스 상태');
      update();
    });


  }
  @override
  void onInit(){
    //initBle();
    super.onInit();
  }

  @override
  void onClose() {
    // flutterBlue.turnOff();
    // scanResultList[0].device.disconnect();
    startController.dispose();
    endController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    passwdController.dispose();
    phonecontroller.dispose();
    print('게스트키 종료');
    super.onClose();
  }
}