// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:momo/Models/MoimsBoard.dart';
import 'package:momo/Models/MoimInfo.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Controller/ColtrollerStatusChange.dart';
import 'package:momo/Layouts/TileCard.dart';
import 'package:momo/Models/Moims.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/DateForm.dart';
import 'package:momo/Utils/utils.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';

class MoimHomePage extends StatefulWidget {
  final String moims_id;
  final String users_id;
  final bool? isApproved;
  final Function(bool flag) onDisJoin;
  final Function(Moims info) onBoard;
  final Function(String wr_id) onBoardDetail;
  final Function(Moims info) onLoad;
  final Function(MoimInfo info) onInfo;
  final Function(String tag, String extra) onInfoTab;
  ControllerStatusChange? controller;

  MoimHomePage({
    Key? key,
    this.controller,
    required this.moims_id,
    required this.users_id,
    required this.onDisJoin,
    required this.onBoard,
    required this.onBoardDetail,
    required this.onLoad,
    required this.onInfo,
    required this.onInfoTab,
    this.isApproved = true,
  }) : super(key: key);

  @override
  _MoimHomePageState createState() => _MoimHomePageState();
}

class _MoimHomePageState extends State<MoimHomePage>
    with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController(
    initialPage: 0,
  );
  final _valueNotifier = ValueNotifier<int>(0);

  List<MoimsBoard> _boardList = <MoimsBoard>[];

  MoimInfo _moimInfo = MoimInfo();

  bool mLoaded = false;
  late Moims moim;

  List<String> moim_photoList = <String>[];

  late double sz_corver;
  late double sz_report;

  bool _isFrontStatus = true;
  bool _isNextPhoto = true;

  int _iShowPhotoCount = 0;
  void _showNextPhoto() {
    if (_iShowPhotoCount > 8) {
      return;
    }

    if (!_isFrontStatus) {
      return;
    }

    _iShowPhotoCount++;
    Future.delayed(const Duration(seconds: 8), () {
      if (_pageController.positions.isEmpty) {
        return;
      }

      if (!_isFrontStatus) {
        return;
      }

      print(
          "MoimHomePage::_showNextPhoto($_iShowPhotoCount):: ----------------------------------> ");
      int curr = _pageController.page!.toInt();
      int len = moim_photoList.length.toInt();
      if (_isNextPhoto) {
        if (curr < len - 1) {
          curr++;
        } else {
          _isNextPhoto = false;
          curr--;
        }
      } else {
        if (curr > 0) {
          curr--;
        } else {
          _isNextPhoto = true;
          curr++;
        }
      }

      _pageController.animateToPage(curr,
          duration: const Duration(milliseconds: 1200), curve: Curves.easeIn);
    });
  }

  @override
  void initState() {
    super.initState();

    _isFrontStatus = true;
    if (widget.controller != null) {
      widget.controller!.addListener(() {
        //print("MoimHomePage::addListener(): action=${widget.controller!.action}");
        switch (widget.controller!.action) {
          case ControllerStatusChange.aFrontView:
            _isFrontStatus = true;
            _showNextPhoto();
            break;
          case ControllerStatusChange.aBackView:
            _isFrontStatus = false;
            break;
          case ControllerStatusChange.aInvalidate:
            {
              _loadMoimInfo(true);
              break;
            }
        }
      });
    }

    Future.microtask(() {
      _loadMoimInfo(true);
      _showApprove();
    });
  }

  void _showApprove() {
    if (widget.isApproved!) {
      return;
    }

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
        choiceCount: 2,
        yesText: "승인 대기",
        cancelText: "모임 나가기",
        onResult: (bool isOK) async {
          widget.onDisJoin(!isOK);
        });
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
    double main_height = MediaQuery.of(context).size.height * 0.88;
    double cover_offset = MediaQuery.of(context).size.height * 0.25 - 15;
    sz_corver = MediaQuery.of(context).size.width * .99;
    if (sz_corver > main_height * .44) {
      sz_corver = main_height * .44;
    }

    sz_report = main_height - 450;

    return SingleChildScrollView(
        child: SizedBox(
      height: main_height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 모임사진
          Positioned(top: 0, left: 0, right: 0, child: _corverImage()),
          // 모임 타이틀
          //Positioned(top: 10, left: 0, right: 0, child: _coverTitle()),
          // 모임정보  영역
          Positioned(
              top: cover_offset, left: 0, right: 0, child: _contentInfo()),
          // 리포트 영역
          //Positioned(bottom: 10, left: 0, right: 0, child: _notifyPart(),),
        ],
      ),
    ));
  }

  Widget _corverImage() {
    if (moim_photoList.isNotEmpty) {
      return SizedBox(
          height: sz_corver,
          child: Stack(
            children: [
              PageView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: _pageController,
                  //physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _valueNotifier.value = index;
                      //_showNextPhoto();
                    });
                  },
                  itemCount: moim_photoList.length,
                  itemBuilder: (BuildContext context, int index) {
                    String url = URL_HOME + moim_photoList.elementAt(index);
                    return simpleBlurImage(url, 1.0);
                  }),
              Align(
                // indicator
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.only(top: 5),
                  child: CirclePageIndicator(
                    itemCount: moim_photoList.length,
                    dotColor: Colors.black,
                    selectedDotColor: Colors.white,
                    size: 5.0,
                    currentPageNotifier: _valueNotifier,
                  ),
                ),
              ),
            ],
          ));
    }
    return Container();
  }

  Widget _notifyPart() {
    return Container(
      //height: sz_report,
      margin: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(5, 5, 15, 10),
            child: Row(
              children: [
                const Text("최근소식",
                    style:
                        const TextStyle(fontSize: 14.0, color: Colors.black)),
                const Spacer(),
                GestureDetector(
                  child: const Text("더보기",
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                  onTap: () {
                    widget.onBoard(moim);
                  },
                ),
              ],
            ),
          ),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white, // 전체 배경색
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 0.1,
                        spreadRadius: 0.1),
                  ]),
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  itemCount: _boardList.length,
                  itemBuilder: (context, index) {
                    return _itemCard(index);
                  }))
        ],
      ),
    );
  }

  Widget _contentInfo() {
    if (!mLoaded) {
      return Container();
    }

    final String title = moim.moim_title.toString();
    final String desc = moim.moim_description.toString(); //+"\n1\n2\n3";
    //DateForm date = DateForm();

    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 30,
          padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
          margin: const EdgeInsets.symmetric(horizontal: 15.0),
          decoration: BoxDecoration(
              color: Colors.white, // 전체 배경색
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 3,
                    spreadRadius: 0.2),
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Text(
                    title,
                    maxLines: 1,
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  )),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                width: double.infinity,
                child: Text(desc,
                    maxLines: 4,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.normal)),
              ),
              const Divider(
                height: 30,
                color: Colors.grey,
              ),
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: _infoCard(
                          "members",
                          Image.asset("assets/icon/moim_bot_user_group.png",
                              width: 28, height: 28, color: Colors.black),
                          "전체회원",
                          currencyFormat(_moimInfo.count_members) + "명")),
                  Expanded(
                      flex: 1,
                      child: _infoCard(
                          "shops",
                          Icon(Icons.chat, size:24, color: Colors.black),
                          // Image.asset("assets/icon/moim_bot_company.png",
                          //     width: 28, height: 28, color: Colors.black),
                          "한줄근황",
                          "커뮤니티")),
                  Expanded(
                      flex: 1,
                      child: _infoCard(
                          "detail", const Icon(Icons.list_alt), "모임소개", "모임설명")),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 15),
        _notifyPart()
      ],
    );
  }

  Widget _infoCard(String tag, Widget icon, String label, String value) {
    return GestureDetector(
      onTap: () {
        String url = ""; //moim.moim_url.
        widget.onInfoTab(tag, url);
      },
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            icon,
            const SizedBox(height: 5),
            Text(label,
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.normal)),
            const SizedBox(height: 3),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal))
          ],
        ),
      ),
    );
  }

  Widget _itemCard(int index) {
    MoimsBoard info = _boardList.elementAt(index);
    DateForm df = DateForm().parse(info.wr_last.toString());
    String stamp = df.getVisitDay();
    int passHour = df.passInHour();
    return Column(
      children: [
        TileCard(
          key: GlobalKey(),
          padding: const EdgeInsets.all(10),
          title: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Visibility(
                visible: (passHour < 24),
                child: const Icon(Icons.notifications_active,
                    size: 12, color: Colors.redAccent)),
            const SizedBox(width: 2),
            Expanded(
                child: Text(info.wr_subject.toString(),
                    maxLines: 1,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 18.0))),
          ]),
          subtitle: Row(children: [
            Text(stamp,
                maxLines: 1,
                style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                    fontSize: 13.0)),
            const Spacer(),
          ]),
          tailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16.0,
            color: Colors.grey,
          ),
          onTab: () => widget.onBoardDetail(info.wr_id.toString()),
          onTrailing: () => widget.onBoardDetail(info.wr_id.toString()),
        ),
        const Divider(
          height: 1.0,
        ),
      ],
    );
  }

  Future<void> _loadMoimInfo(bool bInit) async {
    mLoaded = false;
    Remote.getMoims(
        params: {"command": "INFO", "id": widget.moims_id},
        onResponse: (List<Moims> list) {
          if (list.isNotEmpty) {
            moim = list.elementAt(0);
            String shop_photos = moim.moim_thumnails!.replaceAll("_thum", "");
            moim_photoList = shop_photos.split(";");
            widget.onLoad(moim);
            _loadBoardInfo();
            _loadInfo();
            setState(() {
              mLoaded = true;
            });
          }
        });
  }

  Future<void> _loadInfo() async {
    Remote.reqMoimInfo(
        params: {
          "command": "Moim",
          "moims_id": moim.id.toString(),
        },
        onResponse: (MoimInfo info) {
          setState(() {
            _moimInfo = info;
            widget.onInfo(info);
          });
        });
  }

  Future<void> _loadBoardInfo() async {
    Map<String, String> params = {
      "command": "LIST",
      "moims_id": widget.moims_id,
      "count": "3"
    };

    Remote.getMoimBoards(
        params: params,
        onResponse: (List<MoimsBoard> list) {
          setState(() {
            _boardList = list;
          });
        });
  }
}
