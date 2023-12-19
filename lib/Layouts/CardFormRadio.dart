// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_radio_group/flutter_radio_group.dart';
import 'CardFormTitle.dart';

class CardFormRadio extends StatefulWidget {
  final List<String> title;
  final List<String> aList;
  final String value;
  final Function(String tag, String value) onSubmit;
  String? subTitle;
  String? tag;
  bool? isVertical;
  String?  users_id;

  CardFormRadio({Key? key,
    required this.title,
    required this.aList,
    required this.value,
    required this.onSubmit,
    this.isVertical = true,
    this.subTitle   = "",
    this.tag        = "",
     } ) : super(key: key);

  @override
  _QSelSCardState createState() => _QSelSCardState();
}

class _QSelSCardState extends State<CardFormRadio> {
  bool m_bProgress = false;
  String answer = "";
  String attach_name = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      answer = widget.value;
    });
  }

  int _getInitIndex(){
    for(int n=0; n<widget.aList.length; n++){
      if(widget.aList[n]==widget.value) {
        return n;
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5,10,5,25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardFormTitle(titles: widget.title, subTitle:widget.subTitle!, titleColor:Colors.black, subColor: Colors.black54,),
          const SizedBox(height: 15,),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 1,),
                borderRadius: BorderRadius.circular(10)
            ),
            child:Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(10,0,0,0),
              child:FlutterRadioGroup(
                  titles: widget.aList,
                  labelVisible: false,
                  //labelStyle: TextStyle(color: Colors.grey),
                  //label: "This is label radio",
                  activeColor: Colors.green,
                  titleStyle: const TextStyle(fontSize: 15),
                  defaultSelected: _getInitIndex(),
                  orientation: (widget.isVertical!) ? RGOrientation.VERTICAL : RGOrientation.HORIZONTAL,
                  onChanged: (index) {
                    setState(() {
                      answer = widget.aList[index!.toInt()];
                      widget.onSubmit(widget.tag!, answer);
                    });
                  }),
            ),
          )
        ],
      ),
    );
  }
}
