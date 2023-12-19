// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Models/FieldData.dart';
import 'package:momo/Models/Moims.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Utils/DateForm.dart';
import 'package:momo/Utils/utils.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';

class MoimInfoView extends StatefulWidget {
  final Moims moims;
  const MoimInfoView({
    Key? key,
    required this.moims
  }) : super(key: key);

  @override
  _MoimInfoViewState createState() => _MoimInfoViewState();
}

class _MoimInfoViewState extends State<MoimInfoView> {
  final _valueNotifier = ValueNotifier<int>(0);
  bool _bReady = false;

  @override
  void initState() {
    setState(() {
      _bReady = true;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
          title: const Text("모임소개",
              style: TextStyle(color: Colors.black)),
          leading: Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                // (isPageBegin) ? Icons.close :
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
          actions: [
            Visibility(
              visible: false,
              child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {}),
            ),
          ],
        ),
        body: _renderBody());
  }

  Widget _renderBody() {
    if (!_bReady) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _renderCorver(),
            const SizedBox(height: 50),
            _renderTitle(widget.moims.moim_name!),
            _renderContent(widget.moims.moim_title!),
            const SizedBox(height: 50),
            _renderTitle("모임설명"),
            _renderContent(widget.moims.moim_description!),
            const SizedBox(height: 50),
            _renderMoimInfo(),
            const SizedBox(height: 50),
          ]),
    );
  }

  Widget _renderCorver() {
    //final PageController _pageController = PageController(initialPage: 0,);
    String thumnails = widget.moims.moim_thumnails!.replaceAll("_thum", "");
    final List<String> photoList = thumnails.split(";");

    final double szCover = MediaQuery.of(context).size.width*.65;
    if (photoList.isNotEmpty) {
      return SizedBox(
          height: szCover,
          child: Stack(
            children: [
              PageView.builder(
                  scrollDirection: Axis.horizontal,
                  //controller: _pageController,
                  //physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _valueNotifier.value = index;
                    });
                  },
                  itemCount: photoList.length,
                  itemBuilder: (BuildContext context, int index) {
                    String url = URL_HOME + photoList.elementAt(index);
                    return simpleBlurImage(url, 1.0);
                  }),
              Align(
                // indicator
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CirclePageIndicator(
                    itemCount: photoList.length,
                    dotColor: Colors.black,
                    selectedDotColor: Colors.white,
                    size: 5.0,
                    currentPageNotifier: _valueNotifier,
                  ),
                ),
              ),
            ],
          ));
    }
    return Container();
  }

  Widget _renderTitle(String text) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20,0,20,0),
      child: Text(text,
          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _renderContent(String text) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20,15,20,0),
      child: Text(text,
          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal)),
    );
  }

  Widget _renderMoimInfo() {
    List<FieldData> data = <FieldData>[];
    String date = DateForm().parse(widget.moims.created_at.toString()).getDate();
    data.add(FieldData(field:"", display:"모임성격", value:widget.moims.moim_category));
    data.add(FieldData(field:"", display:"운영방식", value:widget.moims.moim_kind));
    data.add(FieldData(field:"", display:"가입승인", value:widget.moims.moim_accept));
    data.add(FieldData(field:"", display:"검색테그", value:widget.moims.moim_tag));
    data.add(FieldData(field:"", display:"생성일자", value:date));

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("모임정보", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),),
          const SizedBox(height: 15,),
          Container(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                //padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                itemCount: data.length, //리스트의 개수
                itemBuilder: (BuildContext context, int index) {
                  return _fieldRow(
                      data.elementAt(index).display.toString(),
                      data.elementAt(index).value.toString());
                }),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 1, color: Colors.grey.shade200),
                left: BorderSide(width: 1, color: Colors.grey.shade200),
                right: BorderSide(width: 1, color: Colors.grey.shade200),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _fieldRow(String label, String value) {
    return Container(
      child: Row(
        children: [
          Expanded(
              flex: 25,
              child: Container(
                padding: const EdgeInsets.fromLTRB(5,15,5,15),
                color: Colors.grey.shade50,
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
              )),
          Expanded(
              flex: 75,
              child: Container(
                padding: const EdgeInsets.only(left:10),
                child: Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              )),
        ],
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.0, color: Colors.grey.shade200),
        ),
      ),
    );
  }

}

