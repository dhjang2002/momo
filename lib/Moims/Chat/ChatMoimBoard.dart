// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:momo/Members/MemberHome.dart';
import 'package:momo/Models/ChatItem.dart';
import 'package:momo/Models/MemberInfo.dart';
import 'package:momo/Moims/Chat/ChatBubble.dart';
import 'package:momo/Moims/Chat/ChatCache.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class ChatMoimBoard extends StatefulWidget {
  final String moimsId;
  final bool isNickFirst;
  const ChatMoimBoard({
    Key? key,
    required this.moimsId,
    required this.isNickFirst,
  }) : super(key: key);

  @override
  _ChatMoimBoardState createState() => _ChatMoimBoardState();
}

class _ChatMoimBoardState extends State<ChatMoimBoard> {
  late ScrollController _controller;
  TextEditingController idsController = TextEditingController();
  final ChatCache _chatCache = ChatCache();
  late LoginInfo _loginInfo;

  bool _bReady = false;
  late Timer timer;

  @override
  void initState() {
    _loginInfo = Provider.of<LoginInfo>(context, listen: false);
    _chatCache.setTarget(moimsId: widget.moimsId);
    _controller = ScrollController();
    _controller.addListener(_scrollListener);

    Future.microtask((){
      _chatCache.getRecent(Invalidate: () {
        setState(() {});
      });

      timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
        print("OnRimer()-------------------------");
        _refresh();
      });
    });

    setState(() {
      _bReady = true;
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    _chatCache.clear();
    idsController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _scrollListener() {

    /*
    var _data = Provider.of<VisibilityData>(context, listen: false);
    if (_controller.offset >= _controller.position.maxScrollExtent && !_controller.position.outOfRange) {
      _data.setVisible(false);
    }
    else {
      _data.setVisible(true);
    }
     */
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue.shade100,
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          //Colors.blue.shade100,
          elevation: 0.0,
          title: const Text("한줄근황", style: TextStyle(color: Colors.black)),
          leading: Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () {
                  timer.cancel();
                  Navigator.pop(context);
                }),
          ),
          actions: [
            Visibility(
              visible: false,
              child: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.black),
                  onPressed: () {
                    _refresh();
                  }),
            ),
          ],
        ),
        body: WillPopScope(
          onWillPop: onWillPop,
          child:GestureDetector(
            onTap: () { FocusScope.of(context).unfocus();},
            child: _renderBody())
        )
    );
  }

  Widget _renderBody() {
    if (!_bReady) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: _renderListview()
          ),
          _inputMessage(),
        ]);
  }

  Widget _renderListview() {

    final cache   = _chatCache.cache;
    final loading = _chatCache.loading;
    final hasMore = _chatCache.hasMore;

    // 로딩중이며 캐시에 데이터 없을때
    if(loading && cache.isEmpty){
      return const Center(child:CircularProgressIndicator());
    }

    // 로딩중이 아닌데, 캐시에 아무것도 없음.
    if(!loading && cache.isEmpty){
      return const Center(
          child:Text("우리모임 커뮤니티 공간입니다."
              "\n회원님의 최근 소식을 전하세요."));
    }

    return ListView.builder(
        controller: _controller,
        padding: const EdgeInsets.all(10),
        //scrollDirection: Axis.vertical,
        //shrinkWrap: true,
        reverse: true,
        itemCount: _chatCache.cache.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if(index<cache.length){
            ChatItem item = _chatCache.cache[index];
            return ChatBubble(
              isMe: (item.users_id == _loginInfo.users_id),
              id:item.id!,
              nickname: item.nickname!,
              message: item.message!,
              create_at: item.created_at!,
              thumnail: item.thumnail!,
              usersID: item.users_id!,
              onSelect: (String mesgId) {
                _selectMessage(mesgId);
              },
              onUser: (String usersId) {
                _showMemberInfo(usersId);
              },
            );
          }

          if(!loading && hasMore) {
            Future.microtask(() {
              _chatCache.getPrev(nextId: index, Invalidate: (){
                setState(() {});
              });
            });
          }

          if (!hasMore) {
            return Container();
             //return const Center(child: Icon(Icons.arrow_drop_up));
           }
          return const Center(child: CircularProgressIndicator());
        });
  }

  Widget _inputMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: TextField(
        controller: idsController,
        maxLines: 1,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            isDense: true,
            hintText: "한줄 근황입력...",
            hintStyle: const TextStyle(color: Colors.green),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(const Radius.circular(3.0)),
              borderSide: BorderSide(width: 1, color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(3.0)),
              borderSide: BorderSide(width: 1, color: Colors.grey.shade200),
            ),
            border: const OutlineInputBorder(
              borderRadius: const BorderRadius.all(const Radius.circular(3.0)),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send, color: Colors.green,),
              onPressed:(idsController.text.isNotEmpty) ? _doSumit : null
            )),
        onChanged: (value){
          setState(() {});
        },
      ),
    );
  }

  Future <void> _doSumit() async {
    String text = idsController.text;
    print("_doSumit():text=$text");
    String mesg = text.trim();
    idsController.text = "";
    if (mesg.isEmpty) {
      setState(() {});
      return;
    }

    await Remote.reqChat(
        params: {
          "command":"ADD",
          "users_id":_loginInfo.users_id!,
          "moims_id":widget.moimsId,
          "message":mesg
        },
        onResponse: (bool result) {
          _chatCache.getRecent(Invalidate: () {
            setState(() {});
          });
        });
  }

  Future <void> _refresh() async {
    await _chatCache.getRecent(
        Invalidate: () {
          setState(() {});
        });
  }

  // backKey event 처리
  Future <bool> onWillPop() async {
    timer.cancel();
    Navigator.pop(context);
    return true; // true will exit the app
  }

  Future <void> _showMemberInfo(String usersId) async {
    FocusScope.of(context).unfocus();

    Map<String, String> params = {
      "command": "OWNER",
      "users_id":usersId,
      "moims_id": widget.moimsId
    };

    await Remote.getMemberInfo(
        params: params,
        onResponse: (List<MemberInfo> list) {
            if(list.isNotEmpty) {
              MemberInfo info = list.elementAt(0);
              Navigator.push(
                context,
                Transition(
                    child: MemberHome(
                      isNickFirst: widget.isNickFirst,
                      member_id: info.id!,
                    ),
                    transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
              );
            }
            else {
              showToastMessage("모임에서 탈퇴한 사용자입니다.");
            }
        });
  }

  void _selectMessage(String mesgId) {
    print("_selectMessage() id=$mesgId");
    _showPopupMenu(mesgId);
  }

  Future <void> _showPopupMenu(final String mesgId) async {
     var selItem = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),      //position where you want to show the menu on screen
      items: [
        const PopupMenuItem<String>(
            child: Text('삭제'), value: '1'),
      ],
      //elevation: 8.0,
    );

     if(selItem != null) {
       print("_select($selItem)");
       await Remote.reqChat(
           params: {
             "command": "DELETE",
             "id":mesgId,
           },
           onResponse: (bool result) {
             _refresh();
           });
     }
  }
}
