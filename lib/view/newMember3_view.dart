import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:wisemonster/controller/newMember_controller.dart';
import 'package:wisemonster/view_model/newMem_view_model.dart';

class newMember3_view extends GetView<NewMemberController>{
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return GetBuilder<NewMemberViewModel>(
        init: NewMemberViewModel(),
        builder: (NewMemberViewModel) =>
            WillPopScope(
                onWillPop: () => _goBack(context),
                child: Scaffold(
                  appBar: AppBar(
                      centerTitle: true,
                      backgroundColor: Color.fromARGB(255, 42, 66, 91),
                      iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
                      title:Text('이용 약관')
                  ),
                  resizeToAvoidBottomInset: false,
                  body: Container(
                      padding: const EdgeInsets.only(top: 90),
                      width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                          .size
                          .width,
                      //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
                      height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                          .size
                          .height,
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                              width: MediaQueryData.fromWindow(
                                  WidgetsBinding.instance!.window)
                                  .size
                                  .width,
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: const Text('02',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              )),
                                          decoration: const BoxDecoration(
                                              color: Color.fromARGB(255, 0, 104, 166),
                                              shape: BoxShape.circle),
                                          width: 48,
                                          height: 48,
                                        ),
                                      ),
                                      const Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          '휴대폰 인증',
                                          style: TextStyle(
                                              fontSize: 23,
                                              height: 1.6,
                                              color: Color.fromARGB(255, 0, 104, 166)),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: const Color.fromARGB(255, 0, 104, 166),
                                    width: 1),
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(

                                    width: MediaQueryData.fromWindow(
                                        WidgetsBinding.instance!.window)
                                        .size
                                        .width,
                                    margin: const EdgeInsets.only(right: 20),
                                    padding: const EdgeInsets.fromLTRB(20, 13, 40, 13),
                                    child: const Text(
                                      '휴대폰 번호를 입력해주세요.',
                                      style: TextStyle(fontSize: 20, color: Colors.white),
                                    ),
                                    decoration: const BoxDecoration(
                                        color: Color.fromARGB(
                                            255, 0, 104, 166),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(40),
                                          bottomRight: Radius.circular(40),
                                        )),
                                  ),
                                  Container(
                                      padding: const EdgeInsets.only(left: 20),
                                      margin: const EdgeInsets.fromLTRB(20, 30, 20, 8),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 206, 206, 206)
                                          )
                                      ),
                                      child: TextField(
                                          controller: NewMemberViewModel.nameController, //set id controller
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 206, 206, 206), fontSize: 16),
                                          decoration: const InputDecoration(
                                              hintText: '성명을 입력해 주세요.',
                                              hintStyle: TextStyle(color: Color.fromARGB(
                                                  255, 206, 206, 206)),
                                              border: InputBorder.none
                                          ),
                                          onChanged: (value) {
                                            //변화된 id값 감지
                                            NewMemberViewModel.name = value;
                                          })),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                            flex : 74,
                                            child:Container(
                                              padding: const EdgeInsets.only(left: 20),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: const Color.fromARGB(
                                                          255, 206, 206, 206)
                                                  )
                                              ),
                                              child:  TextField(
                                                  controller: NewMemberViewModel.phoneController, //set id controller
                                                  style: const TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 206, 206, 206), fontSize: 16),
                                                  decoration: const InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: '- 없이 입력해주세요.',
                                                    hintStyle: TextStyle(color: Color.fromARGB(
                                                        255, 206, 206, 206)),
                                                  ),
                                                  keyboardType: TextInputType.number,
                                                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                                  onChanged: (value) {
                                                    //변화된 id값 감지
                                                    NewMemberViewModel.phone = value;
                                                  }),
                                            )),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                                    child: NewMemberViewModel.send == 1 ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                            flex: 74,
                                            child: Container(
                                              padding: const EdgeInsets.only(left: 20),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: const Color.fromARGB(
                                                          255, 206, 206, 206)
                                                  )
                                              ),
                                              child:  Row(

                                                children: [
                                                  Expanded(
                                                    flex: 70,
                                                    child: TextField(
                                                      maxLength: 6,
                                                      controller: NewMemberViewModel.phoneAuthController, //set id controller
                                                      style: const TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 206, 206, 206), fontSize: 16),
                                                      keyboardType: TextInputType.number,
                                                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                                      decoration: const InputDecoration(
                                                        counterText: '',
                                                        border: InputBorder.none,
                                                        hintText: '인증번호를 입력해주세요.',
                                                        hintStyle: TextStyle(color: Color.fromARGB(
                                                            255, 206, 206, 206)),
                                                      ),
                                                      onChanged: (value) {
                                                        //변화된 id값 감지
                                                        NewMemberViewModel.phoneAuth = value;
                                                      }),),
                                                  Expanded(
                                                    flex: 30,
                                                      child: Container(
                                                    padding:const EdgeInsets.fromLTRB(13, 16, 10, 16) ,
                                                    child:
                                                    Obx(() => Text('${NewMemberViewModel.min.value}분 ${NewMemberViewModel.sec.value}초',
                                                        style: const TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 255, 0, 0),
                                                          fontSize: 14,
                                                        ))),
                                                  ))
                                                ],
                                              ),
                                            )
                                        ),
                                        ],
                                    ) : null,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                    height: 68,
                                    child:
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Obx(() => NewMemberViewModel.txt.value == 2 ?
                                        const Text('* 인증번호가 일치하지 않습니다.',
                                            style: TextStyle(
                                                color: Color.fromARGB(255, 255, 0, 0),
                                                fontSize: 14
                                            ) )
                                            :
                                        NewMemberViewModel.txt.value == 1 ?
                                        const Text('* 인증완료 되었습니다.',
                                            style: TextStyle(
                                                color: Color.fromARGB(255, 17, 255, 0),
                                                fontSize: 14
                                            ) )
                                            : const Text('', style: TextStyle(fontSize: 14),)),
                                        const Text('* 입력시간 내 인증번호 6자리를 입력해주세요.',
                                          style: TextStyle(fontSize: 14),),
                                        const Text("* 인증번호가 오지 않는 경우 '재전송'을 클릭해주세요",
                                          style: TextStyle(fontSize: 14),)
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],),
                          Container(
                            height: 106,
                            margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  height: 48,
                                  width: double.infinity,

                                ),
                                SizedBox(
                                  height: 48,
                                  width: double.infinity,
                                )
                              ],
                            ),
                          )
                        ],
                      ) ),
                ))

    );
  }
  Future<bool> _goBack(BuildContext context) async {
    return true;
  }

}