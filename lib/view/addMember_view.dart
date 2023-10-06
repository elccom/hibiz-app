
import 'dart:convert';
import 'dart:developer';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wisemonster/api/api_services.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view/widgets/ContactListWidget.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import 'package:wisemonster/view_model/key_view_model.dart';
import 'package:wisemonster/view_model/newMem_view_model.dart';
import '../controller/member_controller.dart';
import 'widgets/LeftSlideWidget.dart';
import 'dart:math';

class addMember_view extends GetView<PlusController> {

  List<Contact>? contacts;
  getPermission() async{
    var status = await Permission.contacts.status;
    if(status.isGranted){
      print('허락됨');
      // 변수 가져오기!
      contacts = await ContactsService.getContacts();
      for(var i=0; i<contacts!.length; i++){
        print(inspect(contacts![i].phones?.first.value));
      }
      print(contacts![0].displayName);
      return contacts;
    } else if (status.isDenied){
      print('거절됨');
      Permission.contacts.request(); // 허락해달라고 팝업띄우는 코드
    }
  }
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
                  color: Color.fromARGB(255, 0000000000000000000000000018, 136, 248),
                  icon: Icon(
                    Icons.arrow_back_ios_new_outlined,
                    size: 20,
                  ),
                ),
                centerTitle: true,
                title: Text(
                '초대하기',
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
                        H1(changeValue: '호칭', size: 14,),
                        Container(height: 20,),
                      TextFieldWidget(
                          tcontroller: PlusController.namecontroller,
                          changeValue: PlusController.name,
                          hintText: '받으시는 분 호칭을 입력해주세요.'),
                        Container(height: 30,),
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
                                  Get.dialog(AlertDialog(
                                    // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                    //Dialog Main Title
                                    title: Container(
                                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [Text("연락처 목록")],
                                      ),
                                    ),
                                    //
                                    content:
                                    FutureBuilder(
                                        future: getPermission(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Container(
                                              height: 300.0, // Change as per your requirement
                                              width: 300.0, // Change as per your requirement
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: contacts!.length,
                                                itemBuilder: (BuildContext context, int index) {
                                                  return ListTile(
                                                    title: Text('${contacts![index].displayName}'),
                                                    subtitle: Text('${contacts![index].phones?.first.value}'),
                                                    onTap: (){
                                                      print(contacts![index].phones?.first.value);
                                                      Get.put(MemberController()).updateContact(contacts![index].phones?.first.value);
                                                    },
                                                  );
                                                },
                                              ),
                                            );
                                          } else {
                                            return
                                              Container(
                                                width: 100,
                                                height: 150,
                                                child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children:[
                                                      SizedBox
                                                        (
                                                        width: 50,
                                                        height: 50,
                                                        child: CircularProgressIndicator(
                                                        ),
                                                      )
                                                    ]
                                                ),
                                              )
                                            ;
                                          }
                                        }),
                                    actions: <Widget>[

                                    ],
                                  ));
                                  print('호출');
                                },
                                child: Text('주소록', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 14)),
                                style: TextButton.styleFrom(
                                    backgroundColor: Color.fromARGB(255, 87, 132, 255),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                              )),
                        ]),




                      ],
                    ),
                  ),
                  Container(
                      height: 60,
                      child:SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            PlusController.invite();
                          },
                          child: Text(
                            '초대',
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
  var namecontroller = TextEditingController();
  var phonecontroller = TextEditingController();
  var mesaagecontroller = TextEditingController();
  String phone = '';
  String name = '';
  var con = Get.put(MemberController());

  void snackbar(msg) {
    Get.snackbar(
      '알림',
      msg,
      duration: const Duration(seconds: 5),
      backgroundColor: const Color.fromARGB(
          255, 39, 161, 220),
      icon: const Icon(Icons.info_outline, color: Colors.white),
      forwardAnimationCurve: Curves.easeOutBack,
      colorText: Colors.white,
    );
  }

  invite(){
    print('초대');

    Map<String, dynamic> jsonData = {
      "url": "/SmartdoorUserInvite",
      "method": "POST",
      "isToken": true,
      "body":{'name':namecontroller.text,'handphone':phonecontroller.text}
    };

    api.restapi(jsonData).then((res) async {
      if(res['result']) {
        Get.back();
        con.requestMember();
        snackbar('초대 완료되었습니다.');
      } else if(res['statusCode'] == 401) {
        Get.offAll(login_view());
        //snackbar(res['message']);
      } else {
        Get.back();
        snackbar(res['message']);
      }
    });
    /*
    api.post(json.encode({'name':namecontroller.text,'handphone':phonecontroller.text}), '/SmartdoorUserInvite').then((value) {
      if(value.statusCode == 200) {
        Get.back();
        con.requestMember();
        snackbar('초대 완료되었습니다.');
      }else if(value.statusCode == 401) {
        Get.offAll(login_view());
        Get.snackbar(
          '알림',
          utf8.decode(value.reasonPhrase!.codeUnits)
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      }else {
        Get.snackbar(
          '알림',
          utf8.decode(value.reasonPhrase!.codeUnits)
          ,
          duration: Duration(seconds: 5),
          backgroundColor: const Color.fromARGB(
              255, 39, 161, 220),
          icon: Icon(Icons.info_outline, color: Colors.white),
          forwardAnimationCurve: Curves.easeOutBack,
          colorText: Colors.white,
        );
      }
    });
     */
  }
}
