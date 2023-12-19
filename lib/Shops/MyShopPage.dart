// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:momo/Controller/ColtrollerStatusChange.dart';
import 'package:momo/Layouts/TileCard.dart';
import 'package:momo/Models/ShopItems.dart';
import 'package:momo/Models/Shops.dart';
import 'package:momo/Provider/GpsProvider.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Shops/ShopEdit.dart';
import 'package:momo/Shops/ShopItemEdit.dart';
import 'package:momo/Shops/ShopItemRegist.dart';
import 'package:momo/Utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class MyShopPage extends StatefulWidget {
  final String users_id;
  final String shops_id;
  final Function(Shops shop) onUpdate;
  final Function() onDelete;
  ControllerStatusChange? controller;

  MyShopPage({
    Key? key,
    required this.shops_id,
    required this.users_id,
    required this.onUpdate,
    required this.onDelete,
    this.controller,
  }) : super(key: key);

  @override
  _MyShopPageState createState() => _MyShopPageState();
}

class _MyShopPageState extends State<MyShopPage> with AutomaticKeepAliveClientMixin {
  final PageController pageController = PageController(initialPage: 0,);
  final currentPageNotifier = ValueNotifier<int>(0);

  final Completer<GoogleMapController> _mapController = Completer();

  late Shops shop;
  bool sLoaded = false;
  bool isOwner = false;

  List<ShopItems> items = <ShopItems>[];
  bool iLoaded = false;

  List<String> shop_photoList = <String>[];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _loadShopInfo(false);

