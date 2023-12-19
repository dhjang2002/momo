// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Constants/Constants.dart';
import 'package:momo/Layouts/Card2Buttons.dart';
import 'package:momo/Layouts/CardFormCheck.dart';
import 'package:momo/Layouts/CardFormText.dart';
import 'package:momo/Layouts/CardPhotoSales.dart';
import 'package:momo/Models/Moims.dart';
import 'package:momo/Models/SalesItems.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/utils.dart';
import 'package:provider/provider.dart';

const int stepMoim        = 0;  // 모임선택.
const int stepInfo        = 1;  // 상품명
const int stepPhoto       = 2;  // 상품명
const int stepConfirm     = 3;  // 가입하기.

const int stepPageCount       = 4;

class SalesRegist extends StatefulWidget {
  final String shops_id;
  final String owner_id;
  const SalesRegist({ Key? key,
    required this.shops_id,
    required this.owner_id
  }) : super(key: key);

  @override
  State<SalesRegist> createState() => _SalesRegistState();
}

class _SalesRegistState extends State<SalesRegist> {

  bool m_moimsLoaded = false;
  List<Moims> _moimsList = <Moims>[];
  final List<String> _moimsArray = <String>[];
  final List<SalesItems> _salesList = <SalesItems>[];
  List<String> type_ids = <String>[];
  int m_photo_count = 0;

  bool m_isAdded = false;
  bool isPageBegin = true;
  bool isPageLast = false;
  int curr_page_index = 0;
  int past_page_index = 0;

  final PageController _pageController = PageController(initialPage: 0);
  String targetMoims = "";

  String app_title = "거래등록";
  var visible = List.filled(stepPageCount, false, growable: false);

  late SalesItems _salesInfo;
  late LoginInfo loginInfo;

