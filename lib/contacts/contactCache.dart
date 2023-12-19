// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:momo/Models/contactPerson.dart';
import 'package:momo/Remote/Remote.dart';

class ContactCache {
  List<ContactPerson> cache = [];

  final int fetch_size = 25;
  // 로디중....
  bool loading = false;

  // 마지막 데이터 체크
  bool hasMore = true;

  late String usersId;
  String category = "all";
  String orderby  = "";

  void clear(bool notify) {
    cache.clear();
  }

  void setTarget({
    required String category,
    required String orderby,
    required String usersId
  }) {
    this.usersId  = usersId;
    this.category = category;
    this.orderby  = orderby;
  }

  Future <void> setOrder({
    required String orderby,
    required Function Invalidate,
  }) async {
    this.orderby = orderby;
    cache.clear();
    fetchItems(nextId: 0, Invalidate: (){
      Invalidate();
    });
  }

  Future <void> fetchItems({
    required int nextId,
    required Function Invalidate,
  }) async {

    loading = true;
    Invalidate();

    await Remote.getContactPerson(
        params: {
          "command": "LIST",
          "owner":usersId,
          "category":category,  //
          "orderby":orderby,
          "rec_start":nextId.toString(),
          "rec_count":fetch_size.toString(),
        },
        onResponse: (List<ContactPerson> list) {
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