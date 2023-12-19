// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Members/MembersCache.dart';
import 'package:momo/Provider/GpsProvider.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Controller/ColtrollerStatusChange.dart';
import 'package:momo/Layouts/TileCard.dart';
import 'package:momo/Models/MemberInfo.dart';
import 'package:momo/Utils/utils.dart';
import 'package:provider/provider.dart';

class MemberListPage extends StatefulWidget {
  final bool isNickFirst;
  final bool isListMode;
  final String target;    // "Owner", "Member", "Moims"
  final String targetId;
  final Function(MemberInfo memberInfo) onTap;
  Widget? tailing;
  Function(MemberInfo moim)? onDetail;
  ControllerStatusChange? controller;
  
  MemberListPage({Key? key,
    required this.isNickFirst,
    required this.target,
    required this.targetId,
    required this.onTap,
    this.tailing,
    this.onDetail,
    this.controller,
    required this.isListMode,
  }) : super(key: key);

  @override
  _MemberListPageState createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> with AutomaticKeepAliveClientMixin {

  late GpsProvider _gpsProvider;
  final MembersCache _membersCache = MembersCache();
  bool _ready = false;

  late LoginInfo _loginInfo;
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      _gpsProvider = Provider.of<GpsProvider>(context, listen: false);
      _loginInfo   = Provider.of<LoginInfo>(context, listen:false);
      _membersCache.setTarget(
          targetTag: widget.target.toString(),
          targetId: widget.targetId,
          usersId: _loginInfo.users_id!);
      _membersCache.clear(false);
      await _gpsProvider.updateGeolocator(false);
      _membersCache.setLocation(
          latitude: _gpsProvider.latitude().toString(),
          longitude: _gpsProvider.longitude().toString(),
          limit_dist: "800000");
      _membersCache.fetchItems(isListMode:widget.isListMode, nextId: 0, approve:"Y", Invalidate: (){
        setState(() {
          _ready = true;
        });
      });
    });

    if (widget.controller != null) {
      widget.controller!.addListener(() async {

        print("MemberListPage::addListener(): action=${widget.controller!.action}");

        switch(widget.controller!.action){
          case ControllerStatusChange.aFrontView:
            break;

          case ControllerStatusChange.aBackView:
            break;

          case ControllerStatusChange.aInvalidate:{
            print("widget.isListMode=${widget.isListMode}");

            _membersCache.setTarget(
                targetTag: widget.target.toString(),
                targetId: widget.targetId,usersId:
                _loginInfo.users_id!);
            _membersCache.clear(false);
            await _gpsProvider.updateGeolocator(false);
            _membersCache.setLocation(
                latitude: _gpsProvider.latitude().toString(),
                longitude: _gpsProvider.longitude().toString(),
                limit_dist: "800000");
            _membersCache.fetchItems(isListMode:widget.isListMode, nextId: 0, approve:"Y", Invalidate: () {
              setState(() {});
            });
            break;
          }
        }
      });
    }
  }
  
  @override
  bool get wantKeepAlive => true;

  Widget _renderListView() {
    final _gpsProvider = Provider.of<GpsProvider>(context, listen: true);

    if (!_ready || (!widget.isListMode && _gpsProvider.bWait)) {
      return const Center(child: CircularProgressIndicator());
    }

    final cache   = _membersCache.cache;
    final loading = _membersCache.loading;
    final hasMore = _membersCache.hasMore;

    // 로딩중이며 캐시에 데이터 없을때
    if(loading && cache.isEmpty){
      return const Center(child:CircularProgressIndicator());
    }

    // 로딩중이 아닌데, 캐시에 아무것도 없음.
    if(!loading && cache.isEmpty){
      return const Center(child:Text("데이터가 없습니다."));
    }

    print("MemberListPage::_renderListView()");

    return ListView.builder(
      //scrollDirection: Axis.vertical,
      //  shrinkWrap: true,
      //  physics: const ClampingScrollPhysics(),
      //  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        itemCount: cache.length+1,
        itemBuilder: (BuildContext context, int index)
        {
          if(index<cache.length){
            return ItemCard(widget.isNickFirst, cache[index]);
          }

          if(!loading && hasMore) {
            Future.microtask(() {
              _membersCache.fetchItems(
                  isListMode:widget.isListMode,
                  nextId: index,
                  approve:"Y",
                  Invalidate: (){
                    setState(() {});
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
      color:Colors.white,
        child: Column(
          children: [
            _buildListCount(),
            Expanded(child: _renderListView()),
          ],
        )
    );
  }

  Widget _buildListCount() {
    String listTitle = (widget.isListMode) ? "모든회원 (${_membersCache.cache.length})" : "주변회원 (${_membersCache.cache.length})";
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


  Widget ItemCard(bool isNickFirst, MemberInfo info) {

    String display = "";
    if(isNickFirst) {
      display = info.mb_nick.toString();
      if(display.isEmpty) {
        display = info.mb_name.toString();
      }
    }
    else {
      display = info.mb_name.toString();
    }
    String url = "";
    if(info.mb_thumnail!.length>3) {
      url = URL_HOME + info.mb_thumnail.toString();
    }

    String duty = info.member_duty.toString();
    if(duty.length>2) {
      duty = duty.substring(2);
      if(duty=="회원") duty="";
    }

    String grade = info.member_grade.toString();
    if(grade=="일반") {
      grade = "";
    }

    String distance = "";
    if (info.mb_distance!.isNotEmpty) {
      double dist = double.parse(info.mb_distance!) / 1000;
      distance = "${dist.toStringAsFixed(2)} km";
    }

    String area = ""; //info.member_area.toString() + " ($distance)";
    if(!widget.isListMode) {
      area = " "+distance;
    }

    return Column(
        children: [
          TileCard(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(5,5,10,5),
            key: GlobalKey(),
            leading: SizedBox(
                height: 50, width: 50,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(100.0),
                    child: simpleBlurImageWithName(info.mb_name.toString(), 28, url, 1.0)
                )),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  display,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0),
                ),
                const SizedBox(width: 5),
                Text(duty,
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),),
                const Spacer(),
                Text(grade,
                  style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                      fontSize: 12.0),),
              ],
            ),
            subtitle: (area.isNotEmpty)?Text(area,
              style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0),) : null,
            tailing: widget.tailing,
            onTab:() => _onTab(info),
            onTrailing: ()=>_onDetail(info),
            
            //trailing: widget.tailing,
            //onTab:() => widget.onTap(m_MemberList.elementAt(index)),
            //onTrailing: ()=> widget.onDetail(m_MemberList.elementAt(index)),
          ),
          const Divider(height: 1.0,),
        ],
    );
  }

  void _onTab(MemberInfo info) {
    widget.onTap(info);
  }

  void _onDetail(MemberInfo info) {
    if(widget.onDetail != null) {
      widget.onDetail!(info);
    }
  }

}
