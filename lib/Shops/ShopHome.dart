// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'dart:async';

import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:momo/Layouts/TileCard.dart';
import 'package:momo/Models/Moims.dart';
import 'package:momo/Models/Person.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Models/ShopItems.dart';
import 'package:momo/Models/Shops.dart';
import 'package:momo/Shops/SalesRegist.dart';
import 'package:momo/Shops/ShopEdit.dart';
import 'package:momo/Shops/ShopItemEdit.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Shops/ShopVisitHome.dart';
import 'package:momo/Utils/Launcher.dart';
import 'package:momo/Utils/utils.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';
import 'ShopItemRegist.dart';

class ShopHome extends StatefulWidget {
  final bool isEditMode;
  final String shops_id;
  const ShopHome({
    Key? key,
    required this.shops_id,
    required this.isEditMode,
  }) : super(key: key);

  @override
  _ShopHomeState createState() => _ShopHomeState();
}

class _ShopHomeState extends State<ShopHome> {
  final GlobalKey<FabCircularMenuState> _fabKey = GlobalKey();
  final PageController _pageController = PageController(initialPage: 0,);
  final _valueNotifier = ValueNotifier<int>(0);

  String title = "";

  late Shops shop;
  bool sLoaded = false;
  bool isOwner = false;

  bool   _bPerson = false;
  Person _person = Person();

  List<ShopItems> items = <ShopItems>[];
  bool iLoaded = false;

  List<String> shop_photoList = <String>[];

  late CameraPosition   _kGooglePlex;
  late LatLng _kMapCenter;
  late Set <Marker> kMarker;

  @override
  void initState() {
    super.initState();
    //final loginInfo = Provider.of<LoginInfo>(context, listen:false);
    //loginInfo.users_id.toString();
    Future.microtask(() {
      _loadShopInfo();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  late BuildContext btx;
  @override
  Widget build(BuildContext context) {
    btx = context;
    // if (!sLoaded) {
    //   return const Center(child: const CircularProgressIndicator(),);
    // }
    return WillPopScope(
        onWillPop: onWillPop,
        child:Scaffold(
          backgroundColor: Colors.white,
            floatingActionButton: _renderFabCircularButton(),
            body: (!sLoaded)
                ? Center(child: const CircularProgressIndicator())
                : CustomScrollView(
                  slivers: [
                    _renderSliverAppBar(),
                    _renderSliverList()
                  ],
                ),
        )
    );
  }

  Widget _renderSliverAppBar() {
    final double expandedHeight = (MediaQuery.of(context).size.height*.4<400) ? MediaQuery.of(context).size.height*.4: 400;
    return SliverAppBar(
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.black),
      expandedHeight: expandedHeight,
      pinned: true,
      floating: false,
      flexibleSpace: FlexibleSpaceBar(
        background: _corverImage(),
      ),
      leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          }),
      title: Text(title, style: const TextStyle(color: Colors.black),),
      automaticallyImplyLeading: true,
    );
  }

  Widget _renderSliverList(){
    return SliverList(
        delegate: SliverChildListDelegate(
        [
          _ownerInfo(),
          const SizedBox(height: 35),
          _buildContact(),
          const SizedBox(height: 35),
          _buildShopInfo(),
          const SizedBox(height: 35),
          _buildMap(),
          const SizedBox(height: 35),
          Visibility(
              visible: items.isNotEmpty,
              child: _buildShopItems()
          ),
          const SizedBox(height: 25),
          Visibility(
            visible: shop_photoList.isNotEmpty,
            child: Container(
              padding: const EdgeInsets.only(left:20),
              child: const Text("사업장사진", style: const TextStyle(fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)))
          ),
          _buildShopPhotos(),
          _buildEditAction(),
          const SizedBox(height: 50,)
        ])
    );
  }

