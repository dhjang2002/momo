// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:momo/Constants/Constants.dart';
import 'package:momo/Controller/ColtrollerStatusChange.dart';
import 'package:momo/Models/SalesItems.dart';
import 'package:momo/Models/SalesSumarry.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Layouts/TileCard.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Shops/SalesCache.dart';
import 'package:momo/Shops/SalesDetail.dart';
import 'package:momo/Utils/DateForm.dart';
import 'package:momo/Utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class SalesReportPage extends StatefulWidget {
  final String title;
  final String moims_id;
  ControllerStatusChange? controller;
  SalesReportPage({
    Key? key,
    required this.moims_id,
    required this.title,
    this.controller,
  }) : super(key: key);

  @override
  _SalesReportPageState createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> with AutomaticKeepAliveClientMixin {

  // 검색기간
  final List<String> _listSalesRange = [
    "ALL",
    "THIS_WEEK",
    "LAST_WEEK",
    "THIS_MONTH",
    "LAST_MONTH",
    "THIS_YEAR",
    "LAST_YEAR"
  ];

  final List<String> _listMenuRange = [
    '전체',
    '이번주',
    '지난주',
    '이번달',
    '지난달',
    '금년',
    '작년',
  ];

// 거래유형
  final List<String> _listSalesKind = [
    "LIST_ALL",
    "LIST_SALES",
    "LIST_BUYS",
    "MY_SALES",
    "MY_BUYS"
  ];

  final List<String> _listMenuKind = [
    '거래현황',
    '판매현황',
    '구매현황',
    '내 판매현황',
    '내 구매현황',
  ];

  final SalesCache _salesCache = SalesCache();

  String _selectedKind   = "거래현황";
  String _selectedRange  = "전체";
  String _currRange = "ALL";
  String _users_id = "";

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _users_id = Provider.of<LoginInfo>(context, listen: false).users_id.toString();
      _salesCache.setTarget(comon_id: _users_id, moims_id: widget.moims_id);
      _salesCache.fetchItems(
          nextId: 0,
          onNotify: () {
            setState(() {
              print("Head:${_salesCache.head.toString()}");
              //ready = true;
            });
          });
    });
    if (widget.controller != null) {
      widget.controller!.addListener(() {
        switch(widget.controller!.action){
          case ControllerStatusChange.aFrontView:
            break;
          case ControllerStatusChange.aBackView:
            break;
          case ControllerStatusChange.aInvalidate:{
            _salesCache.setTarget(comon_id: _users_id, moims_id: widget.moims_id);
            _salesCache.clear();
            _salesCache.fetchItems(
                nextId: 0,
                onNotify: () {
                  setState(() {
                    //print("Head:${_salesCache.head.toString()}");
                    //ready = true;
                  });
                });
            break;
          }
        }
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildCategiry() {
    return Container(
      width: double.infinity,
      color: Colors.white,
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          children: [
            _kindSelect(),
            _rangeSelect(),
            const Spacer(),
          ],
        ));
  }

  Widget _rangeSelect() {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        isExpanded: true,
        items: _listMenuRange.map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                )).toList(),
        value: _selectedRange,
        onChanged: (value) {
            if (_selectedRange != value.toString()) {
              _selectedRange = value.toString();
              _currRange = _listSalesRange[_listMenuRange.indexOf(_selectedRange)];
              _salesCache.changeRange(range: _currRange);
              _salesCache.fetchItems(
                  nextId: 0,
                  onNotify: () {
                    setState(() {});
                  });
            }
        },
        icon: const Icon(Icons.calendar_today,),
        iconSize: 20,
        iconEnabledColor: Colors.black,
        iconDisabledColor: Colors.grey,
        buttonHeight: 30,
        buttonWidth: 130,
        buttonPadding: const EdgeInsets.only(left: 15, right: 15),
        buttonDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: Colors.white,
          ),
          color: Colors.white,
        ),
        buttonElevation: 0,
        itemHeight: 35,
        //itemWidth: 130,
        itemPadding: const EdgeInsets.only(left: 14, right: 14),
        dropdownMaxHeight: 500,
        dropdownPadding: null,
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
        ),
        dropdownElevation: 8,
        scrollbarRadius: const Radius.circular(40),
        scrollbarThickness: 6,
        scrollbarAlwaysShow: true,
        offset: const Offset(-20, 0),
      ),
    );
  }

  Widget _kindSelect() {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        isExpanded: true,
        items: _listMenuKind.map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                )).toList(),
        value: _selectedKind,
        onChanged: (value) {
          if (_selectedKind != value.toString()) {
            _selectedKind = value.toString();
            _salesCache.changeKind(
                kind: _listSalesKind[_listMenuKind.indexOf(_selectedKind)],
                comon_id: _users_id);
            _salesCache.fetchItems(
                nextId: 0,
                onNotify: () {
                  setState(() {});
                });
          }
        },
        icon: const Icon(Icons.arrow_drop_down,),
        iconSize: 20,
        iconEnabledColor: Colors.black,
        iconDisabledColor: Colors.grey,
        buttonHeight: 30,
        buttonWidth: 130,
        buttonPadding: const EdgeInsets.only(left: 15, right: 15),
        buttonDecoration: BoxDecoration(borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.white,),
          color: Colors.white,
        ),
        buttonElevation: 0,
        itemHeight: 35,
        //itemWidth: 130,
        itemPadding: const EdgeInsets.only(left: 14, right: 14),
        dropdownMaxHeight: 500,
        dropdownPadding: null,
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
        ),
        dropdownElevation: 8,
        scrollbarRadius: const Radius.circular(40),
        scrollbarThickness: 6,
        scrollbarAlwaysShow: true,
        offset: const Offset(-20, 0),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategiry(),
        const Divider(height: 1,),
        Expanded(
          child: _renderListView(),
        )
      ],
    );
  }

  Widget _renderListView() {
    final items = _salesCache.cache;
    final head = _salesCache.head;
    final loading = _salesCache.loading;
    final hasMore = _salesCache.hasMore;

    // 로딩중이며 캐시에 데이터 없을때
    if (loading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 로딩중이 아닌데, 캐시에 아무것도 없음.
    if (!loading && items.isEmpty) {
      return const Center(
        child: const Text("데이터가 없습니다.",
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey)),
      );
    }

    //print("_renderListView():provider.cache.length=${items.length}");
    return Container(
        color: Colors.white,
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: items.length + 1, //리스트의 개수
            itemBuilder: (BuildContext context, int index) {
              if (index < items.length) {
                if (_salesCache.isItems) {
                  return _itemCard((index == 0), items[index], head);
                } else {
                  return _sumarryCard((index == 0), items[index], head);
                }
              }

              print("index=$index, loading=$loading, hasMore=$hasMore");
              if (!loading && hasMore) {
                Future.microtask(() {
                  _salesCache.fetchItems(
                      nextId: index,
                      onNotify: () {
                        setState(() {});
                      });
                });
              }

              if (!hasMore) {
                return const Center(child: Icon(Icons.arrow_drop_up));
              }

              return const Center(child: CircularProgressIndicator());
            }));
  }

  Widget _headHead(SalesSumarry sumarry) {
    return Container(
      margin: const EdgeInsets.all(3),
      child: Container(
        padding: const EdgeInsets.all(10),
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.orange.shade100,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(15.0)),
        child: Row(
          children: [
            Expanded(
              flex: 40,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "거래건수: ",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 16.0),
                  ),
                  Text(
                    sumarry.count.toString() + "건",
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 60,
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "거래금액: ",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 16.0),
                  ),
                  Text(
                    currencyFormat(sumarry.total.toString()) + "원",
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _itemCard(bool hasHead, SalesItems info, SalesSumarry head) {
    String url = "";
    List<String> thumnails = info.thumnails.toString().split(";");
    if (thumnails.isNotEmpty && thumnails.elementAt(0).isNotEmpty) {
      url = URL_HOME + thumnails.elementAt(0);
    }
    return Column(
      children: [
        (hasHead) ? _headHead(head) : Container(),
        const Divider(
          height: 12.0,
        ),
        TileCard(
          key: GlobalKey(),
          padding: const EdgeInsets.fromLTRB(15,10,15,10),
          title: Container(
            padding: const EdgeInsets.only(right: 10, bottom: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.shop_name.toString() + "(${info.shop_owner})",
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 18.0),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const Text(
                      "거래항목: ",
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                          fontSize: 16.0),
                    ),
                    Text(
                      info.item.toString(),
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const Text(
                      "거래금액: ",
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                          fontSize: 16.0),
                    ),
                    Text(
                      currencyFormat(info.price.toString()) + "원",
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const Text(
                      "구입회원: ",
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                          fontSize: 16.0),
                    ),
                    Text(
                      info.customer.toString(),
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const Text(
                      "등록일자: ",
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                          fontSize: 16.0),
                    ),
                    Text(DateForm().parse(info.created_at.toString()).getVisitDay(),
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
          tailing: (url.isNotEmpty)
              ? const Icon(
                  Icons.list_alt_outlined,
                  size: 32,
                  color: Colors.green,
                )
              : Container(),
          onTrailing: () => showPhotoUrl(context: context, title:"영수증", type:photo_tag_sales, id:info.id.toString()),
        ),
      ],
    );
  }

  Widget _sumarryCard(bool hasHead, SalesSumarry info, SalesSumarry head) {
    return Column(
      children: [
        (hasHead) ? _headHead(head) : Container(),
        const Divider(height: 12.0,),
        
        TileCard(
          key: GlobalKey(),
          padding: const EdgeInsets.fromLTRB(15,10,15,10),
          title: Container(
            padding: const EdgeInsets.only(right: 10, bottom: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.owner_name.toString(),
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 18.0),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const Text(
                      "거래건수: ",
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                          fontSize: 16.0),
                    ),
                    Text(
                      info.count.toString(),
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const Text(
                      "거래금액: ",
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                          fontSize: 16.0),
                    ),
                    Text(
                      info.total.toString(),
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
          tailing: const Icon(Icons.navigate_next, size: 32, color: Colors.black,),
          onTab: () {},
          onTrailing: () => _onDetail(info),
        ),
      ],
    );
  }

  void _onDetail(SalesSumarry info) {
    String kind = (_salesCache.kind == "LIST_BUYS") ? "MY_BUYS" : "MY_SALES";
    Navigator.push(
      context,
      Transition(
          child: SalesDetail(
            title: "상세내역",
            comon_id: info.owner_id.toString(),
            kind:  kind,
            range: _salesCache.range,
            moims_id: widget.moims_id,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
  }
}
