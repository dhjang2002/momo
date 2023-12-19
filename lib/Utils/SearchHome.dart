// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Layouts/TileCard.dart';
import 'package:momo/Models/SearchItem.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Utils/SearchCache.dart';
import 'package:momo/Utils/utils.dart';
import 'package:provider/provider.dart';

class SearchHome extends StatefulWidget {
  final String target; // "shop", "member", "moim"
  final String moimId; // 모임내 검색인 경우...
  const SearchHome({
    Key? key,
    required this.target,
    required this.moimId
  }) : super(key: key);

  @override
  _SearchHomeState createState() => _SearchHomeState();
}

class _SearchHomeState extends State<SearchHome> {
  TextEditingController idsController = TextEditingController();
  final SearchCache _searchCache = SearchCache();
  bool _bReady = true;
  String _hint = "";
  String _keyValue = "";

  @override
  void initState() {
    setState(() {
      if(widget.target=="moim") {
        _hint = "모임검색";
      } else if(widget.target=="shop") {
        _hint = "사업장검색";
      } else if(widget.target=="member") {
        _hint = "회원검색";
      }

      var _loginInfo = Provider.of<LoginInfo>(context, listen:false);
      _searchCache.setTarget(
          usersId:_loginInfo.users_id.toString(),
          target: widget.target.toString(),
          targetId: widget.moimId);
      _bReady = true;
    });

    //Future.microtask(() async {});
    super.initState();
  }

  @override
  void dispose() {
    idsController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        child: Container(),
        preferredSize: const Size(0.0, 0.0),
      ),
      body: _buildHome(),
    );
  }

  Widget _buildHome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(),
        Divider(height: 1),
        _buildListCount(),
        Expanded(child: _searchBody())
      ],
    );
  }

  Widget _buildListCount() {
    String listTitle = "검색결과 (${_searchCache.cache.length})";
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
  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          Visibility(
            visible: true,
            child: GestureDetector(
              child: const Icon(Icons.navigate_before, size: 36, color: Colors.black),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),

          Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: idsController,
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.fromLTRB(10,5,10,5),
                    isDense: true,
                    hintText: _hint,
                    hintStyle: const TextStyle(color: Colors.green),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(const Radius.circular(30.0)),
                      borderSide: BorderSide(width: 1, color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                      borderSide: BorderSide(width: 1, color: Colors.grey.shade200),
                    ),
                    border: const OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(const Radius.circular(30.0)),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        _doSearch(idsController.text);
                      },
                    )
                  ),
                  onSubmitted: (value) {
                    //FocusScope.of(context).unfocus();
                    _doSearch(idsController.text);
                  },
            ),
          )),

          Visibility(
              visible: false,
              child: GestureDetector(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  child: const Icon(Icons.menu, size: 28, color: Colors.black),
                ),
                onTap: () {},
              )),
        ],
      ),
    );
  }
  Widget _searchBody() {
    if(!_bReady) {
      return const Center(child: CircularProgressIndicator());
    }

    final cache   = _searchCache.cache;
    final loading = _searchCache.loading;
    final hasMore = _searchCache.hasMore;

    // 로딩중이며 캐시에 데이터 없을때
    if(loading && cache.isEmpty) {
      return const Center(child:CircularProgressIndicator());
    }

    // 로딩중이 아닌데, 캐시에 아무것도 없음.
    if(!loading && cache.isEmpty) {
      return const Center(child:Text("데이터가 없습니다."));
    }
    
    return ListView.builder(
        itemCount: cache.length+1,
        itemBuilder: (BuildContext context, int index)
        {
          if(index<cache.length){
            return _itemCard(cache[index]);
          }

          if(!loading && hasMore) {
            Future.microtask(() {
              _searchCache.fetchItems(nextId: index, count:25, keyValue:_keyValue, onNotify: () {
                setState(() {
                });
              });
            });
          }

          if (!hasMore) {
            return const Center(child: Icon(Icons.arrow_drop_up));
          }
          return const Center(child: CircularProgressIndicator());
        });
  }
  
  Widget _itemCard(SearchItem info) {
    String title = info.title;
    String subTitle = info.subTitle;

    String url = "";
    List<String> thumnails = info.thumnails.toString().split(";");
    if(thumnails.isNotEmpty && thumnails.elementAt(0).length>5) {
      url = URL_HOME + thumnails.elementAt(0);
    }
    
    return Column(
      children: [
        TileCard(
          key: GlobalKey(),
          color:Colors.white,
          padding: EdgeInsets.all(10),
          leading: SizedBox(
              height: 50, width: 50,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: simpleBlurImageWithName(title, 18, url, 1.0)
              )),
          title: Text(
            title,
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18.0),
          ),
          subtitle: Text(
            subTitle,
            style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
                fontSize: 14.0)),
          
          onTab:() => _onTab(info),
        ),
        const Divider(height: 1.0,),
      ],
    );
  }
  void _onTab(SearchItem info) {
    Navigator.pop(context, info.id);
    //widget.onTap(info);
  }

  void _doSearch(String value) {
    FocusScope.of(context).unfocus();

    print("_doSearch()value=$value");
    _keyValue = value.trim();
    if(_keyValue.isEmpty)
      _keyValue = "***";

    _searchCache.clear();
    _searchCache.fetchItems(nextId: 0, count:25, keyValue:_keyValue, onNotify: () {
      setState(() {});
    });
  }
}
