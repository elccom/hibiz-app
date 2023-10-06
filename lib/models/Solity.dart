import 'dart:async';
import 'package:platform/platform.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Solity {
  //블루투스 인스턴스
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  //연결할 장치
  late BluetoothDevice device;
  //스캐팅여부
  bool isScanning = false;

  // 연결 상태 리스너 핸들 화면 종료시 리스너 해제를 위함
  StreamSubscription<BluetoothDeviceState>? stateListener;
  // 현재 연결 상태 저장용
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;
  //서비스
  late List<BluetoothService> services;
  List<BluetoothService> bluetoothService = [];

  Solity() {
    print("Solity init!");
  }

  // ble찾기
  void find(String macaddr) async {
    print("Solity find ${macaddr}");

    if(device == null) {
      await isOn().then((value) {
        print("블루튜스 isOn : ${value}");
        var scanResultList = [];
        if (value == true) {
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
                  device = element.device;
                  print("스캔된 장치 : ${element.device.id}");
                  flutterBlue.stopScan();
                  await listening();
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

  listening() async {
    print("Solity listening");

    if(device != null){
      stateListener = await device.state.listen((event) {
        print('블루투스상태 : ${event}');
        if(deviceState == event) return;
        else deviceState = event;
      });
    }

    await connect();
  }

  connect() async {
    if (deviceState == BluetoothDeviceState.disconnected) {
      device.connect(autoConnect: false).timeout(Duration(milliseconds: 15000), onTimeout: () {
        print('타임아웃');
        throw Exception("연결 대기 시간이 초과되어 연결할 수 없습니다.");
      }).then((data) async {
        services = await device.discoverServices();
        print('서비스 ${services}');
        bluetoothService = services;
        print('Service UUID: ${services[2].uuid}');
        print('Service UUID: ${services[2].characteristics[0]}');
        print('Service UUID: ${services[2].characteristics[0].uuid}');
        print('Service UUID: ${services[2].characteristics[1].uuid}');
        print('Service descriptors: ${services[2].characteristics[1].descriptors}');
      });
    }
  }

  //ble가 켜져 있는지
  Future<bool> isOn() async {
    return await flutterBlue.isOn;
  }

  //solity ble 연결 상태 가져오기
  String getStatus() {
    switch (deviceState) {
      case BluetoothDeviceState.disconnected:
        return 'Disconnected';
      case BluetoothDeviceState.disconnecting:
        return 'Disconnecting';
      case BluetoothDeviceState.connected:
        return 'Connected';
      case BluetoothDeviceState.connecting:
        return 'Connecting';
      default:
        return '';
    }
  }
}
