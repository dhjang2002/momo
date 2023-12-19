// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Constants/Constants.dart';
import 'package:momo/Controller/ColtrollerStatusChange.dart';
import 'package:momo/Models/ShopEvent.dart';
import 'package:momo/Models/ShopVisit.dart';
import 'package:momo/Models/Shops.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Shops/MyShopPage.dart';
import 'package:momo/Shops/ShopListEventPage.dart';
import 'package:momo/Shops/ShopListVisitPage.dart';
import 'package:momo/Utils/utils.dart';
import 'package:momo/Webview/WebBrowser.dart';
import 'package:momo/Webview/WebExplorer.dart';
import 'package:momo/delegate/persistent_header_delegate.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';
import 'package:transition/transition.dart';

class MyShopsTab extends StatefulWidget {
  final String users_id;
  final Shops  shops;
  const MyShopsTab({
    Key? key,
    required this.users_id,
    required this.shops,
  }) : super(key: key);

  @override
  _MyShopsTabState createState() => _MyShopsTabState();
}

class _MyShopsTabState extends State<MyShopsTab>
    with SingleTickerProviderStateMixin {
  final int TAB_COUNT = 4;
  final _pageNotifier = ValueNotifier<int>(0);
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final PageController _pageController = PageController(
    initialPage: 0,
  );

  bool _bDirty = false;
  int _currTabIndex = 0;

  late TabController _tabController;
  late final ControllerStatusChange _statusShop;
  late final ControllerStatusChange _statusEvent;
  late final ControllerStatusChange _statusVisit;
  late final ControllerStatusChange _statusInfo;

  List<String> shop_photoList = <String>[];

  String title = "";
  String url = "";

  bool _bReady = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: TAB_COUNT, vsync: this);
    _statusShop = ControllerStatusChange();
    _statusEvent = ControllerStatusChange();
    _statusVisit = ControllerStatusChange();
    _statusInfo = ControllerStatusChange();

    _tabController.addListener(() {
      setState(() {
        _currTabIndex = _tabController.index;
        _tabController.animateTo(_currTabIndex);
      });
      print("Selected Index: " + _tabController.index.toString());
    });

    String shop_photos = widget.shops.shop_thumnails!.replaceAll("_thum", "");
    shop_photoList = shop_photos.split(";");

    setState(() {
      _bReady = true;
      title = widget.shops.shop_name!;
      print("Init Selected Index: " + _tabController.index.toString());
      _tabController.animateTo(_currTabIndex);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _statusShop.dispose();
    _statusEvent.dispose();
    _statusVisit.dispose();
    _statusInfo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
            key: _key,
            floatingActionButton: Visibility(
              visible: (_currTabIndex == 1),
              child: FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () {
                  _addCoupon();
                },
              ),
            ),
            backgroundColor: Colors.white,
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxisScrolled) {
                return <Widget>
                [
                  _renderSliverAppBar(),
                  SliverPersistentHeader(
                      delegate: SliverPersistentHeaderDelegateImpl(
                          tabBar: TabBar(
                            labelColor: Colors.black,
                            indicatorColor: Colors.black,
                            controller: _tabController,
                            // unselectedLabelColor: Colors.black,
                            //isScrollable: true,
                            onTap: (int index) {
                              setState(() {
                                _currTabIndex = index;
                              });
                            },

                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: const <Tab>[
                              Tab(text: "사업장"),
                              Tab(text: "쿠폰발행"),
                              Tab(text: "쿠폰사용"),
                              Tab(text: "방문기록"),
                            ],
                          ))),
                ];
              },
              body: _tabBarView(),
            ))
    );
  }

  Widget _renderSliverAppBar() {
    final double expandedHeight = MediaQuery.of(context).size.height*.35;
    return SliverAppBar(
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.black),
      expandedHeight: expandedHeight,
      pinned: true,
      floating: true,
      flexibleSpace: FlexibleSpaceBar(
        background: _corverImage(),
      ),

      title: Text(title, style: const TextStyle(color: Colors.black),),
      leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppBar_Icon,
          ),
          onPressed: () {
            Navigator.pop(context, _bDirty);
          }),
      automaticallyImplyLeading: true,
      actions: [
        Visibility(
          visible: false, //(!bSearch) ? true : false,
          child: IconButton(icon: const Icon(Icons.approval), onPressed: () {}),
        ),
        Visibility(
          visible: false,
          child: IconButton(
              icon: const Icon(Icons.more_vert), // dehaze_rounded),
              onPressed: () {}),
        ),
      ],
    );
  }

  Widget _tabBarView() {
    if (_bReady) {
      return TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          MyShopPage(
            controller: _statusShop,
            users_id: widget.users_id,
            shops_id: widget.shops.id.toString(),
            onUpdate: (Shops shop) {
              setState(() {
                _bDirty = true;
                String shop_photos = shop.shop_thumnails!.replaceAll("_thum", "");
                shop_photoList = shop_photos.split(";");
              });
            },
            onDelete: () {
              _bDirty = true;
              Navigator.pop(context, _bDirty);
            },
          ),
          ShopListEventPage(
            controller: _statusEvent,
            targetId: widget.shops.id.toString(),
            target: 'Shop',
            tailing: const Icon(
              Icons.close,
              color: Colors.red,
            ),
            onTap: (ShopEvent info) {
              // show Event
              if (info.event_url!.isNotEmpty) {
                String url = URL_HOME + info.event_url.toString();
                Navigator.push(
                  context,
                  Transition(
                      child: WebExplorer(title: '쿠폰보기', website: url),
                      transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
                );
              }
            },
            onDetail: (ShopEvent info) {
              // delete Event
              //print(">>> call::onDetail()");
              _doDelete(info);
            },
          ),
          ShopListVisitPage(
            controller: _statusVisit,
            targetId: widget.shops.id.toString(),
            target: 'Shop',
            onTap: (ShopVisit info) {},
            onDetail: (ShopVisit info) {},
          ),
          ShopListVisitPage(
            controller: _statusVisit,
            targetId: widget.shops.id.toString(),
            target: 'Shop',
            onTap: (ShopVisit info) {},
            onDetail: (ShopVisit info) {},
          ),
        ],
      );
    }
    return Container();
  }

  Widget _corverImage() {
    return SizedBox(
        height: 200,
        child: Stack(
          children: [
            SizedBox(
                child: PageView.builder(
                    //key: GlobalKey(),
                    scrollDirection: Axis.horizontal,
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _pageNotifier.value = index;
                      });
                    },
                    itemCount: shop_photoList.length,
                    itemBuilder: (BuildContext context, int index) {
                      String url =
                          URL_HOME + shop_photoList.elementAt(index);
                      return SizedBox(child: simpleBlurImage(url, 1.0));
                    })),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.only(bottom: 5),
                child: CirclePageIndicator(
                  itemCount: shop_photoList.length,
                  dotColor: Colors.black,
                  selectedDotColor: Colors.white,
                  size: 5,
                  currentPageNotifier: _pageNotifier,
                ),
              ),
            ),
          ],
        ));
  }

  Future <void> _addCoupon() async {
    var result = await Navigator.push(
      context,
      Transition(
          child: WebExplorer(
              title: '쿠폰발행',
              website:
                  "$URL_HOME/coupon/?mode=template&shops_id=${widget.shops.id}&mb_no=${widget.users_id}"),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    if (result != null) {
      if (result = true) {
        setState(() {
          _statusEvent.Invalidate();
        });
      }
    }
  }

  Future <void> _doDelete(ShopEvent info) async {
    //print("onDetail() id=${info.id}");
    await Remote.reqEvents(
        params: {
          "command": "DELETE",
          "id": "${info.id}",
        },
        onResponse: (bool result) {
          Future.microtask(() async {
            print(">>> call::_statusEvent.Invalidate()");
            _statusEvent.Invalidate();
          });
        });
  }

  // backKey event 처리
  Future<bool> onWillPop() async {
    Navigator.pop(context, _bDirty);
    return true; // true will exit the app
  }
}
