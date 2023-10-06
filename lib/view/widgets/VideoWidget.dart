import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';


/// Stateful widget to fetch and then display video content.
class VideoWidget extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoWidget> {
  final Completer<WebViewController> webview = Completer<WebViewController>();

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
          children: const [Text("동영상 재생")],
        ),
      ),
      //
      content: Builder(
        builder: (BuildContext context) => WebView(
      initialUrl: 'https://api.hizib.watchbook.tv/Smartdoor/streamProcess?smartdoor_vod_id=${Get.arguments}',
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        webview.complete(webViewController);
      },
      onPageStarted: (String url) {
        print('Page started loading: $url');
      },
      navigationDelegate: (NavigationRequest request) async {
        print('navigation to $request');
        final url = request.url;
        return NavigationDecision.navigate;
      },
      gestureNavigationEnabled: false,
    ),
    ),
      actions: <Widget>[
        TextButton(
          child: const Text("뒤로가기"),
          onPressed: () {
            Get.back();
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}