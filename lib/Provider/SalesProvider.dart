import 'package:flutter/material.dart';
import 'package:momo/Models/SalesSumarry.dart';
import 'package:momo/Remote/Remote.dart';

class SalesProvider with ChangeNotifier {
  SalesSumarry head = SalesSumarry();
  List<dynamic> cache = [];

  final int fetch_size = 5;
  // 로디중....
  bool loading = false;

  // 마지막 데이터 체크
  bool hasMore = true;

  late String moims_id;
  late String comon_id;
  String range = "ALL";
  String kind  = "LIST_ALL";

  bool isItems = true;

  void setTarget({required String comon_id, required String moims_id}) {
    this.comon_id  = comon_id;
    this.moims_id  = moims_id;
    loading = false;
    hasMore = true;
  }

  void changeRange({required String range}) {
    cache.clear();
    this.range   = range;
    loading = false;
    hasMore = true;
    notifyListeners();
  }

  // const List<String> sales_kind  = ["LIST_ALL", "LIST_SALES", "LIST_BUYS", "MY_SALES", "MY_BUYS"];
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
    notifyListeners();
  }

  void clear(bool notify) {
    cache.clear();
    loading   = false;
    hasMore   = true;
    if(notify) {
      notifyListeners();
    }
  }

  Future <void> fetchItems({required int nextId}) async {
    loading = true;
    notifyListeners();

    await Remote.getSalesItems(
        isItems: isItems,
        params: {
          "command": "LIST",
          "range":range,
          "kind":kind,
          "moims_id": moims_id,
          "comon_id": comon_id,
          "rec_start":nextId.toString(),
          "rec_count":fetch_size.toString(),
        },
        onResponse: (List<dynamic> list, bool hasHead, SalesSumarry head) {
          if(hasHead) {
            this.head = head;
          }

          final items = list;
          if(list.length<fetch_size) {
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
          Future.microtask(() {
            notifyListeners();
          });
        });
  }

}