  Widget _ownerInfo() {
    if(!_bPerson || _person.mb_no!.isEmpty) {
      return Container();
    }

    String url = "";
    if(_person.mb_thumnail!.length>3) {
      url = URL_HOME + _person.mb_thumnail.toString();
    }

    String name = _person.mb_name.toString();

    return Container(
      color: Colors.white,
        padding: const EdgeInsets.fromLTRB(15,10,10,5),
        child:Row(
          children: [
            SizedBox(
                height: 34, width: 34,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(100.0),
                    child: simpleBlurImageWithName(name, 28, url, 1.0))),
            const SizedBox(width: 10),
            Text(name.toString(),
              maxLines: 1,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0),
            ),
            const Text(" 회원님",
              maxLines: 1,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 14.0),
            ),
          ])
    );
  }

  Widget _renderFabCircularButton(){
    //final primaryColor = Theme.of(context).primaryColor;
    return FabCircularMenu(
     key: _fabKey,
      alignment: Alignment.bottomRight,
      ringColor: Colors.grey.withAlpha(15),
      ringDiameter: 500.0,
      ringWidth: 150.0,
      fabSize: 56.0,
      fabElevation: 8.0,
      fabIconBorder: const CircleBorder(),
      // Also can use specific color based on wether
      // the menu is open or not:
      // fabOpenColor: Colors.white
      // fabCloseColor: Colors.white
      // These properties take precedence over fabColor
      fabColor: Colors.green,
      fabOpenIcon: const Icon(Icons.arrow_drop_up, color: Colors.white, size: 32,),
      fabCloseIcon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 32),
      fabMargin: const EdgeInsets.all(16.0),
      animationDuration: const Duration(milliseconds: 600),
      animationCurve: Curves.easeInOutCirc,
      onDisplayChange: (isOpen) {
        //_showSnackBar(context, "The menu is ${isOpen ? "open" : "closed"}");
      },
      children: <Widget>[
        // 전화걸기
        RawMaterialButton(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(8.0),
          //child: const Icon(Icons.call, color: Colors.white, size:24),
          child: Image.asset("assets/icon/shop_ring_call.png", width: 44, height: 44, color: Colors.white),
          fillColor:Colors.redAccent,

          onPressed: () {
            _fabKey.currentState!.close();
            callPhone(shop.shop_tel.toString());
          },
        ),

        // 길안내
        RawMaterialButton(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(8.0),
          fillColor:Colors.redAccent,
          child: Image.asset("assets/icon/shop_ring_nav.png", width: 44, height: 44, color: Colors.white),
          onPressed: () {
            _fabKey.currentState!.close();
            doNavi();
          },
        ),

        // 방문확인
        RawMaterialButton(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(8.0),
          fillColor:Colors.green,
          child: Image.asset("assets/icon/shop_ring_coupon.png", width: 44, height: 44, color: Colors.white),
          onPressed: () {
            _fabKey.currentState!.close();
            _onVisit();
          },
        ),

        // 협업기록.
        RawMaterialButton(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(8.0),
          fillColor:Colors.green,
          child: Image.asset("assets/icon/shop_ring_write.png", width: 44, height: 44, color: Colors.white),
          onPressed: () {
            _fabKey.currentState!.close();
            _addSales();
          },
        ),
      ],
    );
  }

  Widget _buildContact() {
    return Container(
      padding: const EdgeInsets.only(left:20, right:20),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child:OutlinedButton(
              child: Container(
                  padding: const EdgeInsets.only(top:10, bottom: 10),
                child:Row(
                  children: [
                    const Spacer(),
                    Image.asset("assets/icon/icon_map.png", width: 30, height: 30),
                    const SizedBox(width: 3),
                    const Text("길안내",
                        style: const TextStyle(color:Colors.black, fontSize: 11, fontWeight:FontWeight.bold)),
                    const Spacer(),
              ])),
              onPressed: () {
                doNavi();
              },
            )),

            Expanded(
                child:OutlinedButton(
              child: Container(
                  padding: const EdgeInsets.only(top:10, bottom: 10),
                child:Row(
                  children: [
                    const Spacer(),
                    Image.asset("assets/icon/icon_phone.png", width: 30, height: 30),
                    const SizedBox(width: 3),
                    const Text("통 화",
                        style: const TextStyle(color:Colors.black, fontSize: 11, fontWeight:FontWeight.bold)),
                    const Spacer(),
                  ])),
              onPressed: () {
                callPhone(shop.shop_tel.toString());
              },
            )),

            Expanded(child:OutlinedButton(
              child: Container(
                padding: const EdgeInsets.only(top:10, bottom: 10),
                child:Row(
                  children: [
                    const Spacer(),
                    Image.asset("assets/icon/icon_home.png", width: 30, height: 30),
                    const SizedBox(width: 3),
                    const Text("홈페이지",
                        style: const TextStyle(color:Colors.black, fontSize: 11, fontWeight:FontWeight.bold)),
                    const Spacer(),
                  ])),
              onPressed: () {
                if(shop.shop_url!.isNotEmpty) {
                  showUrl(shop.shop_url.toString());
                }
              },
            )),
          ]),
    );
  }

  Widget _corverImage() {
    return SizedBox(
        child: Stack(
          children: [
            SizedBox(
                child: PageView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _valueNotifier.value = index;
                      });
                    },
                    itemCount: shop_photoList.length,
                    itemBuilder: (BuildContext context, int index) {
                      String url = URL_HOME + shop_photoList.elementAt(index);
                      return SizedBox(child: simpleBlurImage(url, 1.0));
                    })),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.only(bottom: 15),
                child: CirclePageIndicator(
                  itemCount: shop_photoList.length,
                  dotColor: Colors.black,
                  selectedDotColor: Colors.white,
                  size: 5,
                  currentPageNotifier: _valueNotifier,
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildMap() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                "사업장위치",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _showGoogleMap()
        ],
      ),
    );
    //_showGoogleMap(),
  }

  Widget _buildShopInfo() {
    if(!sLoaded){
      return const Center(child: CircularProgressIndicator(),);
    }

    String addr = shop.shop_addr.toString();
    if (shop.shop_addr_ext!.isNotEmpty) addr = addr + ", ${shop.shop_addr_ext}";

    String tag = "";
    if (shop.shop_tag!.isNotEmpty) {
      List<String> tagData = shop.shop_tag.toString().split(";");
      for (var element in tagData) {
        if (element.isNotEmpty) {
          if (tag.isNotEmpty) {
            tag += ", #$element";
          } else {
            tag += "#$element";
          }
        }
      }
    }
    
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              //const Spacer(),
              const Text(
                "사업장 정보",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Visibility(
                visible: widget.isEditMode,
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: const Color(0xffc2c2c2),
                  ),
                  child: const Text(
                    '정보수정',
                    style: const TextStyle(fontSize: 15),
                  ),
                  onPressed: () async {
                    _modifyShop();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            //mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoItem(const Icon(Icons.home_work_outlined, size: 24,color: Colors.grey,), shop.shop_name.toString()),
              _infoItem(const Icon(Icons.phone, size: 24,color: Colors.grey,), shop.shop_tel.toString()),
              _infoItem(const Icon(Icons.description_outlined, size: 24,color: Colors.grey,), shop.shop_desc.toString()),
              _infoItem(const Icon(Icons.home, size: 24,color: Colors.grey,), shop.shop_url.toString()),
              _infoItem(const Icon(Icons.star_border, size: 24,color: Colors.grey,), tag),
              _infoItem(const Icon(Icons.location_on, size: 24,color: Colors.grey,), addr),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShopPhotos() {
    return Visibility(
        visible: shop_photoList.isNotEmpty,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.builder(
            padding: const EdgeInsets.only(top:10),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: shop_photoList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              String url = URL_HOME+shop_photoList[index];
              return SizedBox(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: simpleBlurImage(url, 1.0)
                  ));
            },
          ),
        ));
  }

  Widget _infoItem(Widget icon, String value) {
    return TileCard(
          padding: const EdgeInsets.fromLTRB(0, 15, 15, 0),
          leading: icon,
          title: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, maxLines: 32,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 17.0),
                  ),
                ],
              )
          ),
        );
  }

  Widget _buildShopItems() {
    return Column(
      children: [
        const SizedBox(height: 30,),
        Row(
          children: [
            const SizedBox(width: 20),
            const Text(
              "상품정보",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const Spacer(),
            Visibility(
              visible: widget.isEditMode,
              child: TextButton(
                style: TextButton.styleFrom(
                  primary: const Color(0xffc2c2c2),
                ),
                child: const Text(
                  '상품추가',
                  style: const TextStyle(fontSize: 15),
                ),
                onPressed: () async {
                  _addItem();
                },
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(1),
          child: GridView.builder(
            padding: const EdgeInsets.only(left:10, right: 10),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemBuilder: (context, index) {
              return _itemCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _itemCard(int index) {
    ShopItems info = items.elementAt(index);
    String url = URL_HOME + info.item_thumnails!.split(";").elementAt(0);
    url = url.replaceFirst("_thum", "");
    String price = currencyFormat(info.item_price.toString());
    String title = "${info.item_name.toString()} / $price원";
    return GestureDetector(
        onTap: () {
          _onItemTap(info);
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          //color: Colors.grey[50],
          child: Column(
            children: [
              SizedBox(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: simpleBlurImage(url, 1.0))
              ),
              const SizedBox(height: 7),
              Container(
                alignment: Alignment.center,
                child: Text(title, maxLines: 1,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 2),
              Expanded(child: Text(
                  info.item_desc.toString(),
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildEditAction() {
    return Visibility(
      visible: widget.isEditMode,
      child:Container(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
        child: Center(
          child: ElevatedButton(
            child: const Text("삭제하기",
                style: TextStyle(
                    fontSize: 16.0, color: Colors.white)),
            style: ElevatedButton.styleFrom(
                primary: Colors.red,
                fixedSize: const Size(300, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50))),
            onPressed: () {
              _deleteShop();
            },
          ),
        ),
      )
    );
  }

  Future <void> _loadPhotos() async {
    String shop_photos = shop.shop_thumnails!.replaceAll("_thum", "");
    shop_photoList = shop_photos.split(";");
  }

  Future <void> _loadItems() async {
    iLoaded = false;
    Remote.getShopItems(
        params: {"command": "LIST", "shops_id": widget.shops_id},
        onResponse: (List<ShopItems> list) {
          setState(() {
            iLoaded = true;
            items = list;
          });
        });
  }

  Future <void> _addItem() async {
    var rtn = await Navigator.push(
      context,
      Transition(
          child: ShopItemRegist(shop_id: shop.id.toString()),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    if (rtn != null) {
      _loadItems();
    }
  }

  Future <void> _modifyItem(String items_id) async {
    var result = await Navigator.push(
      context,
      Transition(
          child: ShopItemEdit(items_id: items_id),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    if (result != null) {
      _loadItems();
    }
  }

  void _onItemTap(ShopItems info) {
    if (widget.isEditMode) {
      _modifyItem(info.id.toString());
    }
  }

  Future <void> _modifyShop() async {
    var result = await Navigator.push(
      context,
      Transition(
          child: ShopEdit(shop_id: shop.id.toString()),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    if (result != null) {
      _loadShopInfo();
    }
  }

  void _deleteShop() {
    print("_deleteShop():------------>");

    showDialogPop(
        context: context,
        title: "삭제",
        body: const Text(
          "작업을 진행 하시겠습니까?",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          "사업장을 삭제합니다. 삭제된 정보는 복구할 수 없습니다.",
          style: const TextStyle(
              fontWeight: FontWeight.normal, fontSize: 16, color: Colors.red),
        ),
        choiceCount: 2,
        yesText: "예",
        cancelText: "아니오",
        onResult: (bool isOK) async {
          if (isOK) {
            _onDelete();
          }
        });
  }

  void _addSales() {
    Navigator.push(
      context,
      Transition(
          child: SalesRegist(shops_id: shop.id.toString(), owner_id: shop.users_id.toString(),),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
  }

  Future <void> _onDelete() async {
    await Remote.reqShops(
        params: {
          "command": "DELETE",
          "id": "${shop.id}",
        },
        onResponse: (bool result) {
          Navigator.pop(context, true);
        });
  }

  Set <Marker> _createMarker(String title) {
    return <Marker>{
      Marker(
        markerId: const MarkerId("marker_1"),
        position: _kMapCenter,
        //icon: Icon(Icons.location_on),
        infoWindow: InfoWindow(
          title: title,
        ),
      ),
    };
  }

  void _setMapInfo() {
    double lat = double.parse(shop.shop_addr_gps_latitude.toString());
    double lon = double.parse(shop.shop_addr_gps_longitude.toString());

    _kMapCenter  = LatLng(lat, lon);
    _kGooglePlex = CameraPosition(target: LatLng(lat, lon), zoom: 14.4746,);

    print("_showGoogleMap()---------------->");
    print("_kMapCenter: ${_kMapCenter.toString()}");
    print("_kGooglePlex: ${_kGooglePlex.toString()}");
    kMarker = _createMarker(shop.shop_name.toString());
  }

  Widget _showGoogleMap() {
    final double map_height = (MediaQuery.of(context).size.width*.55>200) ? MediaQuery.of(context).size.width*.55: 200;
    return Container(
      padding: const EdgeInsets.fromLTRB(2,0,2,0),
      child: SizedBox(
        height: map_height,
        child: GoogleMap(
          //mapType: MapType.normal,
          markers: kMarker,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            print("onMapCreated() .........................");
            //_controller.complete(controller);
          },
        ),
      ),
    );
  }


  Future <void> _loadShopInfo() async {
    sLoaded = false;
    Remote.getShops(
        params: {"command": "INFO", "id": widget.shops_id},
        onResponse: (List<Shops> list) {
          setState(() {
            sLoaded = true;
            shop = list.elementAt(0);
            title = shop.shop_name!;
            _setMapInfo();
            _loadPerson(shop.users_id.toString());
            _loadItems();
            _loadPhotos();
          });
        });
  }

  Future <void> _loadPerson(String usersId) async {
    _bPerson = false;
    Remote.getPerson(
        params: {"command": "INFO", "mb_no": usersId},
        onResponse: (bool status, Person person) async {
          if (status) {
            setState(() {
              _person = person;
              _bPerson = true;
            });
          }
        });
  }

  Future <void> _onVisit() async {
    // 1. 같이 활동하는 모임찾기
    var loginInfo = Provider.of<LoginInfo>(context, listen:false);
    await Remote.getMoims(
        params: {
          "command": "LIST",
          "list_attr": "Visit",
          "users_id": loginInfo.users_id.toString(),
          "shop_id": widget.shops_id
        },
        onResponse: (List<Moims> list) {
            String targetMoims = "";
            for (var element in list) {
              String name = element.moim_name!;
              if (targetMoims.isNotEmpty) {
                targetMoims += ";";
              }
              targetMoims += name;
            }
            _addVisit(loginInfo.users_id.toString(), widget.shops_id, targetMoims);
        });
  }

  Future <void> _addVisit(String users_id, String shops_id, String targetMoims) async {
    await Navigator.push(context,
      Transition(
          child: ShopVisitHome(
            users_id: users_id,
            shops_id: shops_id,
            moims: targetMoims,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
  }

  // backKey event 처리
  Future <bool> onWillPop() async {
    if(_fabKey.currentState!.isOpen) {
      _fabKey.currentState!.close();
      return false;
    }
    return true;
  }

  Future<void> doNavi() async {

    // callKakaoNavi(shop.shop_name.toString(),
    //     shop.shop_addr_gps_latitude.toString(),
    //     shop.shop_addr_gps_longitude.toString());

    showDialogMenu(
        context:context,
        items: ["카카오내비", "TMAP", "길안내 취소"],
        onResult:(int index, String item) async {
          String target = "";
          switch(index) {
            case 0:
              target = "kakao";
              break;

            case 1:
              target = "tmap";
              break;
            case 2:
              break;
          }

          if(target.isNotEmpty) {
            Future.microtask(() {
              callNaviSelect(target, shop.shop_name.toString(),
                  shop.shop_addr_gps_latitude.toString(),
                  shop.shop_addr_gps_longitude.toString());
            });
          }
        }
    );
  }
}
