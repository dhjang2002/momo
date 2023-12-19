// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Constants/Constants.dart';
import 'package:momo/Layouts/CardEditItem.dart';
import 'package:momo/Layouts/CardExtraField.dart';
import 'package:momo/Models/MemberExtra.dart';
import 'package:momo/Utils/utils.dart';

class InputAttribute extends StatefulWidget {
  final MemberExtra m_extra;
  final String command;
  const InputAttribute({Key? key,
    required this.m_extra,
    required this.command
  }) : super(key: key);

  @override
  _InputAttributeState createState() => _InputAttributeState();
}

class _InputAttributeState extends State<InputAttribute> {


  bool isInput = false;
  String selAttribute = item_attribute.elementAt(0);//"직접입력";
  String selKeyboard  = item_keyboard.elementAt(0);//"문자열";
  String field_data   = "";
  String input_guide  = "키보드로 직접 입력합니다.";
  String sdata_guide  = "";

  @override
  void initState() {
    if(widget.command=="UPDATE") {
      setState(() {
        selAttribute = widget.m_extra.field_attribute.toString();
        if(selAttribute.isEmpty) {
          selAttribute = item_attribute.elementAt(0);//"직접입력";
          widget.m_extra.field_attribute = selAttribute;
        }

        selKeyboard = widget.m_extra.field_keyboard.toString();
        if(selKeyboard.isEmpty) {
          selKeyboard = item_keyboard.elementAt(0);//"문자";
          widget.m_extra.field_keyboard = selKeyboard;
        }

        field_data = widget.m_extra.field_data.toString();
        _changeInput(selAttribute);
      });
    }
    else{
      widget.m_extra.field_keyboard = selKeyboard;
      widget.m_extra.field_data = field_data;
      widget.m_extra.field_attribute = selAttribute;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.3,
        title: const Text("필드항목",),
        leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppBar_Icon,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: BuildSttribute(),
    );
  }

