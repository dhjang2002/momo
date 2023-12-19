// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:momo/Models/Shops.dart';
import 'package:momo/Remote/Remote.dart';

class ShopsCache {
  final int fetch_size = 25;
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

  Future <void> fetchItems({
    required bool isDistOrder,
    required int nextId,
    required Function Invalidate
  }) async {

    loading = true;
    Invalidate();

    String target_type = "users_id";
    if(target=="Moims") {
      target_type = "moims_id";
    }

    String lat = "";
    String lon = "";
    String dist = "";
    if(isDistOrder) {
      lat = latitude.toString();
      lon = longitude.toString();
      dist = limit_dist;
    }

    Map<String,String> params = {
      "command": "LIST",
      "list_attr":target,
      target_type: target_id,
      "rec_start":nextId.toString(),
      "rec_count":fetch_size.toString(),
      "lon":lon,
      "lat":lat,
      "distance":dist,
      "findKey":keyword,
      "tag":tag,
      "filter":filter,
    };

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
            Invalidate();
          });
        });
  }

}