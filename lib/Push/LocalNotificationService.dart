// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context) {
    print("LocalNotificationService::initialize().\n");

    const InitializationSettings initializationSettings =
    const InitializationSettings(
        //android: AndroidInitializationSettings("@mipmap/ic_launcher"),
        android: AndroidInitializationSettings("@drawable/icon_push_message"),
        iOS: IOSInitializationSettings()
    );

    _notificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: (String? action) {
          doRoute(context, action!);
        });
  }

  static Future <void> display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = const NotificationDetails(
          android: AndroidNotificationDetails(
              "easyapproach",
              "easyapproach channel",
              importance: Importance.max,
              priority: Priority.high
          )
      );

      await _notificationsPlugin.show(
          id,
          message.notification!.title!,
          message.notification!.body,
          notificationDetails,
          payload: message.data["action"]);
    }
    catch (e) {
      print(e.toString());
    }
  }

  // http://211.175.164.72/app/fcm_send_test.php?target=moim&moims_id=147
  static void doRoute(BuildContext context, String action) async {
    print("LocalNotificationService::doRoute():action=$action");
    if (action.isNotEmpty) {
      List<String> data = action.split("_");

      String routeName = "";
      String withParam = "";
      if (data.isNotEmpty) {
        routeName = data[0];
      }

      if (data.length>1) {
        withParam = data[1];
      }

      if (routeName.isNotEmpty) {
        switch(routeName) {
          case "momo":
            Navigator.popAndPushNamed(context, "/");
            break;

          case "moims":
            if(withParam.isNotEmpty) {
              //Navigator.popAndPushNamed(context, "/moims", arguments: withParam);
              Navigator.popUntil(context, ModalRoute.withName("/"));
              Navigator.pushNamed(context, "/moims", arguments: withParam);
            }
            break;

          case "none":
            break;

          default:
            //Navigator.popAndPushNamed(context, "/");
            break;
        }
      }
    }
  }
}