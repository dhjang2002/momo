// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Layouts/CardExtraField.dart';
import 'package:momo/Models/MemberExtra.dart';
import 'package:momo/Models/Members.dart';

class CardExtraForm extends StatefulWidget {
  final Members m_member;
  final List<MemberExtra> m_extra;
  const CardExtraForm({Key? key,
    required this.m_member,
    required this.m_extra}) : super(key: key);

  @override
  _CardExtraFormState createState() => _CardExtraFormState();
}

class _CardExtraFormState extends State<CardExtraForm> {

  int m_itemCount = 0;
  String moims_id = "0";
  @override
  void initState() {
    super.initState();
    setState(() {
      m_itemCount = widget.m_extra.length;
      if(m_itemCount>0) {
        moims_id = widget.m_extra.elementAt(0).moims_id.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
      ],);
  }

  Widget ItemCard(int index) {
    MemberExtra info = widget.m_extra.elementAt(index);
    String diaplay   = info.field_display.toString();
    String value     = getFieldValue(info.field_name.toString());
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
              setFieldValue(tag, value);
        }, ),
      ],
    );
  }

  String getFieldValue(String filed){
    switch(filed){
      case "member_field_01":
        return widget.m_member.member_field_01.toString();
      case "member_field_02":
        return widget.m_member.member_field_02.toString();
      case "member_field_03":
        return widget.m_member.member_field_03.toString();
      case "member_field_04":
        return widget.m_member.member_field_04.toString();
      case "member_field_05":
        return widget.m_member.member_field_05.toString();
      case "member_field_06":
        return widget.m_member.member_field_06.toString();
      case "member_field_07":
        return widget.m_member.member_field_07.toString();
      case "member_field_08":
        return widget.m_member.member_field_08.toString();
      case "member_field_09":
        return widget.m_member.member_field_09.toString();
      case "member_field_10":
        return widget.m_member.member_field_10.toString();
      case "member_field_11":
        return widget.m_member.member_field_11.toString();
      case "member_field_12":
        return widget.m_member.member_field_12.toString();
      case "member_field_13":
        return widget.m_member.member_field_13.toString();
      case "member_field_14":
        return widget.m_member.member_field_14.toString();
      case "member_field_15":
        return widget.m_member.member_field_15.toString();
    }
    return "";
  }

  void setFieldValue(String filed, String value){
    switch(filed){
      case "member_field_01":
        widget.m_member.member_field_01 = value; break;
      case "member_field_02":
        widget.m_member.member_field_02 = value; break;
      case "member_field_03":
        widget.m_member.member_field_03 = value; break;
      case "member_field_04":
        widget.m_member.member_field_04 = value; break;
      case "member_field_05":
        widget.m_member.member_field_05 = value; break;
      case "member_field_06":
        widget.m_member.member_field_06 = value; break;
      case "member_field_07":
        widget.m_member.member_field_07 = value; break;
      case "member_field_08":
        widget.m_member.member_field_08 = value; break;
      case "member_field_09":
        widget.m_member.member_field_09 = value; break;
      case "member_field_10":
        widget.m_member.member_field_10 = value; break;
      case "member_field_11":
        widget.m_member.member_field_11 = value; break;
      case "member_field_12":
        widget.m_member.member_field_12 = value; break;
      case "member_field_13":
        widget.m_member.member_field_13 = value; break;
      case "member_field_14":
        widget.m_member.member_field_14 = value; break;
      case "member_field_15":
        widget.m_member.member_field_15 = value; break;
    }
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

}
