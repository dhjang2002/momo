
// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Constants/Constants.dart';
import 'package:momo/Models/SalesItems.dart';
import 'package:momo/Models/SalesSumarry.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Layouts/TileCard.dart';
import 'package:momo/Shops/SalesCache.dart';
import 'package:momo/Utils/DateForm.dart';
import 'package:momo/Utils/utils.dart';

class SalesDetail extends StatefulWidget {
  final String title;
  final String moims_id;   
  final String comon_id;
  final String kind;
  final String range;
  const SalesDetail({Key? key,
    required this.moims_id,
    required this.comon_id,
    required this.title, 
    required this.kind,
    required this.range
  }) : super(key: key);

  @override
  _SalesDetailState createState() => _SalesDetailState();
}

class _SalesDetailState extends State<SalesDetail> {
  final SalesCache _salesCache = SalesCache();
  bool isReady = false;

  @override
  void initState() {

    _salesCache.clear();
    _salesCache.setTarget(comon_id: widget.comon_id, moims_id: widget.moims_id);
    _salesCache.changeKind(kind: widget.kind, comon_id: widget.comon_id);
    _salesCache.changeRange(range: widget.range);

    Future.microtask(() {
      setState(() {
        _salesCache.fetchItems(nextId: 0, onNotify: () {
          setState(() {
            print("Head:${_salesCache.head.toString()}");
            isReady = true;
          });
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.3,
          title: Text(widget.title,),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppBar_Icon,),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: _buildBody()
    );
  }

  Widget _buildBody() {

    final items   = _salesCache.cache;
    final head    = _salesCache.head;
    final loading = _salesCache.loading;
    final hasMore = _salesCache.hasMore;

    if(!isReady){
      return const Center(child: const CircularProgressIndicator(),);
    }

    // 로딩중이며 캐시에 데이터 없을때
    if(loading && items.isEmpty){
      return const Center(child:CircularProgressIndicator());
    }

    // 로딩중이 아닌데, 캐시에 아무것도 없음.
    if(!loading && items.isEmpty){
      return const Center(
        child: const Text("데이터가 없습니다.",
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey)),
      );
    }

    return Container(
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: items.length+1, //리스트의 개수
        itemBuilder: (BuildContext context, int index) {
          if(index<items.length) {
              return _itemCard((index==0), items[index], head);
          }

          if(!loading && hasMore) {
            Future.microtask(() {
              setState(() {
                _salesCache.fetchItems(nextId: index, onNotify: () {
                  setState(() {
                  });
                });
              });
            });
          }

          if (!hasMore) {
            return const Center(child: Icon(Icons.arrow_drop_up));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
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
            borderRadius: BorderRadius.circular(15.0)
        ),
        child: Row(
          children: [
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("거래건수: ",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 15.0),),
                  Text(currencyFormat(sumarry.count.toString())+"건",
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0),),
                ]
            ),
            Spacer(),
            Row(
                //mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  const Text("거래금액: ",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 15.0),),
                  Text(currencyFormat(sumarry.total.toString())+"원",
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0),),
                ]
            )
          ],
        ),
      ),
    );
  }

  Widget _itemCard(bool hasHead, SalesItems info, SalesSumarry sumarry) {
    String url = "";
    List<String> thumnails = info.thumnails.toString().split(";");
    if(thumnails.isNotEmpty && thumnails.elementAt(0).isNotEmpty) {
      url = URL_HOME + thumnails.elementAt(0);
    }
    return Column(
      children: [
        (hasHead) ? _headHead(sumarry) : Container(),
        const Divider(height: 12.0,),
        TileCard(
          key: GlobalKey(),
          padding: const EdgeInsets.fromLTRB(15,10,15,10),
          title: Container(
            padding: const EdgeInsets.only(right:10, bottom: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info.shop_name.toString()+"(${info.shop_owner})",
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 18.0),),
                const SizedBox(height: 15,),
                Row(children: [
                  const Text("거래항목: ",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.normal, fontSize: 16.0),),
                  Text(info.item.toString(),
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0),),
                ],),

                const SizedBox(height: 5,),
                Row(children: [
                  const Text("거래금액: ",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.normal, fontSize: 16.0),),
                  Text(currencyFormat(info.price.toString())+"원",
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0),),
                ],),

                const SizedBox(height: 5,),
                Row(children: [
                  const Text("구입회원: ",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.normal, fontSize: 16.0),),
                  Text(info.customer.toString(),
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0),),
                ],),

                const SizedBox(height: 5,),
                Row(children: [
                  const Text("등록일자: ",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.normal, fontSize: 16.0),),
                  Text(DateForm().parse(info.created_at.toString()).getVisitDay(),
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0),),
                ],),
              ],
            ),
          ),
          tailing: (url.isNotEmpty) ? const Icon(Icons.list_alt_outlined, size:24, color: Colors.green,):Container(),
          onTrailing: ()=> showPhotoUrl(context: context, title:"영수증", type:photo_tag_sales, id:info.id.toString()),
        ),
      ],
    );
  }

}
