// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:momo/Models/MainInfo.dart';
import 'package:momo/Provider/GpsProvider.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Controller/ColtrollerStatusChange.dart';
import 'package:momo/Models/Moims.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/utils.dart';
import 'package:provider/provider.dart';

class MainPageHome extends StatefulWidget {
  final Function(Moims info) onShowMoim;
  final Function(String key) onSearchMoim;
  final Function(String tag) onTagMoim;
  final Function(Moims info) onJoinMoim;
  final Function(Moims info) onJoinable;
  final Function(MainInfo info) onInfo;
  ControllerStatusChange? controller;

  MainPageHome({
    Key? key,
    this.controller,
    required this.onShowMoim,
    required this.onJoinMoim,
    required this.onSearchMoim,
    required this.onTagMoim,
    required this.onInfo,
    required this.onJoinable,
  }) : super(key: key);

  @override
  _MainPageHomeState createState() => _MainPageHomeState();
}

class _MainPageHomeState extends State<MainPageHome>
    with AutomaticKeepAliveClientMixin {

  final PageController _pageController = PageController(initialPage: 0,);

  bool jmLoad = false;
  bool amLoad = false;
  List<Moims> _jMoimList = <Moims>[];
  List<Moims> _aMoimList = <Moims>[];

  String _userPostfix = "로그인 해주세요!";
  String _greetMessage = "";

  bool _bReady = false;
  late LoginInfo _userInfo;

  @override
  void initState() {
    print("<><><><>MainPageHome::initState()");
    _userInfo = Provider.of<LoginInfo>(context, listen: false);
    if (_userInfo.person!.mb_name!.isNotEmpty) {
      _greetMessage = "님, 환영합니다.";
      _userPostfix = "";
      _fetchJoinAbleMoims();
      _fetchJoinedMoims();
      _loadMainInfo();
      setState(() {
        _bReady = true;
      });
    } else {
      _greetMessage = "";
      _userPostfix = "로그인 해주세요!";
    }

    if (widget.controller != null) {
      widget.controller!.addListener(() async {

        print("<><><><>MainPageHome::addListener(): action=${widget.controller!.action}");

        switch (widget.controller!.action) {
          case ControllerStatusChange.aFrontView: {
            break;
          }

          case ControllerStatusChange.aBackView: {
            break;
          }

          case ControllerStatusChange.aChange:{
            _aMoimList.clear();
            _jMoimList.clear();
            setState(() {
              _bReady = true;
              if (_userInfo.person!.mb_name!.isNotEmpty) {
                _greetMessage = "님, 환영합니다.";
                _userPostfix = "함께하는 모임 어떠세요?";
              } else {
                _greetMessage = "";
                _userPostfix = "로그인 해주세요!";
              }
            });

            _fetchJoinAbleMoims();
            _fetchJoinedMoims();
            _loadMainInfo();
            GpsProvider gpsInfo = Provider.of<GpsProvider>(context, listen:false);
            gpsInfo.usersId     = _userInfo.users_id!;
            gpsInfo.updateGeolocator(false);
            reportMyToken();
            setState(() { });
            break;
          }

          case ControllerStatusChange.aInvalidate:{
            _fetchJoinAbleMoims();
            _fetchJoinedMoims();
            _loadMainInfo();
            setState(() { });
            break;
          }
        }
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return BuildBodyWidget();
  }

  Widget BuildBodyWidget() {
    if(!_bReady) {
      return Container(
          color: Colors.white,
          child: Center(
              child: Image.asset(
                "assets/icon/icon_logo1.png", width: 100, height: 100,))
      );
    }

    return Container(
        color:Colors.white,
        child: SingleChildScrollView(
            child: SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  _showWelcome(),

                  const SizedBox(height: 40),
                  _showjMoimInfo(),

                  //const SizedBox(height: 40),
                  //_showJoinable(),

                  const SizedBox(height: 40),
                  Container(
                      padding: const EdgeInsets.only(left: 20, bottom: 5),
                      child: Text("함께하는 모임공간 (${_aMoimList.length})",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                      )
                  ),
                  _showJoined(),
                  const SizedBox(height: 50),
                ],
              ),
            ))
    );
  }

  Widget _showWelcome() {
    return Container(
        margin: const EdgeInsets.only(left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _userInfo.person!.mb_name!,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  _greetMessage,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Text(
              _userPostfix,
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.normal),
            ),
          ],
        ));
  }

  Widget _showjMoimInfo() {

    if(!jmLoad) {
      return Container();
    }

    if(_jMoimList.isEmpty)
    {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.only(bottom: 30),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300,),
            borderRadius: const BorderRadius.all(const Radius.circular(10))
        ),
        child: Center(
            child:SizedBox(width: 160,
                child:Image.asset("assets/icon/icon_empty_jmoim2.png", fit: BoxFit.fitWidth))
        ),
      );
    }

    final double item_width  = MediaQuery.of(context).size.width*.8;
    final double list_height = item_width *.74;

      return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: list_height,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: _jMoimList.length,
                    itemBuilder: (context, index) {
                      return _jMoimCard(_jMoimList[index]);
                    }),
              )
            ],)
      );
  }

  Widget _jMoimCard(Moims info) {
    final double item_width  = MediaQuery.of(context).size.width*.8;
    final double item_height = item_width *.74;
    String url   = URL_HOME + info.moim_thumnails!.split(";").elementAt(0).replaceFirst("_thum", "");

    return GestureDetector(
      onTap:() {
        _onTabJoinable(info);
      },
      child: Container(
        padding: const EdgeInsets.only(left:7, right:7),
        child: Stack(
          children: [
            SizedBox(width: item_width, height: item_height,
                child: ClipRRect(borderRadius: BorderRadius.circular(10.0), child:simpleBlurImage(url, 1.0))
            ),

            Positioned(
              bottom: 1,
              child: Container(
                width: item_width,
                color: Colors.black.withAlpha(50),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(info.moim_name.toString(),
                          maxLines: 1,
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      Text(info.moim_title.toString(),
                          maxLines: 2,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.normal)),
                    ],
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showJoined() {
    if(!amLoad) {
      return Container();
    }

    if(_aMoimList.isEmpty)
    {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        padding: const EdgeInsets.only(bottom: 20, top:20),
        /*
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300,),
            borderRadius: const BorderRadius.all(const Radius.circular(10))
        ),
        */
        child: Center(
            child:SizedBox(width: 160, //height: 150,
              child:Image.asset("assets/icon/icon_empty_amoim.png",fit: BoxFit.fitWidth))
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            padding: const EdgeInsets.all(0),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _aMoimList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
              childAspectRatio: 0.82, //item 의 가로 1, 세로 2 의 비율
              mainAxisSpacing: 10, //수평 Padding
              //crossAxisSpacing: 5
            ),
            itemBuilder: (context, index) {
              return _moimCard(index);
            },
          )
        ],
      ),
    );
  }

  Widget _moimCard(int index) {
    String url = "";
    Moims info = _aMoimList.elementAt(index);
    bool isApprove = (info.member_approve.toString()=="Y");
    String name = info.moim_name.toString();
    String title = info.moim_title.toString();
    if (info.moim_thumnails!.split(";").elementAt(0).length > 1) {
      url = URL_HOME + info.moim_thumnails!.split(";").elementAt(0);
      url = url.replaceFirst("_thum", "");
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        widget.onShowMoim(info);
      },
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: const EdgeInsets.all(5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: simpleBlurImage(url, 1.0),
                )
            ),
            Container(
              padding: const EdgeInsets.only(left: 10, top:3, right: 10),
              //alignment: Alignment.centerLeft,
              child: Row(children: [
                Expanded(
                    child: Text(name, maxLines: 1,
                        style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold)),
                ),

                const SizedBox(width: 5),
                Visibility(
                    visible: !isApprove,
                    child: const Text("(미승인)", maxLines: 1,
                            style: TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.normal))
                ),
              ],)
            ),

            Container(
                padding: const EdgeInsets.only(left: 10, top:1, right: 10),
                child: Row(children: [
                  Expanded(
                    child: Text(title, maxLines: 1,
                        style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.normal)),
                  ),
                ],)
            ),
          ],
        ),
      ),
    );
  }

  Future <void> _fetchJoinedMoims() async {
    // "Owner", "Member", "Joinable"
    await Remote.getMoims(
        params: {
          "command": "LIST",
          "list_attr": "Member",
          "users_id": _userInfo.users_id.toString()
        },
        onResponse: (List<Moims> list) async {
          setState(() {
            amLoad = true;
            _aMoimList = list;
            setFirebaseSubcribed();
          });
        });
  }

  Future <void> setFirebaseSubcribed() async {
    print("setFirebaseSubcribed(${_userInfo.isSetSubscribed})");
    if(_userInfo.isSetSubscribed! != "Y")
    {
      print("setFirebaseSubcribed() -> add(${_aMoimList.length})");
      for (var info in _aMoimList) {
        print("scan >>> ${info.moim_name}(${info.id}): approve[${info.member_approve.toString()}]");
        if(info.member_approve.toString()=="Y") {
          String topic = "moims_${info.id.toString()}";
          FirebaseMessaging.instance.subscribeToTopic(topic);
          print("Set >>> subscribeToTopic($topic)");
        }
      }
      _userInfo.isSetSubscribed = "Y";
      _userInfo.setPref();
    }
  }

  Future <void> _fetchJoinAbleMoims() async {
    await Remote.getMoims(
        params: {
          "command": "LIST",
          "list_attr":"Joinable",
          "users_id": _userInfo.users_id.toString(),
          "rec_start":"0",
          "rec_count":"10",
        },
        onResponse: (List<Moims> list) {
          setState(() {
            _jMoimList = list;
            jmLoad = true;
          });
        });
  }

  Future <void> _loadMainInfo() async {
    await Remote.reqMainInfo(
        params: {
          "command": "Main",
          "users_id": _userInfo.users_id.toString(),
        },
        onResponse: (MainInfo info) {
            widget.onInfo(info);
        });
  }

  Future <void> reportMyToken() async {
    //if(_m_isSigned) {
      await Remote.reqUsers(
          params: {
            "command": "SET_TOKEN",
            "users_id": _userInfo.users_id.toString(),
            "push_token": _userInfo.push_token.toString(),
          },
          onResponse: (bool result) {
            print("reportMyToken(): result=$result");
          });
  }

  void _onTabJoinable(Moims info) {
    widget.onJoinable(info);
  }
}
