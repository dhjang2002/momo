// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:momo/Moims/MoimHomeTab.dart';
import 'package:momo/Provider/GpsProvider.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Provider/RouteStatus.dart';
import 'package:momo/home/MainHomeTab.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future <void> _onBackgroundHandler(RemoteMessage message) async {

  print("\n_onBackgroundHandler() -----------------> ");
  if(message.notification != null) {
    String action = "";
    if(message.data["action"] != null) {
      action = message.data["action"];
    }
    print("title=${message.notification!.title.toString()},\n"
        "body=${message.notification!.body.toString()},\n"
        "action=$action");

    //LocalNotificationService.display(message);
  }
}

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_onBackgroundHandler);

  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }

  return runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GpsProvider()),
          ChangeNotifierProvider(create: (_) => LoginInfo()),
          ChangeNotifierProvider(create: (_) => RouteStatus()),
        ],
        child: const MoimApp(),
      ),
  );
}

class MoimApp extends StatefulWidget {
  const MoimApp({Key? key}) : super(key: key);

  @override
  _MoimAppState createState() => _MoimAppState();
}

class _MoimAppState extends State<MoimApp> {
  bool _bReady = false;


  @override
  void initState() {
    //print("MoimApp::initState()");
    setState(() {
      _bReady = true;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(!_bReady){
      return Container(color:Colors.white,
          child: Center(
              child: Image.asset("assets/icon/icon_logo1.png",
                width: 100, height: 100))
      );
    }

    return RefreshConfiguration(
      footerTriggerDistance: 10,
      dragSpeedRatio: 0.8,
      headerBuilder: () => const MaterialClassicHeader(),
      footerBuilder: () => const ClassicFooter(),
      enableLoadingWhenNoData: false,
      enableRefreshVibrate: false,
      enableLoadMoreVibrate: false,
      shouldFooterFollowWhenNotFull: (state) {
        return false;
      },

      child:MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '모두의모임',
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                iconTheme: IconThemeData(color: Colors.black),
                actionsIconTheme: const IconThemeData(color: Colors.black),
                centerTitle: true,
                elevation: 1.0,
                titleTextStyle: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.normal)
            ),
            primaryColor: Colors.black,
            primarySwatch: Colors.green,
            backgroundColor: Colors.white
          ),

          initialRoute: '/',
          routes: {
            "/"  : (_) => const MainHomeTab(),
            "/moims"  : (_) => const MoimHomeTab(moims_id: "147"),
          },
          //home: (_loginInfo.skip_intro=="Y") ? const MainHomeTab() : const IntroScreenPage(),
      ),
    );
  }
}

