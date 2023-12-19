// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Constants/Constants.dart';
import 'package:momo/Controller/ColtrollerStatusChange.dart';
import 'package:momo/Models/Moims.dart';
import 'package:momo/Moims/MoimEdit.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';
import 'MoimListPage.dart';

class MyMoimTab extends StatefulWidget {
  final String users_id;
  const MyMoimTab({Key? key, required this.users_id}) : super(key: key);

  @override
  _MyMoimTabState createState() => _MyMoimTabState();
}

class _MyMoimTabState extends State<MyMoimTab>
    with SingleTickerProviderStateMixin {
  final int TAB_COUNT = 2;
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  bool m_bDirty = false;

  int _currTabIndex = 0;
  late TabController _tabController;

  late final ControllerStatusChange _statusChange1;
  late final ControllerStatusChange _statusChange2;

  String title = "모임관리";
  bool mLoaded = false;
  bool bReady = false;

  late LoginInfo loginInfo;
  @override
  void initState() {
    super.initState();
    loginInfo = Provider.of<LoginInfo>(context, listen:false);
    _statusChange1 = ControllerStatusChange();
    _statusChange2 = ControllerStatusChange();
    _tabController = TabController(length: TAB_COUNT, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currTabIndex = _tabController.index;
        _tabController.animateTo(_currTabIndex);
      });
      print("Selected Index: " + _tabController.index.toString());
    });

    setState(() {
      bReady = true;
      print("Init Selected Index: " + _tabController.index.toString());
      _tabController.animateTo(_currTabIndex);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _statusChange1.dispose();
    _statusChange2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _onBackPressed(context),
        child: DefaultTabController(
            initialIndex: 0,
            length: TAB_COUNT,
            child: Scaffold(
              key: _key,
              backgroundColor: Colors.white,
              body: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      title: Text(
                        title,
                        style: const TextStyle(color: Colors.black),
                      ),
                      leading: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: AppBar_Icon,
                          ),
                          onPressed: () {
                            Navigator.pop(context, m_bDirty);
                          }),
                      centerTitle: true,
                      backgroundColor: Colors.white,
                      elevation: 1.0,

                      pinned: true,
                      floating: true,
                      //snap: false,
                      //expandedHeight: 80,
                      //collapsedHeight: 60,
                      automaticallyImplyLeading: true,
                      actions: [
                        Visibility(
                          visible: false, //(!bSearch) ? true : false,
                          child: IconButton(
                              icon: const Icon(Icons.approval),
                              onPressed: () {}),
                        ),
                        Visibility(
                          visible: false,
                          child: IconButton(
                              icon: const Icon(
                                  Icons.more_vert), // dehaze_rounded),
                              onPressed: () {}),
                        ),
                      ],
                      bottom: TabBar(
                        //indicator: BoxDecoration(border: Border(right: BorderSide(color: Colors.orange))),
                        unselectedLabelColor: Colors.black,
                        labelColor: Colors.green,
                        onTap: (int index) {
                          setState(() {
                            _currTabIndex = index;
                          });
                        },
                        controller: _tabController,
                        //isScrollable: true,
                        indicatorColor: Colors.green,
                        indicatorSize: TabBarIndicatorSize.tab,
                        //indicatorWeight: 3,

                        /*
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(0), // Creates border
                    color: Colors.green,
                    //image: DecorationImage(
                    //    image: AssetImage('assets/images/icon_bottom_home.png'),
                    //    fit: BoxFit.fitWidth)
                  ),
                  */
                        tabs: const <Tab>[
                          Tab(text: "내가 만든 모임"),
                          Tab(text: "활동중인 모임"),
                        ],
                      ),
                    ),
                  ];
                },
                body: BuildTabHome(),
              ),
            )));
  }

  Widget BuildTabHome() {
    if (bReady) {
      return TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          MoimListPage(
            controller: _statusChange1,
            userId: widget.users_id,
            target: 'Owner',
            onTap: (Moims moim) {
            },
            tailing: Container(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              alignment: Alignment.center,
              child: const Text(
                "정보수정",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.normal),
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
                boxShadow: [
                  const BoxShadow(
                    color: Colors.grey,
                    offset: const Offset(2.0, 2.0),
                    blurRadius: 5.0,
                    spreadRadius: 1.0,
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-2.0, -2.0),
                    blurRadius: 5.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
            ),
            onDetail: (Moims moim) {
              _modifyMoim(moim.id.toString());
            }
          ),
          MoimListPage(
            controller: _statusChange2,
            userId: widget.users_id,
            target: 'Member',
            tailing: Container(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              alignment: Alignment.center,
              child: const Text(
                "나가기",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.normal),
              ),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
                boxShadow: [
                  const BoxShadow(
                    color: Colors.grey,
                    offset: const Offset(2.0, 2.0),
                    blurRadius: 5.0,
                    spreadRadius: 1.0,
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-2.0, -2.0),
                    blurRadius: 5.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
            ),
            onTap: (Moims moim) {},
            onDetail: (Moims moim) {
              _disJoin(moim.id.toString());
            },
          ),
        ],
      );
    }
    return Container();
  }

  Future<void> _disJoin(String moim_id) async {
    showDialogPop(
        context: context,
        title: "확인",
        body: const Text(
          "모임의 활동을 중지하시겠습니까?",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        content: const Text(
          "모임의 모든 기록이 삭제됩니다.",
          style: const TextStyle(
              fontWeight: FontWeight.normal, fontSize: 13, color: Colors.grey),
        ),
        choiceCount: 2,
        yesText: "예",
        cancelText: "아니오",
        onResult: (bool isOK) async {
          if (isOK) {
            await Remote.reqMembers(
                params: {
                  "command": "DELETE",
                  "users_id": "${loginInfo.users_id}",
                  "moims_id": moim_id
                },
                onResponse: (bool result) {
                  if (result) {
                    _statusChange2.setUserId(widget.users_id);
                    m_bDirty = true;
                  }
                });
          }
        });
  }

  Future <void> _modifyMoim(String moim_id) async {
    var result = await Navigator.push(
      context,
      Transition(
          child: MoimEdit(moims_id: moim_id.toString()),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    if (result != null) {
      m_bDirty = true;
      _statusChange1.setUserId(widget.users_id);
    }
  }

  Future <bool> _onBackPressed(BuildContext context) {
    Navigator.pop(context, m_bDirty);
    return Future(() => false);
  }
}
