// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:momo/Models/SalesSumarry.dart';
import 'package:momo/Remote/Remote.dart';

class SalesCache {
  SalesSumarry  head = SalesSumarry();
  List<dynamic> cache = [];

  int  page_items = 25;     //
  bool loading = false;     // 로디중....
  bool hasMore = true;      // 마지막 데이터 체크
  bool isItems = true;      // Item / Summary
  late String moims_id;
  late String comon_id;
  String range = "ALL";
  String kind  = "LIST_ALL";

  void setTarget({required String comon_id, required String moims_id}) {
    this.comon_id  = comon_id;
    this.moims_id  = moims_id;
    loading = false;
    hasMore = true;
  }

  // const List<String> sales_kind  = ["LIST_ALL", "LIST_SALES", "LIST_BUYS", "MY_SALES", "MY_BUYS"];
  void changeRange({required String range}) {
    cache.clear();
    this.range   = range;
    loading = false;
    hasMore = true;
  }

  void changeKind({required String kind, required String comon_id}) {
    cache.clear();
    this.kind = kind;
    this.comon_id  = comon_id;
    loading   = false;
    hasMore   = true;
    if(kind=="LIST_ALL" || kind=="MY_SALES" || kind=="MY_BUYS"){
      isItems = true;
    }
    else{
      isItems = false;
    }
  }

  void clear() {
    cache.clear();
  }

  Future <void> fetchItems({
    required int nextId,
    required Function() onNotify
  }) async {

    loading = true;
    onNotify();

    await Remote.getSalesItems(
        isItems: isItems,
        params: {
          "command": "LIST",
          "range":range,
          "kind":kind,
          "moims_id": moims_id,
          "comon_id": comon_id,
          "rec_start":nextId.toString(),
          "rec_count":page_items.toString(),
        },
        onResponse: (List<dynamic> list, bool hasHead, SalesSumarry head) {
          if(hasHead) {
            this.head = head;
          }

          final items = list;
          if(list.length<page_items) {
            hasMore = false;
          }

          if (items.isNotEmpty) {
            cache = [
              ...cache,
              ...items,
            ];
          }

          //print("\nlist.length=${list.length}");
          //print("\cache.length=${cache.length}");
          loading = false;
          onNotify();
        });
  }
}