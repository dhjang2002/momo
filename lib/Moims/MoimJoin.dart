// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Constants/Constants.dart';
import 'package:momo/Models/FieldData.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Layouts/CardExtraForm.dart';
import 'package:momo/Layouts/CardFormText.dart';
import 'package:momo/Models/Files.dart';
import 'package:momo/Models/MemberExtra.dart';
import 'package:momo/Models/Members.dart';
import 'package:momo/Models/Moims.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/DateForm.dart';
import 'package:momo/Utils/utils.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';
import 'package:provider/provider.dart';

const int stepinfo          = 0; // 시작.
const int stepCodeCheck     = 1; // 비공개/코드체크
const int stepExtraInfo     = 2; // 추가정보
const int stepSumit         = 3; // 가입처리.
const int stepPageCount     = 4;

class MoimJoin extends StatefulWidget {
  final String moims_id;
  final bool isOwner;
  const MoimJoin({Key? key, required this.moims_id, required this.isOwner})
      : super(key: key);

  @override
  State<MoimJoin> createState() => _MoimJoinState();
}

class _MoimJoinState extends State<MoimJoin> {
  final _valueNotifier = ValueNotifier<int>(0);

  Members _members = Members();

  late Moims _m_moims;
  List<MemberExtra> _m_extra = <MemberExtra>[];
  List<Files> m_photos = <Files>[];

  bool _m_extra_ready = false;
  bool _m_moim_ready = false;

  bool _bDirty = false;

  bool isPageBegin = true;
  bool isPageLast = false;
  int curr_page_index = 0;
  int past_page_index = 0;

  final PageController pageController = PageController(initialPage: 0);
  //final _currentPageNotifier = ValueNotifier<int>(0);

  final String app_title = "";
  var visible = List.filled(stepPageCount, true, growable: false);
  var m_route = List.filled(stepPageCount, 0, growable: false);

