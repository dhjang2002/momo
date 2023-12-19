// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Controller/ColtrollerStatusChange.dart';
import 'package:momo/Layouts/TileCard.dart';
import 'package:momo/Models/Shops.dart';
import 'package:momo/Provider/GpsProvider.dart';
import 'package:momo/Shops/ShopsMapView.dart';
import 'package:momo/Shops/ShopsChche.dart';
import 'package:momo/Utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class ShopListPage extends StatefulWidget {
  final bool   isDistOrder;
  final String target; // "Owner", "Member", "Moims"
  final String targetId;
  final Function(Shops moim) onTap;
  Widget? tailing;
  Function(Shops moim)? onDetail;
  ControllerStatusChange? controller;
  String? keyword;
  String? tag;
  String? filter;

  ShopListPage({
    Key? key,
    required this.isDistOrder,
    required this.target,
    required this.targetId,
    required this.onTap,
    this.tailing,
    this.onDetail,
    this.controller,
    this.keyword = "",
    this.tag = "",
    this.filter = "",
  }) : super(key: key);

  @override
  _ShopListPageState createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage> with AutomaticKeepAliveClientMixin {
  bool _ready = false;

  late GpsProvider _gpsProvider;
  final ShopsCache _shopsCache = ShopsCache();

  @override
  void initState() {

    Future.microtask(() async {
      _gpsProvider = Provider.of<GpsProvider>(context, listen: false);
      _shopsCache.setTarget(
          targetTag: widget.target.toString(), targetId: widget.targetId);
      _shopsCache.clear(false);
      if(widget.isDistOrder) {
        _gpsProvider.updateGeolocator(false);
        _shopsCache.setLocation(
            latitude: _gpsProvider.latitude().toString(),
            longitude: _gpsProvider.longitude().toString(),
            limit_dist: "800000");
      }
      _ready = true;
      _shopsCache.fetchItems(
          isDistOrder:widget.isDistOrder,
          nextId: 0,
          Invalidate: () {
            setState(() {});
          });
    });

    if (widget.controller != null) {
      widget.controller!.addListener(() async {

        print("ShopListPage::addListener(): action=${widget.controller!.action}");

        switch (widget.controller!.action) {
          case ControllerStatusChange.aFrontView:
            break;

          case ControllerStatusChange.aBackView:
            break;

          case ControllerStatusChange.aInvalidate:
            {
              _shopsCache.setTarget(
                  targetTag: widget.target.toString(),
                  targetId: widget.targetId);
              _shopsCache.clear(false);
              if(widget.isDistOrder) {
                _gpsProvider.updateGeolocator(false);
                _shopsCache.setLocation(
                    latitude: _gpsProvider.latitude().toString(),
                    longitude: _gpsProvider.longitude().toString(),
                    limit_dist: "800000"); // 800km
              }
              _shopsCache.fetchItems(isDistOrder:widget.isDistOrder, nextId: 0, Invalidate: () {
                    setState(() {});
                  });
              break;
            }

          case ControllerStatusChange.aSearch:
              break;
        }
      });
    }
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }

  Widget _renderListView() {
    final _gps = Provider.of<GpsProvider>(context, listen: true);

    if (!_ready) {
      return const Center(child: CircularProgressIndicator());
    }

    if ((widget.isDistOrder && _gps.bWait)) {
      print(">>> Location Scanning....");
      return const Center(child: CircularProgressIndicator());
    }

    final cache   = _shopsCache.cache;
    final loading = _shopsCache.loading;
    final hasMore = _shopsCache.hasMore;

    // 로딩중이며 캐시에 데이터 없을때
    if (loading && cache.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 로딩중이 아닌데, 캐시에 아무것도 없음.
    if (!loading && cache.isEmpty) {
      return const Center(child: Text("데이터가 없습니다."));
    }

    print("ShopListPage::_renderListView()");

    return ListView.builder(
        //scrollDirection: Axis.vertical,
        //shrinkWrap: true,
        //physics: const ClampingScrollPhysics(),
        //padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        itemCount: cache.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index < cache.length) {
            return ItemCard(cache[index]);
          }

          if (!loading && hasMore) {
            Future.microtask(() {
              _shopsCache.fetchItems(
                  isDistOrder:widget.isDistOrder,
                  nextId: index,
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
    return Container(color: Colors.white, child: _buildHome());
  }

  Widget _buildHome() {
    return Column(
      children: [
        _buildListCount(),
        Expanded(child: _renderListView()),
      ],
    );
  }

  Widget _buildListCount() {
    String listTitle = (widget.isDistOrder) ? "주변사업장 (${_shopsCache.cache.length})" : "전체사업장 (${_shopsCache.cache.length})";
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15,15,0,10),
        //color: (widget.isListMode) ? Colors.orangeAccent : Colors.green,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(listTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
            Spacer(),
            Visibility(
              visible: widget.isDistOrder,
                child: IconButton(
                  icon: Icon(Icons.location_on, color: Colors.redAccent),
                  onPressed:() {
                    Navigator.push(
                      context,
                      Transition(
                        // targetTag: widget.target.toString(), targetId: widget.targetId
                          child: ShopsMapView(target: widget.target, target_id: widget.targetId),
                          transitionEffect: TransitionEffect.BOTTOM_TO_TOP),
                    );
                  }
                )
            )
          ],
        ));
  }

  Widget ItemCard(Shops info) {
    String title = info.shop_name!;
    List<String> thumnails = info.shop_thumnails.toString().split(";");
    String url = URL_HOME + thumnails.elementAt(0);
    String subTitle = info.shop_desc!;
    String shopArea = getAreaFromAddress(info.shop_addr.toString());
    String distance = "";
    if (info.shop_dist!.isNotEmpty) {
      double dist = double.parse(info.shop_dist!) / 1000;
      distance = "${dist.toStringAsFixed(2)} km";
    }

    return Column(
      children: [
        TileCard(
          key: GlobalKey(),
          padding: const EdgeInsets.fromLTRB(5, 10, 15, 5),
          leading: SizedBox(
              height: 50, width: 50,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: simpleBlurImageWithName(info.shop_name.toString(), 18.0, url,  1.0)
              )
          ),
          title: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                          padding:const EdgeInsets.only(right: 15),
                          child: Text(title, maxLines: 1,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0),
                          ))),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(distance, maxLines: 1,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0),
                        ),

                        Text( shopArea, maxLines: 1,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 11.0),
                        ),
                      ],
                    )
                  ],
                ),
                Text(subTitle, maxLines: 1,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 12.0),
                  ),
              ],
            )
          ),
          tailing: widget.tailing,
          onTab: () => _onTab(info),
          onTrailing: () => _onDetail(info),
        ),
        const Divider(
          height: 12.0,
        ),
      ],
    );
  }

  void _onTab(Shops info) {
    widget.onTap(info);
  }

  void _onDetail(Shops info) {
    if (widget.onDetail != null) {
      widget.onDetail!(info);
    }
  }
}
