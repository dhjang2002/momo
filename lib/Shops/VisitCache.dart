
import 'package:momo/Models/ShopVisit.dart';
import 'package:momo/Remote/Remote.dart';

class VisitCache {
  List<ShopVisit> cache = [];

  final int fetchSize = 50;
  // 로디중....
  bool loading = false;

  // 마지막 데이터 체크
  bool hasMore = true;

  late String target;
  late String targetId;
  void setTarget({
    required String targetTag,
    required String targetId
  }) {
    cache.clear();
    target    = targetTag;
    this.targetId = targetId;
  }

  void clear(bool notify) {
    cache.clear();
  }

  Future <void> fetchItems({
    required int nextId,
    required Function() onNotify
  }) async {

    loading = true;
    onNotify();

    // "Owner", "Member", "Joinable"
    String listAttr = target.toString();
    Remote.getVisits(
        params: {
          "command": "LIST",
          "list_attr":listAttr,
          "target_id": targetId,
          "rec_start":nextId.toString(),
          "rec_count":fetchSize.toString(),
        },
        onResponse: (List<ShopVisit> list) {
          final items = list;
          if(list.length<fetchSize) {
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
            onNotify();
          });
        });
  }

}