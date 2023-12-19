// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:momo/Constants/Constants.dart';
import 'package:momo/Moims/MoimEdit.dart';
import 'package:momo/Moims/MoimRegist.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Layouts/TileCard.dart';
import 'package:momo/Models/Moims.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class MyMoimList extends StatefulWidget {
  final String title;
  final String target; // "Owner", "Member", "Joinable"
  final String users_id;
  const MyMoimList(
      {Key? key,
      required this.target,
      required this.users_id,
      required this.title})
      : super(key: key);

  @override
  _MyMoimListState createState() => _MyMoimListState();
}

class _MyMoimListState extends State<MyMoimList> {
  bool _bDirty = false;

  late List<Moims> m_mList;
  bool bLoaded = false;

  late LoginInfo _loginInfo;
  @override
  void initState() {
    super.initState();
    _loginInfo = Provider.of<LoginInfo>(context, listen: false);
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _onBackPressed(context),
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0.3,
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
                  visible: false,
                  child: IconButton(
                      icon: const Icon(
                        Icons.add,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          _onMoimCreate();
                        });
                      }),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                _onMoimCreate();
              },
            ),
            body: _buildBody(),
        )
    );
  }

  Widget _buildBody() {
    if(!bLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if(m_mList.isEmpty){
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

  Widget _renderListView() {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        //scrollDirection: Axis.vertical,
        shrinkWrap: true,
        //physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        itemCount: m_mList.length, //리스트의 개수
        itemBuilder: (BuildContext context, int index) {
          return _itemCard(index);
        },
      ),
    );
  }

  Widget _buildListCount() {
    if(!bLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    String listTitle = "모임목록  (${m_mList.length})";
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

  Widget _itemCard(int index) {
    Moims info = m_mList.elementAt(index);
    String url = "";
    List<String> thumnails = info.moim_thumnails.toString().split(";");
    if (thumnails.isNotEmpty && thumnails.elementAt(0).isNotEmpty) {
      url = URL_HOME + thumnails.elementAt(0);
    }

    //print("ItemCard($index):$url");

    return Column(
      children: [
        TileCard(
          key: GlobalKey(),
          leading: SizedBox(
              height: 50, width: 50,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: simpleBlurImageWithName(info.moim_name.toString(), 28, url, 1)
              )),
          title: Text(
            info.moim_name.toString(),
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18.0),
          ),
          subtitle: Text(
            info.moim_title.toString(),
            style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
                fontSize: 14.0),
          ),
          tailing: const Icon(
            Icons.arrow_forward_ios,
            size: 18.0,
          ),
          onTab: () => _onTab(index),
          onTrailing: () => _onDetail(index),
        ),
        const Divider(
          height: 12.0,
        ),
      ],
    );
  }

  void _onTab(int index) {
    String moims_id = m_mList.elementAt(index).id.toString();
    _modifyMoim(moims_id);
  }

  void _onDetail(int index) {
    String moims_id = m_mList.elementAt(index).id.toString();
    _modifyMoim(moims_id);
  }

  Future <void> _fetchData() async {
    bLoaded = false;
    // "Owner", "Member", "Joinable"
    String list_attr = widget.target.toString();
    await Remote.getMoims(
        params: {
          "command": "LIST",
          "list_attr": list_attr,
          "users_id": _loginInfo.users_id.toString()
        },
        onResponse: (List<Moims> list) {
          setState(() {
            bLoaded = true;
            m_mList = list;
          });
        });
  }

  // 모임 만들기
  Future <void> _onMoimCreate() async {
    var moimsId = await Navigator.push(
      context,
      Transition(
          child: MoimRegist(usersId: _loginInfo.person!.mb_no!),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    // 모임이 생성되면 관리자 모드로 등록한다.
    if (moimsId != null && moimsId.toString().isNotEmpty) {
      String topic = "moims_$moimsId";
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      _bDirty = true;
      _fetchData();
    }
  }

  Future <void> _modifyMoim(String moim_id) async {
    var result = await Navigator.push(
      context,
      Transition(
          child: MoimEdit(moims_id: moim_id.toString()),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    if (result != null) {
      _bDirty = true;
      _fetchData();
    }
  }

  Future<bool> _onBackPressed(BuildContext context) {
    Navigator.pop(context, _bDirty);
    return Future(() => false);
  }
}
