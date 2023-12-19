// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Models/ShopVisit.dart';
import 'package:momo/Controller/ColtrollerStatusChange.dart';
import 'package:momo/Layouts/TileCard.dart';
import 'package:momo/Shops/VisitCache.dart';
import 'package:momo/Utils/DateForm.dart';

class ShopListVisitPage extends StatefulWidget {
  final String target;    // "Owner", "Shop"
  final String targetId;
  final Function(ShopVisit info) onTap;
  Widget? tailing;
  Function(ShopVisit info)? onDetail;
  ControllerStatusChange? controller;

  ShopListVisitPage({Key? key,
    required this.target,
    required this.targetId,
    required this.onTap,
    this.tailing,
    this.onDetail,
    this.controller,
  }) : super(key: key);

  @override
  _ShopListVisitPageState createState() => _ShopListVisitPageState();
}

class _ShopListVisitPageState extends State<ShopListVisitPage> with AutomaticKeepAliveClientMixin {

  bool _bReady = false;
  final VisitCache _visitCache = VisitCache();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      _visitCache.setTarget(targetTag: widget.target.toString(), targetId: widget.targetId);
      _visitCache.fetchItems(nextId: 0, onNotify: () {
        setState(() {
          _bReady = true;
        });
      });
    });

    if (widget.controller != null) {
      widget.controller!.addListener(() {
        _visitCache.setTarget(targetTag: widget.target.toString(), targetId: widget.targetId);
        _visitCache.fetchItems(nextId: 0, onNotify: () {
          setState(() {});
        });
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }

  Widget _renderListView() {

    if(!_bReady) {
      return const Center(child: CircularProgressIndicator());
    }

    final cache   = _visitCache.cache;
    final loading = _visitCache.loading;
    final hasMore = _visitCache.hasMore;

    // 로딩중이며 캐시에 데이터 없을때
    if(loading && cache.isEmpty){
      return const Center(child:CircularProgressIndicator());
    }

    // 로딩중이 아닌데, 캐시에 아무것도 없음.
    if(!loading && cache.isEmpty){
      return const Center(child:Text("데이터가 없습니다."));
    }

    print("ShopListVisitPage::_renderListView():provider.cache.length=${cache.length}");
    return ListView.builder(
      //scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        itemCount: cache.length+1,
        itemBuilder: (BuildContext context, int index)
        {
          //print("index=$index");

          if(index<cache.length){
            return ItemCard(cache[index]);
          }

          if(!loading && hasMore) {
            Future.microtask(() {
              _visitCache.fetchItems(nextId: index, onNotify: () {
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

  Widget ItemCard(ShopVisit info) {
    String name = info.user_name!;
    //String date = info.created_at!;
    String moims = info.moims!;
    String date = DateForm().parse(info.created_at!).getVisitDay();
    return Column(
        children: [
          TileCard(
            key: GlobalKey(),
            padding: EdgeInsets.fromLTRB(20,10,20, 5),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
                SizedBox(height: 5,),
                Text(moims,
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal, fontSize: 15.0),
                ),

                Container(
                    padding: EdgeInsets.only(top:3),
                    width: double.infinity,
                    //alignment: Alignment.centerRight,
                    child:Text(date,
                        style: const TextStyle(color: Colors.black,
                            fontWeight: FontWeight.normal, fontSize: 12.0))
                ),
              ],
            ),
            /*
            subtitle: Text(
              subTitle,
              style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                  fontSize: 14.0),),
            //tailing: widget.tailing,
            */
            onTab:() {},
            onTrailing: (){},
          ),
          const Divider(height: 12.0,),
        ],
    );
  }
}
