// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KAddress {
  String zipcode;
  String addr;
  String dong;
  String bname;
  String lat;
  String lon;

  KAddress({
    required this.zipcode,
    required this.addr,
    required this.dong,
    required this.bname,
    required this.lat,
    required this.lon
  });
}

class DaumAddress extends StatefulWidget {
  final Function(KAddress address) callback;
  DaumAddress({Key? key,
    required this.callback,
  }) : super(key: key);

  @override
  _DaumAddressState createState() => _DaumAddressState();
}

class _DaumAddressState extends State<DaumAddress> {
  _DaumAddressState();

  late WebViewController _webViewController;
  final String _url = "${URL_HOME}zipcode/";

  bool _bReady = false;
  @override
  void initState() {
    if(Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }

    setState(() {
      _bReady = true;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: const Text("주소검색"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: WillPopScope(
            onWillPop: () => _onBackPressed(context),
            child: _buildWebview()
      ),
    );
  }

  Widget _buildWebview() {
    if(!_bReady) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
        child: WebView(
          zoomEnabled:false,
          initialUrl: _url,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _webViewController = webViewController;
          },

          onProgress: (int progress) {
            print("WebView is loading (progress : $progress%)");
          },

          javascriptChannels: <JavascriptChannel> {
            fromApp(context),
          },

          navigationDelegate: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              print('blocking navigation to $request}');
              return NavigationDecision.prevent;
            }
            print('allowing navigation to $request');
            return NavigationDecision.navigate;
          },

          onPageStarted: (String url) {
            print('Page started loading: $url');
          },

          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },

          gestureNavigationEnabled: true,
        )
    );
  }

  // webToAppMoim.postMessage("{command:'OK'}");
  JavascriptChannel fromApp(BuildContext context) {
    return JavascriptChannel(
        name: 'webToAppMoim',
        onMessageReceived: (JavascriptMessage message) {
          print("webToAppMoim(): message = ${message.message}");
          dynamic param = jsonDecode(message.message)[0];
          var cmd = param['command'];
          switch(cmd) {
            case "KADDR": {
                final KAddress addr = KAddress(
                    zipcode: param['zipcode'],
                    addr: param['addr'],
                    dong: param['dong'],
                    bname: param['bname'],
                    lat: param['lat'],
                    lon: param['lon']
                );
                widget.callback(addr);
                Navigator.pop(context, true);
                break;
            }
            default:
              Navigator.pop(context);
              break;
          }
        }
    );
  }

  Future<bool> _canGoBack() async {
    return await _webViewController.canGoBack();
  }

  Future<void> _goBack() async {
    var flag = await _webViewController.canGoBack();
    if (flag) {
      await _webViewController.goBack();
    }
  }

  Future<bool> _onBackPressed(BuildContext context) async {
    var flag = await _canGoBack();
    if (flag) {
      _goBack();
    }
    else {
      Navigator.pop(context);
    }
    return Future(() => false);
  }
}
