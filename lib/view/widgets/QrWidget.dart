import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:wisemonster/view/login_view.dart';
import 'package:wisemonster/view_model/home_view_model.dart';

import '../../controller/qr_controller.dart';
final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
final home = Get.put(QRController());
class QrWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return AlertDialog(
      // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      //Dialog Main Title
      title: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [Text("QR코드 스캔")],
        ),
      ),
      //
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(child: QRView(
            key: qrKey,
            onQRViewCreated: home.onQRViewCreated,
            overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                ),
            onPermissionSet: (ctrl, p) => home.onPermissionSet(context, ctrl, p),
          ),),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("취소"),
          onPressed: () {
            Get.back();
          },
        ),
    ]);
  }

}