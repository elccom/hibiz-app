import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wisemonster/controller/newMember_controller.dart';
import 'package:wisemonster/view/newMember5_view.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view/widgets/H2.dart';
import 'package:wisemonster/view/widgets/SnackBarWidget.dart';
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';
import 'package:wisemonster/view_model/newMem_view_model.dart';
import 'package:wisemonster/view/widgets/AlertWidget.dart';

class afterQr_view extends GetView<NewMemberController> {
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return GetBuilder<NewMemberViewModel>(
        init: NewMemberViewModel(),
        builder: (NewMemberViewModel) =>
            WillPopScope(
                onWillPop: () => _goBack(context),
                child: Scaffold(
                  // resizeToAvoidBottomInset: false,
                  appBar: AppBar(
                      centerTitle: true,
                      backgroundColor: Color.fromARGB(255, 42, 66, 91),
                      iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
                      title:Text('기기 정보 확인 및 장소등록')
                  ),
                  body: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child:
                      Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                          width: MediaQueryData
                              .fromWindow(WidgetsBinding.instance!.window)
                              .size
                              .width,
                          //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
                          height: MediaQueryData
                              .fromWindow(WidgetsBinding.instance!.window)
                              .size
                              .height - 140,
                          color: Colors.white,
                            child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    H1(changeValue: '제품명', size: 20,),
                                    Container(height: 10,),
                                    H2(changeValue: Get.arguments[0]),
                                    Container(height: 30,),
                                    H1(changeValue: '제품시리얼넘버',size: 20,),
                                    Container(height: 10,),
                                    H2(changeValue: Get.arguments[1]),
                                    Container(height: 30,),
                                    H1(changeValue: '등록 장소',size: 20,),
                                    TextFieldWidget(tcontroller: NewMemberViewModel.placeController, changeValue: NewMemberViewModel.place, hintText: '등록할 장소를 입력해주세요.',),
                                  ],
                                )),
                          ),
                      Container(
                          height: 60,
                          child:SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // NewMemberViewModel.requestPlaceJoinProcess(Get.arguments[2]);
                              },
                              child: const Text(
                                "등록완료",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                    255, 39, 161, 220),
                              ),
                            ),
                          )
                      )
                    ],
                  )
                  ),
                )
            )
    );
  }

  Future<bool> _goBack(BuildContext context) async {
    return true;
  }
}
