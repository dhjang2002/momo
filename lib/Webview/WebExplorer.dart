// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:momo/Webview/DaumAddress.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebExplorer extends StatefulWidget {
  final String website;
  String? title;
  bool? supportZoom;

  WebExplorer({Key? key,
    required this.website,
    this.title="",
    this.supportZoom = true
  }) : super(key: key);

  @override
  _WebExplorerState createState() => _WebExplorerState();
}

class _WebExplorerState extends State<WebExplorer> {
  _WebExplorerState();

  late WebViewController _webViewController;

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
        title: Text(widget.title!),
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
      return const Center(child: const CircularProgressIndicator());
    }

    return SafeArea(
        child: WebView(
          zoomEnabled:widget.supportZoom!,
          initialUrl: widget.website,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _webViewController = webViewController;
            _webViewController.clearCache();
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
          //print("webToAppMoim() data="+param.toString());
          var cmd = param['command'];
          switch(cmd) {
            case "OK":
              _doClose(true);
              break;
            case "CANCEL":
              _doClose(false);
              break;
            case "ADDR":
              _callAddrView();
              break;
            default:
              break;
          }
        }
    );
  }

  Future<void> appToWeb(String postCode, String address, String bname,
      String latitude, String longitude) async {
    await _webViewController.runJavascript("window.appToSetAddr('$postCode','$address', '$bname')");
  }

  void _doClose(bool result) {
    Navigator.pop(context, result);
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
      _doClose(false);
    }
    return Future(() => false);
  }

  Future <void> _callAddrView() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DaumAddress(
          callback: (KAddress result) {
            appToWeb(result.zipcode, result.addr, result.bname, result.lat.toString(), result.lon.toString());
          },
        ),
      ),
    );
  }

}
