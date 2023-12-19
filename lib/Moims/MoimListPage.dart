// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Moims/MoimsCache.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Controller/ColtrollerStatusChange.dart';
import 'package:momo/Layouts/TileCard.dart';
import 'package:momo/Models/Moims.dart';
import 'package:momo/Utils/utils.dart';

class MoimListPage extends StatefulWidget {
  final String target;    // "Owner", "Member", "Joinable"
  final String userId;
  final Function(Moims moim) onTap;
  Widget? tailing;
  Function(Moims moim)? onDetail;
  ControllerStatusChange? controller;
  MoimListPage({Key? key,
    required this.target,
    required this.userId,
    required this.onTap,
    this.tailing,
    this.onDetail,
    this.controller,
  }) : super(key: key);

  @override
  _MoimListPageState createState() => _MoimListPageState();
}

class _MoimListPageState extends State<MoimListPage> with AutomaticKeepAliveClientMixin {

  final MoimsCache _moimsCache = MoimsCache();
  bool _bReady = false;
  late String _usersId;

  @override
  void initState() {
    super.initState();

    _usersId = widget.userId;

    Future.microtask(() {
      _moimsCache.setTarget(targetTag: widget.target.toString(), targetId: _usersId);
      _moimsCache.clear(false);
      _moimsCache.fetchItems(nextId: 0, Invalidate: (){
        setState(() {
          _bReady = true;
        });
      });
    });

    if (widget.controller != null) {
      widget.controller!.addListener(() {

        print("MoimListPage::addListener(): action=${widget.controller!.action}");

        switch(widget.controller!.action){
          case ControllerStatusChange.aFrontView:
            break;

          case ControllerStatusChange.aBackView:
            break;

          case ControllerStatusChange.aChange:
            {
              if (_usersId != widget.controller!.users_id) {
                _usersId = widget.controller!.users_id;
                _moimsCache.setTarget(
                    targetTag: widget.target.toString(), targetId: _usersId);
                _moimsCache.clear(false);
                _moimsCache.fetchItems(nextId: 0, Invalidate: () {
                  setState(() {});
                });
              }
              break;
            }

          case ControllerStatusChange.aInvalidate:{
            _moimsCache.setTarget(targetTag: widget.target.toString(), targetId: _usersId);
            _moimsCache.clear(false);
            _moimsCache.fetchItems(nextId: 0, Invalidate: () {
              setState(() {});
            });
            break;
          }

          case ControllerStatusChange.aSearch:
              break;
        }
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildHome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildListCount(),
        Expanded(child: _renderListView())
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: _buildHome());
  }

  Widget _buildListCount() {
    String listTitle = "공개모임 (${_moimsCache.cache.length})";
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15,15,0,10),
        //color: (widget.isListMode) ? Colors.orangeAccent : Colors.green,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(listTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
          ],
        ));
  }

  Widget _renderListView() {
    if(!_bReady) {
      return const Center(child: CircularProgressIndicator());
    }

    final cache   = _moimsCache.cache;
    final loading = _moimsCache.loading;
    final hasMore = _moimsCache.hasMore;

    // 로딩중이며 캐시에 데이터 없을때
    if(loading && cache.isEmpty){
      return const Center(child:CircularProgressIndicator());
    }

    // 로딩중이 아닌데, 캐시에 아무것도 없음.
    if(!loading && cache.isEmpty){
      return const Center(child:Text("데이터가 없습니다."));
    }

    print("_renderListView():provider.cache.length=${cache.length}");
    return ListView.builder(
        itemCount: cache.length+1,
        itemBuilder: (BuildContext context, int index)
        {
          if(index<cache.length){
            return _itemCard(cache[index]);
          }

          if(!loading && hasMore) {
            Future.microtask(() {
              _moimsCache.fetchItems(nextId: index, Invalidate: (){
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

  Widget _itemCard(Moims info) {
    String url = "";
    List<String> thumnails = info.moim_thumnails.toString().split(";");
    if(thumnails.isNotEmpty && thumnails.elementAt(0).isNotEmpty) {
      url = URL_HOME + thumnails.elementAt(0);
    }

    return Column(
      children: [
        TileCard(
          key: GlobalKey(),
          color: Colors.white,
          leading: SizedBox(
              height: 50, width: 50,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: simpleBlurImageWithName(info.moim_name.toString(), 18.0, url, 1.0)
              )
          ),
          title: Text(
            info.moim_name.toString(),
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18.0),
          ),
          subtitle: Text(
            info.moim_title.toString(),
            style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
                fontSize: 14.0),
          ),

          tailing: widget.tailing,
          onTab:() => _onTab(info),
          onTrailing: ()=>_onDetail(info),
        ),
        const Divider(height: 1.0,),
      ],
    );
  }
  void _onTab(Moims info) {
    widget.onTap(info);
  }
  void _onDetail(Moims info) {
    if(widget.onDetail != null) {
      widget.onDetail!(info);
    }
  }
}
