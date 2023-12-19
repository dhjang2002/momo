import 'package:flutter/material.dart';
import 'package:momo/Models/MemberInfo.dart';
import 'package:momo/Models/PageInfo.dart';
import 'package:momo/Remote/Remote.dart';

class MembersProvider with ChangeNotifier {
  List<MemberInfo> cache = [];

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
    //clear();
  }

  void clear(bool notify) {
    cache.clear();
    if(notify) {
      notifyListeners();
    }
  }
  /*
  Future<List<int>> _makeRequest({required int nextId,}) async {
    assert(nextId != null);
    await Future.delayed(Duration(seconds: 1));
    return List.generate(20, (index) => nextId+index);
  }
   */

  Future <void> fetchItems({required int nextId}) async {
    assert(nextId != null);

    loading = true;
    notifyListeners();

    String target_type = "users_id";
    if(target=="Moims") {
      target_type = "moims_id";
    }
    await Remote.getMemberInfo(
        params: {"command": "LIST",
          "list_attr":target,
          target_type: target_id,
          "rec_start":nextId.toString(),
          "rec_count":fetch_size.toString(),
        },
        onResponse: (List<MemberInfo> list) {
          //print("Remote.getMemberInfo():page="+page.toString());
          final items = list;
          if(list.length<fetch_size) {
            hasMore = false;
            if (list.length > 0) {
              this.cache = [
                ...this.cache,
                ...items,
              ];
            }
          }

          print("\nlist.length=${list.length}");
          print("\cache.length=${cache.length}");

          loading = false;
          Future.microtask(() {
            notifyListeners();
          });

        });
  }

}