// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Layouts/CardFormTitle.dart';
import 'package:momo/Layouts/TileCard.dart';
import 'package:momo/Utils/utils.dart';

class CardEditItem extends StatefulWidget {
  final Function(String tag, String value) onChanged;
  final String value;
  final String tag;

  List<String>? title;
  int? maxCount;
  String? hint;
  String? subTitle;
  String? desc;

  CardEditItem({Key? key,
    required this.onChanged,
    required this.value,
    required this.tag,

    this.title,
    this.maxCount = 15,
    this.hint = "",
    this.subTitle = "",
    this.desc="",
    }) : super(key: key);

  @override
  _CardEditItemState createState() => _CardEditItemState();
}

class _CardEditItemState extends State<CardEditItem> {
  TextEditingController tController = TextEditingController();

  List<String> m_items = <String>[];
  
  @override
  void initState() {
    super.initState();
    setState(() {
      if(widget.value.length>1) {
        m_items = widget.value.split(";");
      }
      tController.text = "";
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
      color: Colors.white,
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      padding: const EdgeInsets.all(10),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (widget.title != null) ? CardFormTitle(
              titles: widget.title!,
              subTitle: widget.subTitle!,
              titleColor: Colors.black,
              subColor: Colors.black54,) : Container(),
            (widget.title != null)? const SizedBox(height: 10) : Container(),

            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: TextField(
                    controller: tController,
                    maxLines:1,
                    //maxLength:32,
                    textInputAction:TextInputAction.next,
                    textAlign:TextAlign.start,
                    readOnly: false,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                    onChanged: (String value) {},
                    onSubmitted: (value) {
                      _onAdd(tController.text);},
                  decoration: InputDecoration(
                    filled:true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.fromLTRB(15,10,15,10),
                    isDense: true,
                    suffixIcon: IconButton( icon: const Icon(Icons.add, color: Colors.black,),
                      onPressed: () { _onAdd(tController.text.trim()); },),
                    hintText: widget.hint,
                    hintStyle: const TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      borderSide: BorderSide(width: 2, color:Colors.black.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      borderSide: BorderSide(width: 2, color:Colors.black.withOpacity(0.3)),
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: const BorderRadius.all(const Radius.circular(5.0)),
                    ),
                  ),
                ),
              ),
            ),

            Text(widget.desc!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),),
            //const Divider(height: 1,),

            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              itemCount: m_items.length, //리스트의 개수
              itemBuilder: (BuildContext context, int index) {
                return ItemCard(index);
              },),
            const Divider(height: 1,),
            //const Divider(height: 5,),
          ]
      ),
    );
  }

  Widget ItemCard(int index) {
    return Column(
        children: [
          Divider(height: 1),
          TileCard(
            key: GlobalKey(),
            padding: EdgeInsets.fromLTRB(10,13,13,10),
            title: Text(m_items.elementAt(index),
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0),),
            tailing: const Icon(Icons.close, size: 18.0, color: Colors.redAccent,),
            onTrailing:() {
              _onDelete(index);
            },
          ),
    ]);
  }

  String _getItemsValue() {
    String value = "";
    if(m_items.isNotEmpty){
      for (var element in m_items) {
        if(value.isNotEmpty) {
          value += ";";
        }
        value += element;
      }
    }
    return value;
  }
  
  void _onDelete(int index){
    setState(() {
      m_items.removeAt(index);
      widget.onChanged(widget.tag, _getItemsValue());
    });
  }

  bool isValid(String value) {

    int count = m_items.length;
    if(count+1 >= widget.maxCount!) {
      showToastMessage("최대 갯수 초과입니다.");
      return false;
    }

    if(value.length<1){
      showToastMessage("1자 이상 입력해주세요.");
      return false;
    }

    int index = m_items.indexOf(value);
    print("index=$index");
    if(count>0 && index>=0){
      showToastMessage("중복 데이터 입니다.");
      return false;
    }
    return true;
  }

  void _onAdd(String text) {
    text = text.replaceAll("#", "");
    setState(() {
      if(isValid(text)) {
        tController.text = "";
        m_items.insert(0, text);
        if(widget.title != null){
          //widget.title = "(${m_items.length})";
        }
        widget.onChanged(widget.tag, _getItemsValue());
      }
    });
  }

}