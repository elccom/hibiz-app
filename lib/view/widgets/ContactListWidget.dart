import 'dart:developer';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view_model/key_view_model.dart';

class ContactListWidget extends StatelessWidget {
  List<Contact>? contacts;
  getPermission() async{
    var status = await Permission.contacts.status;
    if(status.isGranted){
      print('허락됨');
      // 변수 가져오기!
      contacts = await ContactsService.getContacts();
      /*
      for(var i=0; i<contacts!.length; i++){
        print(inspect(contacts![i].phones?.first.value));
      }
      print(contacts![0].displayName);
      */
      return contacts;
    } else if (status.isDenied){
      print('거절됨');
      Permission.contacts.request(); // 허락해달라고 팝업띄우는 코드
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
                        Get.put(KeyViewModel()).updateContact(contacts![index].phones?.first.value);
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
    );
  }
}