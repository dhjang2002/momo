// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Webview/DaumAddress.dart';
//import 'package:kpostal/kpostal.dart';
import 'CardFormTitle.dart';

class CardFormAddr extends StatefulWidget {
  CardFormAddr({Key? key, required this.title, required this.subTitle,
    required this.initAddr, required this.initExt,
    required this.onAddrChanged, required this.onExtChanged,}) : super(key: key);

  final List<String> title;
  final String subTitle;
  final String initAddr;
  final String initExt;

  final Function(String addr, String area, String latitude, String longitude) onAddrChanged;
  final Function(String ext) onExtChanged;

  @override
  _CardFormAddrState createState() => _CardFormAddrState();
}

class _CardFormAddrState extends State<CardFormAddr> {
  TextEditingController t1Controller = TextEditingController();
  TextEditingController t2Controller = TextEditingController();

  late FocusNode myFocusNode;
  @override
  void initState() {
    super.initState();
    setState(() {
      t1Controller.text = widget.initAddr;
      t2Controller.text = widget.initExt;
      myFocusNode = FocusNode();
    });
  }

  @override
  void dispose() {
    t1Controller.dispose();
    t2Controller.dispose();
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      padding: const EdgeInsets.all(10),

      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardFormTitle(titles: widget.title, subTitle:widget.subTitle,
            titleColor:Colors.black, subColor: Colors.black54,),
          const SizedBox(height:10),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: TextField(
                    //key:GlobalKey(),
                      controller: t1Controller,
                      readOnly: true,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, ),
                      onChanged: (String value){},
                      decoration: InputDecoration(
                          filled:true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.fromLTRB(15,15,15,12),
                          isDense: true,
                          hintText: "주소",
                          hintStyle: const TextStyle(color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
                            borderSide: BorderSide(width: 2, color: Colors.grey.shade400),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
                            borderSide: BorderSide(width: 1, color: Colors.grey.shade400),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
                          ),
                        suffixIcon: IconButton (
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DaumAddress(
                                  callback: (KAddress result) {
                                    //Navigator.pop(context, address);
                                    if(result != null){
                                      setState(() {
                                        t1Controller.text = result.addr;
                                        t2Controller.text = result.bname;
                                      });
                                      String area = result.dong;
                                      String latitude = result.lat.toString();
                                      String longitude = result.lon.toString();
                                      widget.onAddrChanged(result.addr, area, latitude, longitude);
                                      FocusScope.of(context).requestFocus(myFocusNode);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.search),
                        ) ,
                      )
                  ),
                ),

                Visibility(
                  visible: (t1Controller.text.isNotEmpty) ? true : false,
                  child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: TextField(
                    //key:GlobalKey(),
                      controller: t2Controller,
                      focusNode: myFocusNode,
                      readOnly: false,//(widget.useSelect) ? true : false,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, ),
                      onChanged: (String value){
                        widget.onExtChanged(value);
                      },
                      decoration: InputDecoration(
                        filled:true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.fromLTRB(15,15,15,12),
                        isDense: true,
                        hintText: "상세 주소",
                        hintStyle: const TextStyle(color: Colors.grey),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
                          borderSide: BorderSide(width: 2, color: Colors.grey.shade400),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(const Radius.circular(8.0)),
                          borderSide: BorderSide(width: 1, color: Colors.grey.shade400),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                        ),)
                  ),
                ),),
              ],
            )
          ),
        ]
      ),
    );
  }
}
