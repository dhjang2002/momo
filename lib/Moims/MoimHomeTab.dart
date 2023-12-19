// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:momo/Controller/ColtrollerStatusChange.dart';
import 'package:momo/Members/MemberApprove.dart';
import 'package:momo/Members/MemberHome.dart';
import 'package:momo/Models/MemberInfo.dart';
import 'package:momo/Models/MoimInfo.dart';
import 'package:momo/Models/Moims.dart';
import 'package:momo/Models/Shops.dart';
import 'package:momo/Members/MemberListPage.dart';
import 'package:momo/Moims/Chat/ChatMoimBoard.dart';
import 'package:momo/Moims/MoimInfoView.dart';
import 'package:momo/Moims/MoimEdit.dart';
import 'package:momo/Moims/SalesReport.dart';
import 'package:momo/Provider/GpsProvider.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Shops/MyShopList.dart';
import 'package:momo/Shops/ShopHome.dart';
import 'package:momo/Moims/MoimHomePage.dart';
import 'package:momo/Shops/ShopListPage.dart';
import 'package:momo/Utils/Launcher.dart';
import 'package:momo/Utils/SearchHome.dart';
import 'package:momo/Utils/utils.dart';
import 'package:momo/Webview/WebExplorer.dart';
import 'package:momo/contacts/contactMain.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class MoimHomeTab extends StatefulWidget {
  final String moims_id;
  const MoimHomeTab({
    Key? key,
    required this.moims_id,
  }) : super(key: key);

  @override
  _MoimHomeTabState createState() => _MoimHomeTabState();
}

