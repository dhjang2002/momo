
import 'package:momo/Models/SearchItem.dart';
import 'package:momo/Remote/Remote.dart';

class SearchCache {
  List<SearchItem> cache = [];  // cache
  bool loading = false;         // 로디중....
  bool hasMore = true;          // 마지막 데이터 체크
  late String target;
  late String targetId;
  late String usersId;
  
  void clear() {
    cache.clear();
  }
  
  void setTarget({
    required String usersId,
    required String target,
    required String targetId
  }) {
    this.usersId = usersId;
    this.target = target;
    this.targetId  = targetId;
  }

  Future <void> fetchItems({
    required int nextId,
    required int count,
    required String keyValue,
    required Function onNotify
  }) async {
    loading = true;
    onNotify();
    Remote.reqQuery(
        params: {
          "command": "Query",
          "target": target.toString(),
          "target_id": targetId,
          "owner_id": usersId,
          "key":keyValue,
          "rec_start": nextId.toString(),
          "rec_count": count.toString(),
        },

        onResponse: (List<SearchItem> list) {
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
          onNotify();
        });
  }

}