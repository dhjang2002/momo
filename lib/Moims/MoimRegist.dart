// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Constants/Constants.dart';
import 'package:momo/Layouts/Card2Buttons.dart';
import 'package:momo/Layouts/CardEditItem.dart';
import 'package:momo/Layouts/CardFieldsView.dart';
import 'package:momo/Layouts/CardFormText.dart';
import 'package:momo/Layouts/CardFormRadio.dart';
import 'package:momo/Layouts/CardPhotoEdit.dart';
import 'package:momo/Models/Members.dart';
import 'package:momo/Models/Moims.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/utils.dart';
import 'package:provider/provider.dart';

const int stepDesc        = 0; // 모임설명: 모임이름/한줄설명/설명 .
const int stepManage      = 1; // 모임관리: 공개여부/승인방식/운영목적
const int stepExtra       = 2; // 추가정보
const int stepTag         = 3; // Tag
const int stepPhoto       = 4; // Photo
const int stepSumit       = 5; // sumit.
const int stepPageCount   = 6;

class MoimRegist extends StatefulWidget {
  final String usersId;
  const MoimRegist({ Key? key,
    required this.usersId,
  }) : super(key: key);

  @override
  State<MoimRegist> createState() => _MoimRegistState();
}

class _MoimRegistState extends State<MoimRegist> {
  int m_photo_count = 0;
  Moims m_moims = Moims();
  double curr_progress = 0.0;
  bool m_isAdded = false;
  bool m_isJoined = false;
  bool isPageBegin = true;
  bool isPageLast  = false;
  int  curr_page_index = 0;
  int  past_page_index = 0;

  final PageController pageController = PageController(initialPage: 0);
  //final _currentPageNotifier = ValueNotifier<int>(0);

  String app_title = "";
  bool m_bIsOpened = false;
  bool m_bUseExtra = false;
  bool _bCheckMoimName = false;

  var m_bIsValid = List.filled(stepPageCount, false, growable: false);

