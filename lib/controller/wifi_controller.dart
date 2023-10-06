import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as en;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';
import 'package:byte_util/byte_util.dart';
import 'package:convert/convert.dart';
import 'package:hex/hex.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:crypto/crypto.dart';



class Util {
  static List<int>? convertInt2Bytes(value, Endian order, int bytesSize ) {
    try{
      final kMaxBytes = 8;
      var bytes = Uint8List(kMaxBytes)
        ..buffer.asByteData().setInt64(0, value, order);
      List<int> intArray;
      if(order == Endian.big){
        intArray = bytes.sublist(kMaxBytes-bytesSize, kMaxBytes).toList();
      }else{
        intArray = bytes.sublist(0, bytesSize).toList();
      }
      return intArray;
    }catch(e) {
      print('util convert error: $e');
    }
    return null;
  }
}
class WifiController extends GetxController {
   BluetoothDevice device = Get.arguments;
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
// 연결 상태 표시 문자열
  String stateText = 'Connecting';

  // 연결 버튼 문자열
  String connectButtonText = 'Disconnect';

  // 현재 연결 상태 저장용
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

  // 연결 상태 리스너 핸들 화면 종료시 리스너 해제를 위함
  StreamSubscription<BluetoothDeviceState>? stateListener;

  // 연결된 장치의 서비스 정보를 저장하기 위한 변수
  List<BluetoothService> bluetoothService = [];

  Map<String, List<int>> notifyDatas = {};

  @override
  onInit() {
    super.onInit();
    stateListener = device.state.listen((event) {
      debugPrint('event :  $event');
      if (deviceState == event) {
        // 상태가 동일하다면 무시
        return;
      }
      // 연결 상태 정보 변경
      setBleConnectionState(event);
    });
    // 연결 시작
    connectWIFI();
  }

  @override
  onClose() {
    // 상태 리스터 해제
    stateListener?.cancel();
    // 연결 해제
    device.disconnect();
    print('연결 해제');
    super.onClose();
  }

  /* 연결 상태 갱신 */
  setBleConnectionState(BluetoothDeviceState event) {
    switch (event) {
      case BluetoothDeviceState.disconnected:
        stateText = 'Disconnected';
        // 버튼 상태 변경
        connectButtonText = 'Connect';
        break;
      case BluetoothDeviceState.disconnecting:
        stateText = 'Disconnecting';
        break;
      case BluetoothDeviceState.connected:
        stateText = 'Connected';
        // 버튼 상태 변경
        connectButtonText = 'Disconnect';
        break;
      case BluetoothDeviceState.connecting:
        stateText = 'Connecting';
        break;
    }
    //이전 상태 이벤트 저장
    deviceState = event;
    if(Get.routing.current == "/ble_send_view"){
      update();
    }
  }

  /* 연결 시작 */
  Future<bool> connectWIFI() async {
    Future<bool>? returnValue;

    /* 상태 표시를 Connecting으로 변경 */
    stateText = 'Connecting';
    update();

    /*
      타임아웃을 10초(10000ms)로 설정 및 autoconnect 해제
       참고로 autoconnect가 true되어있으면 연결이 지연되는 경우가 있음.
     */
    await device
        .connect(autoConnect: false)
        .timeout(Duration(milliseconds: 15000), onTimeout: () {
      //타임아웃 발생
      //returnValue를 false로 설정
      returnValue = Future.value(false);
      debugPrint('timeout failed');

      //연결 상태 disconnected로 변경
      setBleConnectionState(BluetoothDeviceState.disconnected);
    }).then((data) async {
      if (returnValue == null) {
        //returnValue가 null이면 timeout이 발생한 것이 아니므로 연결 성공
        debugPrint('connection successful');

        List<BluetoothService> bleServices =
        await device.discoverServices();
        bluetoothService = bleServices;
        update();
        // 각 속성을 디버그에 출력
        for (BluetoothService service in bleServices) {
          print('============================================');
          print('Service UUID: ${service.uuid}');
          for (BluetoothCharacteristic c in service.characteristics) {
            print('\tcharacteristic UUID: ${c.uuid.toString()}');
            print('\t\twrite: ${c.properties.write}');
            print('\t\tread: ${c.properties.read}');
            print('\t\tnotify: ${c.properties.notify}');
            print('\t\tisNotifying: ${c.isNotifying}');
            print(
                '\t\twriteWithoutResponse: ${c.properties.writeWithoutResponse}');
            print('\t\tindicate: ${c.properties.indicate}');

            // notify나 indicate가 true면 디바이스에서 데이터를 보낼 수 있는 캐릭터리스틱이니 활성화 한다.
            // 단, descriptors가 비었다면 notify를 할 수 없으므로 패스!
            if (c.properties.notify && c.descriptors.isNotEmpty) {
              // 진짜 0x2902 가 있는지 단순 체크용!
              for (BluetoothDescriptor d in c.descriptors) {
                print('BluetoothDescriptor uuid ${d.uuid}');
                if (d.uuid == BluetoothDescriptor.cccd) {
                  print('d.lastValue: ${d.lastValue}');
                }
              }

              if (!c.isNotifying) {
                try {
                  await c.setNotifyValue(true);
                  // 받을 데이터 변수 Map 형식으로 키 생성
                  notifyDatas[c.uuid.toString()] = List.empty();
                  c.value.listen((value) {
                    // 데이터 읽기 처리!
                    print('${c.uuid}: $value');
                    // 받은 데이터 저장 화면 표시용
                    notifyDatas[c.uuid.toString()] = value;
                    print(value);
                    print('암호화 함');
                    }
                  );
                  update();
                  // 설정 후 일정시간 지연
                  await Future.delayed(const Duration(milliseconds: 500));
                } catch (e) {
                  print('error ${c.uuid} $e');
                }
              }
            }
          }
        }
        returnValue = Future.value(true);
      }
    });

    return returnValue ?? Future.value(false);
  }


  /* 연결 해제 */
  void disconnect() {
    try {
        stateText = 'Disconnecting';
        device.disconnect();
        update();
    } catch (e) {}
  }



  //stx값,cmd값,데이터(날짜),데이터(앱키 처음실행여부),데이터(암호화 여부)
  send(service) async{
    List<int> send;
      send = [
        1
      ];
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        print(c.uuid);
            c.write(
                send
                , withoutResponse: true);
            print('${send} 보낸거');
      }
  }}
