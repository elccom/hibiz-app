import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:wisemonster/controller/config_controller.dart';
import 'package:wisemonster/view/home_view.dart';
import 'package:wisemonster/view/widgets/TextFieldWidget.dart';

import '../controller/faq_controller.dart';
import 'widgets/LeftSlideWidget.dart';

class faq_view extends GetView<FaqController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FaqController>(
        init:FaqController(),
        builder:(FaqController)=>
            Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Color.fromARGB(255, 255, 255, 255),
                iconTheme: const IconThemeData(color: Color.fromARGB(255, 44, 95, 233)),
                centerTitle: true,
                title: Text('FAQ', style: TextStyle(
                    color: Color.fromARGB(255, 44, 95, 233),
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
                automaticallyImplyLeading: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_outlined),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ),
              body: FaqController.toggle == false ? Center(child: CircularProgressIndicator(),) :
              Container(
                margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width - 32,
                height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height-40,
                child: SingleChildScrollView(
                  child: ExpansionPanelList(
                    elevation: 4,
                    animationDuration: Duration(milliseconds: 1000),
                    expansionCallback: (int index, bool isExpanded) {
                      FaqController.items[index].isExpanded = !isExpanded;
                      print(FaqController.items[index].isExpanded);
                      FaqController.update();
                    },
                    children: FaqController.items.map<ExpansionPanel>((item) =>
                        FaqController.buildExpansionPanel(item))
                        .toList(),
                  )


                ),
              ),
            ));}
}