  late LoginInfo _loginInfo;
  @override
  void initState() {
    _loginInfo = Provider.of<LoginInfo>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {FocusScope.of(context).unfocus();},
      child: WillPopScope (
        onWillPop: () => _onBackPressed(context),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: AppBar_Color,
            elevation: 0.0,
            leading: Visibility(
              visible:  true,
              child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: AppBar_Icon,), // (isPageBegin) ? Icons.close :
                  onPressed: () {
                      _prevPage();
                  }
              ),
            ),
            actions: [
              Visibility(
                visible: (isPageBegin) ? false: true,
                child: IconButton(
                    icon: const Icon(Icons.close, color: AppBar_Icon),
                    onPressed: () {
                      doConfirmQuit();
                    }
                ),
              ),
            ],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              Expanded(
                flex: 1,
                child: SafeArea(
                  child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: pageController,
                      physics: const NeverScrollableScrollPhysics(), // disable swipe
                      onPageChanged: (int index) {
                        _onPageChanged(index);
                      },

                      itemCount: stepPageCount,
                      itemBuilder: (BuildContext context, int index) {
                        switch (index) {// 절차안내.
                          case stepDesc:           // 모임이름 & 설명
                            return stDescription(index);
                          case stepManage:       // 모임형태(회원제, 사업장홍보).
                            return stManage(index);
                          case stepExtra:           // 기본정보
                            return stExtra(index);
                          case stepTag:          // 회원 승인방식
                            return stTag(index);
                          case stepPhoto:
                            return stPhoto(index); // 가입코드
                          case stepSumit:
                            return stConfirm(index);// 회원 승인방식
                          default:
                            return Container();
                        }
                      }
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget stDescription(int index) {
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
                  //mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //const SizedBox(height: 10,),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("모임 만들기", style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),),),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("어떤 모임을 개설하시나요?", style: TextStyle(color: Colors.black, fontSize: 20),),),
                    const SizedBox(height: 20),
                    CardFormText(
                      //maxLength: 64,
                        title: const ["bQ1. ","n우리 모임명"],
                        hint: "모임 이름을 입력해주세요.",
                        value: m_moims.moim_name.toString(),
                        keyboardType: TextInputType.text,
                        onChanged: (String tag, String value) {
                          setState(() {
                            m_moims.moim_name = value.trim();
                            _bCheckMoimName = false;
                            _checkValidate();
                          });
                        }),
                    Visibility(
                      visible: !_bCheckMoimName,//m_moims.moim_name!.isNotEmpty,
                        child: Row(
                          children: [
                            const Spacer(),
                            TextButton.icon(
                              icon: const Icon(Icons.check, color: Color(0xffc2c2c2)),
                              label: const Text('중복확인', style: TextStyle(fontSize: 14, color: Color(0xffc2c2c2))),
                              onPressed: () async {
                                if(m_moims.moim_name!.length <2 ) {
                                  showToastMessage("모임이름은 2자 이상입니다.");
                                  return;
                                }

                                Remote.reqMoims(
                                    params: {
                                      "command":"duplicate",
                                      "canidate":m_moims.moim_name.toString(),
                                    },
                                    onResponse: (bool result){
                                      setState(() {
                                        _bCheckMoimName = result;
                                      });

                                      if(!result) {
                                        showToastMessage("사용할 수 없는 명칭입니다.");
                                      }
                                    });
                              },
                            )
                        ])),
                    Visibility(visible: _bCheckMoimName,
                        child: Column(
                        children: [
                        const SizedBox(height:40),
                        CardFormText(
                            maxLength: 255,
                            title: const ["bQ2. ","n우리 모임 한 줄 소개"],
                            subTitle: "*50자 이내로 작성해주세요.",
                            hint: "예) 친목을 위한 활동모임.",
                            keyboardType: TextInputType.multiline,
                            maxLines:3,
                            value: m_moims.moim_title.toString(),
                            tag: "moim_description",
                            useSelect: false,
                            onChanged: (String tag, String value) {
                              m_moims.moim_title = value;
                              setState(() {
                                _checkValidate();
                              });
                              print(
                                  "onSubmit():tag=$tag, value=$value");
                            }),
                        const SizedBox(height:20),
                        CardFormText(
                            maxLength: 8192,
                            title: const ["bQ3. ","n우리 모임 상세소개"],
                            subTitle: "*모임의 목적, 취지, 운영방법 등, 잠재 회원에게 소개할 내용을 입력합니다.",
                            hint: "모임의 상세 소개를 해주세요.",
                            keyboardType: TextInputType.multiline,
                            maxLines:15,
                            value: m_moims.moim_description.toString(),
                            tag: "moim_description",

                            useSelect: false,
                            onChanged: (String tag, String value) {
                              m_moims.moim_description = value;
                              setState(() {
                                _checkValidate();
                              });
                              print(
                                  "onSubmit():tag=$tag, value=$value");
                            }),
                        const SizedBox(height:50),
                        Card2Buttons(
                            onPrev: () =>_prevPage(),
                            onNext: () => _doAdd(),
                          ),
                        const SizedBox(height:50),
                        ],
                      )),
                  ],),
              ),
            )
        ),
      ],
    );
  }

  Widget stManage(int index) {
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
                  //mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //const SizedBox(height: 20,),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("모임 만들기", style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),),),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("우리모임 관리 설정하기", style: TextStyle(color: Colors.black, fontSize: 20),),),
                    const SizedBox(height: 20,),
                    CardFormRadio(title: const ["bQ4. ","n우리 모임의 운영 목적은 무엇인가요?"],
                      subTitle: "",isVertical: false,
                      aList: const ["비즈니스","친목모임", "기타", ],
                      tag:"moim_category", value: m_moims.moim_category.toString(),
                      onSubmit: (String tag, String value) {
                        m_moims.moim_category = value;
                        setState(() {
                          _checkValidate();
                        });
                      },
                    ),
                    const SizedBox(height:15),
                    CardFormRadio(title: const ["bQ5. ","n우리 모임의 검색을 허용하시겠습니까?"],
                      subTitle: "",isVertical: false,
                      aList: const ["공개", "비공개"],
                      tag:"moim_kind", value: m_moims.moim_kind.toString(),
                      onSubmit: (String tag, String value) {
                        setState(() {
                          m_moims.moim_kind = value;
                          m_bIsOpened = (m_moims.moim_kind.toString()=="공개") ? false : true;
                          if(!m_bIsOpened) {
                            m_moims.moim_code = "";
                          }
                          _checkValidate();
                        });
                      },
                    ),
                    const SizedBox(height:15),
                    Visibility(visible:m_bIsOpened,
                      child: CardFormText(
                          maxLength: 4,
                          title: const ["bQ6. ","n우리 모임의 가입 확인코드"],
                          subTitle: "",
                          keyboardType: TextInputType.number,
                          value: m_moims.moim_code.toString(),
                          tag: "moim_code", hint: "숫자4자",
                          useSelect: false,
                          onChanged: (String tag, String value) {
                            m_moims.moim_code = value;
                            setState(() {
                              _checkValidate();
                            });
                          }),),
                    const SizedBox(height:15),
                    CardFormRadio(title: const ["bQ7. ","n우리 모임 가입시 자동 승인처리 하시겠습니까?"],
                      subTitle: "",isVertical: false,
                      aList: const ["자동승인", "관리자 확인후 승인"],
                      tag:"moim_accept", value: m_moims.moim_accept.toString(),
                      onSubmit: (String tag, String value) {
                        m_moims.moim_accept = value;
                        setState(() {
                          _checkValidate();
                        });
                      },
                    ),

                    const SizedBox(height:15),
                    CardFormRadio(title: const ["bQ8. ","n회원정보에 익명(닉네임)을 사용할까요?"],
                      subTitle: "",isVertical: false,
                      aList: const ["예", "아니오"],
                      tag:"use_nick", value: m_moims.use_nick.toString(),
                      onSubmit: (String tag, String value) {
                        m_moims.use_nick = value;
                        setState(() {
                          _checkValidate();
                        });
                      },
                    ),

                    const SizedBox(height:50),
                    Visibility(visible: true,
                      child: Card2Buttons(
                        onPrev: () =>_prevPage(),
                        onNext: () => _doAdd(),
                      ),),
                    const SizedBox(height:100),
                  ],),
              ),
            )
        ),
      ],
    );
  }

  Widget stExtra(int index) {
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
                  //mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //const SizedBox(height: 20,),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("모임 만들기", style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),),),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("모임 가입 시 추가정보 설정", style: TextStyle(color: Colors.black, fontSize: 20),),),
                    const SizedBox(height: 20,),

                    CardFormRadio(title: const ["bQ9.","n 모임 가입시 ","b추가정보","n를 받으시겠습니까?"],
                      subTitle: "",isVertical: false,
                      aList: const ["받지않음", "추가정보 받기"],
                      tag:"moim_kind", value: "받지않음",
                      onSubmit: (String tag, String value) {
                        setState(() {
                          m_bUseExtra = (value=="받지않음") ? false : true;
                        });
                      },
                    ),

                    Visibility(
                      visible: m_bUseExtra,
                      child: const SizedBox(height:20),),

                    Visibility(
                      visible:m_bUseExtra,
                      child: CardFieldsView(
                          title: const ["bQ9.","n 회원가입 ","b필수 항목","n을 추가하십시오."],
                          moims_id: m_moims.id.toString(),
                          onChange: (String tag, String value) { }),
                    ),

                    const SizedBox(height:50),
                    Visibility(visible: true,
                      child: Card2Buttons(
                        onPrev: () =>_prevPage(),
                        onNext: () => _doAdd(),
                      ),),
                    const SizedBox(height:100),
                  ],),
              ),
            )
        ),
      ],
    );
  }

  Widget stTag(int index) {
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
                    //const SizedBox(height: 20,),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("모임 만들기", style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),),),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("우리모임 Tag 등록하기", style: TextStyle(color: Colors.black, fontSize: 20),),),
                    const SizedBox(height: 20,),
                    CardEditItem(
                      title: const ["bQ10.","n 검색용 ","bTag","n를 등록해 주세요."],
                      value: m_moims.moim_tag.toString(),
                      hint: "#친목",
                      tag: 'moim_tag',
                      desc: "우리 모임의 Tag를 1개이상 추가해주세요.",
                      onChanged: (String tag, String value) {
                        m_moims.moim_tag = value;
                        setState(() {
                          _checkValidate();
                        });
                      },
                    ),

                    const SizedBox(height:50),
                    Visibility(visible: true,
                      child: Card2Buttons(
                        onPrev: () =>_prevPage(),
                        onNext: () => _doAdd(),
                      ),),
                    const SizedBox(height:100),
                  ],),
              ),
            )
        ),
      ],
    );
  }

  Widget stPhoto(int index) {
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
                  //mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //const SizedBox(height: 20,),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("모임 만들기", style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),),),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("우리모임 사진 등록하기", style: TextStyle(color: Colors.black, fontSize: 20),),),
                    const SizedBox(height: 20,),

                    CardPhotoEdit(
                        title: const ["bQ11.","n 모임의 대표","b사진","n을 추가해주세요."],
                        max_count: max_photo_moim, photo_type: photo_tag_moim,
                      photo_id: m_moims.id.toString(),
                        users_id: widget.usersId.toString(),
                      message: "모임의 대표 사진을 등록해 주세요. $min_photo_moim~$max_photo_moim장까지 저장할 수 있습니다.",
                        onChanged: (int count, String thumnails) {
                          setState(() {
                            m_moims.moim_thumnails = thumnails;
                            m_photo_count = count;
                            print("m_photo_count=$m_photo_count");
                            _checkValidate();
                          });
                        }),

                    const SizedBox(height:50),
                    Visibility(visible: true,
                      child: Card2Buttons(
                        onPrev: () =>_prevPage(),
                        onNext: () => _doAdd(),
                      ),),
                    const SizedBox(height:100),
                  ],),
              ),
            )
        ),
      ],
    );
  }

  Widget stConfirm(int index) {

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
                const Text("모임 만들기", style: TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),),
                const SizedBox(height: 15),
                Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: const Text("새로운 모임이 생성되었습니다.",
                        style: TextStyle(color: Colors.black, fontSize: 20))),

                const SizedBox(height: 80),
                Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                      width: 200,
                      //height: 220,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.asset("assets/icon/icon_finish1.png"))
                  ),
                ),
                const SizedBox(height: 50),
                Visibility(
                  visible: true,
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
                        _doUpdate();
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
    if(isPageBegin) {
      doConfirmQuit();
    } else {
      _prevPage();
    }

    return Future(() => false);
  }

  void _checkValidate() {
    setState(() {
      switch(curr_page_index) {
        case stepDesc: // 모임설명 .
          m_bIsValid[curr_page_index] = true;
          if(m_moims.moim_name!.isEmpty || m_moims.moim_title!.isEmpty || m_moims.moim_description!.isEmpty) {
            m_bIsValid[curr_page_index] = false;
          }
          break;

        case stepManage: // 관리정보
          m_bIsValid[curr_page_index] = true;
          if(m_moims.moim_category!.isEmpty || m_moims.moim_kind!.isEmpty || m_moims.moim_accept!.isEmpty) {
            m_bIsValid[curr_page_index] = false;
          }
          if(m_bIsOpened && m_moims.moim_code!.isEmpty){
            m_bIsValid[curr_page_index] = false;
          }
          break;

        case stepExtra: // 부가정보
          m_bIsValid[curr_page_index] = true;
          break;

        case stepTag: // Tag정보
          m_bIsValid[curr_page_index] = true;
          if(m_moims.moim_tag!.isEmpty) {
            m_bIsValid[curr_page_index] = false;
          }
          break;

        case stepPhoto:
          m_bIsValid[curr_page_index] = false;
          if(m_photo_count>=min_photo_moim) {
            m_bIsValid[curr_page_index] = true;
          }
          break;

        case stepSumit: // 승인
          m_bIsValid[curr_page_index] = true;
          break;
      }
    });
  }

  String _validMessage = "필수 입력 항목입니다.";
  bool validate(index) {
    if(m_bIsValid[index]) {
      _validMessage = "";
      return true;
    }

    switch(curr_page_index) {
        case stepDesc: // 정보동의.
          if(m_moims.moim_name!.isEmpty) {
            _validMessage = "모임 이름을 입력해주세요.";
          }
          else if(m_moims.moim_title!.isEmpty) {
            _validMessage = "모임 타이틀을 입력해주세요.";
          }
          else if(m_moims.moim_description!.isEmpty) {
            _validMessage = "모임 설명글을 입력해주세요.";
          }
          break;

        case stepManage: // 모임형태.
          if(m_moims.moim_category!.isEmpty) {
            _validMessage = "모임의 운영목적을 선택해주세요.";
          }
          else if(m_moims.moim_kind!.isEmpty) {
            _validMessage = "모임의 공개여부를 선택해주세요.";
          }
          else if(m_moims.moim_accept!.isEmpty) {
            _validMessage = "모임 승인방식을 선택해주세요.";
          }
          else if(m_bIsOpened && m_moims.moim_code!.isEmpty){
            _validMessage = "가입코드를 입력해주세요.";
          }
          break;

        case stepExtra: // 모임구분(5)
          break;

        case stepTag: // 모임구분(5)
          if(m_moims.moim_tag!.isEmpty) {
            _validMessage = "Tag를 입력해주세요.";
          }
          break;

        case stepPhoto: // 가입코드(5)
          if(m_photo_count<2) {
            _validMessage = "사진을 2장 이상 입력해주세요.";
          }
          break;

        case stepSumit: // 등록(5)
          break;
    }
    return false;
  }

  void _onPageChanged(int page) {
    setState(() {
      curr_page_index = page;

      if(past_page_index<=curr_page_index) {
        past_page_index = curr_page_index;
      }

      m_bIsValid[curr_page_index] = true;
      isPageBegin = (curr_page_index == 0) ? true : false;
      isPageLast  = (curr_page_index>=stepPageCount-1) ? true : false;

      double pos = (curr_page_index+1);
      curr_progress = pos/stepPageCount;
      _checkValidate();
    });
  }

  void _nextPage() {
    FocusScope.of(context).unfocus();
    if(!validate(curr_page_index)) {
      return;
    }

    pageController.animateToPage(pageController.page!.toInt() + 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn
    );
  }

  void _prevPage() {
    FocusScope.of(context).unfocus();
    if(!isPageBegin) {
      pageController.animateToPage(pageController.page!.toInt() - 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn
      );
    }
    else{
      doConfirmQuit();
    }
  }

  Future <void> _doUpdate() async {
    m_moims.moim_data_ready = "Y";
    Map<String,String> params = m_moims.toMap();
    params.addAll({
      "command":"UPDATE",
    });

    await Remote.reqMoims(
        params: params,
        onResponse: (bool result) {
      if(result){
        m_isAdded = false;
        _doJoin();
      }

    });
  }

  Future <void> _doAdd() async {
    if(!validate(curr_page_index)) {
      showToastMessage(_validMessage);
      return;
    }

    if(m_moims.id!.isEmpty) {
      Map<String, String> params = m_moims.toMap();
      params.addAll({
        "command": "ADD",
        "moim_owner": widget.usersId,
      });

      await Remote.addMoims(params: params, onResponse: (Moims info) {
        setState(() {
          m_moims = info;
          m_isAdded = true;
          //print("_addMoims():" + m_moims.toString());
          _nextPage();
        });
      });
    }
    else{
      _nextPage();
    }
  }

  void doConfirmQuit() {
    if(m_isAdded && m_moims.id!.isNotEmpty) {
      showDialogPop(
          context:context,
          title: "확인",
          body:const Text("작업을 중지 하시겠습니까?",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
          content:const Text("작성중인 데이터는 보관되지 않습니다.",
            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: Colors.black),),
          choiceCount:2, yesText: "예", cancelText: "아니오",
          onResult:(bool isOK) async {
            if(isOK) {
              await Remote.reqMoims(
                  params: {"command": "DELETE", "id": "${m_moims.id}"},
                  onResponse: (bool result) {
                    Navigator.pop(context);
                  });
            }
          }
        );
    }
    else{
      Navigator.pop(context);
    }
  }

  Future <void> _doJoin() async {
    if(m_isJoined){
      return;
    }

    Members _members = Members();
    //_members.mb_no = _loginInfo.users_id.toString();
    _members.member_duty    = "30회원";
    _members.member_grade   = "관리자";
    _members.member_approve = "Y";
    _members.member_data_ready = "Y";
    _members.member_area = getAreaFromAddress(_loginInfo.person!.mb_addr1.toString());

    Map<String, String> params;
      params = _members.toAddMap();
      params.addAll({
        "command": "ADD",
        "moims_id": "${m_moims.id}",
        "mb_no": _loginInfo.users_id.toString(),
      });

    await Remote.joinToMember(
        params: params,
        onResponse: (Members info) {
          showDialogPop(
              context:context,
              title: "가입확인",
              body:const Text("",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
              content:const Text("이 모임의 관리자로 등록되었습니다.",
                style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: Colors.black),),
              choiceCount:1, yesText: "확인", cancelText: "",
              onResult:(bool isOK) async {
                m_isJoined = true;
                if(isOK) {
                  Navigator.pop(context, m_moims.id);
                }
              }
          );
        });
  }

}