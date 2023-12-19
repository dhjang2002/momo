// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Constants/Constants.dart';
import 'package:momo/Layouts/Card2Buttons.dart';
import 'package:momo/Layouts/CardEditItem.dart';
import 'package:momo/Layouts/CardExtraField.dart';
import 'package:momo/Layouts/CardFormAddr.dart';
import 'package:momo/Layouts/CardFormText.dart';
import 'package:momo/Layouts/CardPhotoEdit.dart';
import 'package:momo/Models/Shops.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/utils.dart';

const int stepName        = 0;  // 상호 및 설명
const int stepAddr        = 1;  // 사업장주소.
const int stepTel         = 2;  // 전화번호
const int stepUrl         = 3;  // 홈페이지
const int stepCategory    = 4;  // 업종분
const int stepTag         = 5;  // Tag.
const int stepPhoto       = 6;  // 사진등록.
const int stepConfirm     = 7;  // 가입하기.
const int stepPageCount   = 8;

class ShopRegist extends StatefulWidget {
  final String users_id;
  const ShopRegist({
    Key? key,
    required this.users_id
  }) : super(key: key);

  @override
  State<ShopRegist> createState() => _ShopRegistState();
}

class _ShopRegistState extends State<ShopRegist> {
  Shops m_shops = Shops();
  int m_photo_count = 0;

  bool m_isAdded = false;
  bool isPageBegin = true;
  bool isPageLast  = false;

  double curr_progress = 0.0;
  int  curr_page_index = 0;
  int  past_page_index = 0;

  final PageController _pageController = PageController(initialPage: 0);
  //final _currentPageNotifier = ValueNotifier<int>(0);

