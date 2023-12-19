// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:momo/Intro/intro_screen_page.dart';
import 'package:momo/Models/MainInfo.dart';
import 'package:momo/Models/MoimsBoard.dart';
import 'package:momo/Moims/MyMoimList.dart';
import 'package:momo/Push/LocalNotificationService.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Controller/ColtrollerStatusChange.dart';
import 'package:momo/Models/Moims.dart';
import 'package:momo/Models/Person.dart';
import 'package:momo/Models/Shops.dart';
import 'package:momo/Moims/MoimHomeTab.dart';
import 'package:momo/Moims/MoimJoin.dart';
import 'package:momo/Moims/MoimRegist.dart';
import 'package:momo/Shops/MyShopList.dart';
import 'package:momo/Provider/GpsProvider.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Shops/ShopHome.dart';
import 'package:momo/Users/Login.dart';
import 'package:momo/Utils/DateForm.dart';
import 'package:momo/Utils/Launcher.dart';
import 'package:momo/Utils/SearchHome.dart';
import 'package:momo/Utils/utils.dart';
import 'package:momo/Members/MemberEditPage.dart';
import 'package:momo/Moims/MoimListPage.dart';
import 'package:momo/Shops/ShopListPage.dart';
import 'package:momo/Webview/WebExplorer.dart';
import 'package:momo/contacts/contactDemo.dart';
import 'package:momo/contacts/contactMain.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:transition/transition.dart';
import 'MainPageHome.dart';

class MainHomeTab extends StatefulWidget {
  const MainHomeTab({
    Key? key,
  }) : super(key: key);

  @override
  _MainHomeTabState createState() => _MainHomeTabState();
}

