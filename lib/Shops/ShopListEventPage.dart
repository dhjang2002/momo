// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Models/ShopEvent.dart';
import 'package:momo/Provider/EventProvider.dart';
import 'package:momo/Controller/ColtrollerStatusChange.dart';
import 'package:momo/Layouts/TileCard.dart';
import 'package:momo/Provider/ShopsProvider.dart';
import 'package:momo/Shops/EventCache.dart';
import 'package:provider/provider.dart';

class ShopListEventPage extends StatefulWidget {
  final String target;    // "Owner", "Shop"
  final String targetId;
  Widget? tailing;
  final Function(ShopEvent moim) onTap;
  Function(ShopEvent moim)? onDetail;
  ControllerStatusChange? controller;
  ShopListEventPage({Key? key,
    required this.target,
    required this.targetId,
    required this.onTap,
    this.tailing,
    this.onDetail,
    this.controller,
  }) : super(key: key);

  @override
  _ShopListEventPageState createState() => _ShopListEventPageState();
}

class _ShopListEventPageState extends State<ShopListEventPage> with AutomaticKeepAliveClientMixin {
  bool ready = false;

  EventCache _eventCache = EventCache();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      _eventCache.setTarget(targetTag: widget.target.toString(), targetId: widget.targetId);
      _eventCache.fetchItems(nextId: 0, count: 25, invalidate: (){
        setState(() {
          ready = true;
        });
      });
    });
    if (widget.controller != null) {
      widget.controller!.addListener(() {
        print("\n>>> ShopListEventPage::widget.controller!.addListener()");
        _eventCache.clear(false);
        _eventCache.fetchItems(nextId: 0, count: 25, invalidate: () {
          setState(() {});
        });
      });
    }
  }


  @override
  void dispose() {
    super.dispose();
  }

  Widget _renderListView() {
    if(!ready) {
      return const Center(child: CircularProgressIndicator());
    }

    final cache   = _eventCache.cache;
    final loading = _eventCache.loading;
    final hasMore = _eventCache.hasMore;

    // 로딩중이며 캐시에 데이터 없을때
    if(loading && cache.isEmpty){
      return const Center(child:CircularProgressIndicator());
    }

    // 로딩중이 아닌데, 캐시에 아무것도 없음.
    if(!loading && cache.isEmpty){
      return const Center(child:Text("데이터가 없습니다."));
    }

    return ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        itemCount: cache.length+1,
        itemBuilder: (BuildContext context, int index)
        {
          if(index<cache.length){
            return ItemCard(cache[index]);
          }

          if(!loading && hasMore) {
            Future.microtask(() {
              _eventCache.fetchItems(nextId: index, count: 25, invalidate: (){
                setState(() {
                });
              });
            });
          }

          if (!hasMore) {
            return const Center(child: Icon(Icons.arrow_drop_up));
          }

          return const Center(child: CircularProgressIndicator());
        });
  }

  @override
  Widget build(BuildContext context) {
      return Container(
        color: Colors.white,
        child: _renderListView(),);
  }

  Widget ItemCard(ShopEvent info) {
    String title = info.event_title!;
    String subTitle = info.event_content!;
    return Column(
        children: [
          TileCard(
            key: GlobalKey(),
            padding: EdgeInsets.all(10),
            title: Text(
              title,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0),
            ),
            subtitle: Text(
              subTitle,
              style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                  fontSize: 14.0),),
            tailing: widget.tailing,
            onTab:() => _onTab(info),
            onTrailing: () =>_onDetail(info),
          ),
          const Divider(height: 12.0,),
        ],
    );
  }

  void _onTab(ShopEvent info) {
    widget.onTap(info);
  }

  void _onDetail(ShopEvent info) {
    if(widget.onDetail != null) {
      widget.onDetail!(info);
    }
  }

}
