// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Constants/Constants.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Layouts/TileCard.dart';
import 'package:momo/Models/Shops.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Utils/utils.dart';
import 'package:momo/Shops/MyShopsTab.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';
import 'ShopRegist.dart';

class MyShopList extends StatefulWidget {
  final String title;
  final String target;    // "Owner", "Member", "Moims"
  final String id;

  const MyShopList({Key? key,
    required this.title,
    required this.target,
    required this.id
  }) : super(key: key);

  @override
  _MyShopListState createState() => _MyShopListState();

}

class _MyShopListState extends State<MyShopList> {

  bool _bDirty = false;

  bool _bShopList = false;
  late List<Shops> _shopList;

  late LoginInfo _loginInfo;
  
  @override
  void initState() {
    super.initState();
    _loginInfo = Provider.of<LoginInfo>(context, listen:false);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _onBackPressed(context),
        child: Scaffold(
          backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(widget.title,),
              leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: AppBar_Icon,
                  ),
                  onPressed: () {
                    Navigator.pop(context, _bDirty);
                  }),
              actions: [
                Visibility(
                  visible: false, //(!bSearch) ? true : false,
                  child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                      }),
                ),
              ],
            ),
            body: _buildBody(),
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                _onAddShops();
                },
              ),
        )
    );
  }

  Widget _buildBody() {
    if(!_bShopList) {
      return const Center(child: CircularProgressIndicator());
    }

    if(_shopList.isEmpty){
      return const Center(
        child: Text("데이터가 없습니다.",
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey)),
      );
    }

    return Container(
        color:Colors.white,
        child: Column(
          children: [
            _buildListCount(),
            Expanded(child: _renderListView()),
          ],
        )
    );
  }
  Widget _buildListCount() {
    if(!_bShopList) {
      return const Center(child: CircularProgressIndicator());
    }

    String listTitle = "등록 사업장 (${_shopList.length})";
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(15,15,0,10),
        //color: (widget.isListMode) ? Colors.orangeAccent : Colors.green,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(listTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
          ],
        ));
  }

  Widget _renderListView() {
    if(_shopList.isNotEmpty) {
      return Container(
        color: Colors.white,
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          //physics: ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          itemCount: _shopList.length,
          itemBuilder: (BuildContext context, int index) {
            return _itemCard(index);
            //return BuildItemCard(index);
          },
        ),
      );
    }
    
    return const Center(
      child: Text("데이터가 없습니다.",
          style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey)),
    );
  }
  
  Widget _itemCard(int index){
    Shops info = _shopList.elementAt(index);
    List<String> thumnails = info.shop_thumnails.toString().split(";");
    String url = URL_HOME + thumnails.elementAt(0);
    return Column(
        children: [
          TileCard(
            key: GlobalKey(),
            leading: SizedBox(
                height: 50, width: 50,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: simpleBlurImageWithName(info.shop_name.toString(), 28, url, 1)
                )),
            title: Text(
              info.shop_name.toString(),
              maxLines: 1,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0),
            ),
            subtitle: Text(
              info.shop_desc.toString(),
              maxLines: 1,
              style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                  fontSize: 14.0),),
            tailing: const Icon(
              Icons.arrow_forward_ios,
              size: 18.0,
            ),
            onTab:() => _onEditShop(_shopList.elementAt(index)),
            onTrailing: () {
              _onEditShop(_shopList.elementAt(index));
            },
          ),
          const Divider(height: 12.0,),
        ],
    );
  }

  Future <void> _reload() async {
    String id_type = "users_id";
    if(widget.target=="Moims") {
      id_type = "moims_id";
    }

    _bShopList = false;
    Remote.getShops(
        params: {"command": "LIST", "list_attr":widget.target, id_type: widget.id},
        onResponse: (List<Shops> list) {
          setState(() {
            _bShopList = true;
            _shopList = list;
          });
        });
  }

  Future <void> _onEditShop(final Shops info) async {
    var result = await Navigator.push(
      context,
      Transition(
          child: MyShopsTab(
            users_id: widget.id,
            shops: info,
          ),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    if(result != null) {
      _bDirty = true;
      _reload();
    }
  }

  Future <void> _onAddShops() async {
    var rtn = await Navigator.push(
      context,
      Transition(
          child: ShopRegist(users_id: _loginInfo.users_id.toString(),),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    if(rtn != null) {
      _bDirty = true;
      _reload();
    }
  }

  Future<bool> _onBackPressed(BuildContext context) {
    Navigator.pop(context, _bDirty);
    return Future(() => false);
  }

}
