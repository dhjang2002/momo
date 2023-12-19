// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:momo/Constants/Constants.dart';
import 'package:momo/Members/MemberModeManage.dart';
import 'package:momo/Members/MembersCache.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Layouts/TileCard.dart';
import 'package:momo/Models/MemberInfo.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/DateForm.dart';
import 'package:momo/Utils/SearchHome.dart';
import 'package:momo/Utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class MemberApprove extends StatefulWidget {
  final String title;
  final String moims_id;
  final String moims_name;

  const MemberApprove({Key? key,
    required this.title,
    required this.moims_id,
    required this.moims_name,
  }) : super(key: key);

  @override
  _MemberApproveState createState() => _MemberApproveState();
}

class _MemberApproveState extends State<MemberApprove> {
  final MembersCache _membersCache = MembersCache();
  bool _bReady = false;
  bool _bDirty = false;

  final List<String> _listMenuApproved = ['전체', '승인', '미승인',];

  String _currApprove = "";
  String _selectedApprove = "전체";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      LoginInfo _loginInfo   = Provider.of<LoginInfo>(context, listen:false);
      _membersCache.setTarget(
          usersId: _loginInfo.users_id!,
          targetTag: "Moims",
          targetId: widget.moims_id);
      _membersCache.isAll = "false";
      _membersCache.clear(false);
      _membersCache.fetchItems(
          isListMode:true,
          nextId: 0,
          approve: _currApprove,
          Invalidate: () {
            setState(() {
              _bReady = true;
            });
          });
    });
  }

  Widget _renderListView() {
    if (!_bReady) {
      return const Center(child: CircularProgressIndicator());
    }

    final cache   = _membersCache.cache;
    final loading = _membersCache.loading;
    final hasMore = _membersCache.hasMore;

    // 로딩중이며 캐시에 데이터 없을때
    if (loading && cache.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 로딩중이 아닌데, 캐시에 아무것도 없음.
    if (!loading && cache.isEmpty) {
      return const Center(child: Text("데이터가 없습니다."));
    }

    //print("_renderListView():provider.cache.length=${cache.length}");
    return ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        itemCount: cache.length + 1,
        itemBuilder: (BuildContext context, int index) {
          //print("index=$index");
          if (index < cache.length) {
            return ItemCard(index, cache[index]);
          }

          if (!loading && hasMore) {
            Future.microtask(() {
              _membersCache.fetchItems(
                  isListMode:true,
                  nextId: index,
                  approve: _currApprove,
                  Invalidate: () {
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
    return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              widget.title,
            ),
            leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppBar_Icon,
                ),
                onPressed: () {
                  Navigator.pop(context, _bDirty);
                }),
            actions: [
              Visibility(
                visible: true, //(!bSearch) ? true : false,
                child: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _onSearch();
                    }),
              ),
            ],
          ),
          body: WillPopScope(
            onWillPop: () {
              return onWillPop();
            },
            child: _buildBody()),
    );
  }

  Widget _selectMembers() {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        isExpanded: true,
        value: _selectedApprove,
        items: _listMenuApproved
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        icon: const Icon(
          Icons.arrow_drop_down,
        ),
        iconSize: 20,
        iconEnabledColor: Colors.black,
        iconDisabledColor: Colors.grey,
        buttonHeight: 30,
        buttonWidth: 130,
        buttonPadding: const EdgeInsets.only(left: 15, right: 15),
        buttonDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: Colors.white,
          ),
          color: Colors.white,
        ),
        buttonElevation: 0,
        itemHeight: 35,
        //itemWidth: 130,
        itemPadding: const EdgeInsets.only(left: 14, right: 14),
        dropdownMaxHeight: 500,
        dropdownPadding: null,
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
        ),
        dropdownElevation: 8,
        scrollbarRadius: const Radius.circular(40),
        scrollbarThickness: 6,
        scrollbarAlwaysShow: true,
        offset: const Offset(-20, 0),
        onChanged: (value) {
          _selectedApprove = value.toString();
          if (_selectedApprove == "전체") {
            _membersCache.isAll = "false";
            _currApprove = "";
          } else if (_selectedApprove == "승인") {
            _membersCache.isAll = "false";
            _currApprove = "Y";
          } else if (_selectedApprove == "미승인") {
            _membersCache.isAll = "false";
            _currApprove = "N";
          }
          _membersCache.clear(false);
          _membersCache.fetchItems(
              isListMode:true,
              nextId: 0,
              approve: _currApprove,
              Invalidate: () {
                setState(() {});
              });
        },
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategiry(),
        const Divider(height: 1,),
        Expanded(child: _renderListView(),)
      ],
    );
  }

  Widget _buildCategiry() {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _selectMembers(),
            const Spacer(),
            Container(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  _membersCache.cache.length.toString(),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                ))
          ],
        ));
  }

  Widget ItemCard(int index, final MemberInfo info) {
    String url = "";
    if (info.mb_thumnail!.length > 3) {
      url = URL_HOME + info.mb_thumnail.toString();
    }

    String name    = info.mb_name.toString();

    String duty = "회원";
    if(info.member_duty!.length>2) {
      duty = info.member_duty!.substring(2);
    }

    String approve = "";
    if(info.member_approve == "N") {
      approve = "승인요청";
    }

    String grade   = info.member_grade!;

    String subTitle = "요청일자: " + DateForm().parse(info.created_at.toString()).getVisitDay();

    return Column(
      children: [
        TileCard(
          key: GlobalKey(),
          color: Colors.white,
          leading: SizedBox(
              height: 50,
              width: 50,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(100.0),
                  child: simpleBlurImageWithName(
                      info.mb_name.toString(), 28, url, 1.0))),
          title: Row(
            children: [
              Text(name, maxLines: 1,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0),),
              const SizedBox(width: 5,),
              Text(approve, maxLines: 1,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0),),
            ],
          ),

          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: (info.member_approve == "Y"),
                child: Row(
                children: [
                  Text(duty, maxLines: 1, style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 14.0),),
                  const Text(" / ", maxLines: 1, style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 14.0),),
                  Text(grade, maxLines: 1, style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 14.0),),
                ],
              ),),

              Visibility(
                visible: (info.member_approve == "N"),
                child: Text(subTitle, maxLines: 1, style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 12.0),
                )),
            ]),

          onTab: () => _onTab(info),
          tailing: const Icon(
            Icons.navigate_next,
            size: 24.0,
          ),
          //onTrailing: ()=>_onDetail(info),
        ),
        const Divider(
          height: 12.0,
        ),
      ],
    );
  }

  Future <void> _onTab(MemberInfo info) async {
    var result = await Navigator.push(
      context,
      Transition(
          child: MemberManage(
            memberInfo: info, moim_name: widget.moims_name,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    if (result != null) {
      _bDirty = true;
      _membersCache.clear(false);
      _membersCache.fetchItems(
          isListMode:true,
          nextId: 0,
          approve: _currApprove,
          Invalidate: () {
            setState(() {});
          });
    }
  }

  Future<void> _onSearch() async {
    var memberId = await Navigator.push(
      context,
      Transition(
          child: SearchHome(
            target: "member",
            moimId: widget.moims_id,
          ),
          transitionEffect: TransitionEffect.BOTTOM_TO_TOP),
    );

    if (memberId != null) {
      Future.microtask(() {
        Remote.getMemberInfo(
            params: {"command": "INFO", "id": memberId},
            onResponse: (List<MemberInfo> list) {
              MemberInfo info = list.elementAt(0);
              _onTab(info);
            });
      });
    }
  }

  Future <bool> onWillPop() async {
    Navigator.pop(context, _bDirty);
    return true; // true will exit the app
  }
}
