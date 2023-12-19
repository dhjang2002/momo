// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Models/contactPerson.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Controller/ColtrollerStatusChange.dart';
import 'package:momo/Layouts/TileCard.dart';
import 'package:momo/Utils/utils.dart';
import 'package:momo/contacts/contactCache.dart';

class ContactList extends StatefulWidget {
  final String usersId;     // 사용자
  final String category;    // "all", "business", "friend", "event"
  //final String orderby;     // "stamp", "name", "importance",

  final Function(ContactPerson info) onTap;
  Widget? tailing;
  Function(ContactPerson info)? onDetail;
  ControllerStatusChange? controller;
  
  ContactList({Key? key,
    required this.usersId,
    required this.category,
    required this.onTap,
    this.tailing,
    this.onDetail,
    this.controller,
  }) : super(key: key);

  @override
  _ContactListState createState() => _ContactListState();
}

//class _ContactListState extends State<ContactList> {
class _ContactListState extends State<ContactList> with AutomaticKeepAliveClientMixin {

  final ContactCache _contactCache = ContactCache();
  bool _ready = false;
  String orderby = "name";


  @override
  void initState() {

    Future.microtask(() async {
      _contactCache.setTarget(
          category: widget.category,
          orderby:  orderby,
          usersId: widget.usersId);
      _contactCache.clear(false);
      _contactCache.fetchItems(nextId: 0, Invalidate: (){
        setState(() {
          _ready = true;
        });
      });
    });

    if (widget.controller != null) {
      widget.controller!.addListener(() async {

        print("ContactList::addListener(): action=${widget.controller!.action}");

        switch(widget.controller!.action){
          case ControllerStatusChange.aFrontView:
            break;

          case ControllerStatusChange.aBackView:
            break;

          case ControllerStatusChange.aInvalidate:{
            _contactCache.setTarget(
                usersId: widget.usersId,
            category: widget.category,
            orderby: orderby);
            _contactCache.clear(false);
            _contactCache.fetchItems(nextId: 0, Invalidate: () {
              setState(() {});
            });
            break;
          }
        }
      });
    }
    super.initState();
  }
  
  @override
  bool get wantKeepAlive => true;

  Widget _renderListView() {
    if (!_ready) {
      return const Center(child: CircularProgressIndicator());
    }

    final cache   = _contactCache.cache;
    final loading = _contactCache.loading;
    final hasMore = _contactCache.hasMore;

    // 로딩중이며 캐시에 데이터 없을때
    if(loading && cache.isEmpty){
      return const Center(child:CircularProgressIndicator());
    }

    // 로딩중이 아닌데, 캐시에 아무것도 없음.
    if(!loading && cache.isEmpty){
      return const Center(child:Text("데이터가 없습니다."));
    }

    print("ContactList::_renderListView()");

    return ListView.builder(
      //scrollDirection: Axis.vertical,
      //  shrinkWrap: true,
      //  physics: const ClampingScrollPhysics(),
      //  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        itemCount: cache.length+1,
        itemBuilder: (BuildContext context, int index)
        {
          if(index<cache.length){
            return ItemCard(cache[index]);
          }

          if(!loading && hasMore) {
            Future.microtask(() {
              _contactCache.fetchItems(
                  nextId: index,
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
    String listTitle = "모든회원 (${_contactCache.cache.length})";
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


  Widget ItemCard(ContactPerson info) {
    String display = "";
    display = info.name.toString();

    String phone = "";
    phone = info.phone.toString();

    String company = info.company.toString();
    String part = info.part.toString();
    String duty = info.duty.toString();

    //return Container();
    String area = "";

    String url = info.thumnails.toString();
    if(url.isNotEmpty) {
      url = URL_HOME + url;
     }
    //
    // String duty = info.duty.toString();
    // if(duty.length>2) {
    //   duty = duty.substring(2);
    //   if(duty=="회원") duty="";
    // }
    //
    // String company = info.company.toString();
    // if (info.importance!.isNotEmpty) {
    // }
    //
    // String area = ""; //info.member_area.toString() + " ($distance)";



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
                    child: simpleBlurImageWithName(info.name.toString(), 28, url, 1.0)
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
                Text(phone,
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

  void _onTab(ContactPerson info) {
    widget.onTap(info);
  }

  void _onDetail(ContactPerson info) {
    if(widget.onDetail != null) {
      widget.onDetail!(info);
    }
  }

}
