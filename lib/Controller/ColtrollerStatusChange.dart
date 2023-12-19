// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/widgets.dart';

class ControllerStatusChange extends ChangeNotifier {

  static const String aInvalidate = "aInvalidate";
  static const String aFrontView  = "aFrontView";
  static const String aBackView   = "aBackView";
  static const String aChange     = "aChange";
  static const String aSearch     = "aSearch";

  String users_id = "";
  String action   = "known";

  setUserId(String id){
    users_id = id;
    action = aChange;
    notifyListeners();
  }

  void goBack() {
    action = aBackView;
    notifyListeners();
  }

  void goFront() {
    action = aFrontView;
    notifyListeners();
  }

  void Invalidate() {
    action = aInvalidate;
    notifyListeners();
  }

  void goSearch() {
    action = aSearch;
    notifyListeners();
  }
}