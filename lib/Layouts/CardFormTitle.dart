// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';

class CardFormTitle extends StatelessWidget {
  CardFormTitle({Key? key,
    required this.titles,
    required this.subTitle,
    this.titleColor,
    this.titleSize,
    this.subColor,
    this.subSize }) : super(key: key);

  final List<String> titles;
  final Color?  titleColor;
  final double? titleSize;
  final String  subTitle;
  final Color?  subColor;
  final double? subSize;

  @override
  Widget build(BuildContext context) {
    int count = titles.length;
    bool isSubTitle = (subTitle.length>1) ? true: false;
    if(count==1) {
      String title = titles.elementAt(0).substring(1);
      String flag  = titles.elementAt(0).substring(0,1);
      return Column(
        //mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
                text: title,
                style: TextStyle(//letterSpacing: 1.0,
                    fontSize: (titleSize!=null) ? titleSize:18,
                    color: (titleColor!=null) ? titleColor:Colors.black,
                    fontWeight: (flag=="b") ? FontWeight.bold:FontWeight.normal,
                ),
                children: const []
            ),
          ),

          (subTitle.isNotEmpty) ? const SizedBox(height: 5,): Container(),
          (isSubTitle) ? Text(subTitle,
            style: TextStyle(
              //letterSpacing:0.9,
              fontSize: (subSize!=null) ? subSize:14.0,
              color: (subColor!=null) ? subColor:Colors.brown,
              fontWeight:FontWeight.normal,
            ),): Container(),
        ],
      );
    }
    else if(count==2){
      String t1 = titles.elementAt(0).substring(1);
      String f1  = titles.elementAt(0).substring(0,1);
      String t2 = titles.elementAt(1).substring(1);
      String f2  = titles.elementAt(1).substring(0,1);

      return Column(
        //mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
                text: t1,
                style: TextStyle(
                  //letterSpacing:1.0,
                  fontSize: (titleSize!=null)?titleSize:18,
                  color: (titleColor!=null)?titleColor:Colors.black,
                  fontWeight:(f1=="n")?FontWeight.normal:FontWeight.bold,
                ),
                children: [
                  TextSpan(
                      text: t2,
                      style: TextStyle(
                        //letterSpacing:1.0,
                        fontSize: (titleSize!=null)?titleSize:18,
                        color: (titleColor!=null)?titleColor:Colors.black,
                        fontWeight:(f2=="n")?FontWeight.normal:FontWeight.bold,
                      )
                  ),
                ]
            ),
          ),
          (subTitle.isNotEmpty) ? const SizedBox(height: 5,): Container(),
          (isSubTitle) ? Text(subTitle,
            style: TextStyle(
             // letterSpacing:0.9,
              fontSize: (subSize!=null) ? subSize:14.0,
              color: (subColor!=null) ? subColor:Colors.brown,
              fontWeight:FontWeight.normal,
            ),): Container(),
        ],
      );
    }
    else if(count==3){
      String t1 = titles.elementAt(0).substring(1);
      String f1  = titles.elementAt(0).substring(0,1);
      String t2 = titles.elementAt(1).substring(1);
      String f2  = titles.elementAt(1).substring(0,1);
      String t3 = titles.elementAt(2).substring(1);
      String f3  = titles.elementAt(2).substring(0,1);

      return Column(
        //mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
                text: t1,
                style: TextStyle(
                    fontSize: (titleSize!=null)?titleSize:18,
                    color: (titleColor!=null)?titleColor:Colors.black,
                    fontWeight:(f1=="n")?FontWeight.normal:FontWeight.bold,
                ),
                children: [
                  TextSpan(
                      text: t2,
                      style: TextStyle(
                          fontSize: (titleSize!=null)?titleSize:18,
                          color: (titleColor!=null)?titleColor:Colors.black,
                          fontWeight:(f2=="n")?FontWeight.normal:FontWeight.bold,
                      )
                  ),
                  TextSpan(
                      text: t3,
                      style: TextStyle(
                          fontSize: (titleSize!=null)?titleSize:18,
                          color: (titleColor!=null)?titleColor:Colors.black,
                          fontWeight:(f3=="n")?FontWeight.normal:FontWeight.bold,
                      )
                  ),
                ]
            ),
          ),
          (subTitle.isNotEmpty) ? const SizedBox(height: 5,): Container(),
          (isSubTitle) ? Text(subTitle,
            style: TextStyle(
              //letterSpacing:0.9,
              fontSize: (subSize!=null) ? subSize:14.0,
              color: (subColor!=null) ? subColor:Colors.brown,
              fontWeight:FontWeight.normal,
            ),): Container(),
        ],
      );
    }
    else if(count==4){
      String t1 = titles.elementAt(0).substring(1);
      String f1  = titles.elementAt(0).substring(0,1);
      String t2 = titles.elementAt(1).substring(1);
      String f2  = titles.elementAt(1).substring(0,1);
      String t3 = titles.elementAt(2).substring(1);
      String f3  = titles.elementAt(2).substring(0,1);
      String t4 = titles.elementAt(3).substring(1);
      String f4  = titles.elementAt(3).substring(0,1);
      return Column(
        //mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
                text: t1,
                style: TextStyle(
                  //letterSpacing:1.0,
                  fontSize: (titleSize!=null)?titleSize:18,
                  color: (titleColor!=null)?titleColor:Colors.black,
                  fontWeight:(f1=="n")?FontWeight.normal:FontWeight.bold,
                ),
                children: [
                  TextSpan(
                      text: t2,
                      style: TextStyle(
                        //letterSpacing:1.0,
                        fontSize: (titleSize!=null)?titleSize:18,
                        color: (titleColor!=null)?titleColor:Colors.black,
                        fontWeight:(f2=="n")?FontWeight.normal:FontWeight.bold,
                      )
                  ),
                  TextSpan(
                      text: t3,
                      style: TextStyle(
                        //letterSpacing:1.0,
                        fontSize: (titleSize!=null)?titleSize:18,
                        color: (titleColor!=null)?titleColor:Colors.black,
                        fontWeight:(f3=="n")?FontWeight.normal:FontWeight.bold,
                      )
                  ),
                  TextSpan(
                      text: t4,
                      style: TextStyle(
                        //letterSpacing:1.0,
                        fontSize: (titleSize!=null)?titleSize:18,
                        color: (titleColor!=null)?titleColor:Colors.black,
                        fontWeight:(f4=="n")?FontWeight.normal:FontWeight.bold,
                      )
                  ),
                ]
            ),
          ),
          (subTitle.isNotEmpty) ? const SizedBox(height: 5,): Container(),
          (isSubTitle) ? Text(subTitle,
            style: TextStyle(
              //letterSpacing:0.9,
              fontSize: (subSize!=null) ? subSize:14.0,
              color: (subColor!=null) ? subColor:Colors.brown,
              fontWeight:FontWeight.normal,
            ),): Container(),
        ],
      );
    }
    else if(count==5){
      String t1 = titles.elementAt(0).substring(1);
      String f1  = titles.elementAt(0).substring(0,1);
      String t2 = titles.elementAt(1).substring(1);
      String f2  = titles.elementAt(1).substring(0,1);
      String t3 = titles.elementAt(2).substring(1);
      String f3  = titles.elementAt(2).substring(0,1);
      String t4 = titles.elementAt(3).substring(1);
      String f4  = titles.elementAt(3).substring(0,1);
      String t5 = titles.elementAt(4).substring(1);
      String f5  = titles.elementAt(4).substring(0,1);
      return Column(
        //mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
                text: t1,
                style: TextStyle(
                  //letterSpacing:1.0,
                  fontSize: (titleSize!=null)?titleSize:18,
                  color: (titleColor!=null)?titleColor:Colors.black,
                  fontWeight:(f1=="n")?FontWeight.normal:FontWeight.bold,
                ),
                children: [
                  TextSpan(
                      text: t2,
                      style: TextStyle(
                        //letterSpacing:1.0,
                        fontSize: (titleSize!=null)?titleSize:18,
                        color: (titleColor!=null)?titleColor:Colors.black,
                        fontWeight:(f2=="n")?FontWeight.normal:FontWeight.bold,
                      )
                  ),
                  TextSpan(
                      text: t3,
                      style: TextStyle(
                        fontSize: (titleSize!=null)?titleSize:18,
                        color: (titleColor!=null)?titleColor:Colors.black,
                        fontWeight:(f3=="n")?FontWeight.normal:FontWeight.bold,
                      )
                  ),
                  TextSpan(
                      text: t4,
                      style: TextStyle(
                        //letterSpacing:1.0,
                        fontSize: (titleSize!=null)?titleSize:18,
                        color: (titleColor!=null)?titleColor:Colors.black,
                        fontWeight:(f4=="n")?FontWeight.normal:FontWeight.bold,
                      )
                  ),
                  TextSpan(
                      text: t5,
                      style: TextStyle(
                        //letterSpacing:1.0,
                        fontSize: (titleSize!=null)?titleSize:18,
                        color: (titleColor!=null)?titleColor:Colors.black,
                        fontWeight:(f5=="n")?FontWeight.normal:FontWeight.bold,
                      )
                  ),
                ]
            ),
          ),
          (subTitle.isNotEmpty) ? const SizedBox(height: 5,): Container(),
          (isSubTitle) ? Text(subTitle,
            style: TextStyle(
              //letterSpacing:0.9,
              fontSize: (subSize!=null) ? subSize:14.0,
              color: (subColor!=null) ? subColor:Colors.brown,
              fontWeight:FontWeight.normal,
            ),): Container(),
        ],
      );
    }
    else {
      count = 6;
      String t1 = titles.elementAt(0).substring(1);
      String f1  = titles.elementAt(0).substring(0,1);
      String t2 = titles.elementAt(1).substring(1);
      String f2  = titles.elementAt(1).substring(0,1);
      String t3 = titles.elementAt(2).substring(1);
      String f3  = titles.elementAt(2).substring(0,1);
      String t4 = titles.elementAt(3).substring(1);
      String f4  = titles.elementAt(3).substring(0,1);
      String t5 = titles.elementAt(4).substring(1);
      String f5  = titles.elementAt(4).substring(0,1);
      String t6 = titles.elementAt(5).substring(1);
      String f6  = titles.elementAt(5).substring(0,1);
      return Column(
        //mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
                text: t1,
                style: TextStyle(
                  //letterSpacing:1.0,
                  fontSize: (titleSize!=null)?titleSize:18,
                  color: (titleColor!=null)?titleColor:Colors.black,
                  fontWeight:(f1=="n")?FontWeight.normal:FontWeight.bold,
                ),
                children: [
                  TextSpan(
                      text: t2,
                      style: TextStyle(
                        //letterSpacing:1.0,
                        fontSize: (titleSize!=null)?titleSize:18,
                        color: (titleColor!=null)?titleColor:Colors.black,
                        fontWeight:(f2=="n")?FontWeight.normal:FontWeight.bold,
                      )
                  ),
                  TextSpan(
                      text: t3,
                      style: TextStyle(
                        //letterSpacing:1.0,
                        fontSize: (titleSize!=null)?titleSize:18,
                        color: (titleColor!=null)?titleColor:Colors.black,
                        fontWeight:(f3=="n")?FontWeight.normal:FontWeight.bold,
                      )
                  ),
                  TextSpan(
                      text: t4,
                      style: TextStyle(
                        //letterSpacing:1.0,
                        fontSize: (titleSize!=null)?titleSize:18,
                        color: (titleColor!=null)?titleColor:Colors.black,
                        fontWeight:(f4=="n")?FontWeight.normal:FontWeight.bold,
                      )
                  ),
                  TextSpan(
                      text: t5,
                      style: TextStyle(
                        //letterSpacing:1.0,
                        fontSize: (titleSize!=null)?titleSize:18,
                        color: (titleColor!=null)?titleColor:Colors.black,
                        fontWeight:(f5=="n")?FontWeight.normal:FontWeight.bold,
                      )
                  ),
                  TextSpan(
                      text: t6,
                      style: TextStyle(
                        //letterSpacing:1.0,
                        fontSize: (titleSize!=null)?titleSize:18,
                        color: (titleColor!=null)?titleColor:Colors.black,
                        fontWeight:(f6=="n")?FontWeight.normal:FontWeight.bold,
                      )
                  ),
                ]
            ),
          ),
          (subTitle.isNotEmpty) ? const SizedBox(height: 5,): Container(),
          (isSubTitle) ? Text(subTitle,
            style: TextStyle(
              //letterSpacing:0.9,
              fontSize: (subSize!=null) ? subSize:14.0,
              color: (subColor!=null) ? subColor:Colors.brown,
              fontWeight:FontWeight.normal,
            ),): Container(),
        ],
      );
    }
  }
}
