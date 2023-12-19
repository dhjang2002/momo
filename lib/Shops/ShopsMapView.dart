// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:momo/Models/Shops.dart';
import 'package:momo/Provider/GpsProvider.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:provider/provider.dart';

class ShopsMapView extends StatefulWidget {
  final String target;
  final String target_id;
  ShopsMapView({
    Key? key,
    required this.target,
    required this.target_id,
  }) : super(key: key);

  @override
  State<ShopsMapView> createState() => ShopsMapViewState();
}

class ShopsMapViewState extends State<ShopsMapView> {
  final Completer<GoogleMapController> _controller = Completer();

  bool _bReady = false;
  bool _loading = false;
  Set <Marker> _markSet = <Marker>{};
  late CameraPosition _locateHome;

  late GpsProvider _gpsProvider;

  @override
  void initState() {
    _gpsProvider = Provider.of<GpsProvider>(context, listen: false);
    _locateHome = CameraPosition(
      target: LatLng(_gpsProvider.latitude(), _gpsProvider.longitude()),
      zoom: 11.4746,
    );
    
    setState(() {
      _bReady = true;
    });

    _loadInfo();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        //backgroundColor: Colors.transparent,
        title: Text("주변 사업장"),
        elevation: 0.3,
        leading: Visibility(
          visible:  true,
          child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black,), // (isPageBegin) ? Icons.close :
              onPressed: () {
                Navigator.pop(context);
              }
          ),
        ),
        actions: [
          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.black),
                onPressed: () async {
                  //await _gpsProvider.updateGeolocator(true);
                  _loadInfo();
                }
            ),
          ),
        ],
      ),
      body: _buildBody(),
      // floatingActionButton: FloatingActionButton(
      //   child: Image.asset("assets/icon/icon_map_pin.png", color: Colors.white, width: 40, height: 40,),
      //   onPressed: _goMyLocate,
      // ),
    );
  }

  Widget _buildBody() {
    if(!_bReady || _loading) {
      return const Center(child: const CircularProgressIndicator());
    }

    final _gpsStatus = Provider.of<GpsProvider>(context, listen: true);
    if(_gpsStatus.bWait) {
       return const Center(child: const CircularProgressIndicator());
    }

    return GoogleMap(
      mapType: MapType.normal,
      mapToolbarEnabled:false,
      myLocationEnabled:true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      initialCameraPosition: _locateHome,
      markers: _markSet,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }

  void buildMark(List<Shops> list) {
    _markSet.clear();
    int index = 0;
    for (var shop in list) {
      String markId = "mark_$index++";
      addMaker(
          markId,
        double.parse(shop.shop_addr_gps_latitude!),
        double.parse(shop.shop_addr_gps_longitude!),
        shop.shop_name!
      );
    }
  }

  void addMaker(String markId, double lat, double lon, String title) {
    _markSet.add(
      Marker(
        markerId: MarkerId(markId),
        position: LatLng(lat, lon),
        infoWindow: InfoWindow(
          title: title,
        ),
      )
    );
  }

  Future <void> _goMyLocate() async {
    _locateHome = CameraPosition(
      target: LatLng(_gpsProvider.latitude(), _gpsProvider.longitude()),
      zoom: 14.4746,
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_locateHome));
  }

  Future <void> _loadInfo() async {
    
    setState(() {
      _loading = true;
    });

    String target_type = "users_id";
    if(widget.target=="Moims") {
      target_type = "moims_id";
    }

    String lat = _gpsProvider.latitude().toString();
    String lon = _gpsProvider.longitude().toString();
    String dist = "1000000";

    Map<String,String> params = {
      "command": "LIST",
      "list_attr":widget.target,
      target_type: widget.target_id,
      "rec_start":"0",
      "rec_count":"50",
      "lon":lon,
      "lat":lat,
      "distance":dist,
      "findKey":"",
      "tag":"",
      "filter":"",
    };

    Remote.getShops(
        params: params,
        onResponse: (List<Shops> list) {
          buildMark(list);
          setState(() {
            _loading = false;
          });
        });
  }
}