  // 항목이름:
  // 항목속성(키보드): 문자, 숫자, 영숫자
  // 직접입력방법:직접직접입력, 리스트, 코드데이터
  // 데이터: 항목데이터
  Widget BuildSttribute() {
    return GestureDetector(
      onTap: () { FocusScope.of(context).unfocus();},
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            // 항목명칭
            SizedBox(height: 20),
            CardExtraField(
              title: const ["n항목명칭"],
              maxLength: 32,
              moims_id: widget.m_extra.moims_id.toString(),
              initValue: widget.m_extra.field_display.toString(),
              tag: widget.m_extra.field_display.toString(),
              useSelect: false,
              onChanged: (String tag, String value){
                widget.m_extra.field_display = value;
              }, ),

            // 항목속성(키보드): 문자, 숫자, 영숫자
            //SizedBox(height: 5),
            CardDataType(),

            // 직접입력방법:직접직접입력, 리스트, 코드데이터
            SizedBox(height: 25),
            CardDataInput(),

            Container(
              width: double.infinity,
              child: Text(input_guide,style:const TextStyle(fontSize: 14, color: Colors.grey)),
              //margin: const EdgeInsets.fromLTRB(9,3,9,10),
              padding: const EdgeInsets.all(10.0),
            ),
            //const Divider(height: 25.0,),

            // 항목데이터
            SizedBox(height: 10),
            Visibility(
              visible: isInput,
              child: Column(
                children: [
                  CardEditItem(
                    title: const ["n항목 데이터"],
                    value: widget.m_extra.field_data.toString(),
                    hint: "데이터 항목",
                    desc: "이 필드의 입력데이터 메뉴 아이템을 추가해 주세요.",
                    tag: widget.m_extra.field_data.toString(),
                    onChanged: (String tag, String value) {
                      setState(() {
                        //print("------"+value);
                        widget.m_extra.field_data = value;
                      });

                    },
                  ),

                  Container(
                    width: double.infinity,
                    child: Text(sdata_guide,style:const TextStyle(fontSize: 15)),
                    margin: const EdgeInsets.fromLTRB(9,3,9,10),
                    padding: const EdgeInsets.all(5.0),
                  ),
                ],
              )
            ),
            //const Divider(height: 12.0,),

            // 직접입력버튼
            const SizedBox(height:50),
            Visibility(
              visible: true,
              child: Center(
                child:ElevatedButton(
                  child: const Text("확인", style:TextStyle(fontSize:16.0, color:Colors.white)),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      fixedSize: const Size(300, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                  onPressed:() {
                    _close();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }

  Widget CardDataType() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10,0,10,0),
      padding: const EdgeInsets.fromLTRB(10,0,10,0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
          boxShadow: [
            BoxShadow(
                color:Colors.black.withOpacity(0.3),
                blurRadius: 1,
                spreadRadius: 1
            )
          ]
      ),
      child: Row(
        children: [
          const Text("속성값", style: const TextStyle(fontSize: 18, ),),
          const Spacer(),
          DropdownButton(
            value: selKeyboard,
            items: item_keyboard.map((value) {
              return DropdownMenuItem (
                value: value,
                child: Text(value),);
            },
            ).toList(),
            onChanged: (value) {
              setState(() {
                selKeyboard = value.toString();
                widget.m_extra.field_keyboard = selKeyboard;
              });
            },
          ),
        ],
      )
    );
  }

  Widget CardDataInput() {
    return Container(
        margin: const EdgeInsets.fromLTRB(10,0,10,0),
        padding: const EdgeInsets.fromLTRB(10,0,10,0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3.0),
            boxShadow: [
              BoxShadow(
                  color:Colors.black.withOpacity(0.3),
                  blurRadius: 1,
                  spreadRadius: 1
              )
            ]
        ),
        child: Row(
          children: [
            const Text("입력방식", style: TextStyle(fontSize: 18,),),
            const Spacer(),
            DropdownButton(
              value: selAttribute,
              items: item_attribute.map((value) {
                return DropdownMenuItem (
                  value: value,
                  child: Text(value),);
              },
              ).toList(),
              onChanged: (value) {
                setState(() {
                  selAttribute = value.toString();
                  widget.m_extra.field_attribute = selAttribute;
                  _changeInput(selAttribute);
                });
              },
            ),
          ],
        )
    );
  }

  void _close() {
    if(!isValidate()) {
      return;
    }

    if(widget.m_extra.field_attribute=="코드"){
      widget.m_extra.field_data = widget.m_extra.field_display;
    }
    Navigator.pop(context, widget.command);
  }

  void _changeInput(String value) {

    if(value=="직접입력") {
      isInput = false;
    }
    else{
      isInput = true;
    }

    switch(value){
      case "직접입력":
        input_guide = "키보드로 직접 입력합니다.";
        sdata_guide = "";
        isInput = false;
        break;
      case "선택":
        input_guide = "* 메뉴 선택 방식으로 데이터를 입력합니다."
            " 항목의 갯수가 10개 미만인 경우 사용합니다.";
        sdata_guide = "*항목 구분자는 세미콜론(';')을 사용합니다."
            "\n예) 직급 => 대표;전무;상무;이사;부장;과장;대리";
        isInput = true;
        break;
      case "코드":
        input_guide = "* 메뉴 선택 방식으로 데이터를 입력합니다."
            " 항목의 갯수가 10개 이상 이거나, 추후 변동이 예상되는 경우 사용합니다."
            "\n\n홈페이지에 접속하여 코드 항목을 관리해주십시오.";
        sdata_guide = "";
        isInput = false;
        break;
    }
  }

  bool isValidate() {
    if(widget.m_extra.field_display!.length < 2){
      showToastMessage("'항목명'을 2글자 이상 입력해 주세요.");
      return false;
    }
    if(widget.m_extra.field_keyboard!.isEmpty){
      showToastMessage("'속성값'을 선택해 주세요.");
      return false;
    }
    if(widget.m_extra.field_attribute!.isEmpty){
      showToastMessage("'입력방식'을 선택해주세요.");
      return false;
    }

    if(widget.m_extra.field_attribute.toString()=="선택") {
      if(widget.m_extra.field_data!.isEmpty)
      {
        showToastMessage("'항목'을 1개이상 추가해 주세요.");
        return false;
      }
    }
    return true;
  }
  
}
