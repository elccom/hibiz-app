
import 'dart:convert';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/widgets/ContactListWidget.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/QuitWidget.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'package:wisemonster/view_model/key_view_model.dart';
import 'package:wisemonster/view_model/newMem_view_model.dart';
import '../controller/member_controller.dart';
import 'key_view.dart';
import 'widgets/LeftSlideWidget.dart';
import 'dart:math';

class addkey_view extends GetView<PlusController> {

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlusController>(
        init: PlusController(),
        builder: (PlusController) => Scaffold(
            resizeToAvoidBottomInset : false,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Color.fromARGB(255, 255, 255, 255),
                iconTheme: const IconThemeData(color: Color.fromARGB(255, 44, 95, 233)),
                leading: IconButton(
                  onPressed: () => Get.back(),
                  color: Color.fromARGB(255, 44, 95, 233),
                  icon: Icon(
                    Icons.arrow_back_ios_new_outlined,
                    size: 20,
                  ),
                ),
                centerTitle: true,
                title: Text(
                '게스트 키 발급',
                    style:
                        TextStyle(color: Color.fromARGB(255, 44, 95, 233), fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(16, 40, 16, 0),
                    width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width - 32,
                    height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height - 186,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        H1(changeValue: '휴대폰번호', size: 14,),
                        Row(children: [
                          Expanded(
                              flex: 66,
                              child: TextFieldWidget(
                                  tcontroller: PlusController.phonecontroller,
                                  changeValue: PlusController.phone,
                                  hintText: '휴대폰번호를 입력해주세요.')),
                          Container(width: 20,),
                          Expanded(
                              flex: 27,
                              child: TextButton(
                                onPressed: () {
                                  Get.dialog(ContactListWidget());
                                  print('호출');
                                },
                                child: Text('주소록', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 14)),
                                style: TextButton.styleFrom(
                                    backgroundColor: Color.fromARGB(255, 87, 132, 255),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                              )),
                        ]),
                        Container(height: 30,),
                        H1(changeValue: '기간설정', size: 14,),
                        Row(
                          children: [
                            Expanded(
                              flex: 43,
                              child:
                              TextField(
                                controller: PlusController.startController, //editing controller of this TextField
                                decoration: InputDecoration(
                                    icon: Icon(Icons.calendar_month_outlined), //icon of text field
                                    labelText: "시작일" //label text of field
                                ),
                                readOnly: true, //set it true, so that user will not able to edit text
                                onTap: () async {
                                  PlusController.pickedStartDate = (await showDatePicker(
                                      initialEntryMode: DatePickerEntryMode.calendarOnly,
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                                      lastDate: DateTime(2101)))!;
                                  PlusController.selectDate(0);
                                },
                              ),
                            ),
                            Expanded(
                                flex: 12,
                                child:
                                Center(
                                  child: Text('~'),
                                )
                            ),
                            Expanded(
                              flex: 43,
                              child: TextField(
                                controller: PlusController.endController, //editing controller of this TextField
                                decoration: InputDecoration(
                                    icon: Icon(Icons.calendar_month_outlined), //icon of text field
                                    labelText: "종료일" //label text of field
                                ),
                                readOnly: true, //set it true, so that user will not able to edit text
                                onTap: () async {
                                  PlusController.pickedEndDate = (await showDatePicker(
                                      initialEntryMode: DatePickerEntryMode.calendarOnly,
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                                      lastDate: DateTime(2101)))!;
                                  PlusController.selectDate(1);
                                },
                              ),
                            )
                          ],
                        ),
                        Container(height: 30,),
                        H1(changeValue: '시간설정', size: 14,),
                        Row(
                          children: [
                            Expanded(
                              flex: 43,
                              child:
                              TextField(
                                controller: PlusController.startTimeController, //editing controller of this TextField
                                decoration: InputDecoration(
                                    icon: Icon(Icons.timer), //icon of text field
                                    labelText: "시작 시간" //label text of field
                                ),
                                readOnly: true, //set it true, so that user will not able to edit text
                                onTap: () async {
                                  PlusController.selectedStartTime =
                                  (showTimePicker(context: context,
                                      initialEntryMode: TimePickerEntryMode.inputOnly,
                                      initialTime: TimeOfDay.now()))!;
                                  PlusController.selectedStartTime.then((timeOfDay) {
                                    PlusController.selectTime(0,timeOfDay);
                                  }
                                  );
                                },
                              ),
                            ),
                            Expanded(
                                flex: 12,
                                child:
                                Center(
                                  child: Text('~'),
                                )
                            ),
                            Expanded(
                              flex: 41,
                              child:
                              TextField(
                                controller: PlusController.endTimeController, //editing controller of this TextField
                                decoration: InputDecoration(
                                    icon: Icon(Icons.timer), //icon of text field
                                    labelText: "종료 시간" //label text of field
                                ),
                                readOnly: true, //set it true, so that user will not able to edit text
                                onTap: () async {
                                  PlusController.selectedEndTime =
                                  (showTimePicker(
                                      initialEntryMode: TimePickerEntryMode.inputOnly,
                                      context: context, initialTime: TimeOfDay.now()))!;
                                  PlusController.selectedEndTime.then((timeOfDay) {
                                    PlusController.selectTime(1,timeOfDay);
                                  }
                                  );
                                },
                              ),
                            ),

                          ],
                        ),
                        Container(height: 30,),
                        H1(changeValue: '일회용 비밀번호', size: 14,),
                        TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            maxLength: 6,
                            controller: PlusController.passwdController, //set id controller
                            style: const TextStyle(
                                color: Color.fromARGB(255, 43, 43, 43), fontSize: 17),
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Color.fromARGB(255, 43, 43, 43))),
                            ),

                            onChanged: (value) {
                              //변화된 id값 감지
                              PlusController.pw = value;
                              print(value);
                            }),
                        Container(height: 30,),
                        Center(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(20),
                                  ),
                                  maximumSize: Size(246, 40),
                                  backgroundColor: Color.fromARGB(255, 87, 132, 255)
                              ),
                              onPressed: (){
                                List<int> nums = [];

                                for( int i = 0; i < 6; i ++) {
                                  nums.add(Random().nextInt(9));
                                }
                                PlusController.passwdController.text = nums[0].toString()+nums[1].toString()+nums[2].toString()+nums[3].toString()+nums[4].toString()+nums[5].toString();
                              },
                              child:Center(
                                child: Text('일회용 비밀번호 자동 생성',
                                  style: TextStyle(
                                      fontSize: 14
                                  ),
                                ),
                              )
                          ),
                        )

                      ],
                    ),
                  ),
                  Container(
                      height: 60,
                      child:SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            PlusController.createKey();
                          },
                          child: Text(
                            '발급하기',
                            style: TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 87, 132, 255),
                          ),
                        ),
                      )
                  )
                ],
              )
            ));
  }
}
class PlusController extends GetxController{
  ApiServices api = ApiServices();

