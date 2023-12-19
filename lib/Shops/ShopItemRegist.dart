// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Constants/Constants.dart';
import 'package:momo/Layouts/Card2Buttons.dart';
import 'package:momo/Layouts/CardFormText.dart';
import 'package:momo/Layouts/CardPhotoEdit.dart';
import 'package:momo/Models/ShopItems.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/utils.dart';
import 'package:provider/provider.dart';

const int step0Name        = 0;  // 상품명 
const int step1Price       = 1;  // 가격 
const int step2Desc        = 2;  // 설명 
const int step3Url         = 3;  // 홈페이지
const int step4Photo       = 4;  // 사진등록.
const int step5Confirm     = 5;  // 가입하기.

const int stepCount        = 6;

class ShopItemRegist extends StatefulWidget {
  final String shop_id;
  const ShopItemRegist({ Key? key,
    required this.shop_id
  }) : super(key: key);

  @override
  State<ShopItemRegist> createState() => _ShopItemRegistState();
}

class _ShopItemRegistState extends State<ShopItemRegist> {
  int m_photo_count = 0;

  ShopItems m_items = ShopItems();
  double curr_progress = 0.0;
  bool m_isAdded = false;
  bool isPageBegin = true;
  bool isPageLast  = false;
  int  curr_page_index = 0;
  int  past_page_index = 0;

  final PageController _pageController = PageController(initialPage: 0);

  String app_title = "상품등록 (1/5)";
  var visible = List.filled(stepCount, false, growable: false);

