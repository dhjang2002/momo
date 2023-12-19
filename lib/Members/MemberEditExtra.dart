// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Layouts/CardExtraFormEx.dart';
import 'package:momo/Models/MemberExtra.dart';
import 'package:momo/Models/MemberInfo.dart';

class MemberEditExtra extends StatefulWidget {
  final List<MemberExtra> extras;
  final MemberInfo info;
  const MemberEditExtra({Key? key,
    required this.extras,
    required this.info}) : super(key: key);

  @override
  _MemberEditExtraState createState() => _MemberEditExtraState();
}

class _MemberEditExtraState extends State<MemberEditExtra> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("정보수정",),),
      body:SingleChildScrollView(
        child: CardExtraFormEx(memberInfo: widget.info, extras: widget.extras,)
      ),
    );
  }
}
