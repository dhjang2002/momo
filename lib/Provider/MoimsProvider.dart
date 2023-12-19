// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Models/Moims.dart';
import 'package:momo/Remote/Remote.dart';

class MoimsProvider with ChangeNotifier {
  List<Moims> cache = [];

  final int fetch_size = 50;
  // 로디중....
  bool loading = false;

  // 마지막 데이터 체크
  bool hasMore = true;

  late String target;
  late String target_id;
  void setTarget({required String targetTag, required String targetId}) {
    target    = targetTag;
    target_id = targetId;
  }

  void clear(bool notify) {
    cache.clear();
    if(notify) {
      notifyListeners();
    }
  }

  Future <void> fetchItems({required int nextId}) async {

    loading = true;
    notifyListeners();

    // "Owner", "Member", "Joinable"
    String list_attr = target.toString();
    Remote.getMoims(
        params: {
          "command": "LIST",
          "list_attr":list_attr,
          "users_id": target_id,
          "rec_start":nextId.toString(),
          "rec_count":fetch_size.toString(),
        },
        onResponse: (List<Moims> list) {
          final items = list;
          if(list.length<fetch_size) {
            hasMore = false;
          }

          if (list.isNotEmpty) {
            cache = [
              ...cache,
              ...items,
            ];
          }

          //print("\nlist.length=${list.length}");
          //print("\cache.length=${cache.length}");

          loading = false;
          Future.microtask(() {
            notifyListeners();
          });
        });
  }

}