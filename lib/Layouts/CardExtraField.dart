// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Codes/SelectList.dart';
import 'package:transition/transition.dart';
import 'CardFormTitle.dart';

class CardExtraField extends StatefulWidget {
  final String moims_id;
  final List<String> title;
  final String initValue;
  final String tag;
  final bool useSelect;
  final Function(String tag, String value) onChanged;

  String? useSelectTitle;
  String? hint;
  String? subTitle;
  String? selType;
  String? selData;

  int ? maxLength;
  int ? maxLines;
  TextInputAction ? textInputAction;
  TextAlign ? textAlign;
  TextInputType? keyboardType;

  CardExtraField({Key? key,
    required this.title,
    required this.initValue,
    required this.tag,
    required this.moims_id,
    required this.useSelect,
    required this.onChanged,

    this.useSelectTitle = "",
    this.selType = "list",
    this.selData = "",
    this.hint = "",
    this.keyboardType = TextInputType.text,
    this.subTitle = "",

    this.maxLines = 1,
    this.maxLength,//8192,
    this.textInputAction = TextInputAction.done,
    this.textAlign = TextAlign.start,
    }) : super(key: key);

  @override
  _CardExtraFieldState createState() => _CardExtraFieldState();
}

class _CardExtraFieldState extends State<CardExtraField> {
  TextEditingController tController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      tController.text = widget.initValue;
    });
  }

  @override
  void dispose() {
    tController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      padding: const EdgeInsets.all(10),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardFormTitle(
              titles: widget.title,
              subTitle: widget.subTitle!,
              titleColor: Colors.black,
              subColor: Colors.black54,),
            const SizedBox(height: 10),
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: TextField(
                    controller: tController,
                    maxLines:widget.maxLines,
                    maxLength:widget.maxLength,
                    textInputAction:widget.textInputAction,
                    textAlign:widget.textAlign!,
                    readOnly: widget.useSelect,
                    keyboardType: widget.keyboardType,
                    style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold,),
                    onChanged: (String value) {
                      widget.onChanged(widget.tag, value);
                    },
                    decoration: (widget.useSelect)
                        ? InputDecoration(
                      filled:true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.fromLTRB(15,15,15,12),
                      isDense: true,
                      hintText: "카테고리",
                      hintStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
                        borderSide: BorderSide(width: 2, color: Colors.grey.shade400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(width: 1, color: Colors.grey.shade400),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      suffixIcon: IconButton (
                        onPressed: () async {
                          _onSelect(context);
                        },
                        icon: const Icon(Icons.list),
                      ) ,
                    )
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

  Future<void> _onSelect(BuildContext context) async {
    bool isCode;
    String category = widget.useSelectTitle.toString();
    List<String> items;
    if(widget.selType == "코드"){
      isCode = true;
      category = widget.selData.toString();
      items = <String>[];
    }
    else{
      isCode = false;
      items = widget.selData!.split(";");
    }

    var value = await Navigator.push(context,
      Transition(
          child: SelectList(
            title: widget.useSelectTitle.toString(),
            moims_id: widget.moims_id,
            category: category,
            isCodes: isCode,
            isMulti: false,
            items: items,
            minCheckCount: 1,),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
    if (value != null) {
      widget.onChanged(widget.tag, value);
      setState(() {
        tController.text = value;
      });
    }
  }

}