// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
//import 'package:flutter_inappwebview/flutter_inappwebview.dart';
//import 'package:kpostal/kpostal.dart';

/*
class WebBrowser extends StatefulWidget {
  final String website;
  String? title;
  bool supportZoom = true;
  WebBrowser({Key? key,
    required this.website,
    this.title,
    this.supportZoom = true,
  }) : super(key: key);
  @override
  _WebBrowserState createState() => _WebBrowserState();
}
*/
/*
class _WebBrowserState extends State<WebBrowser> {

  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  late InAppWebViewGroupOptions options;

  late PullToRefreshController pullToRefreshController;
  String url = "";
  double progress = 0;
  bool _bReady = false;

  @override
  void initState() {
    super.initState();

    options = InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          supportZoom: widget.supportZoom,
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false,
          clearCache: true,
          javaScriptCanOpenWindowsAutomatically: true,
        ),
        android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
          supportMultipleWindows: true,
        ),
        ios: IOSInAppWebViewOptions(
          allowsInlineMediaPlayback: true,
        ));
    print("initState()::url="+widget.website);

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );

    setState(() {
      _bReady = true;
    });

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(!_bReady) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1.0,
          title:
              Text(widget.title!, style: const TextStyle(color: Colors.black)),
          leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onPressed: () {
                _doClose(false);
              }),
        ),
        body: WillPopScope(
            onWillPop: () => _onBackPressed(context),
            child: SafeArea(
                child: Column(children: <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    InAppWebView(
                      key: webViewKey,
                      initialUrlRequest: URLRequest(
                        url: Uri.parse(widget.website),
                      ),
                      initialOptions: options,
                      pullToRefreshController: pullToRefreshController,
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                        webViewController!.addJavaScriptHandler(
                            handlerName: "webToAppMoim",
                            callback: (List list) {
                              fromApp(list.elementAt(0));
                            });
                      },
                      onLoadStart: (controller, url) {
                        print("onLoadStart():$url");
                      },
                      onConsoleMessage: (controller, consoleMessage) {
                        print(consoleMessage);
                      },
                      androidOnPermissionRequest:
                          (controller, origin, resources) async {
                        return PermissionRequestResponse(
                            resources: resources,
                            action: PermissionRequestResponseAction.GRANT);
                      },
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async {
                        var uri = navigationAction.request.url!;

                          // print(uri.toString());
                          //
                          // if (![ "http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri.scheme)) {
                          //   if (await canLaunch(url)) {
                          //     // Launch the App
                          //     await launch(url,);
                          //     // and cancel the request
                          //     return NavigationActionPolicy.CANCEL;
                          //   }
                          // }

                        return NavigationActionPolicy.ALLOW;
                      },
                      onLoadStop: (controller, url) async {
                        pullToRefreshController.endRefreshing();
                      },
                      onLoadError: (controller, url, code, message) {
                        pullToRefreshController.endRefreshing();
                      },
                      onProgressChanged: (controller, progress) {
                        if (progress == 100) {
                          pullToRefreshController.endRefreshing();
                        }

                        setState(() {
                          this.progress = progress / 100;
                        });
                      },
                      onUpdateVisitedHistory:
                          (controller, url, androidIsReload) {},
                      onCreateWindow: (controller, createWindowRequest) async {
                        print("onCreateWindow");
                      },
                    ),
                    (progress < 1.0)
                        ? LinearProgressIndicator(value: progress)
                        : Container(),
                  ],
                ),
              ),
            ]))));
  }

  Future<void> appToWeb(String postCode, String address, String bname,
      String latitude, String longitude) async {
    await webViewController!.evaluateJavascript(
        source: "window.appToSetAddr('$postCode','$address', '$bname')");
  }

  void fromApp(String cmd) {
    if (cmd == "ADDR") {
      _callAddrView();
    } else if (cmd == "OK") {
      _doClose(true);
    } else {
      _doClose(false);
    }
  }

  void _doClose(bool result) {
    Navigator.pop(context, result);
  }

  Future<bool> _canGoBack() async {
    return await webViewController!.canGoBack();
  }

  Future<void> _goBack() async {
    var flag = await webViewController!.canGoBack();
    if (flag) {
      await webViewController!.goBack();
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

  Future<void> _callAddrView() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KpostalView(
          useLocalServer: false,
          localPort: 1024,
          // kakaoKey: '{Add your KAKAO DEVELOPERS JS KEY}',
          callback: (Kpostal result) {
            appToWeb(result.postCode, result.address, result.bname,
                result.latitude.toString(), result.longitude.toString());
          },
        ),
      ),
    );
  }
}
*/