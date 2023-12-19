import 'package:flutter/material.dart';
import 'package:momo/Layouts/TileCard.dart';
import 'package:momo/Models/contactAnniversary.dart';
import 'package:momo/Models/contactFieldData.dart';
import 'package:momo/Models/contactItem.dart';
import 'package:momo/Models/contactMemo.dart';
import 'package:momo/Models/contactPerson.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/Launcher.dart';
import 'package:momo/Utils/utils.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';

class ContactPersonInfo extends StatefulWidget {
  final String usersID;
  final String personID;
  const ContactPersonInfo({
    Key? key,
    required this.usersID,
    required this.personID,
  }) : super(key: key);

  @override
  State<ContactPersonInfo> createState() => _ContactPersonInfoState();
}

class _ContactPersonInfoState extends State<ContactPersonInfo> {
  late ContactPerson person;
  List<ContactItem>         _ciList = <ContactItem>[];
  List<ContactAnniversary>  _caList = <ContactAnniversary>[];
  List<ContactMemo>         _cmList = <ContactMemo>[];

  bool isReady = false;
  String title = "";

  @override
  void initState() {

    Future.microtask((){
      getPerson();
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        //title: "",
        centerTitle: false,
        elevation: 0.0,
        actions: [
          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(Icons.share, size: 24,),
                onPressed: () {
                }),
          ),
          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(Icons.edit, size: 24,),
                onPressed: () {
                }),
          ),
          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(Icons.delete, size: 24,),
                onPressed: () {
                }),
          ),
        ],
      ),
      body:  _buildBody(),
    );
  }

  Widget _buildBody() {
    if(!isReady)
      return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children:[
              //_buildHeader(),
              _PersonCard(),
              const SizedBox(height: 40),
              _buildContact(),
              const SizedBox(height: 10),
              _buildFieldInfo(),
              const SizedBox(height: 10),
              _buildFieldInfo(),
            ]),
      ),
    );
  }

  Widget _fieldRow(String label, String value) {
    return Container(
      child: Row(
        children: [
          Expanded(
              flex: 30,
              child: Container(
                padding: const EdgeInsets.fromLTRB(5,15,5,15),
                color: Colors.grey.shade50,
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
              )),
          Expanded(
              flex: 70,
              child: Container(
                padding: const EdgeInsets.only(left:10),
                child: Text(
                  value,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              )),
        ],
      ),
      decoration: BoxDecoration(
        border: Border(
          //    top: BorderSide(width: 1.0, color: Colors.lightBlue.shade600),
          bottom: BorderSide(width: 1.0, color: Colors.grey.shade200),
        ),
        //color: Colors.grey,
      ),
    );
  }

  Widget _buildFieldInfo() {
    List<ContactFieldData> data = <ContactFieldData>[];
    data.add(ContactFieldData(field:"", display:"업무폰", value:"010-2001-0937"));
    data.add(ContactFieldData(field:"", display:"메모", value:"ROTC 17기\n신규 사업진행 추진중."));
    data.add(ContactFieldData(field:"", display:"추천주기", value:"30일"));
    data.add(ContactFieldData(field:"", display:"생일", value:"7.14(음)"));
    data.add(ContactFieldData(field:"", display:"결혼기념일", value:"12.21"));


    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("회원 소개", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),),
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

  Widget _PersonCard() {
    double tile_size = MediaQuery.of(context).size.width*0.25;
    String name = person.name.toString();
    String url = "";
    if(person.thumnails!.isNotEmpty) {
      url = URL_HOME + person.thumnails.toString();
    }

    String phone = person.phone.toString();
    String division = "SMDT | 소프트웨어 개발";
    String duty = "대표"; // 영업팀/팀장
    String addr = "대전시 서구 신갈마로 102, 302-903호";
    String email = "dhjang2002@gmail.com";
    return TileCard(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(5,20,5,20),
      //key: GlobalKey(),
      leading: SizedBox(
          height: tile_size, width: tile_size,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: simpleBlurImageWithName(name.toString(), 28, url, 1.0)
          )),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                name,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0),
              ),
              const SizedBox(width: 5),
              Text(duty,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 14.0),),

              const Spacer(),
              Text("업무",
                style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0),),
              const SizedBox(width: 5),
              Text("경조사",
                style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0),),
              const SizedBox(width: 5),
              Text("친밀",
                style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0),),
            ],
          ),

          // 휴대폰
          SizedBox(height: 10),
          Text(
            phone,
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 15.0),
          ),

          // 소속
          SizedBox(height: 5),
          Text(
            division,
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 15.0),
          ),

          // 주소
          SizedBox(height: 5),
          Text(
            addr,
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 15.0),
          ),

          // 이메일
          SizedBox(height: 5),
          Text(
            email,
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 15.0),
          ),
        ],
      ),
      // subtitle: (area.isNotEmpty)?Text(area,
      //   style: const TextStyle(
      //       color: Colors.green,
      //       fontWeight: FontWeight.bold,
      //       fontSize: 12.0),) : null,
      // tailing: widget.tailing,
      // onTab:() => _onTab(info),
      // onTrailing: ()=>_onDetail(info),
      //trailing: widget.tailing,
      //onTab:() => widget.onTap(m_MemberList.elementAt(index)),
      //onTrailing: ()=> widget.onDetail(m_MemberList.elementAt(index)),
    );
  }
  Widget _buildContact(){
    return Container(
      padding: const EdgeInsets.only(left:20, right:20),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child:OutlinedButton(
              child: Container(
                  padding: const EdgeInsets.only(top:8, bottom: 8),
                  child:Row(
                      children: [
                        Image.asset("assets/icon/icon_phone.png", width: 30, height: 30),
                        const SizedBox(width: 3),
                        const Text("통화",
                            style: const TextStyle(color:Colors.black, fontSize: 12, fontWeight:FontWeight.bold)),
                      ])),
              onPressed: () {
                callPhone(person.phone.toString());
              },
            )),
            Expanded(child:OutlinedButton(
              child: Container(
                  padding: const EdgeInsets.only(top:8, bottom: 8),
                  child:Row(
                      children: [
                        Image.asset("assets/icon/icon_message.png", width: 30, height: 30),
                        const SizedBox(width: 3),
                        const Text("문자",
                            style: const TextStyle(color:Colors.black, fontSize: 12, fontWeight:FontWeight.bold)),
                      ])),
              onPressed: () {
                callSms(person.phone.toString());
              },
            )),
            Expanded(child:OutlinedButton(
                  child: Container(
                      padding: const EdgeInsets.only(top:8, bottom: 8),
                      child:Row(
                          children: [
                            Image.asset("assets/icon/icon_share.png", width: 30, height: 30),
                            const SizedBox(width: 3),
                            const Text("교류",
                                style: const TextStyle(color:Colors.black, fontSize: 12, fontWeight:FontWeight.bold)),
                          ])),
                  onPressed: () async {
                    String subject = "연락처 공유";
                    String text = "\n\n이름: ${person.name}"
                        "\n휴대폰: ${person.phone}"
                        "\n이메일: ${person.email}"
                        "\n\nMOMO에서 보냄";
                    //"\nmomo.maxidc.net";

                    String imageUrl = URL_HOME+person.thumnails.toString();
                    String imagePath = await downloadFile(imageUrl, "face.jpg");
                    await shareInfo(subject: subject, text: text, imagePaths:[]);
                  },
                )),

          ]),
    );
  }

  Future <void> getItem() async {
    await Remote.getContactItem(
        params: {
          "command":"LIST",
          "users_id":widget.usersID,
          "person_id":widget.personID,
          "rec_start":"0",
          "rec_count":"10",
        },
        onResponse: (List <ContactItem> list) {
          setState(() {
            _ciList = list;
          });
        }
    );
  }

  Future <void> getAnniversary() async {
    await Remote.getContactAnniversary(
        params: {
          "command":"LIST",
          "users_id":widget.usersID,
          "person_id":widget.personID,
          "rec_start":"0",
          "rec_count":"10",
        },
        onResponse: (List <ContactAnniversary> list) {
          setState(() {
            _caList = list;
          });
        }
    );
  }

  Future <void> getMemo() async {
    await Remote.getContactMemo(
        params: {
          "command":"LIST",
          "users_id":widget.usersID,
          "person_id":widget.personID,
          "rec_start":"0",
          "rec_count":"10",
        },
        onResponse: (List <ContactMemo> list) {
          setState(() {
            _cmList = list;
          });
        }
    );
  }

  Future <void> getPerson() async {
    await Remote.getContactPerson(
        params: {
          "command":"INFO",
          "id":widget.personID,
        },
        onResponse: (List <ContactPerson> list) {
          setState(() {
            person = list[0];
            title = person.name!;
            isReady = true;
          });

          getItem();
          getMemo();
          getAnniversary();
        }
    );
  }
}