  late LoginInfo _loginInfo;
  String _checkCode = "";
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _loginInfo = Provider.of<LoginInfo>(context, listen: false);
      _members.member_area =
          getAreaFromAddress(_loginInfo.person!.mb_addr1.toString());
      _roadPhotos();
      _roadMerberExtra();
      _roadMoimInfo();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () => _onBackPressed(context),
        child: Scaffold(
            backgroundColor: Colors.white,
            extendBodyBehindAppBar: false, //isPageBegin,
            appBar: AppBar(
              centerTitle: false,
              backgroundColor: AppBar_Color,
              elevation: 0.0,
              title:
                  Text(app_title, style: const TextStyle(color: AppBar_Title)),
              leading: Visibility(
                visible: true,
                child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppBar_Icon,
                    ), // (isPageBegin) ? Icons.close :
                    onPressed: () {
                      _prevPage();
                    }),
              ),
              actions: [
                Visibility(
                  visible: (isPageBegin) ? false : true,
                  child: IconButton(
                      icon: const Icon(Icons.close, color: AppBar_Icon),
                      onPressed: () {
                        doConfirmQuit();
                      }),
                ),
              ],
            ),
            body: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (!_m_extra_ready && !_m_moim_ready) {
      return const Center(child: const CircularProgressIndicator());
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.white,
            //padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: SafeArea(
              child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: pageController,
                  physics:
                      const NeverScrollableScrollPhysics(), // disable swipe
                  onPageChanged: (int index) {
                    _onPageChanged(index);
                  },
                  itemCount: stepPageCount,
                  itemBuilder: (BuildContext context, int index) {
                    switch (index) {
                      case stepinfo:
                        return _stepIntro(index);
                      case stepCodeCheck: // 가입코드
                        return _stepCodeCheck(index);
                      case stepExtraInfo: // 확장 멤버속성
                        return _stepExtraInfo(index);
                      case stepSumit: // 신청  .
                        return _stepSumit(index);
                      default:
                        return Container();
                    }
                  }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepIntro(int index) {

    if(!_m_moim_ready) {
      return const Center(child:CircularProgressIndicator());
    }

    /*
    String url = "";
    if (m_photos.isNotEmpty) {
      url = URL_HOME + m_photos.elementAt(0).url.toString();
    }
    */

    return Stack(
      children: [
        Positioned(
          child: Container(
            //padding: const EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:  [
                          _renderCorver(),
                          const SizedBox(height: 30),
                          _renderTitle(_m_moims.moim_name!),
                          _renderContent(_m_moims.moim_title!),
                          const SizedBox(height: 50),
                          _renderTitle("모임소개"),
                          _renderContent(_m_moims.moim_description!),
                          const SizedBox(height: 30),
                          _renderMoimInfo(),
                          const SizedBox(height: 80),

                          /*
                          const SizedBox(height: 10,),
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: const Text("모임가입", style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),),),
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: const Text("가입 절차를 시작합니다.", style: TextStyle(color: Colors.black, fontSize: 20),),),
                          const SizedBox(height: 60),
                          Center(
                              child: Column(
                                children: [
                                  Text(
                                    _m_moims.moim_name.toString(),
                                    style: const TextStyle(
                                        fontSize: 24,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  //const SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    child: SizedBox(
                                        width: 220,
                                        height: 220,
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.circular(15.0),
                                            child: simpleBlurImage(url, 1.0))),
                                  ),

                                  Text(
                                    _m_moims.moim_description.toString(),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ))
                           */
                        ],
                      ),
                    )),
                Visibility(
                  visible: visible[curr_page_index],
                  child: Center(
                    child: ElevatedButton(
                      child: const Text("모임가입",
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          fixedSize: const Size(300, 48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50))),
                      onPressed: () {
                        _nextPage();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderCorver() {
    //final PageController _pageController = PageController(initialPage: 0,);

    String thumnails = _m_moims.moim_thumnails!.replaceAll("_thum", "");
    final List<String> photoList = thumnails.split(";");

    final double szCover = MediaQuery.of(context).size.width*.65;
    if (photoList.isNotEmpty) {
      return SizedBox(
          height: szCover,
          child: Stack(
            children: [
              PageView.builder(
                  scrollDirection: Axis.horizontal,
                  //controller: _pageController,
                  //physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _valueNotifier.value = index;
                    });
                  },
                  itemCount: photoList.length,
                  itemBuilder: (BuildContext context, int index) {
                    String url = URL_HOME + photoList.elementAt(index);
                    return simpleBlurImage(url, 1.0);
                  }),
              Align(
                // indicator
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CirclePageIndicator(
                    itemCount: photoList.length,
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

  Widget _renderTitle(String text) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20,0,20,0),
      child: Text(text,
          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _renderContent(String text) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20,15,20,0),
      child: Text(text,
          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal)),
    );
  }

  Widget _renderMoimInfo() {
    List<FieldData> data = <FieldData>[];
    String date = DateForm().parse(_m_moims.created_at.toString()).getDate();
    data.add(FieldData(field:"", display:"모임성격", value:_m_moims.moim_category));
    data.add(FieldData(field:"", display:"운영방식", value:_m_moims.moim_kind));
    data.add(FieldData(field:"", display:"가입승인", value:_m_moims.moim_accept));
    data.add(FieldData(field:"", display:"검색테그", value:_m_moims.moim_tag));
    data.add(FieldData(field:"", display:"생성일자", value:date));

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("모임정보", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),),
          const SizedBox(height: 15,),
          Container(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                //padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                itemCount: data.length, //리스트의 개수
                itemBuilder: (BuildContext context, int index) {
                  return _fieldRow(
                      data.elementAt(index).display.toString(),
                      data.elementAt(index).value.toString());
                }),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 1, color: Colors.grey.shade200),
                left: BorderSide(width: 1, color: Colors.grey.shade200),
                right: BorderSide(width: 1, color: Colors.grey.shade200),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _fieldRow(String label, String value) {
    return Container(
      child: Row(
        children: [
          Expanded(
              flex: 25,
              child: Container(
                padding: const EdgeInsets.fromLTRB(5,15,5,15),
                color: Colors.grey.shade50,
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
              )),
          Expanded(
              flex: 75,
              child: Container(
                padding: const EdgeInsets.only(left:10),
                child: Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              )),
        ],
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.0, color: Colors.grey.shade200),
        ),
      ),
    );
  }


  Widget _stepCodeCheck(int index) {
    return Stack(
      children: [
        Positioned(
            child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(15),
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: const Text("가입코드", style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),),),
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: const Text("모임에서 받은 코드번호를 입력하세요.", style: TextStyle(color: Colors.black, fontSize: 20),),),
                const SizedBox(height: 20),
                CardFormText(
                    maxLength: 4,
                    title: const ["b가입코드", "n를 입력해주세요."],
                    subTitle: "가입코드는 모임을 관리하는 관리자가 지정한 숫자코드입니다."
                        " 이 모임은 비공개 모임으로 가입코드를 모들경우 가입이 불가능 합니다.",
                    keyboardType: TextInputType.number,
                    value: "",
                    tag: "",
                    hint: "가입코드",
                    useSelect: false,
                    onChanged: (String tag, String value) {
                      _checkCode = value;
                      setState(() {
                        _checkValidate();
                      });
                    }),
                Visibility(
                  visible: visible[curr_page_index],
                  child: Center(
                    child: ElevatedButton(
                      child: const Text("다음단계",
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          fixedSize: const Size(300, 48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50))),
                      onPressed: () {
                        if(_checkCode.isNotEmpty && _checkCode==_m_moims.moim_code){
                          _nextPage();
                          return;
                        }
                        showToastMessage("가입코드가 일치하지 않습니다.");
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _stepExtraInfo(int index) {
    return Stack(
      children: [
        Positioned(
            child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(15),
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: const Text("모임 가입", style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),),),
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: const Text("필수 정보를 입력해주세요.", style: TextStyle(color: Colors.black, fontSize: 20),),),
                const SizedBox(height: 20),
                CardExtraForm(
                  m_member: _members,
                  m_extra: _m_extra,
                ),
                const SizedBox(height: 50),
                Visibility(
                  visible: visible[curr_page_index],
                  child: Center(
                    child: ElevatedButton(
                      child: const Text("다음단계",
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          fixedSize: const Size(300, 48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50))),
                      onPressed: () {
                        _nextPage();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _stepSumit(int index) {
    if(_m_moims.moim_accept=="자동") {
    }
    else {
    }
    return Stack(
      children: [
        Positioned(
          child: Container(
            padding: const EdgeInsets.all(15),
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20,),
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: const Text("가입확인", style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),),),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: const Text("모임에 가입해 주셔서 감사합니다.", style: TextStyle(color: Colors.black, fontSize: 20),),),

                const SizedBox(height: 50),
                Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                      width: 200,
                      //height: 220,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.asset("assets/icon/icon_finish2.png"))
                  ),
                ),
                const SizedBox(height: 50),
                Visibility(
                  visible: visible[curr_page_index],
                  child: Center(
                    child: ElevatedButton(
                      child: const Text("확인",
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          fixedSize: const Size(300, 48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50))),
                      onPressed: () {
                        _doJoin();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        )
      ],
    );
  }

  Future <bool> _onBackPressed(BuildContext context) {
    if (isPageBegin) {
      doConfirmQuit();
    } else {
      _prevPage();
    }

    return Future(() => false);
  }

  void _checkValidate() {
    setState(() {
      switch (curr_page_index) {
        case stepinfo: // 모임정보 확인
          visible[curr_page_index] = true;
          break;
        case stepCodeCheck: // 가입코드 체크
          visible[curr_page_index] = true;
          break;

        case stepExtraInfo: // 추가정보 입력   .
          visible[curr_page_index] = true;
          break;

        case stepSumit: // 신청하기
          visible[curr_page_index] = true;
          break;
      }
    });
  }

  bool isValidExtra() {
    for (int n = 0; n < _m_extra.length; n++) {
      String value = getFieldValue(_m_extra.elementAt(n).field_name.toString());
      if (value.isEmpty) {
        return false;
      }
    }
    return true;
  }

  String getFieldValue(String filed) {
    switch (filed) {
      case "member_field_01":
        return _members.member_field_01.toString();
      case "member_field_02":
        return _members.member_field_02.toString();
      case "member_field_03":
        return _members.member_field_03.toString();
      case "member_field_04":
        return _members.member_field_04.toString();
      case "member_field_05":
        return _members.member_field_05.toString();
      case "member_field_06":
        return _members.member_field_06.toString();
      case "member_field_07":
        return _members.member_field_07.toString();
      case "member_field_08":
        return _members.member_field_08.toString();
      case "member_field_09":
        return _members.member_field_09.toString();
      case "member_field_10":
        return _members.member_field_10.toString();
      case "member_field_11":
        return _members.member_field_11.toString();
      case "member_field_12":
        return _members.member_field_12.toString();
      case "member_field_13":
        return _members.member_field_13.toString();
      case "member_field_14":
        return _members.member_field_14.toString();
      case "member_field_15":
        return _members.member_field_15.toString();
    }
    return "";
  }

  void _onPageChanged(int page) {
    setState(() {
      curr_page_index = page;
      if (past_page_index <= curr_page_index) {
        past_page_index = curr_page_index;
      }

      visible[curr_page_index] = true;
      isPageBegin = (curr_page_index == 0) ? true : false;
      isPageLast = (curr_page_index >= stepPageCount - 1) ? true : false;

      //double pos = (curr_page_index+1);
      //_curr_progress = pos/stepPageCount;
      _checkValidate();

      switch (curr_page_index) {
        case stepinfo: // 상품명.
          break;

        case stepCodeCheck: // 상품명.
          break;

        case stepExtraInfo: // 상품가격.
          break;

        case stepSumit: // 상품설명.
          break;

      }
    });
  }

  void doConfirmQuit() {
    if (_bDirty && _members.id!.isNotEmpty) {
      showDialogPop(
          context: context,
          title: "확인",
          body: const Text(
            "작업을 중지 하시겠습니까?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: const Text(
            "작성중인 데이터는 보관되지 않습니다.",
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.black),
          ),
          choiceCount: 2,
          yesText: "예",
          cancelText: "아니오",
          onResult: (bool isOK) async {
            if (isOK) {
              //goHome(context,"0");
              Navigator.pop(context);
            }
          });
    } else {
      //goHome(context, "0");
      Navigator.pop(context);
    }
  }

  int getNextRoute(int curr) {
    for (int n = curr + 1; n < stepPageCount; n++) {
      if (m_route[n] == 0) {
        return n;
      }
    }
    return stepPageCount - 1;
  }

  int getPrevRoute(int curr) {
    for (int n = curr - 1; n >= 0; n--) {
      if (m_route[n] == 0) {
        return n;
      }
    }
    return 0;
  }

  void _nextPage() {
    FocusScope.of(context).unfocus();

    if (curr_page_index == stepExtraInfo) {
      if (!isValidExtra()) {
        showToastMessage("항목 정보를 입력해주세요.");
        return;
      }
    }

    int page = getNextRoute(curr_page_index);
    if (curr_page_index + 1 == page) {
      pageController.animateToPage(page,
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      pageController.jumpToPage(page);
    }
  }

  void _prevPage() {
    FocusScope.of(context).unfocus();
    _checkCode = "";
    if (!isPageBegin) {
      int page = getPrevRoute(curr_page_index);
      if (page == curr_page_index - 1) {
        pageController.animateToPage(page,
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      } else {
        pageController.jumpToPage(page);
      }
    } else {
      doConfirmQuit();
    }
  }

  Future <void> _roadMerberExtra() async {
    Remote.getMemberExtra(
        params: {"command": "LIST", "moims_id": widget.moims_id},
        onResponse: (List<MemberExtra> list) {
          setState(() {
            _m_extra = list;
            _m_extra_ready = true;
            if (_m_extra.isNotEmpty) {
              m_route[2] = 0;
            } else {
              m_route[2] = 1;
            }
          });
        });
  }

  Future <void> _roadMoimInfo() async {
    Remote.getMoims(
        params: {"command": "INFO", "id": widget.moims_id},
        onResponse: (List<Moims> list) {
          setState(() {
            _m_moims = list.elementAt(0);
            _m_moim_ready = true;
            if (_m_moims.moim_kind == "공개") {
              m_route[1] = 1;
            } else {
              m_route[1] = 0;
            }
          });
        });
  }

  Future <void> _roadPhotos() async {
    Remote.getFiles(
        params: {
          "command": "LIST",
          "photo_type": photo_tag_moim,
          "photo_id": widget.moims_id
        },
        onResponse: (List<Files> list) {
          setState(() {
            m_photos = list;
          });
        });
  }

  Future <void> _doJoin() async {
    // 모임 개설자이면 승인 및 관리자 지정함.
    if(_loginInfo.users_id.toString() == _m_moims.moim_owner.toString()) {
    //if (widget.isOwner || ) {
      _members.member_approve = "Y";
      _members.member_grade = "관리자";
    } else {
      // '자동승인'인 경우 처리
      if (_m_moims.moim_accept.toString() == "자동승인") {
        _members.member_approve = "Y";
      }
    }

    Map<String, String> params;
    if (_members.id!.isEmpty) {
      _members.member_data_ready = "Y";
      params = _members.toAddMap();
      params.addAll({
        "command": "ADD",
        "moims_id": "${_m_moims.id}",
        "mb_no": _loginInfo.users_id.toString(),
      });
    } else {
      params = _members.toMap();
      params.addAll({
        "command": "UPDATE",
      });
    }

    await Remote.joinToMember(
        params: params,
        onResponse: (Members info) {
          setState(() {
            _members = info;
            _bDirty = true;
            showToastMessage("처리되었습니다.");
            Navigator.pop(context, true);
          });
        });
  }
}