class _MainHomeTabState extends State<MainHomeTab>
    with SingleTickerProviderStateMixin {

  final GlobalKey<ScaffoldState> _scaffoldStateKey = GlobalKey();
  final GlobalKey<FabCircularMenuState> _fabKey = GlobalKey();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  late final List<ControllerStatusChange> _pageController;
  late TabController _tabController;
  late DateTime _preBackpress;
  late LoginInfo _loginInfo;

  MainInfo _mainInfo = MainInfo();

  int  _currTabIndex = 0;
  bool _bSearch = false;
  bool _bReady  = false;
  bool _m_isSigned = false;
  bool _hasNotify = false;

  void _onRefresh() async {
    print("_onRefresh()::....................");
    _pageController[_currTabIndex].Invalidate();
    _refreshController.refreshCompleted();
  }

  Future <void> procFirebaseMassing() async {

    print("MainHomeTab::procFirebaseMassing(0)::_loginInfo="+_loginInfo.toString());

    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    bool bDirdy = false;
    messaging.getToken().then((token) {
      print("getToken(): ---- > $token");
        if(_loginInfo.push_token != token) {
          _loginInfo.push_token = token;
          bDirdy = true;
        }
    });
    // var token = await messaging.getToken();
    // if(token != null) {
    //   if(_loginInfo.push_token != token) {
    //     _loginInfo.push_token = token;
    //     bDirdy = true;
    //   }
    // }

    if(_loginInfo.isInitNotify != "Y") {
      FirebaseMessaging.instance.subscribeToTopic("momo");
      _loginInfo.isInitNotify = "Y";
      bDirdy = true;
    }

    if(bDirdy) {
      await _loginInfo.setPref();
      print("MainHomeTab::procFirebaseMassing(1)::_loginInfo="+_loginInfo.toString());
    }

    // 사용자가 클릭한 메시지를 제공함.
    messaging.getInitialMessage().then((message) {
      print("\n\ngetInitialMessage(user tab) -----------------> ");
      if(message != null && message.notification != null) {
        String action = "";
        if(message.data["action"] != null) {
          action = message.data["action"];
        }
        print("title=${message.notification!.title.toString()},\n"
            "body=${message.notification!.body.toString()},\n"
            "action=$action");
        LocalNotificationService.doRoute(context, action);
      }

      // if foreground state here.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("\n\nForeground Status(active) -----------------> ");
        if(message.notification != null) {
          String action = "";
          if(message.data["action"] != null) {
            action = message.data["action"];
          }
          print("title=${message.notification!.title.toString()},\n"
              "body=${message.notification!.body.toString()},\n"
              "action=$action");
          LocalNotificationService.display(message);
        }
      });

      // 엡이 죽지않고 백그라운드 상태일때...
      FirebaseMessaging.onMessageOpenedApp.listen((message) async {
        print("\n\nBackground Status(alive) -----------------> ");
        if(message.notification != null) {
          String action = "";
          if(message.data["action"] != null) {
            action = message.data["action"];
          }
          print("title=${message.notification!.title.toString()},\n"
              "body=${message.notification!.body.toString()},\n"
              "action=$action");
          LocalNotificationService.doRoute(context, action);
        }
      });
    });

    print("MainHomeTab::procFirebaseMassing(3)::_loginInfo="+_loginInfo.toString());
  }

  @override
  void initState() {
    LocalNotificationService.initialize(context);

    _preBackpress   = DateTime.now();
    _tabController  = TabController(vsync: this, length: 5);
    _pageController = [
      ControllerStatusChange(),
      ControllerStatusChange(),
      ControllerStatusChange(),
      ControllerStatusChange(),
      ControllerStatusChange(),
    ];

    Future.microtask(() async {
      _loginInfo = Provider.of<LoginInfo>(context, listen:false);
      await _loginInfo.getPref();
      await procFirebaseMassing();
      setState(() { _bReady = true; });
      await _showIntro();
      _login();
      print("MainHomeTab::initState(4)::_loginInfo="+_loginInfo.toString());
    });

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldStateKey,
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0.0,
          title: Visibility(
            visible: true,//_m_isSigned,
            child: Image.asset("assets/icon/icon_sign_in.png", height: 30, fit: BoxFit.fitHeight)),
          actions: [
            // 위치정보 갱신
            Visibility(
              visible: (_currTabIndex==1), // 사업장 화면만 표시
              child: IconButton(
                  icon: Image.asset("assets/icon/icon_map_pin.png", width: 32, height: 32, color: Colors.black),
                  onPressed: () {
                    _updateLocation();
                  }),
            ),
            // 검색
            Visibility(
              visible: (_m_isSigned && _bSearch),
              child: IconButton(
                  icon: const Icon(Icons.search, size: 26),
                  onPressed: () {
                    setState(() {
                      String target = "";
                      if(_currTabIndex==1) {
                        target = "shop";
                      } else if(_currTabIndex==3) {
                        target = "moim";
                      }
                      _onSearch(target);
                    });
                  }),
            ),

            // 알림
            Visibility(
              visible: _hasNotify,//(_m_isSigned && _bSearch),
              child: IconButton(
                //padding: EdgeInsets.all(0),
                icon: const Icon(Icons.notifications_active, size:20, color: Colors.redAccent),
                  //icon: Image.asset("assets/icon/icon_notice.png", width: 26, height: 26, color: Colors.red),
                  onPressed: () {
                    _userBoard();
                  }),
            ),

            // 로그인
            Visibility(
              visible: false,//(!_m_isSigned),
              child: IconButton(
                  icon: const Icon(Icons.person, color: Colors.black,size: 32,),
                  onPressed: () async {
                    _login();
                  }),
            ),

            // 메뉴
            Visibility(
              visible: _m_isSigned,
              child: IconButton(
                  icon: Image.asset("assets/icon/icon_menu.png", width: 32, height: 32, color: Colors.black),
                  onPressed: () {
                    _scaffoldStateKey.currentState!.openEndDrawer();
                  }),
            ),
          ],
        ),
        endDrawer: (_m_isSigned) ? _buildDrawerWidget() : Container(),
        //bottomNavigationBar: _bottomCurvedNavigationBar(),
        bottomNavigationBar: _bottomNavigationBar(),
        body: WillPopScope(
            onWillPop: onWillPop,
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: const WaterDropHeader(
                waterDropColor: Colors.black,
                complete: Text("업데이트 완료",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                failed: Text('Failed',
                    style: TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              //onLoading: _onLoading,
              child: BuildTabHome()
            )));
  }

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.black,
      selectedFontSize: 14,
      unselectedFontSize: 11,

      onTap: (int index) {
        if(!_m_isSigned) {
          showToastMessage("로그인 후 사용하세요.");
          return;
        }

        if(index == 1) {
          var _gpsProvider = Provider.of<GpsProvider>(context, listen: false);
          if(!_gpsProvider.isInit) {
            showToastMessage("위치정보 초기화중입니다."
                "\n잠시만 기다려주십시오...");
            return;
          }
        }

        if (index == 2) {
          _onMoimCreate();
          return;
        }

        if (index == 4) {
          _onContact();
          return;
        }

        checkNotice();

        if(_currTabIndex == index) {
          return;
        }

        _currTabIndex = index;
        _tabController.animateTo(_currTabIndex,
            duration: const Duration(milliseconds: 200),
            curve: Curves.ease);
        _pageController[_currTabIndex].Invalidate();

        setState(() {
          _bSearch = (_currTabIndex==1 || _currTabIndex==3) ? true : false;
        });
      },

      currentIndex: _currTabIndex, //_selectedIndex, //현재 선택된 Index
      items: [
        BottomNavigationBarItem(
            label: '홈',
            icon: Image.asset("assets/icon/main_bot_home.png",
              width: (_currTabIndex == 0) ? 28 : 28,
              height: (_currTabIndex == 0) ? 28 : 28,
              color: (_currTabIndex == 0) ? Colors.green : Colors.black,
            )
        ),
        BottomNavigationBarItem(
            label: '주변사업장',
            icon: Image.asset("assets/icon/main_bot_map.png",
              width: (_currTabIndex == 1) ? 28 : 28,
              height: (_currTabIndex == 1) ? 28 : 28,
              color: (_currTabIndex == 1) ? Colors.green : Colors.black,
            )
        ),
        BottomNavigationBarItem(
            label: '모임개설',
            icon: Image.asset("assets/icon/main_bot_create.png",
              width: (_currTabIndex == 2) ? 28 : 28,
              height: (_currTabIndex == 2) ? 28 : 28,
              color: (_currTabIndex == 2) ? Colors.green : Colors.black,
            )),
        BottomNavigationBarItem(
            label: '모임찾기',
            icon: Image.asset("assets/icon/main_bot_search.png",
              width: (_currTabIndex == 3) ? 28 : 28,
              height: (_currTabIndex == 3) ? 28 : 28,
              color: (_currTabIndex == 3) ? Colors.green : Colors.black,
            )),
        BottomNavigationBarItem(
            label: '인맥관리',
            icon: Image.asset("assets/icon/main_bot_user.png",
              width: (_currTabIndex == 4) ? 28 : 28,
              height: (_currTabIndex == 4) ? 28 : 28,
              color: (_currTabIndex == 4) ? Colors.green : Colors.black,
            )),
      ],
    );
  }

  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  Widget? _bottomCurvedNavigationBar() {
    return CurvedNavigationBar(
      key: _bottomNavigationKey,
      index: _currTabIndex,
      height: 44,
      color: Colors.grey.shade50,
      buttonBackgroundColor: Colors.black,
      backgroundColor: Colors.white,
      items: <Widget>[
        Image.asset("assets/icon/main_bot_home.png", width: 24, height:24, color: (_currTabIndex==0) ? Colors.white : Colors.black),
        Image.asset("assets/icon/main_bot_map.png", width: 24, height:24, color: (_currTabIndex==1) ? Colors.white : Colors.black),
        Image.asset("assets/icon/main_bot_create.png", width: 24, height:24, color: (_currTabIndex==2) ? Colors.white : Colors.black),
        Image.asset("assets/icon/main_bot_search.png", width: 24, height:24, color: (_currTabIndex==3) ? Colors.white : Colors.black),
        Image.asset("assets/icon/main_bot_user.png", width: 24, height:24, color: (_currTabIndex==4) ? Colors.white : Colors.black),

      ],
      onTap: (index) {
        if(!_m_isSigned) {
          showToastMessage("로그인 후 사용하세요.");
          return;
        }

        if(index == 1) {
          var _gpsProvider = Provider.of<GpsProvider>(context, listen: false);
          if(!_gpsProvider.isInit) {
            showToastMessage("위치정보 초기화중입니다."
                "\n잠시만 기다려주십시오...");
            return;
          }
        }

        if (index == 2) {
          _onMoimCreate();
          return;
        }

        if (index == 4) {
          _onContact();
          return;
        }

        checkNotice();

        if(_currTabIndex == index) {
          return;
        }

        setState(() {
          _currTabIndex = index;
        });

        CurvedNavigationBarState? navBarState =
            _bottomNavigationKey.currentState;
        navBarState?.setPage(_currTabIndex);

        _tabController.animateTo(_currTabIndex,
            duration: const Duration(milliseconds: 200),
            curve: Curves.ease);
        _pageController[_currTabIndex].Invalidate();

        setState(() {
          _bSearch = (_currTabIndex==1 || _currTabIndex==3) ? true : false;
        });
      },
    );
  }

  Widget BuildTabHome() {
    if (!_bReady)  {
      return Container();
    }
    return TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[

          // 0 home
          MainPageHome(
            controller: _pageController[0],
            onShowMoim: (Moims info) {
              bool isApprove = (info.member_approve.toString()=="Y");
              _showMoimHome(_loginInfo.users_id!, isApprove, info.id);
            },
            onTagMoim: (String tag) {},
            onSearchMoim: (String key) {},
            onJoinMoim: (Moims info) {
              bool isOwner = (info.moim_owner == _loginInfo.users_id!);
              _joinMember(info.id.toString(), isOwner);
            },

            onInfo: (MainInfo info) {
              setState(() {
                _mainInfo = info;
              });
            },
            onJoinable:(Moims moim){
              bool isOwner = (moim.moim_owner==_loginInfo.users_id!);
              _joinMember(moim.id.toString(), isOwner);
            }
          ),

          // 1: shopList
          ShopListPage(
            controller: _pageController[1],
            isDistOrder:true,
            targetId:_loginInfo.users_id!,
            target: 'Member',
            onTap: (Shops shop) {
              _showShop(shop.id.toString());
            },
            onDetail: (Shops shop) {},
          ),

          // 2: 모임개설
          Container(),

          // 3: moims list
          MoimListPage(
            controller: _pageController[3],
            userId: _loginInfo.users_id!,
            target: 'Joinable',
            onTap: (Moims moim) {
              bool isOwner = (moim.moim_owner==_loginInfo.users_id!);
              _joinMember(moim.id.toString(), isOwner);
            },

            onDetail: (Moims moim) {

            },
          ),

          // 4: 인맥관리
          Container(),
          // MemberEditPage(
          //   controller: _pageController[4],
          //   moimsId: "",
          //   isMember: false,
          //   onUpdate: (bool result) {
          //     if (result) {
          //       //_fetchPerson();
          //       setState(() {
          //
          //       });
          //       // 기본정보 reload!
          //     }
          //   },
          // ),
        ],
      );
  }

  // 메뉴바 표시
  Widget _buildDrawerWidget() {
    String url = "";
    if (_loginInfo.person!.mb_thumnail!.isNotEmpty) {
      url = URL_HOME + _loginInfo.person!.mb_thumnail!;
    }

    print("_buildDrawerWidget()url=$url");

    const double _menuFontMainSize = 16.0;
    const double _menuFontSubSize  = 13.0;
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
                        Padding(
                            padding: const EdgeInsets.only(left:10),
                            child: IconButton(icon: Image.asset("assets/icon/icon_cancel.png", width: 16,height: 16),
                            onPressed: () { Navigator.pop(context); })
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
                                  // title
                                  Row(children: [
                                    Text(_loginInfo.person!.mb_name.toString(), maxLines: 1,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold),
                                    ),

                                    const SizedBox(width: 5),
                                    TextButton.icon(icon: Image.asset("assets/icon/icon_write.png", width: 22, height: 22, color:const Color(0xffc2c2c2)),
                                      label: const Text("정보수정", style: const TextStyle(color:const Color(0xffc2c2c2), fontSize: 14, fontWeight:FontWeight.bold)),
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
                                  const SizedBox(height: 10),
                                  Text(_loginInfo.person!.mb_email!,
                                    style: const TextStyle(color: Colors.black, fontSize: 14)),
                                  const SizedBox(height: 30),
                                ],
                              ),
                      ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(30, 15, 100, 20),
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 가입모임 수
                              GestureDetector(
                                onTap: () async {},
                                child: Container(
                                    color: Colors.transparent,
                                    child: Column(
                                      //mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(_mainInfo.count_active_moims,
                                            style: const TextStyle(
                                                fontSize: 24.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey)),
                                        const SizedBox(height: 5),
                                        const Text("가입모임",
                                            style: const TextStyle(
                                                fontSize: 14.0, color: Colors.black))
                                      ],
                                    )),
                              ),
                              // 개설모임 수
                              GestureDetector(
                                onTap: () async {},
                                child: Container(
                                    color: Colors.transparent,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(_mainInfo.count_mine_moims,
                                            style: const TextStyle(
                                                fontSize: 24.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey)),
                                        const SizedBox(height: 5),
                                        const Text("개설모임",
                                            style: const TextStyle(
                                                fontSize: 14.0, color: Colors.black))
                                      ],
                                    )),
                              ),
                              // 예약 건수
                              /*
                              GestureDetector(
                                onTap: () async {},
                                child: Container(
                                    color: Colors.transparent,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                         Text(_mainInfo.count_reservation,
                                            style: const TextStyle(
                                                fontSize: 24.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey)),

                                        const SizedBox(height: 5),
                                        const Text("예약",
                                            style: const TextStyle(
                                                fontSize: 14.0, color: Colors.black))

                                      ],
                                    )),
                              ),
                              */
                            ],
                          )),
                        const Divider(height: 1,),

                        // 모임관리
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.only(left:5),
                          child: ListTile(
                            leading: Image.asset("assets/icon/moim_side_momo_ab.png", width: 32, height: 32),
                            title: const Text(
                              '나의 모임 관리',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: _menuFontMainSize),
                            ),
                            subtitle: const Text(
                              '내가 개설한 모임',
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                  fontSize: _menuFontSubSize),
                            ),
                            onTap: () {
                              _myMoimManage(_loginInfo.users_id!);
                            },
                          ),
                        ),
                        const Divider(height: 1),

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
                            subtitle: const Text(
                              '사업장 관리하기',
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
                        const Divider(height: 1),

                        // 공지사항
                        Container(
                            color: Colors.white,
                            padding: const EdgeInsets.fromLTRB(8,5,5,5),
                            child: ListTile(
                              title: Row(children: [
                                const Text('공지사항',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: _menuFontMainSize),
                                ),
                                const SizedBox(width: 5),
                                Visibility(
                                  visible: _hasNotify,
                                  child: const Icon(Icons.notifications_active, size:16, color: Colors.redAccent),
                                )

                              ]),
                              onTap: () {
                                _userBoard();
                              },
                            )),
                        const Divider(height: 1),

                        // 추천하기
                        Container(
                            color: Colors.white,
                            padding: const EdgeInsets.fromLTRB(8,5,5,5),
                            child: ListTile(
                              title: const Text(
                                '앱 추천하기',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: _menuFontMainSize),
                              ),
                              onTap: () {
                                _appRecommend();
                              },
                            )),
                        const Divider(height: 1),

                        // 로그아웃
                        Container(
                            color: Colors.white,
                            padding: const EdgeInsets.fromLTRB(8,5,5,5),
                            child: ListTile(
                              title: const Text(
                                '로그아웃',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: _menuFontMainSize),
                              ),
                              onTap: () { _logout();},
                            )),

                        const Divider(height: 1),

                        // 인맥관리
                        Container(
                            color: Colors.white,
                            padding: const EdgeInsets.fromLTRB(8,5,5,5),
                            child: ListTile(
                              title: const Text(
                                '인맥관리',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: _menuFontMainSize),
                              ),
                              onTap: () { _contacts();},
                            )),
                        //const Divider(height: 1),
                        //Expanded(child: Container(color: Colors.white,))
                        //const SizedBox(height: 50)
                  ],
                )),
        ))));
  }

  // 위치정보 보고
  void _updateLocation() {
    Provider.of<GpsProvider>(context, listen:false).updateGeolocator(true).then((value) {
      _pageController[1].Invalidate();
    });
  }

  // 소개화면 표시
  Future <void> _showIntro() async {
    if(_loginInfo.skip_intro != "Y" ) {
      await Navigator.push(context,
          Transition(child: const IntroScreenPage(),
              transitionEffect: TransitionEffect.RIGHT_TO_LEFT));
    }
  }

  // 로그인
  Future <bool> _tryLogin() async {

    bool rtn = false;
    print("_tryLogin()::");

    _m_isSigned = false;
    if (_loginInfo.auto_login != "Y") {
      return rtn;
    }

    if(_loginInfo.uid!.isEmpty || _loginInfo.pwd!.isEmpty) {
      return rtn;
    }

    await Remote.login(
        uid: _loginInfo.uid.toString(),
        pwd: _loginInfo.pwd.toString(),
        onResponse: (int status, Person person) async {
          if (status == 1) {
            rtn = true;
            setState(() {
              _m_isSigned = true;
              _loginInfo.users_id = person.mb_no;
              _loginInfo.person   = person;
              _pageController[0].setUserId(_loginInfo.users_id!);
              checkNotice();
            });
          }
        });
    return rtn;
  }
  Future <void> _login() async {
    bool bLogin = await _tryLogin();
    if(!bLogin) {
      var person = await Navigator.push(context,
        Transition(
            child: const Login(),
            transitionEffect: TransitionEffect.RIGHT_TO_LEFT),);
      
      if(person != null) {
        setState(() {
          _m_isSigned = true;
          _loginInfo.users_id = person.mb_no;
          _loginInfo.person   = person;
          _pageController[0].setUserId(_loginInfo.users_id!);
          checkNotice();
        });
      }
    }
  }

  Future <void> _logout() async {
    if (_scaffoldStateKey.currentState!.isEndDrawerOpen) {
      Navigator.pop(context);
    }

    _loginInfo.clearSignInfo();
    _loginInfo.setPref();
    _login();
  }

  Future <void> _contacts() async {
    // if (_scaffoldStateKey.currentState!.isEndDrawerOpen) {
    //   Navigator.pop(context);
    // }
    //
    // _loginInfo.clearSignInfo();
    // _loginInfo.setPref();
    // _login();
    Navigator.push(
      context,
      Transition(
          child: ContactsDemo(
          ),
          transitionEffect: TransitionEffect.BOTTOM_TO_TOP),
    );
  }

  // 공지사항 체크
  Future <void> checkNotice() async {
    await Remote.getUserBoards(
        params: {
          "command":"LIST",
          "count":"1"
        },
        onResponse: (List<MoimsBoard> list) {
          bool flag = false;
          if(list.isNotEmpty) {
            MoimsBoard info = list.elementAt(0);
            DateForm df = DateForm().parse(info.wr_last.toString());
            int dayCount = df.passInHour();
            if(dayCount<24) {
              flag = true;
            }
          }
          setState(() {
            _hasNotify = flag;
          });
        });
  }

  // 공지 게시판
  Future <void> _userBoard() async {
    const String url = "${URL_HOME}bbs/board.php?bo_table=notice&isApp=true";
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

  // 모임열기
  Future <void> _showMoimHome(String userId, bool isApprove, moimsId) async {
    /*
    if(!isApprove){
      showDialogPop(
          context: context,
          title: "확인",
          body: const Text(
            "이 모임의 활동은 모임 관리자의 가입 승인후에 가능합니다.",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          content: const Text(
            "모임 관리자에게 문의하십시오.",
            style: const TextStyle(
                fontWeight: FontWeight.normal, fontSize: 13, color: Colors.grey),
          ),
          choiceCount: 1,
          yesText: "확인",
          //cancelText: "아니오",
          onResult: (bool isOK) async {});
      return;
    }
    */
    var result = await Navigator.push(
      context,
      Transition(
          child: MoimHomeTab(moims_id: moimsId),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
    if(result != null) {
      _pageController[_currTabIndex].Invalidate();
    }
  }

  Future <void> _onContact() async {
    var result = await Navigator.push(
      context,
      Transition(
          child: ContactMain(usersId: _loginInfo.person!.mb_no!),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
  }

  // 모임 만들기
  Future <void> _onMoimCreate() async {
    var moimsId = await Navigator.push(
      context,
      Transition(
          child: MoimRegist(usersId: _loginInfo.person!.mb_no!),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    // 모임이 생성되면 관리자 모드로 등록한다.
    if(moimsId != null) {
      // 구독등록
      String topic = "moims_$moimsId";
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      if(_currTabIndex == 0) {
        _pageController[_currTabIndex].Invalidate();
      }
      else
      {
          setState(() {
            _currTabIndex = 0;
            _pageController[_currTabIndex].Invalidate();
            _tabController.animateTo(_currTabIndex,
                duration: const Duration(milliseconds: 100),
                curve: Curves.ease);
          });
      }
    }
  }

  // 모임 가입처리
  Future <void> _joinMember(final String moimsId, bool isOwner) async {
    var result = await Navigator.push(
      context,
      Transition(
          child: MoimJoin(moims_id: moimsId, isOwner:isOwner),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    if(result != null) {
      // 구독등록
      String topic = "moims_$moimsId";
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      _pageController[_currTabIndex].Invalidate();
    }
  }

  // 모임 관리 실행.
  Future <void> _myMoimManage(String usersId) async {
    var result = await Navigator.push(
      context,
      Transition(
          child: MyMoimList(title: "내 모임 관리", target: 'Owner', users_id: usersId),
          transitionEffect: TransitionEffect.BOTTOM_TO_TOP),
    );

    if (result != null) {
      _pageController[_currTabIndex].Invalidate();
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

    if (result != null) {
      _pageController[_currTabIndex].Invalidate();
    }
  }

  // 메뉴바 닫기
  bool _closeDrower() {
    if (_scaffoldStateKey.currentState!.isEndDrawerOpen) {
      Navigator.pop(context);
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

    if(_currTabIndex != 0){
      setState(() {
        _currTabIndex = 0;
        _tabController.animateTo(_currTabIndex,
            duration: const Duration(milliseconds: 200),
            curve: Curves.ease);
      });
      return false;
    }

    final timegap = DateTime.now().difference(_preBackpress);

    final cantExit = timegap >= const Duration(seconds: 2);

    _preBackpress = DateTime.now();

    if (cantExit) {
      showToastMessage("한번 더 누르면 앱을 종료합니다.");
      return false; // false will do nothing when back press
    }
    return true; // true will exit the app
  }

  // 사업장 보기
  void _showShop(String shopId) {
    Navigator.push(
      context,
      Transition(
          child: ShopHome(
            isEditMode: false,
            shops_id: shopId,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
  }

  // 검색하기
  Future <void> _onSearch(String target) async {
    var result = await Navigator.push(
      context,
      Transition(
          child: SearchHome(
            target: target,
            moimId: '',
          ),
          transitionEffect: TransitionEffect.BOTTOM_TO_TOP),
    );

    if(result != null){
      Future.microtask(() {
        if(target=="shop"){
          _showShop(result.toString());
        }
        else if(target=="moim"){
          _joinMember(result.toString(), false);
        }
      });
    }
  }

  // 추천하기
  Future <void> _appRecommend() async {
    String subject = "";
    String text = "⌜모두의모임⌟에서 당신을 초대합니다."
        "\n비지니스 모임. 상부상조."
        "\n서로에게 도움이되는 모임을 만들어 보세요."
        "\n모모는 비지니스 모임을 위한 다양한 서비스를 제공합니다."
        "\n\n다운로드:"
        "\nmomo.maxidc.net";
        //"\n\nplay.google.com/store/apps/details?id=com.smdt.moims";
    await shareInfo(subject: subject, text: text, imagePaths:[]);
  }
}
