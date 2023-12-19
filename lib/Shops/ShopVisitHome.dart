// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
//import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:momo/Models/ShopVisit.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ShopVisitHome extends StatefulWidget {
  final String shops_id;
  final String users_id;
  final String moims;
  const ShopVisitHome({Key? key,
    required this.shops_id,
    required this.users_id,
    required this.moims,
  }) : super(key: key);
  @override
  _ShopVisitHomeState createState() => _ShopVisitHomeState();
}

class _ShopVisitHomeState extends State<ShopVisitHome> {
  //final GlobalKey _webViewKey = GlobalKey();
  //late WebViewController _webViewController;
  final String _appTitle = "방문확인";
  String _eventUrl = "";
  final double _webProgress = 0;
  bool _bReady = false;

  @override
  void initState() {

    if(Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    setState(() {
      _eventUrl = URL_HOME + "coupon/?mode=view&id=${widget.shops_id}";
      _bReady = true;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
          title:
              Text(_appTitle, style: const TextStyle(color: Colors.black)),
          leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onPressed: () {
                _doClose(false);
              }),
        ),
        body: _buildBody()
    );
  }

  Widget _buildBody() {
    if(!_bReady){
      return const Center(child: CircularProgressIndicator());
    }

    return WillPopScope(
        onWillPop: () => _onBackPressed(context),
        child: SafeArea(
            child: Column(children: <Widget>[
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Visibility(
                      visible: true,
                        child: WebView(
                          zoomEnabled:false,
                          initialUrl: _eventUrl,
                          javascriptMode: JavascriptMode.unrestricted,
                          onWebViewCreated: (WebViewController webViewController) {
                            //_webViewController = webViewController;
                          },

                          onProgress: (int progress) {
                            print("WebView is loading (progress : $progress%)");
                          },

                          javascriptChannels: <JavascriptChannel>{
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
                    ),
                    Visibility(
                      visible: true,
                      child: (_webProgress < 1.0)
                        ? LinearProgressIndicator(value: _webProgress)
                        : Container(),
                    ),
                    Visibility(
                        visible: false,//(_eventCache.cache.isEmpty),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          height: 200,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(15.0)
                          ),
                          child: const Text("발행된 쿠폰이 없습니다."),
                        )
                    ),
                    Positioned(
                      bottom: 50,
                        child: Visibility(
                          visible: true,
                          child: Center(
                            child:ElevatedButton(
                              child: const Text("방문\n확인", style:const TextStyle(fontSize:14.0, color:Colors.white)),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green,
                                  fixedSize: const Size(75, 75),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                              onPressed:() {
                                _addVisit();
                              },
                            ),),
                        ),
                    )
                  ],
                ),
              ),
            ])));
  }

  JavascriptChannel fromApp(BuildContext context) {
    return JavascriptChannel(
        name: 'webToApp',
        onMessageReceived: (JavascriptMessage message) {
          print("webToApp():${message.message}");
          if (message.message == "OK") {
            _doClose(true);
          } else {
            _doClose(false);
          }
        }
    );
  }

  void _doClose(bool result) {
    Navigator.pop(context, result);
  }

  Future<bool> _onBackPressed(BuildContext context) async {
    _doClose(false);
    return Future(() => false);
  }

  Future<void> _addVisit() async {
    //2. 방문기록하기
    await Remote.addVisits(
        params: {
          "command": "ADD",
          "users_id": widget.users_id,
          "shops_id": widget.shops_id,
          "moims": widget.moims,
          "consume": "아니오"
        },
        onResponse: (ShopVisit info ) {
          Navigator.pop(context);
        });
  }
}