class _MoimHomeTabState extends State<MoimHomeTab>
    with SingleTickerProviderStateMixin {

  final GlobalKey<ScaffoldState> _scaffoldStateKey = GlobalKey();
  final GlobalKey<FabCircularMenuState> _fabKey = GlobalKey();

  int _currTabIndex = 0;
  late Moims _moim;
  late TabController _tabController;
  late final List<ControllerStatusChange> _pageController;

  bool _bMemberInfo = false;


  bool _bDirty = false;
  bool _bSearch = false;
  bool _bReady = false;
  bool _bMoims = false;
  String _appTitle = "";

  late MemberInfo _memberInfo;
  late LoginInfo _loginInfo;

  MoimInfo _moimInfo = MoimInfo();
  bool _isListMode = true;

  bool _use_nick = false;

  @override
  void initState() {
    super.initState();
    _pageController = [
      ControllerStatusChange(),
      ControllerStatusChange(),
      ControllerStatusChange(),
      ControllerStatusChange(),
      ControllerStatusChange(),
    ];

    _tabController = TabController(vsync: this, length: 5);
    Future.microtask(() async {
      //_loginInfo = Provider.of<LoginInfo>(context, listen:false);
      //await _loginInfo.getPref();
      _loadMemberInfo();
      setState(() {
        _bReady = true;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _loginInfo = Provider.of<LoginInfo>(context, listen:true);
    if(!_bReady || !_bMemberInfo) {
      return const Center(child: const CircularProgressIndicator(),);
    }

    return Scaffold(
        key: _scaffoldStateKey,
        backgroundColor: Colors.grey[150],
        endDrawer: _buildEndDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0.0,
          title: Text(_appTitle, style: const TextStyle(color: Colors.black)),
          leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black, size: 26,
              ),
              onPressed: () {
                if(!canGoBack()) {
                  Navigator.pop(context, _bDirty);
                }
              }),
          actions: [
            Visibility(
              visible: ((_currTabIndex == 1 && !_isListMode) || _currTabIndex == 3 ), // 사업장 화면만 표시
              child: IconButton(
                  icon: Image.asset(
                    "assets/icon/icon_map_pin.png",
                    width: 32,
                    height: 32,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    _updateLocation();
                  }),
            ),
            Visibility(
              visible: _bSearch,
              child: IconButton(
                  icon: const Icon(Icons.search, size: 30,),
                  onPressed: () {
                    setState(() {
                      String target = "";
                      if(_currTabIndex==1) {
                        target = "member";
                      } else if(_currTabIndex==3) {
                        target = "shop";
                      }
                      _onSearch(target);
                    });
                  }),
            ),
            Visibility(
              visible: _bMemberInfo, // 홈화면에서만 표시
              child: IconButton(
                  icon: Image.asset("assets/icon/icon_menu.png", width: 32, height: 32, color: Colors.black),
                  onPressed: () {
                    _scaffoldStateKey.currentState!.openEndDrawer();
                  }),
            ),
          ],
        ),
        floatingActionButton: _renderFabCircularButton(),
        bottomNavigationBar: _buildBottomBar(),
        body: WillPopScope(
          onWillPop: onWillPop,
          child: _buildTabHome(),
        ));
  }

  Widget _renderFabCircularButton(){
    if(_currTabIndex == 1 ) {
      return FabCircularMenu(
        key: _fabKey,
        alignment: Alignment.bottomRight,
        ringColor: Colors.grey.withAlpha(15),
        ringDiameter: 300.0,
        ringWidth: 100.0,
        fabSize: 56.0,
        fabElevation: 8.0,
        fabIconBorder: const CircleBorder(),
        // Also can use specific color based on wether
        // the menu is open or not:
        // fabOpenColor: Colors.white
        // fabCloseColor: Colors.white
        // These properties take precedence over fabColor
        fabColor: (_isListMode) ? Colors.orangeAccent : Colors.green,
        fabOpenIcon: (_isListMode)
            ? Image.asset("assets/icon/member_ring_user_list.png", width: 44,
            height: 44,
            color: Colors.white)
            : Image.asset("assets/icon/member_ring_users.png", width: 44,
            height: 44,
            color: Colors.white),
        fabCloseIcon: const Icon(
            Icons.arrow_drop_down, size: 32, color: Colors.white),
        fabMargin: const EdgeInsets.all(15.0),
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOutCirc,
        onDisplayChange: (isOpen) {},
        children: <Widget>[
          RawMaterialButton(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
                "assets/icon/member_ring_user_list.png", width: 44,
                height: 44,
                color: Colors.white),
            fillColor: Colors.orangeAccent,
            onPressed: () async {
              _fabKey.currentState!.close();
              if (!_isListMode) {
                setState(() {
                  _isListMode = true;
                });
                await Future.delayed(const Duration(milliseconds: 50));
                _pageController[1].Invalidate();
              }
            },
          ),
          RawMaterialButton(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(8.0),
            fillColor: Colors.green,
            child: Image.asset("assets/icon/member_ring_users.png", width: 44,
                height: 44,
                color: Colors.white),
            onPressed: () async {
              _fabKey.currentState!.close();
              if (_isListMode) {
                setState(() {
                  _isListMode = false;
                });
                await Future.delayed(const Duration(milliseconds: 50));
                _pageController[1].Invalidate();
              }
            },
          ),
        ],
      );
    }
    if(_currTabIndex == 4 ) {
      return FabCircularMenu(
        key: _fabKey,
        alignment: Alignment.bottomRight,
        ringColor: Colors.grey.withAlpha(15),
        ringDiameter: 300.0,
        ringWidth: 100.0,
        fabSize: 56.0,
        fabElevation: 8.0,
        fabIconBorder: const CircleBorder(),
        // Also can use specific color based on wether
        // the menu is open or not:
        // fabOpenColor: Colors.white
        // fabCloseColor: Colors.white
        // These properties take precedence over fabColor
        fabColor: Colors.redAccent,
        fabOpenIcon: const Icon(
            Icons.add, size: 32, color: Colors.white),
        fabCloseIcon: const Icon(
            Icons.arrow_drop_down, size: 32, color: Colors.white),
        fabMargin: const EdgeInsets.all(15.0),
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOutCirc,
        onDisplayChange: (isOpen) {},
        children: <Widget>[
          RawMaterialButton(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
                "assets/icon/member_ring_user_list.png", width: 44,
                height: 44,
                color: Colors.white),
            fillColor: Colors.orangeAccent,
            onPressed: () async {
              _fabKey.currentState!.close();
              // if (!_isListMode) {
              //   setState(() {
              //     _isListMode = true;
              //   });
              //   await Future.delayed(const Duration(milliseconds: 50));
              //   _pageController[1].Invalidate();
              // }
            },
          ),
          RawMaterialButton(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(8.0),
            fillColor: Colors.green,
            child: Image.asset("assets/icon/member_ring_users.png", width: 44,
                height: 44,
                color: Colors.white),
            onPressed: () async {
              _fabKey.currentState!.close();
              // if (_isListMode) {
              //   setState(() {
              //     _isListMode = false;
              //   });
              //   await Future.delayed(const Duration(milliseconds: 50));
              //   _pageController[1].Invalidate();
              // }
            },
          ),
        ],
      );
    }
    return Container();
  }

  Widget _buildTabHome() {
    if(!_bReady || !_bMemberInfo) {
      return const Center(child: const CircularProgressIndicator(),);
    }

    return TabBarView(
      controller: _tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[

        MoimHomePage(
          controller: _pageController[0],
          users_id: _loginInfo.users_id!,
          isApproved: (_memberInfo.member_approve=="Y"),
          moims_id: widget.moims_id,
          onDisJoin:(bool flag) {
            if(flag) {
              _moimDisJoin(false);
            }
            else {
              Future.microtask(() {
                print("onDisJoin() ....");
                Navigator.pop(context, _bDirty);
              });
            }
          },
          onBoard:(Moims info) {
            _moimBoard();
          },
          onBoardDetail: (String wrId) {
            _onBoardDetail(wrId);
          },
          onLoad: (Moims info) {
            setState(() {
              _use_nick = (info.use_nick=="예") ? true : false;
              _moim = info;
              _bMoims = true;
              _appTitle = info.moim_name!;
            });
          },
          onInfo: (MoimInfo info) {
            setState((){
              _moimInfo = info;
            });
          },
          onInfoTab:(String tag, String extra){
            switch(tag) {
              case "members":
                setState(() {
                  _currTabIndex = 1;
                  _tabController.animateTo(_currTabIndex,
                      duration: const Duration(milliseconds: 1),
                      curve: Curves.ease);
                });
                break;

              case "shops":
                Navigator.push(context,
                  Transition(
                      child:ChatMoimBoard(
                          moimsId: _moim.id!,
                          isNickFirst: _use_nick,
                      ),
                      transitionEffect: TransitionEffect.BOTTOM_TO_TOP),
                );
                break;

              case "detail":
                Navigator.push(context,
                  Transition(
                      child: MoimInfoView(moims:_moim),
                      transitionEffect: TransitionEffect.BOTTOM_TO_TOP),
                );
                break;
            }
          },
        ),

        MemberListPage(
          isNickFirst: _use_nick,
          isListMode:  _isListMode,
          controller:  _pageController[1],
          targetId: widget.moims_id,
          target: 'Moims',
          onTap: (MemberInfo memberInfo) {
            _showMember(memberInfo.id.toString());
          },
        ),

        ShopListPage(
          controller: _pageController[2],
          isDistOrder:false,
          targetId: widget.moims_id,
          target: 'Moims',
          onTap: (Shops shop) {
            _showShop(shop.id.toString());
          },
        ),

        ShopListPage(
          controller: _pageController[3],
          isDistOrder:true,
          targetId: widget.moims_id,
          target: 'Moims',
          onTap: (Shops shop) {
            _showShop(shop.id.toString());
          },
        ),

        // 4: 인맥관리
        Container(),
        // MemberEditPage(
        //   controller: _pageController[4],
        //   isMember: true,
        //   moimsId: widget.moims_id,
        //   onUpdate: (bool result) {
        //     if (result) {
        //       _loadMemberInfo();
        //     }
        //   },
        // ),
      ],
    );
  }

  Widget _buildEndDrawer() {
    String moim_code = "";//"""모임코드:1234";
    if(_bMoims && _moim.moim_code!.isNotEmpty) {
      moim_code = "모임코드: " + _moim.moim_code.toString();
    }

    String duty = _memberInfo.member_duty.toString();
    String approve = "승인요청";
    if(_moimInfo.extra.toString().isNotEmpty) {
      approve = "가입 승인요청 (${_moimInfo.extra.toString()})";
    }

    if(duty.length>2) {
      duty = duty.substring(2);
    }

    bool isManager = (_memberInfo.member_grade != "일반");
    String url = "";
    if (_memberInfo.mb_thumnail!.isNotEmpty) {
      url = URL_HOME + "${_memberInfo.mb_thumnail}";
    }
    const double _menuFontMainSize = 17.0;
    const double _menuFontSubSize = 14.0;
    return Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
            child: SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  child: Container(
                      color: Colors.white,
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                              children: [
                                const SizedBox(width:10),
                                IconButton(
                                    icon: Image.asset("assets/icon/icon_cancel.png", width: 16,height: 16),
                                    onPressed: () {
                                        Navigator.pop(context);
                                    }),
                                  const Spacer(),
                                  Visibility(
                                      visible: isManager,
                                      child: Text(_memberInfo.member_grade.toString(),
                                                style: const TextStyle(color: Colors.black,
                                                fontSize: 14, fontWeight: FontWeight.normal))
                                  ),
                                  const SizedBox(width: 40)
                                ]
                              ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(30, 10, 20, 0),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 36.0,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100.0),
                                      child: simpleBlurImageWithName(_loginInfo.person!.mb_name.toString(), 28, url, 1.0)),
                                ),
                                Row(children: [
                                  Text(
                                    _memberInfo.mb_name.toString(),
                                    maxLines: 1,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 5,),
                                  TextButton.icon(icon: Image.asset("assets/icon/icon_write.png", width: 22, height: 22, color:const Color(0xffc2c2c2)),
                                    label: const Text("정보수정", style: const TextStyle(color:Color(0xffc2c2c2), fontSize: 14, fontWeight:FontWeight.bold)),
                                    onPressed: () async {
                                      setState(() {
                                        _currTabIndex = 4;
                                        _tabController.animateTo(_currTabIndex,
                                            duration: const Duration(milliseconds: 1),
                                            curve: Curves.ease);
                                      });
                                      Future.delayed(const Duration(milliseconds: 500)).then((value) => _closeDrower());
                                    },
                                  ),
                                ]),
                                Text(duty, style: const TextStyle(color: Colors.black, fontWeight:FontWeight.bold, fontSize: 20),),
                                const SizedBox(height: 20),
                                Visibility(
                                    visible: (moim_code.isNotEmpty&&isManager),
                                    child: Row(
                                        children:[
                                          //const Spacer(),
                                          Text(moim_code, style: const TextStyle(color: Colors.red,
                                              fontSize: 14, fontWeight: FontWeight.bold),)
                                        ]
                                    )
                                ),
                                const SizedBox(height: 10),
                            ]),
                          ),

                          const Divider(height: 1),

                          // 승인처리
                          Visibility(
                              visible: isManager,
                              child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.only(left:5),
                                child: ListTile(
                                  leading: Image.asset("assets/icon/moim_side_user_dlist.png", width: 32, height: 32,),
                                  title: const Text("회원관리",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: _menuFontMainSize),
                                  ),
                                  subtitle: Text(
                                    approve,
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal,
                                        fontSize: _menuFontSubSize),
                                  ),
                                  onTap: () {
                                    _moimApprove();
                                  },
                                ),
                              )
                          ),
                          const Divider(height: 1),
                          // 모임관리
                          Visibility(
                            visible: isManager,
                            child:Container(
                              color: Colors.white,
                              padding: const EdgeInsets.only(left:5),
                              child: ListTile(
                                tileColor: Colors.white,
                                leading: Image.asset("assets/icon/moim_side_momo_ab.png", width: 32, height: 32),
                                title: const Text(
                                  '모임관리',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: _menuFontMainSize),
                                ),
                                subtitle: const Text(
                                  '모임 정보 수정하기',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal,
                                      fontSize: _menuFontSubSize),
                                ),
                                onTap: () {
                                    _moimModify();
                                },
                              ),
                            ),
                          ),
                          const Divider(
                            height: 1,
                          ),

                          // 사업장관리
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.only(left:5),
                            child: ListTile(
                              tileColor: Colors.white,
                              leading: Image.asset("assets/icon/moim_side_company.png", width: 32, height: 32),
                              title: const Text(
                                '나의 사업장 관리',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: _menuFontMainSize),
                              ),
                              subtitle: const Text('사업장 관리하기',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal,
                                    fontSize: _menuFontSubSize),
                              ),
                              onTap: () {
                                _myShopManage(_loginInfo.users_id!);
                              },
                            ),
                          ),
                          const Divider(
                            height: 1,
                          ),

                          // 협업현황
                          Container(
                              color: Colors.white,
                              padding: const EdgeInsets.only(left:5),
                              child: ListTile(
                                leading: Image.asset(
                                  "assets/icon/moim_side_hand.png",
                                  color: Colors.black,
                                  width: 32,
                                  height: 32,
                                ),
                                title: const Text(
                                  '협업현황',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: _menuFontMainSize),
                                ),
                                subtitle: const Text(
                                  '회원간 거래현황',
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal,
                                      fontSize: _menuFontSubSize),
                                ),
                                onTap: () {
                                  _moimSales();
                                },
                              )),
                      //    const SizedBox(height: 10),
                          const Divider(height: 1),

                          // 공지사항
                          Container(
                              color: Colors.white,
                              padding: const EdgeInsets.fromLTRB(8,5,5,5),
                              child: ListTile(
                                title: const Text('공지사항',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: _menuFontMainSize),
                                ),
                                subtitle: const Text(
                                  '모임의 공지사항 게시판입니다.',
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal,
                                      fontSize: _menuFontSubSize),
                                ),
                                onTap: () {
                                  _moimBoard();
                                },
                              )),
                          const Divider(height: 1),

                          // 추천하기
                          Container(
                              color: Colors.white,
                              padding: const EdgeInsets.fromLTRB(8,5,5,5),
                              child: ListTile(
                                title: const Text(
                                  '모임 초대하기',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: _menuFontMainSize),
                                ),
                                subtitle: const Text(
                                  '지인을 모임에 초대합니다.',
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal,
                                      fontSize: _menuFontSubSize),
                                ),
                                onTap: () {
                                  _moimRecommend();
                                },
                              )),
                          const Divider(height: 1),

                          // 탈퇴하기
                          Container(
                              color: Colors.white,
                              padding: const EdgeInsets.fromLTRB(8,5,5,5),
                              child: ListTile(
                                title: const Text(
                                  '나가기',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: _menuFontMainSize),
                                ),
                                subtitle: const Text(
                                  '모임 활동을 중지하고 탈퇴합니다.',
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal,
                                      fontSize: _menuFontSubSize),
                                ),
                                onTap: () {
                                  _moimDisJoin(true);
                                  },
                              )),
                          //const Divider(height: 1),
                          //const SizedBox(height: 50,)
                        ],
                      )),
                ))));
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.black,
      selectedFontSize: 14,
      unselectedFontSize: 11,
      onTap: (int index) async {
        if (_currTabIndex == index) {
          return;
        }

        if(_fabKey.currentState != null && _fabKey.currentState!.isOpen) {
          _fabKey.currentState!.close();
        }

        if (index == 4) {
          _onContact();
          return;
        }

        _pageController[_currTabIndex].goBack();
        //_pageController[index].goFront();

        setState(() {
          _currTabIndex = index;
          _bSearch = (_currTabIndex==1 || _currTabIndex==3) ? true : false;
        });

        _tabController.animateTo(_currTabIndex,
            duration: const Duration(milliseconds: 200), curve: Curves.ease);
        _pageController[_currTabIndex].Invalidate();
      },

      currentIndex: _currTabIndex,
      items: [
        BottomNavigationBarItem(
            label: '모임홈',
            icon: Image.asset(
              "assets/icon/moim_bot_home.png",
              width: (_currTabIndex == 0) ? 28 : 28,
              height: (_currTabIndex == 0) ? 28 : 28,
              color: (_currTabIndex == 0) ? Colors.green : Colors.black,
            )),
        BottomNavigationBarItem(
            label: '전체회원',
            icon: Image.asset(
              "assets/icon/moim_bot_user_group.png",
              width: (_currTabIndex == 1) ? 28 : 28,
              height: (_currTabIndex == 1) ? 28 : 28,
              color: (_currTabIndex == 1) ? Colors.green : Colors.black,
            )),
        BottomNavigationBarItem(
            label: '전체사업장',
            icon: Image.asset(
              "assets/icon/moim_bot_company.png",
              width: (_currTabIndex == 2) ? 28 : 28,
              height: (_currTabIndex == 2) ? 28 : 28,
              color: (_currTabIndex == 2) ? Colors.green : Colors.black,
            )),
        BottomNavigationBarItem(
            label: '주변사업장',
            icon: Image.asset(
              "assets/icon/moim_bot_company_map.png",
              width: (_currTabIndex == 3) ? 28 : 28,
              height: (_currTabIndex == 3) ? 28 : 28,
              color: (_currTabIndex == 3) ? Colors.green : Colors.black,
            )),
        BottomNavigationBarItem(
            label: '인맥관리',
            icon: Image.asset(
              "assets/icon/moim_bot_user.png",
              width: (_currTabIndex == 4) ? 28 : 28,
              height: (_currTabIndex == 4) ? 28 : 28,
              color: (_currTabIndex == 4) ? Colors.green : Colors.black,
            )),
      ],
    );
  }

  bool _closeDrower() {
    if (_scaffoldStateKey.currentState!.isEndDrawerOpen) {
      Navigator.pop(context);
      return true;
    }
    return false;
  }

  void _showShop(String shop_id) {
    Navigator.push(
      context,
      Transition(
          child: ShopHome(
            isEditMode: false,
            shops_id: shop_id,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
  }

  Future <void> _loadMemberInfo() async {
    _bMemberInfo = false;
    Map<String, String> params = {
      "command": "OWNER",
      "users_id":_loginInfo.users_id.toString(),
      "moims_id": widget.moims_id
    };

    await Remote.getMemberInfo(
        params: params,
        onResponse: (List<MemberInfo> list) {
          setState(() {
            _bMemberInfo = true;
            if(list.isNotEmpty) {
              _memberInfo = list.elementAt(0);
            }
          });
        });
  }

  Future <void> _showMember(String members_id) async {
    Navigator.push(
      context,
      Transition(
          child: MemberHome(
            isNickFirst: _use_nick,
            member_id: members_id,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
  }

  bool canGoBack() {
    if (_currTabIndex != 0) {
      setState(() {
        _currTabIndex = 0;
        _tabController.animateTo(_currTabIndex,
            duration: const Duration(milliseconds: 200), curve: Curves.ease);
      });
      return true;
    }
    return false;
  }

  // backKey event 처리
  Future <bool> onWillPop() async {

    if(_fabKey.currentState != null && _fabKey.currentState!.isOpen) {
      _fabKey.currentState!.close();
      return false;
    }

    if (_closeDrower()) {
      _closeDrower();
      return false;
    }

    if(canGoBack()) {
      return false;
    }

    Navigator.pop(context, _bDirty);
    return true; // true will exit the app
  }

  Future <void> _onSearch(String target) async {
    var result = await Navigator.push(
      context,
      Transition(
          child: SearchHome(target: target, moimId: widget.moims_id,
          ),
          transitionEffect: TransitionEffect.BOTTOM_TO_TOP),
    );

    if(result != null){
      Future.microtask(() {
        if(target=="shop"){
          _showShop(result.toString());
        }
        else if(target=="member"){
          _showMember(result.toString());
        }
      });
    }
  }

  Future <void> _moimApprove() async {
    var result = await Navigator.push(
      context,
      Transition(
          child: MemberApprove(title: "회원관리", moims_id: widget.moims_id, moims_name:_moim.moim_name!),
          transitionEffect: TransitionEffect.BOTTOM_TO_TOP),
    );

    if(result!=null) {
      _pageController[0].Invalidate();
      setState(() {
      });
    }
  }

  Future <void> _moimModify() async {
    var result = await Navigator.push(
      context,
      Transition(
          child: MoimEdit(moims_id: widget.moims_id.toString()),
          transitionEffect: TransitionEffect.BOTTOM_TO_TOP),
    );

    if (result != null) {
      if(result<0) {
        _closeDrower();
        Navigator.pop(context, true);
      }
      else {
        _bDirty = true;
        _pageController[0].Invalidate();
      }
    }
  }

  Future <void> _moimDisJoin(bool bCheck) async {
    if(_memberInfo.member_grade=="관리자") {
      showDialogPop(
          context: context,
          title: "확인",
          body: const Text(
            "현재 이 모임의 관리자입니다.",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          content: const Text(
            "모임 탈퇴는 관리자 권한을 다른회원에게 이관후 가능합니다.",
            style: const TextStyle(
                fontWeight: FontWeight.normal, fontSize: 13, color: Colors.grey),
          ),
          choiceCount: 1,
          yesText: "확인",
          cancelText: "아니오",
          onResult: (bool isOK) async {
          });
      return;
    }

    if(bCheck) {
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
                fontWeight: FontWeight.normal,
                fontSize: 13,
                color: Colors.grey),
          ),
          choiceCount: 2,
          yesText: "예",
          cancelText: "아니오",
          onResult: (bool isOK) async {
            if (isOK) {
              await Remote.reqMembers(
                  params: {
                    "command": "DELETE",
                    "users_id": "${_loginInfo.users_id}",
                    "moims_id": widget.moims_id
                  },
                  onResponse: (bool result) async {
                    if (result) {
                      String topic = "moims_${widget.moims_id}";
                      await FirebaseMessaging.instance.unsubscribeFromTopic(
                          topic);

                      _bDirty = true;

                      _closeDrower();
                      Navigator.pop(context, _bDirty);
                    }
                  });
            }
          });
    }
    else {
      await Remote.reqMembers(
          params: {
            "command": "DELETE",
            "users_id": "${_loginInfo.users_id}",
            "moims_id": widget.moims_id
          },
          onResponse: (bool result) async {
            if (result) {
              String topic = "moims_${widget.moims_id}";
              await FirebaseMessaging.instance.unsubscribeFromTopic(
                  topic);

              _bDirty = true;

              _closeDrower();
              Navigator.pop(context, _bDirty);
            }
          });
    }
  }

  // 내 사업장 목록
  Future <void> _myShopManage(String usersId) async {
    var result = await Navigator.push(
      context,

      Transition(
          child: MyShopList(title: "내 사업장", target: "Owner", id: usersId),
          transitionEffect: TransitionEffect.BOTTOM_TO_TOP),
    );

    if (result != null && result==true) {
      _pageController[1].Invalidate();
    }
  }

  void _updateLocation() {
    Provider.of<GpsProvider>(context, listen:false).updateGeolocator(true).then((value) {
      _pageController[_currTabIndex].Invalidate();
    });
  }

  Future <void> _moimSales() async {
    await Navigator.push(
      context,
      Transition(
          child: SalesReport(title: '협업현황', moims_id: _moim.id.toString()),
          transitionEffect: TransitionEffect.BOTTOM_TO_TOP),
    );
  }

  Future <void> _moimBoard() async {
    // https://momo.maxidc.net/bbs/board_app.php?bo_table=moim&moims_id=5&isManager=true
    String moims_id = _moim.id.toString();
    bool isManager = (_memberInfo.member_grade != "일반");
    final String url = "${URL_HOME}bbs/board_app.php?bo_table=moim&moims_id=$moims_id&isManager=$isManager";

    await Navigator.push(
      context,
      Transition(
          child: WebExplorer(
            title: "공지사항",
            website: url,
          ),
          transitionEffect: TransitionEffect.BOTTOM_TO_TOP),
    );

    if(_currTabIndex==0) {
      _pageController[0].Invalidate();
    }
  }

  void _onBoardDetail(String wr_id) {
    // https://momo.maxwr_idc.net/bbs/board_app.php?bo_table=moim&wr_id=27
    String moims_id = _moim.id.toString();
    bool isManager = (_memberInfo.member_grade != "일반");
    final String url = "${URL_HOME}bbs/board_app.php?bo_table=moim&wr_id=$wr_id&moims_id=$moims_id&isManager=$isManager";

    Navigator.push(
      context,
      Transition(
          child: WebExplorer(
            title: "공지사항",
            website: url,
          ),
          transitionEffect: TransitionEffect.BOTTOM_TO_TOP),
    );
  }

  Future <void> _moimRecommend() async {
    String subject = "";//"""모임가입 안내";
    String text;

    if(_moim.moim_code!.isEmpty) {
      text = "⌜${_moim.moim_name}⌟에서 당신을 초대합니다."
          "\n아래 링크에서 앱을 다운받아 설치하시고"
          "\n우리 모임에 가입해주세요."
          "\n\n다운로드:"
          "\nmomo.maxidc.net";
      //"\n\nplay.google.com/store/apps/details?id=com.smdt.moims";
    }
    else
    {
      text = "⌜${_moim.moim_name}⌟에서 당신을 초대합니다."
          "\n아래 링크에서 앱을 다운받아 설치하시고"
          "\n우리 모임에 가입해주세요."
          "\n\n우리 모임은 비공개입니다."
          "\n모임 검색창에 '${_moim.moim_name}'을 검색 하세요."
          "\n가입코드는 ${_moim.moim_code}입니다."
          "\n\n다운로드:"
          "\nmomo.maxidc.net";
      //"\n\nplay.google.com/store/apps/details?id=com.smdt.moims";
    }
    await shareInfo(subject: subject, text: text, imagePaths:[]);
  }

  Future <void> _onContact() async {
    var result = await Navigator.push(
      context,
      Transition(
          child: ContactMain(usersId: _loginInfo.person!.mb_no!),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
  }

}
