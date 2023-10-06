import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/controller/SData.dart';

class DeviceController extends GetxController {
  BluetoothDevice device = Get.arguments;
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  late SharedPreferences sharedPreferences;
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

  var encrypter;
  var encrypted;

  var decrypted;

  // iv값 설정
  List<int> iv2 = [61, 62, 63, 64, 65, 66, 67, 68];
  List<int> ini = [0,0,0,0,0,0,0,0];

  List<int> iniData = [];
  late List<int> ivKey = [];
  late en.IV iv;

  var appkey;

  //받을 수
  late bool isNeedDate;
  late bool isfirstRes;
  late bool isEncodeRes;
  var key;
  @override
  onInit() {
    print("DeviceController init!");
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
    connect();
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
  }

  /* 연결 시작 */
  Future<bool> connect() async {
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
                  c.value.listen((value)  {
                    // 데이터 읽기 처리!
                    print('${c.uuid}: $value');
                    // 받은 데이터 저장 화면 표시용
                    notifyDatas[c.uuid.toString()] = value;
                    if(value[3] == 230){
                      appkey = [value[3],value[4],value[5],value[6],value[7],value[8],value[9],value[10]];
                      print('appkey 값 : ${appkey}');
                    }else{
                      AESdecode(value);
                    }
                  });
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

  void encode(String plainText, en.IV iv){
    // 초기 문자열
    print('초기문자열 ${plainText}');
    // 문자열을 byte로
    List<int> byteString = utf8.encode(plainText);;
    // print('Byte로 변환한 문자열 : ${byteString}');
    // byte값을 aes 128 cbc 방식으로 인코딩
    // AESEncode(byteString,iv);
    // AESEncode(plainText);
  }
  late List<int> rdata;
      test(service,STX,cmd ) async{
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
             for(String i in split)
               int.parse(i),
            0,0,7
          ];
           var obj = SData(cmd,Data);
           int Length = 1 + Data.length;
           int sum = 0;
           for (int i = 0; i < Data.length; i++) {
             sum += Data[i];
           }
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
            for (BluetoothCharacteristic c in characteristics) {
              print(c.uuid);
              if (c.uuid.toString() == '48400002-b5a3-f393-e0a9-e50e24dcca9e') {
                c.write(
                    rdata
                    , withoutResponse: true);
                print('암호화 안된 문 전송');
                print('${rdata} 보낸거');
              }
            }


      }

  encrypt(input){
    var k = paddingRight(input, 0);
    print('${k} 이걸 암호화');
    var iv = en.IV.fromBase64(
        base64.encode([61, 62, 63, 64, 65, 66, 67, 68,
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
  enc(string){
    var data = paddingBytes(string);
    return encrypt(data);
  }
  paddingBytes(List<int> plaintext){
    print('${plaintext} 폄눙');
    int pcount = 16 - plaintext.length % 16;
    print(pcount);
    for(var i = 0; i < pcount; i++) {
      plaintext.add(0);
    }
    return plaintext;
  }

  AESdecode(val2) {
    print('받은 값 : ${val2}');
    print(base64.encode(val2));
    var iv = en.IV.fromBase64(
        base64.encode(
            [61, 62, 63, 64, 65, 66, 67, 68,
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

  }


  //stx값,cmd값,데이터(날짜),데이터(앱키 처음실행여부),데이터(암호화 여부)
  send(service,int STX,int Cmd){
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
        ADD];
      print('총 데이터 : ${send}');
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        print(c.uuid);
        if (c.uuid.toString() == '48400002-b5a3-f393-e0a9-e50e24dcca9e') {
            c.write(
                send
                , withoutResponse: true);
            print('암호화 안된 문 전송');
            print(Data);
            print('${send} 보낸거');
            isEncodeRes == true;
            update();
      }
    }
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
      for(String i in split)
        int.parse(i),
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
      ADD];
    print('총 데이터 : ${send}');

    var characteristics = service.characteristics;
    for (BluetoothCharacteristic c in characteristics) {
      print(c.uuid);
      if (c.uuid.toString() == '48400002-b5a3-f393-e0a9-e50e24dcca9e') {
        c.write(
            encrypt(send)
            , withoutResponse: true);
        print(Data);
        print('${encrypt(send)} 보낸거');
        isEncodeRes == true;
        update();
      }
    }
  }


  Widget buildService(BluetoothService service) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            send(service, 0x48, 0x10);
          },
          icon: const Icon(Icons.send_to_mobile_sharp, size: 20),
          label: const Text("전송(Send)"),
        ),
        // TextButton(onPressed: (){send(service, 0x48, 0x11,true ,true, true);}, child: Text('테스트')),
        TextButton(onPressed: (){auth(service, 0x48, 0x11);}, child: Text('인증')),
        TextButton(onPressed: (){test(service, 0x48, 0x21);}, child: Text('문열기')),
      ],
    );
  }


  List<Widget> buildServiceTiles(List<BluetoothService> services) {
    return services.map((s) {
      return buildService(s);
    }).toList();
  }

  Widget buildServices() {
    return StreamBuilder<List<BluetoothService>>(
      stream: device
          .services,
      initialData: [],
      builder: (c, snapshot) {
        return Column(
          children: buildServiceTiles(snapshot.data!),
        );
      },
    );
  }

  Widget buildIconButton() {
    return StreamBuilder<BluetoothDeviceState>(
        stream: device.state,
        initialData: BluetoothDeviceState.connecting,
        builder: (c, snapshot) {
          if (snapshot.data != BluetoothDeviceState.connected)
            return Icon(Icons.warning);
          return IconButton(
              icon: Icon(Icons.bluetooth_searching),
              onPressed: () => device.discoverServices());
        });
  }

  /* 각 캐릭터리스틱 정보 표시 위젯 */
  Widget characteristicInfo(BluetoothService r) {
    String name = '';
    String properties = '';
    String data = '';
    // 캐릭터리스틱을 한개씩 꺼내서 표시
    for (BluetoothCharacteristic c in r.characteristics) {
      properties = '';
      data = '';
      name += '\t\t${c.uuid}\n';
      if (c.properties.write) {
        properties += 'Write ';
      }
      if (c.properties.read) {
        properties += 'Read ';
      }
      if (c.properties.notify) {
        properties += 'Notify ';
        if (notifyDatas.containsKey(c.uuid.toString())) {
          // notify 데이터가 존재한다면
          if (notifyDatas[c.uuid.toString()]!.isNotEmpty) {
            data = notifyDatas[c.uuid.toString()].toString();
          }
        }
      }
      if (c.properties.writeWithoutResponse) {
        properties += 'WriteWR ';
      }
      if (c.properties.indicate) {
        properties += 'Indicate ';
      }
      name += '\t\t\tProperties: $properties\n';
      if (data.isNotEmpty) {
        // 받은 데이터 화면에 출력!
        name += '\t\t\t\t$data\n';
      }
    }
    return Text(name);
  }

  /* Service UUID 위젯  */
  Widget serviceUUID(BluetoothService r) {
    String name = '';
    name = r.uuid.toString();
    return Text(name);
  }

  /* Service 정보 아이템 위젯 */
  Widget listItem(BluetoothService r) {
    return ListTile(
      onTap: null,
      title: serviceUUID(r),
      subtitle: characteristicInfo(r),
    );
  }





}