  String app_title = "사업장설명";
  var visible = List.filled(stepPageCount, false, growable: false);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
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
                child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: SafeArea(
                        child: PageView.builder(
                            scrollDirection: Axis.horizontal,
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(), // disable swipe
                            onPageChanged: (int index) {
                              _onPageChanged(index);
                            },

                            itemCount: stepPageCount,
                            itemBuilder: (BuildContext context, int index) {
                              switch (index) {
                                case stepName:           // 상호 및 설명
                                  return StepName(index);
                                case stepAddr:           // 사업장주소
                                  return StepAddr(index);
                                case stepTel:            // 사업장전화 .
                                  return StepTel(index);
                                case stepUrl:            // 사업장 홈페이지
                                  return StepUrl(index);   // maxLength: 7,
                                case stepCategory:       // 업종
                                  return StepCategory(index);
                                case stepTag:            // Tag
                                  return StepTag(index);
                                case stepPhoto:
                                  return StepPhoto(index); // 사진
                                case stepConfirm:         // 생성확인
                                  return StepConfirm(index);
                                default:
                                  return Container();
                              }
                            }
                        ),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget StepName(int index) {
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
                    CardFormText(
                        maxLength: 64,
                        title: const ["bQ1.","b 사업장명칭","n을 입력해주세요."],
                        subTitle: "",
                        keyboardType: TextInputType.text,
                        value: m_shops.shop_name.toString(),
                        tag: "shop_name",
                        hint: "사업장명칭",
                        useSelect: false,
                        onChanged: (String tag, String value) {
                          m_shops.shop_name = value;
                          setState(() {
                            _checkValidate();
                          });
                          print(
                              "onSubmit():tag=$tag, value=$value");
                        }),

                    CardFormText(
                        maxLength: 8192,
                        title: const ["bQ2.","n 사업장 ","b설명글","n을 입력해주세요."],
                        subTitle: "",
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        value: m_shops.shop_desc.toString(),
                        tag: "shop_desc",
                        hint: "사업장설명",
                        useSelect: false,
                        onChanged: (String tag, String value) {
                          m_shops.shop_desc = value;
                          setState(() {
                            _checkValidate();
                          });
                          print(
                              "onSubmit():tag=$tag, value=$value");
                        }),

                    const SizedBox(height:50),
                    Visibility(visible: true,
                      child: Card2Buttons(
                        goPrev: true,
                        goNext: visible[curr_page_index],
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

  Widget StepAddr(int index) {
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

                    CardFormAddr(
                        title: const ["bQ3.", "n 사업장의 ", "b주소","n를 입력해주세요."],
                        subTitle: "이 정보는 위치기반 주변 사업장 추천에 사용됩니다. 정확한 정보를 입력해주세요.",
                        initAddr: m_shops.shop_addr.toString(),
                        initExt:  m_shops.shop_addr_ext.toString(),
                        onAddrChanged: (String addr, String area, String latitude, String longitude){
                          m_shops.shop_addr = addr;
                          m_shops.shop_area = area;
                          m_shops.shop_addr_gps_latitude  = latitude;
                          m_shops.shop_addr_gps_longitude = longitude;
                          print("onAddrChanged():addr=$addr, area=$area, "
                              "latitude=$latitude, longitude=$longitude");
                          setState(() {
                            _checkValidate();
                          });
                        },
                        onExtChanged: (String ext) {
                          m_shops.shop_addr_ext = ext;
                          print("onExtChanged():ext=$ext");
                          setState(() {
                            _checkValidate();
                          });

                        }),

                    const SizedBox(height:50),
                    Visibility(visible: true,
                      child: Card2Buttons(
                        goPrev: true,
                        goNext: visible[curr_page_index],
                        onPrev: () => _prevPage(),
                        onNext: () => _nextPage(),
                      ),),
                    const SizedBox(height:100),
                  ],),
              ),
            )
        ),
      ],
    );
  }

  Widget StepTel(int index) {
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
                    CardFormText(
                        maxLength: 16,
                        title: const ["bQ4.","n 사업장의 ","b전화번호","n를 입력해주세요."],
                        subTitle: "",
                        keyboardType: TextInputType.phone,
                        value: m_shops.shop_tel.toString(),
                        tag: "shop_tel",
                        hint: "전화번호",
                        useSelect: false,
                        onChanged: (String tag, String value) {
                          m_shops.shop_tel = value;
                          setState(() {
                            _checkValidate();
                          });
                          print(
                              "onSubmit():tag=$tag, value=$value");
                        }),

                    const SizedBox(height:50),
                    Visibility(visible: true,
                      child: Card2Buttons(
                        goPrev: true,
                        goNext: visible[curr_page_index],
                        onPrev: () => _prevPage(),
                        onNext: () => _nextPage(),
                      ),),
                    const SizedBox(height:100),
                  ],),
              ),
            )
        ),
      ],
    );
  }

  Widget StepUrl(int index) {
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
                    CardFormText(
                        maxLength: 128,
                        title: const ["bQ5.","n 사업장의 ","b홈페이지","n를 입력해주세요."],
                        subTitle: "별도로 운영하고 있는 사업장의 홈페이지를 입력합니다.",
                        keyboardType: TextInputType.emailAddress,
                        value: m_shops.shop_url.toString(),
                        tag: "shop_url",
                        hint: "홈페이지",
                        useSelect: false,
                        onChanged: (String tag, String value) {
                          m_shops.shop_url = value;
                          setState(() {
                            _checkValidate();
                          });
                          print(
                              "onSubmit():tag=$tag, value=$value");
                        }),

                    const SizedBox(height:50),
                    Visibility(visible: true,
                      child: Card2Buttons(
                        goPrev: true,
                        goNext: visible[curr_page_index],
                        onPrev: () => _prevPage(),
                        onNext: () => _nextPage(),
                      ),),
                    const SizedBox(height:100),
                  ],),
              ),
            )
        ),
      ],
    );
  }

  Widget StepTag(int index) {
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
                    CardEditItem(
                      title: const ["bQ7.", "n 홍보용 ","bTag","n를 추가해 주세요."],
                      subTitle: "필수 입력 항목입니다. 1개이상 추가해주세요.",
                      value: m_shops.shop_tag.toString(),
                      hint: "Tag",
                      tag: 'shop_tag',
                      onChanged: (String tag, String value) {
                        m_shops.shop_tag = value;
                        print("tag=>$value");
                        setState(() {
                          _checkValidate();
                        });
                      },
                    ),
                    const SizedBox(height:50),
                    Visibility(visible: true,
                      child: Card2Buttons(
                        goPrev: true,
                        goNext: visible[curr_page_index],
                        onPrev: () => _prevPage(),
                        onNext: () => _nextPage(),
                      ),),
                    const SizedBox(height:100),
                  ],),
              ),
            )
        ),
      ],
    );
  }

  Widget StepCategory(int index) {
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
                    CardExtraField(
                        title: const ["bQ6.","n 사업장의 ","b카테고리","n를 선택해주세요."],
                        initValue: m_shops.shop_category.toString(),
                        moims_id: "0",
                        tag: "shop_category",
                        useSelect: true,
                        selType: "코드",
                        selData: "업종",
                        useSelectTitle: "업종구분",
                        keyboardType: TextInputType.text,
                        onChanged: (String tag, String value){
                            m_shops.shop_category = value;
                            m_shops.shop_category = value;
                            setState(() {
                              _checkValidate();
                            });
                        }
                    ),
                    Visibility(visible: true,
                      child: Card2Buttons(
                        goPrev: true,
                        goNext: visible[curr_page_index],
                        onPrev: () => _prevPage(),
                        onNext: () => _nextPage(),
                      ),),
                    const SizedBox(height:100),
                  ],),
              ),
            )
        ),
      ],
    );
  }

  Widget StepPhoto(int index) {
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
                    CardPhotoEdit(
                        title: const ["bQ8.","n 사업장의 대표","b사진","n을 추가해주세요."],
                        max_count: max_photo_shop, photo_type: photo_tag_shop,
                      photo_id: m_shops.id.toString(),
                        users_id: widget.users_id.toString(),
                      message: "사업장 사진을 ($min_photo_shop~$max_photo_shop)장을 첨부해주세요.",// ${max_photo_shop}장까지 추가할 수 있습니다.",
                        onChanged: (int count, String thumnails) {
                          m_shops.shop_thumnails = thumnails;
                          m_photo_count = count;
                          setState(() {
                            _checkValidate();
                          });
                        }),
                    const SizedBox(height:100),
                    Visibility(visible: true,
                      child: Card2Buttons(
                        goPrev: true,
                        goNext: visible[curr_page_index],
                        onPrev: () => _prevPage(),
                        onNext: () => _nextPage(),
                      ),),
                    const SizedBox(height:100),
                  ],),
              ),
            )
        ),
      ],
    );
  }

  Widget StepConfirm(int index) {
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
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("사업장 등록", style: TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),),),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("회원님의 사업장 정보가 등록되었습니다.",
                        style: TextStyle(color: Colors.black, fontSize: 20))),

                    const SizedBox(height: 80),
                    Container(
                      alignment: Alignment.center,
                      child: SizedBox(
                          width: 200,
                          //height: 220,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: Image.asset("assets/icon/icon_finish3.png"))
                      ),
                    ),
                    const SizedBox(height: 50),

                    Visibility(
                      visible: visible[curr_page_index],
                      child: Center(
                        child:ElevatedButton(
                          child: const Text("확인", style:TextStyle(fontSize:16.0, color:Colors.white)),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              fixedSize: const Size(300, 48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                          onPressed:() {
                            _doUpdate();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height:100),
                  ],),
              ),
            )
        ),
      ],
    );
  }

  Future<bool> _onBackPressed(BuildContext context) {
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
        case stepName: // 사업장명칭
          visible[curr_page_index] = true;
          if(m_shops.shop_name!.isEmpty || m_shops.shop_desc!.isEmpty) {
            visible[curr_page_index] = false;
          }
          break;

        case stepAddr: // 사업장주소   .
          visible[curr_page_index] = true;
          if(m_shops.shop_addr!.isEmpty) {
            visible[curr_page_index] = false;
          }
          break;

        case stepTel: // 전화번호
          visible[curr_page_index] = true;
          if(m_shops.shop_tel!.isEmpty) {
            visible[curr_page_index] = false;
          }
          break;

        case stepUrl: // 홍보링크
          visible[curr_page_index] = true;
          //if(m_shops.shop_url!.isEmpty)
          //  visible[curr_page_index] = false;
          break;

        case stepCategory: // 사업장구분
          visible[curr_page_index] = true;
          if(m_shops.shop_category!.isEmpty) {
            visible[curr_page_index] = false;
          }
          break;

        case stepTag: // 테그
          visible[curr_page_index] = true;
          if(m_shops.shop_tag!.isEmpty) {
            visible[curr_page_index] = false;
          }
          break;

        case stepPhoto: // 사업장사진
          visible[curr_page_index] = false;
          if(m_photo_count>=min_photo_shop) {
            visible[curr_page_index] = true;
          }
          break;

        case stepConfirm: // 가입신청
          visible[curr_page_index] = true;
          break;
      }
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      curr_page_index = page;

      if(past_page_index<=curr_page_index) {
        past_page_index = curr_page_index;
      }

      visible[curr_page_index] = true;
      isPageBegin = (curr_page_index == 0) ? true : false;
      isPageLast  = (curr_page_index>=stepPageCount-1) ? true : false;

      double pos = (curr_page_index+1);
      curr_progress = pos/stepPageCount;
      _checkValidate();

      switch(curr_page_index) {
        case stepName: // 사업장명칭.
          app_title = "사업장명칭";
          break;

        case stepAddr: // 사업장주소.
          app_title = "사업장주소";
          break;

        case stepTel: // 사업장전화.
          app_title = "사업장전화";
          break;

        case stepUrl: // 홈페이지
          app_title = "홈페이지";
          break;

        case stepCategory: // 사업장분류
          app_title = "사업장분류";
          break;

        case stepTag: // 태그정보
          app_title = "태그정보";
          break;

        case stepPhoto: // 사진등록
          app_title = "사진등록";
          break;

        case stepConfirm: // 가인신청
          app_title = "등록신청";
          break;
      }
    });
  }

  void _nextPage() {
    FocusScope.of(context).unfocus();
    //if(curr_page_index==stepName) {
    //  _doAdd();
    //}
    //else {
      _pageController.animateToPage(_pageController.page!.toInt() + 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn
      );
   // }
  }

  void _prevPage() {
    FocusScope.of(context).unfocus();
    if(!isPageBegin) {
      _pageController.animateToPage(_pageController.page!.toInt() - 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn
      );
    }
    else{
      doConfirmQuit();
    }
  }

  Future <void> _doUpdate() async {
    m_shops.shop_data_ready = "Y";
    Map<String,String> params = m_shops.toMap();
    params.addAll({
      "command":"UPDATE",
    });

    await Remote.reqShops(params: params, onResponse: (bool result){
      if(result){
        m_isAdded = false;
        showToastMessage("등록되었습니다.");
        Navigator.pop(context, true);
        /*
        showDialogPop(
            context:context,
            title: "사업장등록",
            body:const Text("",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
            content:const Text("사업장이 등록되었습니다.",
              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: Colors.black),),
            choiceCount:2, yesText: "확인", cancelText: "",
            onResult:(bool isOK) async {
              if(isOK) {
                Navigator.pop(context, true);
              }
            }
        );
         */
      }

    });
  }

  Future <void> _doAdd() async {
    if(m_shops.id!.isEmpty) {
      Map<String, String> params = m_shops.toMap();
      params.addAll({
        "command": "ADD",
        "users_id": widget.users_id,
        "moims_id": "0",
      });

      await Remote.addShops(params: params, onResponse: (Shops info) {
        setState(() {
          m_shops = info;
          m_isAdded = true;
          print("_addMoims():" + m_shops.toString());
          //_nextPage();
          _pageController.animateToPage(_pageController.page!.toInt() + 1,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeIn
          );
        });
      });
    }
    else{
      _nextPage();
    }
  }

  void doConfirmQuit() {
    if(m_isAdded && m_shops.id!.isNotEmpty) {
      showDialogPop(
          context:context,
          title: "확인",
          body:const Text("작업을 중지 하시겠습니까?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
          content:const Text("작성중인 데이터는 보관되지 않습니다.",
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.black),),
          choiceCount:2, yesText: "예", cancelText: "아니오",
          onResult:(bool isOK) async {
            if(isOK) {
              await Remote.reqShops(
                  params: {"command": "DELETE", "id": "${m_shops.id}"},
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
}