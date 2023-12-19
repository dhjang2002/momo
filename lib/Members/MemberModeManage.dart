// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Layouts/CardFormRadio.dart';
import 'package:momo/Models/Codes.dart';
import 'package:momo/Models/MemberInfo.dart';
import 'package:momo/Remote/Remote.dart';

class MemberManage extends StatefulWidget {
  final MemberInfo memberInfo;
  final String moim_name;
  const MemberManage({
    Key? key,
    required this.memberInfo,
    required this.moim_name
  }) : super(key: key);

  @override
  _MemberManageState createState() => _MemberManageState();
}


class _MemberManageState extends State<MemberManage> {

  final List<String> _dutyList  = [];//["회장", "부회장", "간사", "총무", "회원"];
  final List<String> _gradeList = [];
  bool _bReady = false;
  bool _isApproved  = false;
  String _tApproved = "아니오";
  String _tDuty = "";

  bool _bDirdy = false;
  String member_approve = "";

  @override
  void initState() {

    //print(widget.memberInfo.toString());
    member_approve = widget.memberInfo.member_approve!;
    if(widget.memberInfo.member_approve=="Y") {
      _isApproved = true;
      _tApproved  = "예";
    }

    loadDuty();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 1.0,
          title: const Text("정보수정", style:TextStyle(color:Colors.black)),
          leading: Visibility(
            visible:  true,
            child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () {
                  _onClose(_bDirdy);
                }
            ),
          ),
          actions: [
            Visibility(
              visible: false,
              child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    //doConfirmQuit();
                  }
              ),
            ),
          ],
        ),
      body: _buildBody()
    );
  }

  Widget _buildBody() {
    if(!_bReady) {
      return const Center(child: const CircularProgressIndicator());
    }

    return SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 30,),
              Container(
                padding: const EdgeInsets.only(left: 10),
                child: Text(widget.memberInfo.mb_name.toString(), style:
                const TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),),),
              Container(
                padding: const EdgeInsets.only(left: 10),
                child: const Text("권한정보 설정하기",
                  style: TextStyle(color: Colors.black, fontSize: 20),),),
              const SizedBox(height: 30,),
              CardFormRadio(title: const ["n  우리 모임의 ","b활동","n을 승인할까요?"],
                subTitle: "",isVertical: false,
                aList: const ["예", "아니오"],
                tag:"member_approve", value: _tApproved,
                onSubmit: (String tag, String value) {
                  _tApproved = value;
                  if(_tApproved=="예") {
                    _isApproved = true;
                    widget.memberInfo.member_approve = "Y";
                  }
                  else {
                    _isApproved = false;
                    widget.memberInfo.member_approve = "N";
                  }
                  _bDirdy = true;
                  setState(() {
                  });
                },
              ),

              const SizedBox(height: 10),
              Visibility(
                visible: _isApproved,
                child: CardFormRadio(
                  title: const ["n  모임직책"], subTitle: "",
                  isVertical: true,
                  aList: _dutyList,
                  tag:"member_duty",
                  value: _tDuty,
                  onSubmit: (String tag, String value) {
                    int inx = _dutyList.indexOf(value);
                    _tDuty  = _gradeList[inx]+value;
                    widget.memberInfo.member_duty = _tDuty;
                    // switch(_tDuty) { // 00회장, 01부회장, 10간사, 20총무, 30회원
                    //   case "회장":  widget.memberInfo.member_duty = "00회장"; break;
                    //   case "부회장": widget.memberInfo.member_duty = "01부회장"; break;
                    //   case "간사":  widget.memberInfo.member_duty = "10간사"; break;
                    //   case "총무":  widget.memberInfo.member_duty = "20총무"; break;
                    //   case "회원":  widget.memberInfo.member_duty = "30회원"; break;
                    // }
                    _bDirdy = true;
                    setState(() {
                    });
                  },
                ),),

              const SizedBox(height: 10),
              Visibility(
                visible: _isApproved,
                child: CardFormRadio(title: const ["n  관리권한"],
                  subTitle: "",isVertical: false,
                  aList: const ["일반", "관리자"],
                  tag:"member_grade", value: widget.memberInfo.member_grade.toString(),
                  onSubmit: (String tag, String value) {
                    widget.memberInfo.member_grade = value;
                    _bDirdy = true;
                    setState(() {
                    });
                  },
                ),),

              const SizedBox(height: 40),
              Visibility(
                visible: _bDirdy,
                child: Center(
                  child:ElevatedButton(
                    child: const Text("변경하기", style:TextStyle(fontSize:16.0, color:Colors.white)),
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
              const SizedBox(height: 80),
            ],
          ),
        ));
  }

  Future <void> _doUpdate() async {
    if(_bDirdy) {
      String push_mesg = "${widget.memberInfo.mb_name}님! ⌜${widget.moim_name}⌟의 회원정보(가입승인)가 변경되었습니다.";
      await Remote.reqMembers(
          params: {
            "command": "UPDATE",
            "push_title":"알림 - ⌜${widget.moim_name}⌟",
            "push_mesg":push_mesg,
            "push_token":widget.memberInfo.push_token!,
            "id": widget.memberInfo.id.toString(),
            "member_duty": widget.memberInfo.member_duty.toString(),
            "member_grade": widget.memberInfo.member_grade.toString(),
            "member_approve": widget.memberInfo.member_approve.toString(),
          },
          onResponse: (bool result) {
            _onClose(result);
          });
    }
    //_onClose(false);
  }

  Future <void> loadDuty() async {
    await Remote.getCodes(
        moims_id: "0",
        category: "모임직책",
        key: "",
        onResponse:(List <Codes> list) {
          _dutyList.clear();
          list.forEach((element) {
            _dutyList.add(element.name!.substring(2));
            _gradeList.add(element.name!.substring(0,2));
          });

          if(widget.memberInfo.member_duty!.length > 2 ) {
            _tDuty = widget.memberInfo.member_duty!.substring(2);
          }

          if(!_dutyList.contains(_tDuty)) {
            _tDuty = _dutyList[_dutyList.length-1];
          }

          setState(() {
            _bReady = true;
          });
        });
  }

  void _onClose(bool bDirdy) {
    Navigator.pop(context, bDirdy);
  }
}
