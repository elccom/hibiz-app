import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:wisemonster/view/qna_edit_view.dart';
import 'package:wisemonster/view/qna_plus_view.dart';
import '../controller/qna_controller.dart';


class qna_view extends GetView<QnaController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<QnaController>(
        init: QnaController(),
        builder: (QnaController) => Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            iconTheme: const IconThemeData(color: Color.fromARGB(255, 44, 95, 233)),
            centerTitle: true,
            title: Text('1:1 문의',
                style: TextStyle(
                    color: Color.fromARGB(255, 44, 95, 233), fontWeight: FontWeight.bold, fontSize: 20)),
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_outlined),
              onPressed: () {
                Get.back();
              },
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Get.to(qna_plus_view());
                  },
                  child: Text(
                    '추가',
                    style: TextStyle(
                      fontSize: 17,
                      color: Color.fromARGB(255, 87, 132, 255),
                    ),
                  ))
            ],
          ),
          body:
          QnaController.isclear == false ? Center(child: CircularProgressIndicator(),) :
          Container(
            margin: EdgeInsets.fromLTRB(16, 40, 16, 0),
            width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width - 32,
            height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height,
            child:
    SingleChildScrollView(
    child: ExpansionPanelList(
    elevation: 4,
    animationDuration: Duration(milliseconds: 1000),
    expansionCallback: (int index, bool isExpanded) {
      QnaController.items[index].isExpanded = !isExpanded;
      print(QnaController.items[index].isExpanded);
      QnaController.update();
    },
    children: QnaController.items.map<ExpansionPanel>((item) =>
    QnaController.buildExpansionPanel(item))
        .toList(),
    )
        ))));
  }
}
