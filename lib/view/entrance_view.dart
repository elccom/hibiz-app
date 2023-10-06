import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:wisemonster/view/addkey_view.dart';
import 'package:wisemonster/view/widgets/H1.dart';
import 'package:wisemonster/view_model/home_view_model.dart';
import '../controller/entrance_controller.dart';
import '../controller/member_controller.dart';
import 'home_view.dart';
import 'widgets/LeftSlideWidget.dart';

class entrance_view extends GetView<EntranceController> {


  @override
  Widget build(BuildContext context) {
    return  GetBuilder<EntranceController>(
            init: EntranceController(),
            builder: (EntranceController) => Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Color.fromARGB(255, 255, 255, 255),
                    iconTheme: const IconThemeData(color: Color.fromARGB(255, 44, 95, 233)),
                    centerTitle: true,
                    title: Text('출입기록',
                        style: TextStyle(
                            color: Color.fromARGB(255, 44, 95, 233), fontWeight: FontWeight.bold, fontSize: 20)),
                    automaticallyImplyLeading: true,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_outlined),
                      onPressed: () {
                        Get.offAll(home_view());
                      },
                    ),
                  ),
                  body: Container(
                    margin: EdgeInsets.fromLTRB(16, 40, 16, 0),
                    width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width - 32,
                    height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.height,
                    child: GroupedListView<dynamic, String>(
                      elements: EntranceController.elements,
                      groupBy: (element) => element['group'],
                      groupComparator: (value1, value2) => value2.compareTo(value1),
                      itemComparator: (item1, item2) => item1['name'].compareTo(item2['name']),
                      order: GroupedListOrder.ASC,
                      useStickyGroupSeparators: true,
                      groupSeparatorBuilder: (String value) => Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 87, 132, 255),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            value,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      indexedItemBuilder: (c, element, i) {
                        return Card(
                          elevation: 8.0,
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          child: SizedBox(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                              leading:Icon(Icons.door_front_door_outlined) ,
                              title: Text('${element['name']}'),
                              trailing: element['group'] =='' ? Text('') :Text(EntranceController.timeData[i]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ));
  }
}