    if (widget.controller != null) {
      widget.controller!.addListener(() {
        _loadShopInfo(false);
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final gps_status = Provider.of<GpsProvider>(context, listen:true);
    // if(sLoaded && gps_status.bWait) {
    //   return const Center(child: const CircularProgressIndicator());
    // }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20,),
          _buildShopInfo(),
          Row(
            children: [
              const Spacer(),
              Visibility(
                visible: true,
                child: TextButton.icon(icon: Image.asset("assets/icon/icon_map_pin.png", width: 22, height: 22, color:const Color(0xffc2c2c2)),
                  label: const Text("현재위치", style: const TextStyle(color:const Color(0xffc2c2c2), fontSize: 16, fontWeight:FontWeight.bold)),
                  onPressed: () async {
                    _setCurrentLocation();
                  },
                )
              ),
              const SizedBox(width: 20)
            ],
          ),
          _buildGoogleMap(),
          const SizedBox(height: 25),
          _buildShopItems(),
          _buildEditAction(),
        ],
      ),
    );
  }

  Widget _buildShopInfo() {
    if(!sLoaded){
      return const Center(child: const CircularProgressIndicator(),);
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
      padding: const EdgeInsets.fromLTRB(10,0,10,0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 10,),
              const Text(
                "사업장정보",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const Spacer(),
              Visibility(
                visible: true,
                child: TextButton.icon(icon: Image.asset("assets/icon/icon_write.png", width: 22, height: 22),
                  label: const Text("정보수정", style: TextStyle(color:Color(0xffc2c2c2), fontSize: 16, fontWeight:FontWeight.bold)),
                  onPressed: () async {
                    _modifyShop();
                  },
                )),
            ],
          ),
          //const SizedBox(height: 5),
          Column(
            children: [
              _infoItem(const Icon(Icons.home_work_outlined, size: 21,color: Colors.grey,), shop.shop_name.toString()),
              _infoItem(const Icon(Icons.phone, size: 22,color: Colors.grey,), shop.shop_tel.toString()),
              _infoItem(const Icon(Icons.description_outlined, size: 22,color: Colors.grey,), shop.shop_desc.toString()),
              _infoItem(const Icon(Icons.home, size: 22,color: Colors.grey,), shop.shop_url.toString()),
              _infoItem(const Icon(Icons.star_border, size: 22,color: Colors.grey,), tag),
              _infoItem(const Icon(Icons.location_on, size: 22,color: Colors.grey,), addr),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
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
    return Container(
      padding: const EdgeInsets.fromLTRB(15,5,15,5),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "상품정보",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const Spacer(),
              Visibility(
                  visible: true,
                  child: TextButton.icon(icon: Image.asset("assets/icon/icon_write.png", width: 22, height: 22),
                    label: const Text("상품추가", style: const TextStyle(color:const Color(0xffc2c2c2), fontSize: 16, fontWeight:FontWeight.bold)),
                    onPressed: () async {
                      _addItem();
                    },
                  )),
            ],
          ),

          Visibility(
            visible: items.isNotEmpty,
              child: GridView.builder(
                padding: const EdgeInsets.all(5),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 25,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return _itemCard(index);
                })
          ),
        ],
      ),
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
          child: Column(
            children: [
              SizedBox(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: simpleBlurImage(url, 1.0)
                  )),
              const SizedBox(height: 7),
              Container(
                alignment: Alignment.center,
                child: Text(
                  title,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 3),
              Expanded(
                child: Text(
                  info.item_desc.toString(),
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildEditAction() {
    return Visibility(
        visible: true,
        child:Container(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 70),
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

  Future <void> _loadShopInfo(bool isMaponly) async {
    sLoaded = false;
    Remote.getShops(
        params: {"command": "INFO", "id": widget.shops_id},
        onResponse: (List<Shops> list) {
          setState(() {
            sLoaded = true;
            shop = list.elementAt(0);
            String shop_photos = shop.shop_thumnails!.replaceAll("_thum", "");
            shop_photoList = shop_photos.split(";");
            widget.onUpdate(shop);
            if(!isMaponly) {
              _loadItems();
            }
          });
        });
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
      _modifyItem(info.id.toString());
  }

  Future <void> _modifyShop() async {
    var result = await Navigator.push(
      context,
      Transition(
          child: ShopEdit(shop_id: shop.id.toString()),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    if (result != null) {
      _loadShopInfo(true);
      //widget.onUpdate();
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

  Future <void> _onDelete() async {
    await Remote.reqShops(
        params: {
          "command": "DELETE",
          "id": "${shop.id}",
        },
        onResponse: (bool result) {
          widget.onDelete();
        });
  }

  final List<Marker> _markers = [];

  bool bMapInit = false;
  Widget _buildGoogleMap() {
    if(!sLoaded) {
      return const CircularProgressIndicator();
    }

    double lat = double.parse(shop.shop_addr_gps_latitude.toString());
    double lon = double.parse(shop.shop_addr_gps_longitude.toString());

    CameraPosition _shopPlex = CameraPosition(target: LatLng(lat, lon), zoom: 14.4746,);

    _markers.clear();
    _markers.add(Marker(
        markerId: const MarkerId("marker_1"),
        position: LatLng(lat, lon)));

    final double map_height = MediaQuery.of(context).size.width*.7;
    return Container(
      padding: const EdgeInsets.fromLTRB(5,0,5,0),
      child: SizedBox(
        height: map_height,
        child: GoogleMap(
          //key: GlobalKey(),
          mapType: MapType.normal,
          markers: Set.from(_markers),
          initialCameraPosition: _shopPlex,
          myLocationButtonEnabled: false,
          onCameraMove:(_position) {
            //_updatePosition(_position, shop.shop_name.toString());
            //showToastMessage("위치정보가 변경되었습니다.");
            //setState(() {});
          },
          onMapCreated: (GoogleMapController controller) {
            if(!bMapInit) {
              bMapInit = true;
              _mapController.complete(controller);
            }
          },
        ),
      ),
    );
  }

  void _setCurrentLocation() {
    showDialogPop(
        context: context,
        title: "위치정보 변경",
        body: const Text("사업장의 위치 정보를 수정하시겠습니까?",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text("\nGPS좌표를 현재 위치로 보정합니다."
            "\n(지도상에 사업장의 위치가 다르게 표시될 경우에만 적용 하십시오.)",
          style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: Colors.grey),
        ),
        choiceCount: 2,
        yesText: "예",
        cancelText: "아니오",
        onResult: (bool isOK) async {
          var gps = Provider.of<GpsProvider>(context, listen:false);
          gps.updateGeolocator(true).then((value) {
            _doUpdateShopGps(gps.latitude(), gps.longitude());
          });
        });
  }

  Future <void> _doUpdateShopGps(double lat, double lon) async {
    CameraPosition targetLocation = CameraPosition(
        target: LatLng(lat, lon),
        zoom: 14.4746);

    await Remote.reqShops(
        params: {
          "command":"UPDATE",
          "id":shop.id.toString(),
          "shop_addr_gps_latitude":lat.toString(),
          "shop_addr_gps_longitude":lon.toString(),
        },
        onResponse: (bool result) async {
          if(result){
            _loadShopInfo(true);
            //widget.onUpdate();
            //*
            //await _loadShopInfo(true);
            GoogleMapController controller = await _mapController.future;
            controller.animateCamera(CameraUpdate.newCameraPosition(targetLocation));
            //controller.moveCamera(CameraUpdate.newCameraPosition(targetLocation));
            //showToastMessage("위치정보가 변경되었습니다.");
            // */
          }
        });
  }
}
