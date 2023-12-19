// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'CardFormTitle.dart';

class CardFormText extends StatefulWidget {
  final Function(String tag, String value) onChanged;
  final List<String> title;
  int?      maxLength;
  bool?     useSelect;
  String?   tag;
  String?   value;
  String?   hint;
  String?   subTitle;
  int ?     maxLines;
  bool ?    edit_lock;
  double ?  fontSize;
  bool?      isBold;
  TextInputType? keyboardType;

  CardFormText({Key? key,
    required this.title,
    this.maxLength,
    required this.onChanged,
    this.tag = "" ,
    this.value = "",
    this.hint = "",
    this.subTitle = "",
    this.keyboardType = TextInputType.text,
    this.maxLines  = 1,
    this.useSelect = false,
    this.edit_lock = false,
    this.fontSize = 16,
    this.isBold = true,

  }) : super(key: key);

  @override
  _CardFormTextState createState() => _CardFormTextState();
}

class _CardFormTextState extends State<CardFormText> {
  TextEditingController tController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      tController.text = widget.value!;
    });
  }

  @override
  void dispose() {
    tController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool read_only = false;
    if(widget.edit_lock!) {
      read_only = true;
    }

    if(widget.useSelect!) {
      read_only = true;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      padding: const EdgeInsets.all(5),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardFormTitle(
            titles: widget.title,
            subTitle:widget.subTitle!,
            titleColor:Colors.black,
            subColor: Colors.black54,),
          const SizedBox(height:10),
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: TextField(
                //key:GlobalKey(),
                controller: tController,
                readOnly: read_only,
                keyboardType: widget.keyboardType,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: (widget.isBold!) ? FontWeight.bold : FontWeight.normal ),
                onChanged: (String value) { widget.onChanged(widget.tag!, value);},
                decoration: (widget.useSelect!)
                    ? InputDecoration(
                      hintText: widget.hint,
                      hintStyle: TextStyle(color: Colors.grey[200]),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton (onPressed: () async {}, icon: const Icon(Icons.list),) ,)
                    : InputDecoration(
                    filled:true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.fromLTRB(15,15,15,12),
                    isDense: true,
                    hintText: widget.hint,
                    hintStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
                      borderSide: BorderSide(width: 3, color: Colors.grey.shade400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(width: 1, color: Colors.grey.shade400),
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
                    ),
                )
              ),
            ),
          ),
        ]
      ),
    );
  }

}
