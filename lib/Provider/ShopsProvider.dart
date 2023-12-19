// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Models/Shops.dart';
import 'package:momo/Remote/Remote.dart';

class ShopsProvider with ChangeNotifier {
  final int fetch_size = 50;
  List<Shops> cache = [];

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

  String filter = "";
  void setFilter(String filter) {
    this.filter = tag;
  }

  String tag = "";
  void setTag(String tag) {
    this.tag = tag;
  }

  String keyword = "";
  void setKeyword(String keyword) {
    this.keyword = keyword;
  }

  String limit_dist = "";
  String longitude = "";
  String latitude = "";
  void setLocation({required String longitude, required String latitude, required String limit_dist}) {
    this.longitude = longitude;
    this.latitude = latitude;
    this.limit_dist = limit_dist;
  }

  Future <void> fetchItems({required int nextId}) async {

    loading = true;
    notifyListeners();

    String target_type = "users_id";
    if(target=="Moims") {
      target_type = "moims_id";
    }

    Map<String,String> params = {
      "command": "LIST",
      "list_attr":target,
      target_type: target_id,
      "rec_start":nextId.toString(),
      "rec_count":fetch_size.toString(),
      "lon":longitude.toString(),
      "lat":latitude.toString(),
      "distance":limit_dist,
      "findKey":keyword,
      "tag":tag,
      "filter":filter,
    };

    //print("ShopsProvider:fetchItems() params=${params.toString()}");

    Remote.getShops(
        params: params,
        onResponse: (List<Shops> list) {
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