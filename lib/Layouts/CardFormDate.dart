// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'CardFormTitle.dart';


class CardFormDate extends StatefulWidget {
  CardFormDate({Key? key, required this.title, required this.subTitle,
    required this.initValue, required this.tag, required this.hint,
    required this.onChanged }) : super(key: key);
  final String tag;
  final List<String> title;
  final String initValue;
  final String hint;
  final String subTitle;
  TextInputType? keyboardType = TextInputType.text;
  final Function(String tag, String value) onChanged;

  @override
  _QFormCardState createState() => _QFormCardState();
}

class _QFormCardState extends State<CardFormDate> {
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
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color:Colors.black.withOpacity(0.3),
              blurRadius: 1,
              spreadRadius: 1
            )
          ]
      ),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardFormTitle(titles: widget.title, subTitle:widget.subTitle, titleColor:Colors.black, subColor: Colors.black54,),
          const SizedBox(height:10),
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: TextField(
                controller: tController,
                readOnly: true,
                keyboardType: widget.keyboardType,//TextInputType.text,
                maxLines: 1,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, ),
                onChanged: (String value){
                  widget.onChanged(widget.tag, value);
                },
                decoration: InputDecoration(
                  hintText: widget.hint,
                  border: const OutlineInputBorder(),
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  suffixIcon: IconButton (
                    onPressed: () async {
                      showDatePickerPop(dateString:tController.text, onSelect: (String dateString){
                        setState(() {
                          tController.text = dateString;
                          widget.onChanged(widget.tag, dateString);
                        });
                      });
                    },
                    icon: const Icon(Icons.list),
                  ) ,
                )
              ),
            ),
          ),
        ]
      ),
    );
  }

  /* DatePicker 띄우기 */
  void showDatePickerPop({ required String dateString, required Function(String dateString) onSelect}) {
    if(dateString.indexOf(".")>0) {
      dateString = dateString.replaceAll(".", "-");
    }

    DateTime date = (dateString.length>=10)
        ? DateFormat('yyyy-MM-dd').parse(dateString)
        : DateTime.now();

    Future<DateTime?> selectedDate = showDatePicker(
      context: context,
      initialDate: date,//DateTime(date.year, date.month, date.day), //초기값
      firstDate: DateTime(2010), //시작일
      lastDate: DateTime.now(), //마지막일
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light(), //다크 테마
          child: child!,
        );
      },
    );

    selectedDate.then((dateTime) {
      DateTime date = dateTime!;
      //String dateStr = DateFormat('yyyy-MM-dd').format(date);
      onSelect(DateFormat('yyyy-MM-dd').format(date));
    });
  }
}
