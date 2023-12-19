// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:momo/Models/Person.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginInfo with ChangeNotifier {
  final String prefAuth = "config";

  Person? person;
  String? uid;
  String? pwd;
  String? users_id;
  String? isSigned;
  String? auto_login;
  String? skip_intro = "";
  String? push_token = "";

  String? isInitNotify = "";
  String? isSetSubscribed = "";

  LoginInfo() {
    clear();
  }

  void clear() {
    uid = "";
    pwd = "";
    users_id   = "";
    auto_login = "";
    isSigned = "";
    person   = Person();
  }

  void clearSignInfo() {
    uid = "";
    pwd = "";
    users_id   = "";
    auto_login = "";
    isSigned   = "";
    isSetSubscribed = "";
    person     = Person();
  }

  Future <bool> getPref() async {
    bool isValid = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var value = prefs.getString(prefAuth);
    if(value != null) {
      dynamic json = jsonDecode(value);
      uid = (json.containsKey("uid")) ? json['uid'] : "";
      push_token = (json.containsKey("push_token")) ? json['push_token'] : "";
      pwd = (json.containsKey("pwd")) ? json['pwd'] : "";
      users_id = (json.containsKey("users_id")) ? json['users_id'] : "";
      skip_intro = (json.containsKey("skip_intro")) ? json['skip_intro'] : "";
      auto_login = (json.containsKey("auto_login")) ? json['auto_login'] : "";
      isSigned = (json.containsKey("isSigned")) ? json['isSigned'] : "";
      isInitNotify = (json.containsKey("isInitNotify")) ? json['isInitNotify'] : "";
      isSetSubscribed = (json.containsKey("isSetSubscribed")) ? json['isSetSubscribed'] : "";
    }
    else{
      clear();
    }

    notifyListeners();
    return isValid;
  }

  Future<void> setPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var map = toMap();
    final json = jsonEncode(map);
    await prefs.setString(prefAuth, json.toString());
  }

  Map<String, String> toMap() => {
    'uid': uid.toString(),
    'pwd': pwd.toString(),
    'users_id': users_id.toString(),
    'push_token': push_token.toString(),
    'auto_login': auto_login.toString(),
    'skip_intro': skip_intro.toString(),
    'isSigned': isSigned.toString(),
    'isInitNotify': isInitNotify.toString(),
    'isSetSubscribed': isSetSubscribed.toString()
  };

  @override
  String toString(){
    return 'Config {'
        'uid:$uid, '
        'pwd:$pwd, '
        'users_id:$users_id, '
        'push_token:$push_token, '
        'auto_login:$auto_login, '
        'isSigned:$isSigned, '
        'isInitNotify:$isInitNotify, '
        'isSetSubscribed:$isSetSubscribed, '
        'kip_intro:$skip_intro}';
  }
}