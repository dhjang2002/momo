// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Layouts/CardExtraField.dart';
import 'package:momo/Models/MemberExtra.dart';
import 'package:momo/Models/MemberInfo.dart';

class CardExtraFormEx extends StatefulWidget {
  final MemberInfo memberInfo;
  final List<MemberExtra> extras;
  const CardExtraFormEx({Key? key,
    required this.memberInfo,
    required this.extras}) : super(key: key);

  @override
  _CardExtraFormExState createState() => _CardExtraFormExState();
}

class _CardExtraFormExState extends State<CardExtraFormEx> {
  bool bDirty = false;
  int m_itemCount = 0;
  String moims_id = "0";
  @override
  void initState() {
    super.initState();
    setState(() {
      m_itemCount = widget.extras.length;
      if(m_itemCount>0) {
        moims_id = widget.extras.elementAt(0).moims_id.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () { FocusScope.of(context).unfocus();},
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: ListView.builder(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: m_itemCount, //리스트의 개수
              itemBuilder: (BuildContext context, int index) {
                return ItemCard(index);
              },
            ),
          ),
          const SizedBox(height: 30,),
          Visibility(
            visible: bDirty,
            child: Center(
              child:ElevatedButton(
                child: const Text("수정", style:TextStyle(fontSize:16.0, color:Colors.white)),
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
        ],)
    );
  }

  Widget ItemCard(int index) {
    MemberExtra info = widget.extras.elementAt(index);
    String diaplay   = info.field_display.toString();
    String value     = widget.memberInfo.getFieldValue(info.field_name.toString());
    TextInputType keyboard = getKeyboard(info.field_keyboard.toString().trim());
    String selData = info.field_data.toString();
    bool isSelect = getInputType(info.field_attribute);

    return Column(
      children: [
        CardExtraField(
          title: ["n$diaplay"],
          moims_id: moims_id,
          initValue: value,
          tag: info.field_name.toString(),
          useSelect: isSelect,
          selType: info.field_attribute,
          selData: selData,
          maxLines: (keyboard==TextInputType.multiline) ? null:1,
          textInputAction: (keyboard==TextInputType.multiline) ? TextInputAction.newline: TextInputAction.done,
          useSelectTitle: info.field_display.toString(),
          keyboardType: keyboard,
          onChanged: (String tag, String value){
            setState(() {
              widget.memberInfo.setFieldValue(tag, value);
              bDirty = true;
            });
        }, ),
      ],
    );
  }

  TextInputType getKeyboard(String field_keyboard) {

    print("getKeyboard() field_keyboard=$field_keyboard");

    switch(field_keyboard){
      case "숫자":
        return TextInputType.number;
      case "텍스트":
        return TextInputType.multiline;
      case "이메일":
        return TextInputType.emailAddress;
    }
    return TextInputType.text;
  }

  bool getInputType(String? field_attribute) {

    print("getInputType():field_attribute=$field_attribute");

    if(field_attribute=="직접입력") {
      return false;
    }
    return true;
  }

  void _close() {
    Navigator.pop(context, bDirty);
  }

}