  late LoginInfo loginInfo;
  @override
  void initState() {
    loginInfo = Provider.of<LoginInfo>(context, listen:false);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { FocusScope.of(context).unfocus();},
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

                            itemCount: stepCount,
                            itemBuilder: (BuildContext context, int index) {
                              switch (index) {
                                case step0Name:           // 상품명
                                  return StepName(index);
                                case step1Price:           // 사업장주소
                                  return StepPrice(index);
                                case step2Desc:            // 사업장전화 .
                                  return StepDesc(index);
                                case step3Url:            // 사업장 홈페이지
                                  return StepUrl(index);   // maxLength: 7,
                                case step4Photo:
                                  return StepPhoto(index); // 사진
                                case step5Confirm:         // 생성확인
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
                        title: const ["bQ1.", "b 상품명","n을 입력해주세요."],
                        subTitle: "",
                        keyboardType: TextInputType.text,
                        value: m_items.item_name.toString(),
                        tag: "item_name",
                        hint: "상품명",
                        useSelect: false,
                        onChanged: (String tag, String value) {
                          m_items.item_name = value;
                          setState(() {
                            _checkValidate();
                          });
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
  Widget StepPrice(int index) {
    if(m_items.item_price=="0") {
      m_items.item_price = "";
    }
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
                        maxLength: 9,
                        title: const ["bQ2.", "b 판매가격","n을 입력해주세요."],
                        subTitle: "",
                        keyboardType: TextInputType.number,
                        value: m_items.item_price.toString(),
                        tag: "item_price",
                        hint: "판매가격",
                        useSelect: false,
                        onChanged: (String tag, String value) {
                          m_items.item_price = value;
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
  Widget StepDesc(int index) {
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
                        maxLength: 8192,
                        title: const ["bQ3. ","n 상품의 ","b설명","n을 입력해주세요."],
                        subTitle: "",
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        value: m_items.item_desc.toString(),
                        tag: "item_desc",
                        hint: "상품설명",
                        useSelect: false,
                        onChanged: (String tag, String value) {
                          m_items.item_desc = value;
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
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("홈페이지", style: TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),),),
                    const SizedBox(height:20),

                    CardFormText(
                        maxLength: 255,
                        title: const ["bQ4.", "n 상품의 ","b홈페이지","n를 입력해주세요."],
                        subTitle: "",
                        keyboardType: TextInputType.emailAddress,
                        value: m_items.item_url.toString(),
                        tag: "item_url", hint: "홈페이지",
                        useSelect: false,
                        onChanged: (String tag, String value) {
                          m_items.item_url = value;
                          setState(() {
                            _checkValidate();
                          });
                        }),

                    const SizedBox(height:50),
                    Visibility(visible: true,
                      child: Card2Buttons(
                        goPrev: true,
                        goNext: visible[curr_page_index],
                        onPrev: () =>_prevPage(),
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
                  children: [
                    CardPhotoEdit(
                        title: const ["bQ5.","n 상품의 대표 ","b사진","n을 추가해 주세요."],
                        max_count: max_photo_item, photo_type: photo_tag_item,
                        photo_id: m_items.id.toString(),
                        users_id: loginInfo.users_id!,
                    message: "상품 사진($min_photo_item~$max_photo_item)을 첨부해주세요.",
                      onChanged: (int count, String thumnails) {
                        m_photo_count = count;
                        m_items.item_thumnails = thumnails;
                        setState(() {
                          _checkValidate();
                        });
                    }),

                    const SizedBox(height:50),
                    Visibility(visible: true,
                      child: Card2Buttons(
                        goPrev: true,
                        goNext: visible[curr_page_index],
                        onPrev: () =>_prevPage(),
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
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("상품 등록", style: TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),),),
                    const SizedBox(height: 15),
                    Container(
                        padding: const EdgeInsets.only(left: 10),
                        child: const Text("상품정보가 등록되었습니다.",
                            style: TextStyle(color: Colors.black, fontSize: 20))),
                    const SizedBox(height: 80),
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
                        child:ElevatedButton(
                          child: const Text("확인", style:const TextStyle(fontSize:16.0, color:Colors.white)),
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
        case step0Name: // 상품명
          visible[curr_page_index] = true;
          if(m_items.item_name!.isEmpty) {
            visible[curr_page_index] = false;
          }
          break;

        case step1Price: // 상품가격   .
          visible[curr_page_index] = true;
          if(m_items.item_price!.isEmpty) {
            visible[curr_page_index] = false;
          }
          break;

        case step2Desc: // 상품설명
          visible[curr_page_index] = true;
          if(m_items.item_desc!.isEmpty) {
            visible[curr_page_index] = false;
          }
          break;

        case step3Url: // 홍보링크
          visible[curr_page_index] = true;
          break;

        case step4Photo: // 상품사진
          visible[curr_page_index] = false;
          if(m_photo_count>=min_photo_item) {
            visible[curr_page_index] = true;
          }
          break;

        case step5Confirm: // 등록
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
      isPageLast  = (curr_page_index>=stepCount-1) ? true : false;

      double pos = (curr_page_index+1);
      curr_progress = pos/stepCount;
      _checkValidate();

      switch(curr_page_index) {
        case step0Name: // 상품명.
          app_title = "상품명 (1/5)";
          break;

        case step1Price: // 상품가격.
          app_title = "상품가격 (2/5)";
          break;

        case step2Desc: // 상품설명.
          app_title = "상품설명 (3/5)";
          break;

        case step3Url: // 홍보링크
          app_title = "홍보링크 (4/5)";
          break;

        case step4Photo: // 상품사진
          app_title = "상품사진 (5/5)";
          break;

        case step5Confirm: // 등록신청
          app_title = "등록신청";
          break;
      }
    });
  }

  void _nextPage() {
    FocusScope.of(context).unfocus();
    _pageController.animateToPage(_pageController.page!.toInt() + 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn
    );
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
    m_items.item_data_ready = "Y";
    Map<String,String> params = m_items.toMap();
    params.addAll({
      "command":"UPDATE",
    });

    await Remote.reqShopItems(params: params, onResponse: (bool result){
      if(result){
        m_isAdded = false;
        showToastMessage("등록되었습니다.");
        Navigator.pop(context, true);
      }
    });
  }

  Future <void> _doAdd() async {
    if(m_items.id!.isEmpty) {
      Map<String, String> params = m_items.toMap();
      params.addAll({
        "command": "ADD",
        "shops_id": widget.shop_id,
        "users_id": loginInfo.users_id!,
      });

      await Remote.addShopItems(params: params, onResponse: (ShopItems info) {
        setState(() {
          m_items = info;
          m_isAdded = true;
          print("_addMoims():" + m_items.toString());
          _nextPage();
        });
      });
    }
    else{
      _nextPage();
    }
  }

  void doConfirmQuit() {
    if(m_isAdded && m_items.id!.isNotEmpty) {
      showDialogPop(
          context:context,
          title: "확인",
          body:const Text("작업을 중지 하시겠습니까?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
          content:const Text("작성중인 데이터는 보관되지 않습니다.",
            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.black),),
          choiceCount:2, yesText: "예", cancelText: "아니오",
          onResult:(bool isOK) async {
            if(isOK) {
              await Remote.reqShopItems(
                  params: {"command": "DELETE", "id": "${m_items.id}"},
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