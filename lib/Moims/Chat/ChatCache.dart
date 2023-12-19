// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:momo/Models/ChatItem.dart';
import 'package:momo/Remote/Remote.dart';

class ChatCache {
  List<ChatItem> cache = [];

  final int fetch_size = 10;
  // 로디중....
  bool loading = false;

  // 마지막 데이터 체크
  bool hasMore  = true;
  String prevId = "";
  String lastId = "";

  late String moimsId;
  void setTarget({required String moimsId,}) {
    this.moimsId = moimsId;
  }

  void clear() {
    cache.clear();
  }
  
  Future <void> getPrev({
    required int nextId,
    required Function Invalidate,
  }) async {

    if(loading) {
      return;
    }

    prevId = "0";
    if(cache.isNotEmpty) {
      prevId = cache.last.id!;
    }

    loading = true;
    Invalidate();
    
    await Remote.getChatInfo(
        params: {
          "command": "PREV",
          "moims_id":moimsId,
          "lastID":prevId,
          //"rec_start":nextId.toString(),
          "rec_count":fetch_size.toString(),
        },
        onResponse: (List<ChatItem> list) {
          if(list.length<fetch_size) {
            hasMore = false;
          }

          if (list.isNotEmpty) {
            cache = [
              ...cache,
              ...list,
            ];
          }

          loading = false;
          Future.microtask(() {
            Invalidate();
          });
        });
  }

  Future <void> getRecent({
    required Function Invalidate,
  }) async {

    if(loading) {
      return;
    }

    loading = true;
    Future.microtask(() {
      Invalidate();
    });

    lastId = "0";
    if(cache.isNotEmpty) {
      lastId = cache.first.id!;
    }

    await Remote.getChatInfo(
        params: {
          "command": "RECENT",
          "moims_id":moimsId,
          "lastID":lastId,
          "rec_count":fetch_size.toString(),
        },

        onResponse: (List<ChatItem> list) {
          if(list.isNotEmpty) {
            cache = [
              ...list,
              ...cache,
            ];
          }
          loading = false;
          Future.microtask(() {
            Invalidate();
          });
        });
  }

}