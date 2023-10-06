import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:wisemonster/controller/config_controller.dart';
import 'package:wisemonster/view/faq_view.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view/qna_view.dart';
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';

import 'widgets/LeftSlideWidget.dart';

class config_view extends GetView<ConfigController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConfigController>(
        init:ConfigController(),
        builder:(ConfigController)=>
            Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Color.fromARGB(255, 255, 255, 255),
                iconTheme: const IconThemeData(color: Color.fromARGB(255, 44, 95, 233)),
                centerTitle: true,
                title: Text('설정', style: TextStyle(
                    color: Color.fromARGB(255, 44, 95, 233),
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
                automaticallyImplyLeading: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_outlined),
                  onPressed: () {
                    Get.offAll(home_view());
                  },
                ),
              ),
              body: Container(
                margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width - 32,
                height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height-40,
                child: SettingsList(
                  sections: [
                SettingsSection(
                title: Text('고객 센터'),
                  tiles: [
                    SettingsTile.navigation(
                      title:  Text('FAQ'),
                      onPressed: (value) {
                        Get.to(faq_view());
                      }
                    ),
                    SettingsTile.navigation(
                        title:  Text('1:1 문의'),
                        onPressed: (value) {
                          Get.to(qna_view());
                        }
                    )
                  ],
                  ),
                    SettingsSection(
                      title: Text('알림 설정'),
                      tiles: <SettingsTile>[
                        SettingsTile.switchTile(
                          onToggle: (value) {
                            ConfigController.isDoorbell = value;
                            ConfigController.toggle(value,'isDoorbell');
                            ConfigController.allupdate();
                          },
                          initialValue:ConfigController.isDoorbell,
                          title: Text('도어벨 알림'),
                        ),
                        SettingsTile.switchTile(
                          onToggle: (value) {
                            ConfigController.isAccessRecord = value;
                            ConfigController.toggle(value,'isAccessRecord');
                            ConfigController.allupdate();
                          },
                          initialValue: ConfigController.isAccessRecord,
                          title: Text('출입 알림'),
                        ),
                        SettingsTile.switchTile(
                          onToggle: (value) {
                            ConfigController.isMotionDetect = value;
                            ConfigController.toggle(value,'isMotionDetect');
                            ConfigController.allupdate();
                          },
                          initialValue: ConfigController.isMotionDetect,
                          title: Text('모션감지 알림'),
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: Text('네트워크 정보'),
                      tiles: <SettingsTile>[
                        SettingsTile.navigation(
                          leading: Icon(Icons.wifi),
                          title: (ConfigController.wifiName != null) ? Text('${ConfigController.wifiName}')
                              : Text('와이파이가 연결되지 않았습니다')
                          ,

                        ),
                      ],
                    ),
                    SettingsSection(
                      title: Text('버전 정보'),
                      tiles: <SettingsTile>[
                        SettingsTile.navigation(
                          leading: Icon(Icons.info_outline),
                          title: (ConfigController.deviceData != null) ? Text('OS 버전 : ${ConfigController.deviceData['OS 버전']}')
                              : Text('버전 정보를 불러올 수 없습니다.'),
                        ),
                        SettingsTile.navigation(
                          leading: Icon(Icons.info_outline),
                          title: (ConfigController.deviceData != null) ? Text('기기 : ${ConfigController.deviceData['기기']}')
                              : Text('버전 정보를 불러올 수 없습니다.'),
                        ),
                        // SettingsTile.navigation(
                        //   leading: Icon(Icons.info_outline),
                        //   title: (ConfigController.token != null) ?
                        //   TextFieldWidget(tcontroller: ConfigController.k, changeValue: ConfigController.test, hintText: '')
                        //       : Text('fcm토큰값 불러올 수 없습니다.'),
                        // ),
                      ],
                    ),

                  ],
                ),
              ),
            ));}
}