  @override
  void initState() {
    loginInfo = Provider.of<LoginInfo>(context, listen: false);
    _salesInfo =
        SalesItems(customer_id: loginInfo.users_id, shops_id: widget.shops_id, owner_id: widget.owner_id);
    _fetchTogetherMoims();
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
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () => _onBackPressed(context),
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: AppBar_Color,
              elevation: 1.0,
              title: Text(app_title),
              leading: Visibility(
                visible: true,
                child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: AppBar_Icon,),
                    // (isPageBegin) ? Icons.close :
                    onPressed: () {
                      _prevPage();
                    }
                ),
              ),
              actions: [
                Visibility(
                  visible: (isPageBegin) ? false : true,
                  child: IconButton(
                      icon: const Icon(Icons.close, color: AppBar_Icon),
                      onPressed: () {
                        doConfirmQuit();
                      }
                  ),
                ),
              ],
            ),
            body: (m_moimsLoaded)
                ? Column(
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
                          physics: const NeverScrollableScrollPhysics(),
                          // disable swipe
                          onPageChanged: (int index) {
                            _onPageChanged(index);
                          },

                          itemCount: stepPageCount,
                          itemBuilder: (BuildContext context, int index) {
                            switch (index) {
                              case stepInfo: // 상품명
                                return StepInfo(index); // maxLength: 7,사진
                              case stepPhoto:
                                return StepPhoto(index);
                              case stepMoim:
                                return StepMoims(index);
                              case stepConfirm: // 생성확인
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
            )
                : const Center(child: CircularProgressIndicator())
        ),
      ),
    );
  }

  Widget StepMoims(int index) {
    return Stack(
      children: [
        Positioned(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(15),
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("협업기록", style: TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),),),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("어떤 모임에 저장할까요?",
                        style: TextStyle(color: Colors.black, fontSize: 20),),),
                    const SizedBox(height: 30,),
                    CardFormCheck(
                      title: const ["bS1. ", "b모임", "n 선택"],
                      subTitle: "협업은 모임별로 관리됩니다. 회원님과 같이 활동하는 모임을 모두 선택해 주세요.",
                      value: targetMoims,
                      aList: _moimsArray,
                      onSubmit: (String tag, String value) {
                        targetMoims = value;
                        print("CardFormCheck:onSubmit() value=$value");
                        setState(() {
                          _checkValidate();
                        });
                      },
                    ),

                    const SizedBox(height: 50),
                    Visibility(
                      visible: visible[curr_page_index],
                      child: Center(
                        child: ElevatedButton(
                          child: const Text("다음단계", style: const TextStyle(
                              fontSize: 16.0, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              fixedSize: const Size(300, 48),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                          onPressed: () {
                            _salesList.clear();
                            List<String> moims = targetMoims.split(";");
                            for (var element in moims) {
                              String moims_id = _getMoimId(element);
                              if (moims_id.isNotEmpty) {
                                _salesList.add(SalesItems(
                                    moims_id: moims_id,
                                    customer_id: loginInfo.users_id,
                                    shops_id: widget.shops_id,
                                  owner_id: widget.owner_id
                                ));
                              }
                            }
                            _doAddGroup();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],),
              ),
            )
        ),
      ],
    );
  }

  Widget StepInfo(int index) {
    return Stack(
      children: [
        Positioned(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(15),
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("협업기록", style: TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),),),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("협업 내용을 기재해주세요.",
                        style: TextStyle(color: Colors.black, fontSize: 20),),),
                    const SizedBox(height: 30,),
                    // 거래내역 
                    CardFormText(
                        maxLength: 64,
                        title: const ["bS2.", "b 거래내역"],
                        subTitle: "(예: 상품구입/식사/주유)",
                        keyboardType: TextInputType.text,
                        value: _salesInfo.item.toString(),
                        tag: "item",
                        hint: "물품구매/식사/주유",
                        useSelect: false,
                        onChanged: (String tag, String value) {
                          _salesInfo.item = value;
                          for (int index = 0; index <
                              _salesList.length; index++) {
                            _salesList[index].item = value;
                          }
                          setState(() {
                            _checkValidate();
                          });
                        }),
                    const SizedBox(height: 10),

                    // 거래금액 
                    CardFormText(
                        maxLength: 9,
                        title: const ["bS3.", "b 거래금액"],
                        subTitle: "금액은 1,000원 단위로 입력해주세요.",
                        keyboardType: TextInputType.number,
                        value: _salesInfo.price.toString(),
                        tag: "price",
                        hint: "금액",
                        useSelect: false,
                        onChanged: (String tag, String value) {

                          // int iPrice = int.parse(value);
                          // if(iPrice<1 || iPrice>999999999) {
                          //   visible[curr_page_index] = false;
                          // }

                          _salesInfo.price = value;

                          for (int index = 0; index <
                              _salesList.length; index++) {
                            _salesList[index].price = value;
                          }
                          setState(() {
                            _checkValidate();
                          });
                          print(
                              "onSubmit():tag=$tag, value=$value");
                        }),

                    const SizedBox(height: 50),

                    Visibility(visible: true,
                      child: Card2Buttons(
                        goPrev: true,
                        goNext: visible[curr_page_index],
                        onPrev: () => _prevPage(),
                        onNext: () => _nextPage(),
                      ),),
                    const SizedBox(height: 100),
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
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("협업기록", style: TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),),),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("영수증 사진을 첨부해주세요.",
                        style: TextStyle(color: Colors.black, fontSize: 20),),),
                    const SizedBox(height: 30,),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: CardPhotoSales(
                          title: const ["bS4.", "b 영수증"],
                          max_count: max_photo_sales,
                          photo_type: photo_tag_sales,
                          users_id: _salesInfo.customer_id!,
                          photo_ids: type_ids,
                          message: "거래 금액을 확인할 수 있도록 촬영해 주세요.",
                          onChanged: (int count, int index, String thumnails) {
                            m_photo_count = count;
                            _salesList[index].thumnails = thumnails;
                            if(index==0) {
                              _salesInfo.thumnails = thumnails;
                            }
                            setState(() {
                              _checkValidate();
                            });
                          }),
                    ),

                    const SizedBox(height: 50),
                    Visibility(visible: true,
                      child: Card2Buttons(
                        goPrev: true,
                        goNext: visible[curr_page_index],
                        onPrev: () => _prevPage(),
                        onNext: () => _nextPage(),
                      ),),
                    const SizedBox(height: 100),
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
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("협업기록", style: TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),),),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.only(left: 10),
                      child: const Text("거래내역이 저장되었습니다.",
                        style: TextStyle(color: Colors.black, fontSize: 20),),),
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
                        child: ElevatedButton(
                          child: const Text("확인", style: const TextStyle(
                              fontSize: 16.0, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              fixedSize: const Size(300, 48),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                          onPressed: () {
                            _updateGroup();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],),
              ),
            )
        ),
      ],
    );
  }

  String _getMoimId(String moim_name) {
    String id = "";
    for (var element in _moimsList) {
      if (moim_name == element.moim_name) {
        id = element.id.toString();
        break;
      }
    }
    return id;
  }

  Future <void> _fetchTogetherMoims() async {
    // "Owner", "Member", "Joinable"
    Remote.getMoims(
        params: {
          "command": "LIST",
          "list_attr": "Visit",
          "users_id": loginInfo.users_id.toString(),
          "shop_id": widget.shops_id
        },
        onResponse: (List<Moims> list) {
          setState(() {
            _moimsList = list;
            targetMoims = "";

            for (var element in _moimsList) {
              String name = element.moim_name!;
              _moimsArray.add(name);
              /*
              if (targetMoims.isNotEmpty) {
                targetMoims += ";";
              }
              targetMoims += name;

               */
              m_moimsLoaded = true;
              visible[0] = true;
            }

          });
        });
  }

  Future<bool> _onBackPressed(BuildContext context) {
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
        case stepMoim: // 모임선택
          visible[curr_page_index] = true;
          if (targetMoims.isEmpty) {
            visible[curr_page_index] = false;
          }
          break;

        case stepInfo: // 구매정보
          visible[curr_page_index] = true;
          if (_salesInfo.item!.isEmpty || _salesInfo.price!.isEmpty) {
            visible[curr_page_index] = false;
          }

          break;

        case stepPhoto: // 영수증    .
          visible[curr_page_index] = true;
          //if(m_photo_count>0) {
          //  visible[curr_page_index] = true;
          //}
          break;

        case stepConfirm: // 등록결과
          visible[curr_page_index] = true;
          break;
      }
    });
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

      _checkValidate();

      switch (curr_page_index) {
        case stepInfo: // 거래정보.
          app_title = "거래등록";
          break;

        case stepPhoto: // 영수증.
          app_title = "거래등록";
          break;

        case stepMoim: // 모임선택.
          app_title = "거래등록";
          break;

        case stepConfirm: // 등록확인
          app_title = "거래등록";
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

  Future <void> _prevPage() async {
    FocusScope.of(context).unfocus();

    if(_pageController.page!.toInt()-1 == stepMoim) {
      await _deleteAll();
    }

    if (!isPageBegin) {
      _pageController.animateToPage(_pageController.page!.toInt() - 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn
      );
    }
    else {
      doConfirmQuit();
    }
  }

  Future <void> _updateGroup() async {
    for(int index=0; index<_salesList.length; index++) {
      await _doUpdate(_salesList[index]);
    }

    m_isAdded = false;
    showToastMessage("등록되었습니다.");
    Navigator.pop(context, true);
    /*
    showDialogPop(
        context: context,
        title: "등록확인",
        body: const Text("",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
        content: const Text("거래내역이 저장되었습니다.",
          style: const TextStyle(fontWeight: FontWeight.normal,
              fontSize: 15,
              color: Colors.black),),
        choiceCount: 2,
        yesText: "확인",
        cancelText: "",
        onResult: (bool isOK) async {
          if (isOK) {
            Navigator.pop(context, true);
          }
        }
    );

     */
  }

  Future <bool> _doUpdate(SalesItems info) async {
    Map<String, String> params = info.toAddMap();
    params.addAll({
      "command": "UPDATE",
    });
    bool rtn = false;
    await Remote.reqSalesItems(
        params: params,
        onResponse: (bool result) {
          rtn = result;
        });
    return rtn;
  }

  void _setPhotoIds() {
    type_ids.clear();
    for (var element in _salesList) {
      type_ids.add(element.id.toString());
    }

    print("_setPhotoIds():type_ids=${type_ids.toString()}");
  }

  Future <void> _doAddGroup() async {

    for(int index=0; index<_salesList.length; index++) {
        await _doAdd(index, _salesList[index]);
        await Future.delayed(const Duration(milliseconds: 50));
    }

    //if(count==_salesList.length){
    m_isAdded  = true;
    //}
    _setPhotoIds();
    _nextPage();
  }

  Future <void> _doAdd(int index, SalesItems info) async {

    if(info.id!.isEmpty) {
      Map<String, String> params = info.toAddMap();
      params.addAll({"command": "ADD",});
      await Remote.addSalesItems(params: params, onResponse: (SalesItems info) {
        print("<<<>>> addSalesItems($index): id=" + info.id.toString());
        //setState(() {
          if(index==0) {
            _salesInfo = info;
          }
          _salesList[index] = info;
        //});
      });
    }
  }

  Future <void> _deleteAll() async {
    for (int index=0; index< _salesList.length; index++)  {
      await Remote.reqSalesItems(
          params: {"command": "DELETE", "id": "${_salesList[index].id}"},
          onResponse: (bool result) {});
      await Future.delayed(const Duration(milliseconds: 10));
    }
    _salesList.clear();
  }

  void doConfirmQuit() {
    if(m_isAdded) {
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
              await _deleteAll();
              Navigator.pop(context);
            }
          }
        );
    }
    else{
      Navigator.pop(context);
    }
  }
}