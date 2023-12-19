
import 'package:momo/Models/ShopEvent.dart';
import 'package:momo/Remote/Remote.dart';

class EventCache {
  bool loading = false;       // 로디중....
  bool hasMore = true;        // 마지막 데이터 체크
  List<ShopEvent> cache = []; // cache

  void clear(bool notify) {
    cache.clear();
  }

  late String targetTag;
  late String targetId;
  void setTarget({
    required String targetTag,
    required String targetId
  }) {
    this.targetTag = targetTag;
    this.targetId  = targetId;
  }

  Future <void> fetchItems({
    required int nextId,
    required int count,
    required Function invalidate
  }) async {
    loading = true;
    invalidate();
    Remote.getEvents(
        params: {
          "command": "LIST",
          "list_attr": targetTag.toString(),
          "target_id": targetId,
          "rec_start": nextId.toString(),
          "rec_count": count.toString(),
        },

        onResponse: (List<ShopEvent> list) {
          final items = list;
          if (list.isNotEmpty) {
            cache = [
              ...cache,
              ...items,
            ];
          }

          if(list.length<count) {
            hasMore = false;
          }

          loading = false;
          invalidate();
        });
  }

}