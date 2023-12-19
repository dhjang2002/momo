// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:momo/Models/MemberInfo.dart';
import 'package:momo/Remote/Remote.dart';

class MembersCache {
  List<MemberInfo> cache = [];

  final int fetch_size = 25;
  // 로디중....
  bool loading = false;

  // 마지막 데이터 체크
  bool hasMore = true;

  String isAll = "true";
  late String target;
  late String target_id;
  late String usersId;
  void setTarget({
    required String targetTag,
    required String targetId,
    required String usersId
  }) {
    target    = targetTag;
    target_id = targetId;
    this.usersId = usersId;
    //clear();
  }

  void clear(bool notify) {
    cache.clear();
  }

  String limit_dist = "";
  String longitude = "";
  String latitude = "";
  void setLocation({
    required String longitude,
    required String latitude,
    required String limit_dist
  }) {
    this.longitude = longitude;
    this.latitude = latitude;
    this.limit_dist = limit_dist;
  }

  Future <void> fetchItems({
    required bool isListMode,
    required int nextId,
    required Function Invalidate,
    required String approve
  }) async {

    loading = true;
    Invalidate();

    String target_type = "users_id";
    if(target=="Moims") {
      target_type = "moims_id";
    }

    String lon = longitude.toString();
    String lat = latitude.toString();
    if(isListMode){
      lon = "";
      lat = "";
    }
    await Remote.getMemberInfo(
        params: {
          "command": "LIST",
          "isAll":isAll,
          "list_attr":target,
          target_type: target_id,
          "users_id":usersId,
          "approve": approve,
          "rec_start":nextId.toString(),
          "rec_count":fetch_size.toString(),
          "lon":lon,
          "lat":lat,
          "distance":limit_dist,
        },
        onResponse: (List<MemberInfo> list) {
          //print("Remote.getMemberInfo():page="+page.toString());
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

          loading = false;
          Future.microtask(() {
            Invalidate();
          });

        });
  }

}