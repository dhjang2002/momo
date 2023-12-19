// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'CardFormTitle.dart';

class CardFormCheck extends StatefulWidget {
  final List<String> title;
  final List<String> aList;
  final Function(String tag, String value) onSubmit;
  String? subTitle;
  String? value;
  String? tag;
  bool? isMulti;

  CardFormCheck({
    Key? key,
    required this.title,
    required this.aList,
    required this.onSubmit,
    this.subTitle = "",
    this.value = "",
    this.tag = "",
    this.isMulti = true,
    }) : super(key: key);

  @override
  _CardFormCheckState createState() => _CardFormCheckState();
}

class _CardFormCheckState extends State<CardFormCheck> {
  String answer = "";
  late List<bool> m_bCheck;

  List<String> _getInitValues(){
    List<String> result = [];
    String values = widget.value!;
    List iList = values.split(";");
    for (var element in iList) {
      result.add(element);
    }
    return result;
  }

  @override
  void initState() {
    setState(() {
      answer = widget.value!;
      m_bCheck = List.filled(widget.aList.length, false, growable: false);
      var value = _getInitValues();
      for(int n=0; n<value.length; n++) {
        int inx = widget.aList.indexOf(value[n]);
        if (inx >= 0) {
          m_bCheck[inx] = true;
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      color: Colors.white,
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardFormTitle(titles: widget.title, subTitle:widget.subTitle!,
            titleColor:Colors.black, subColor: Colors.black54,),
          const SizedBox(height: 10,),
          Container(
            //color: Colors.white,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 1,),
                borderRadius: BorderRadius.circular(10)
            ),
            child:ListView(
              physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children:
                List.generate(widget.aList.length, (index) {
                  return ListTile(
                    onTap: () {
                      _onTab(index);
                      widget.onSubmit(widget.tag!, _getSelectValues());
                    },
                    selected: m_bCheck[index],
                      leading: Container(width: 28, height: 28,
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        alignment: Alignment.center,
                        child: _getIcon(index),
                      ),
                      title: Text(widget.aList[index],
                        style: TextStyle(
                            color: (m_bCheck[index]) ? Color(0xff111111) : Color(0xffa3a3a3),
                            fontWeight: (m_bCheck[index]) ? FontWeight.normal : FontWeight.normal,
                            fontSize: 16.0
                        ),
                      ),
                      //trailing: Icon(Icons.list));
                  );
                }),
            ),
          ),
        ]
      ),
    );
  }

  void _onTab(int index) {
    if (widget.isMulti!) {
      setState(() {
        m_bCheck[index] = !m_bCheck[index];
        int count = 0;
        for (var check in m_bCheck) {
          if (check) {
            count++;
          }
        }
      });
    }
    else {
      setState(() {
        m_bCheck[index] = !m_bCheck[index];
        for (int n = 0; n < m_bCheck.length; n++) {
          if (n != index) {
            if (m_bCheck[n]) {
              m_bCheck[n] = false;
            }
          }
        }
      });
    }
  }

  String _getSelectValues() {
    String codestring = "";
    for (int n = 0; n < m_bCheck.length; n++) {
      if (m_bCheck[n]) {
        if (codestring.isNotEmpty) {
          codestring += ";";
        }
        codestring += widget.aList[n];
      }
    }
    return codestring;
  }

  Widget _getIcon(int index) {
    if (widget.isMulti!) {
      return (m_bCheck[index]) ?
      const Icon(Icons.check_box_sharp, color: Color(0xff111111)) :
      const Icon(Icons.check_box_outline_blank, color: Color(0xffa3a3a3));
    }
    else {
      return (m_bCheck[index]) ?
      const Icon(Icons.check_circle, color: Color(0xff111111)) :
      const Icon(Icons.circle_outlined, color: Color(0xffa3a3a3));
    }
  }
}
