// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/permission_handler.dart';
class RouteStatus with ChangeNotifier {
  //bool bWait = false;
  String target = "";
  String targetId = "";

  void setRoute(String targrt, String targetId) {
    this.target = target;
    this.targetId = targetId;
  }

  void clearRoute() {
    this.target = "";
    this.targetId = "";
  }
}