  var startController = TextEditingController();
  var endController = TextEditingController();
  var startTimeController = TextEditingController();
  var endTimeController = TextEditingController();
  var passwdController = TextEditingController();
  var phonecontroller = TextEditingController();

  late Future<TimeOfDay?> selectedStartTime ;
  late Future<TimeOfDay?> selectedEndTime ;

  bool trigger1 = false;
  bool trigger2 = false;

  late DateTime pickedStartDate;
  late DateTime pickedEndDate;

  String sendStart = '';
  String sendEnd = '';
  String phone = '';
  String pw = '';

  var controller = Get.put(KeyView());

  void snackbar(msg) {
    if(Get.isDialogOpen != null && Get.isDialogOpen!) Get.back();

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

  void dialog(String msg) {
    Get.dialog(
      AlertDialog(
        title: Text('알림'),
        content: Text(msg),
        actions: [
          TextButton(
            child: const Text("닫기"),
            onPressed: () => Get.offAll(key_view()),
          ),
        ],
      ),
    );
  }

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

  selectTime(type,timeOfDay) {
    try{
      if(pickedStartDate != null && type == 0){
        startTimeController.text = '${timeOfDay.hour.toString()}시 ${timeOfDay.minute.toString()}분';
        pickedStartDate=DateTime.utc(pickedStartDate.year, pickedStartDate.month, pickedStartDate.day,
            timeOfDay.hour,timeOfDay.minute
        );
        print(pickedStartDate);
      } else if(pickedEndDate != null && type == 1){
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
    } catch(e){
      Get.dialog(QuitWidget(serverMsg: '기간 설정부터 완료해주세요.',));
      print("Date is not selected");
    }
    update();
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
    } else if(pickedEndDate != null && type == 1 ){
      print(pickedEndDate);
      String formattedDate = DateFormat('yyyy년 MM월 dd일').format(pickedEndDate);
      print(formattedDate);
      sendEnd = DateFormat('yy-MM-dd').format(pickedEndDate);
      endController.text = formattedDate; //set output date to TextField value.
      trigger2 = true;
      update();
    } else{
      snackbar('날짜가 선택되지 않았습니다.');
    }
  }

  createKey() async {
    String handphone = phonecontroller.text;
    String passwd = passwdController.text;
    String startDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(pickedStartDate);
    String stopDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(pickedEndDate);

    if(handphone == null || handphone == "")  Get.dialog(QuitWidget(serverMsg: '핸드폰번호를 설정해주세요.',));
    if(passwd == null || passwd == "")  Get.dialog(QuitWidget(serverMsg: '비밀번호를 설정해주세요.',));
    if(!trigger1)  Get.dialog(QuitWidget(serverMsg: '유효기간 시작일자를 설정해주세요.',));
    if(!trigger2)  Get.dialog(QuitWidget(serverMsg: '유효기간 종료일자를 설정해주세요.',));

    api.qRestApi("post", "/Smartdoor/guestkeyJoinProcess", {'handphone':handphone,'passwd' : passwd,'startDate' : startDate, 'stopDate' : stopDate}, true).then((res) {
      if(res['statusCode'] == 200) {
        controller.requestKey();
        dialog('게스트키 발급 신청하였습니다.\n발급 성공여부는 발급 목록에서 확인하세요.');
      } else if(res['statusCode'] == 401) {
        Get.offAll(login_view());
        snackbar(res['body']['message']);
      } else {
        snackbar(res['body']['message']);
      }
    });
  }
}
