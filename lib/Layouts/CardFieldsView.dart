// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Models/MemberExtra.dart';
import 'package:momo/Layouts/InputAttribute.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/utils.dart';
import 'package:transition/transition.dart';
import 'CardFormTitle.dart';
import 'TileCard.dart';

class CardFieldsView extends StatefulWidget {
  final Function(String tag, String value) onChange;
  final String moims_id;
  List<String>? title;
  CardFieldsView({
    Key? key,
    this.title,
    required this.moims_id,
    required this.onChange,
  }) : super(key: key);

  @override
  _CardFieldsViewState createState() => _CardFieldsViewState();
}

class _CardFieldsViewState extends State<CardFieldsView> {
  List<MemberExtra> m_extra = <MemberExtra>[];

  @override
  void initState() {
    _reload(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            (widget.title != null) ? CardFormTitle(
              titles: widget.title!,
              subTitle: "",
              titleColor: Colors.black,
              subColor: Colors.black54,) : Container(),
            (widget.title != null)? const SizedBox(height: 10) : Container(),

            const Text("모임의 운영에 필요한 회원 정보를 추가하십시오. 기본정보는 앱 사용자 가입시 입력한 정보입니다. 기타 필요한 정보를 추가로 제공받아 사용할 수 있습니다.",
                style:TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
            const SizedBox(height: 20,),
            const Text("기본정보",style:const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
            const SizedBox(height: 5,),
            Container(
              width: double.infinity,
              //color: Colors.grey,
              child: const Text("'회원이름', '별명', '휴대폰', '이메일', '주소'",style:TextStyle(fontSize: 15)),
              margin: const EdgeInsets.fromLTRB(0,5,0,10),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(width: 1, color: Colors.grey,),
                  color: Colors.grey[100]
              ), //  PO
            ),

            const SizedBox(height: 5,),
            Row(
              children: [
                Text("추가항목 (${m_extra.length})",style:const TextStyle(fontSize: 16,fontWeight: FontWeight.normal)),
                const Spacer(),
                TextButton.icon(
                  icon:Icon(Icons.add, color: Colors.black,),
                  //style: TextButton.styleFrom(primary: Colors.blueAccent,),
                  label: const Text('항목추가', style:TextStyle(fontSize: 15, color: Colors.black)),
                  onPressed: () async {
                    if(m_extra.length<14) {
                      _add();
                    }
                    else{
                      showToastMessage("최대 갯수를 초과하였습니다.");
                    }
                  },
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(width: 1, color: Colors.grey,),
              ),
              child: Column(
                children: [
                  Visibility(
                      visible:(m_extra.isNotEmpty),
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                        itemCount: m_extra.length, //리스트의 개수
                        itemBuilder: (BuildContext context, int index) {
                          return ItemCard(index,true);
                        },
                      )
                  ),
                  Visibility(
                      visible:!(m_extra.isNotEmpty),
                      child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    child: const Text("추가된 항목이 없습니다.",style:TextStyle(fontSize: 15, color: Colors.grey)))
                  ),
                  Container(
                    width: double.infinity,
                    child: const Text("*기본항목 이외에 필요한 항목을 추가하십시오."
                        "\n모임 운영을 위해 꼭 필요한 항목만 추가하여 사용하세요. 최대 15개까지 정의하여 사용할 수 있습니다.",style:TextStyle(fontSize: 15)),
                    //margin: const EdgeInsets.fromLTRB(0,0,0,0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(width: 1.0, color: Colors.grey),
                        ),
                        color: Colors.grey[100]
                    ), //  PO
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ItemCard(int index, bool isDelete) {
    String fieldName = m_extra.elementAt(index).field_display.toString();
    String attribute = m_extra.elementAt(index).field_attribute.toString();
    String keyboard  = m_extra.elementAt(index).field_keyboard.toString();
    String desc = "$keyboard/$attribute";

    return TileCard(
      key: GlobalKey(),
      onTab: () {_edit(index);},
      title: Text(fieldName, style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.0),
      ),
      subtitle: Text(desc, style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.normal,
            fontSize: 14.0),
      ),
      tailing: (isDelete)
          ? const Icon(Icons.close, size: 16.0, color: Colors.redAccent,)
          : null,
      onTrailing: () { _delete(index); },
    );
  }

  Future <void> _reload(bool bReport) async {
    await Remote.getMemberExtra(params: {
      "command":"LIST",
      "moims_id":widget.moims_id
    }, onResponse: (List<MemberExtra> list) {
      setState(() {
        m_extra = list;
        if(bReport){
          widget.onChange("","");
        }
      });
    });
  }

  // 항목추가
  Future <void> _add() async {
    MemberExtra info = MemberExtra();
    info.field_name = _getFieldName();
    var result = await Navigator.push(
      context,
      Transition(
          child: InputAttribute(command:"ADD", m_extra: info,),
          transitionEffect:
          TransitionEffect.RIGHT_TO_LEFT),
    );

    if(result=="ADD") {
      print("_add():"+info.toString());
      info.moims_id = widget.moims_id.toString();

      Map<String, String> params = info.toAddMap();
      params.addAll({
        "command": "ADD",
      });

      await Remote.addMemberExtra(
          params: params,
          onResponse: (MemberExtra info) {
            _reload(true);
      });
    }
  }

  int _IndexOf(String field) {
    for(int n=0; n<m_extra.length; n++){
      if(m_extra.elementAt(n).field_name==field) {
        return n;
      }
    }
    return -1;
  }

  String _getFieldName(){
    for(int n=1;n<=15; n++){
      String field = "member_field_${n.toString().padLeft(2,'0')}";
      if(_IndexOf(field)<0){
        return field;
      }
    }
    return "";
  }

  // 항목삭제
  Future<void> _delete(int index) async {
    String id = m_extra.elementAt(index).id.toString();
    Map<String, String> params = {"command": "DELETE", "id":id};
    await Remote.reqMemberExtra(params: params, onResponse: (bool rewsult) {
      _reload(true);
    });
  }

  // 항목수정
  Future <void> _edit(int index) async {
    MemberExtra info = m_extra.elementAt(index);

    print("_edit():"+info.toString());

    var result = await Navigator.push(
      context,
      Transition(
          child: InputAttribute(command: "UPDATE", m_extra: info,),
          transitionEffect:
          TransitionEffect.RIGHT_TO_LEFT),
    );

    if (result == "UPDATE") {
      print("_edit():" + info.toString());
      Map<String, String> params = info.toMap();
      params.addAll({"command": "UPDATE",});
      await Remote.reqMemberExtra(
          params: params, onResponse: (bool rewsult) {
        _reload(true);
      });
    }
  }

}
