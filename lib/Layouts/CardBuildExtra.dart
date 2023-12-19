// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';

class CardBuildExtra extends StatefulWidget {
  const CardBuildExtra({Key? key}) : super(key: key);

  @override
  _CardBuildExtraState createState() => _CardBuildExtraState();
}

class _CardBuildExtraState extends State<CardBuildExtra> {

  int m_itemCount = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // Animal ListView
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
        Row(
          children: [
            const Spacer(),
            TextButton(
              style: TextButton.styleFrom(primary: Colors.blueAccent,),
              child: const Text('필드추가', style:TextStyle(fontSize: 15),),
              onPressed: () async {
                _addField();
              },
            ),
          ],
        ),
      ],);
  }

  Widget ItemCard(int index) {
    return const Center(child: const Text("확장필드"),);
  }

  void _addField() {
    setState(() {
      m_itemCount++;
    });

  }

}
