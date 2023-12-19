// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Constants/Constants.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Models/FieldData.dart';
import 'package:momo/Models/Files.dart';
import 'package:momo/Models/MemberExtra.dart';
import 'package:momo/Models/MemberInfo.dart';
import 'package:momo/Models/Shops.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Shops/ShopHome.dart';
import 'package:momo/Utils/DateForm.dart';
import 'package:momo/Utils/Launcher.dart';
import 'package:momo/Utils/utils.dart';
import 'package:transition/transition.dart';


class MemberHome extends StatefulWidget {
  final String member_id;
  final bool isNickFirst;
  const MemberHome({Key? key,
    required this.isNickFirst,
    required this.member_id
  }) : super(key: key);

  @override
  _MemberHomeState createState() => _MemberHomeState();
}

class _MemberHomeState extends State<MemberHome> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();


  late String _usersId;

  late MemberInfo _memberInfo;
  bool _bMemberInfo = false;

  List<MemberExtra> _extraInfo = <MemberExtra>[];
  //bool _bExtraInfo = false;

  bool _bFacePhoto = false;
  List<Files> _facePhoto = <Files>[];
  
  List<Shops> _shopList = <Shops>[];
  bool _bShopList = false;

  // bool _bShopListPhoto = false;
  List<Files> _shopListPhoto = <Files>[];

  @override
  void initState() {
    super.initState();
    _loadMemberInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key:_key,
      backgroundColor: Colors.white,
      //extendBodyBehindAppBar: true,
      appBar: AppBar(
          elevation: 0.0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppBar_Icon,),
                onPressed: () {
                  Navigator.pop(context);
                }),
            actions: [
              Visibility(
                visible: false,
                child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                    }
                ),
              ),
              Visibility(
                visible: false,//(!bSearch) ? true : false,
                child: IconButton(
                    icon: const Icon(Icons.more_vert),// dehaze_rounded),
                    onPressed: () {
                    }
                ),
              ),
            ],
          ),
      body: SingleChildScrollView(
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: (_bMemberInfo)
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildContact(),
                  const SizedBox(height: 10),
                  Container(
                      padding: const EdgeInsets.only(left:20, right: 20),
                      child:const Divider(height: 50)
                  ),
                  _buildMemberInfo(),
                  const SizedBox(height: 25),
                  _buildCompany(),
                  const SizedBox(height: 25),
                  //ShowItems(),
                ],)
                  : Container()
          )
      )
    );
  }

  Widget _buildHeader() {
    if(!_bFacePhoto) {
      return const SizedBox(
          height: 150,
          width: double.infinity,
          child: Center(child: CircularProgressIndicator())
      );
    }

    String title = "";
    if(widget.isNickFirst) {
      title = _memberInfo.mb_nick.toString();
      if (title.isEmpty) {
        title = _memberInfo.mb_name.toString();
      }
    }
    else {
      title = _memberInfo.mb_name.toString();
    }

    String email = _memberInfo.mb_email.toString();
    String hp = _memberInfo.mb_hp.toString();

    String url = "";
    if(_facePhoto.isNotEmpty && _facePhoto.elementAt(0).url.toString().isNotEmpty) {
      url = URL_HOME + _facePhoto.elementAt(0).url.toString();
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60.0,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: simpleBlurImageWithName(_memberInfo.mb_name.toString(), 52, url, 1.0)),
          ),

          const SizedBox(height: 15,),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),),
          const SizedBox(height: 5,),
          Text(email, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),),
          const SizedBox(height: 5,),
          Text(hp, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),),
        ],
      ),
    );
  }

  Widget _buildContact(){
    return Container(
      padding: const EdgeInsets.only(left:20, right:20),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: OutlinedButton(
              child: Container(
                  padding: const EdgeInsets.only(top:8, bottom: 8),
                  child:Row(
                  children: [
                    Image.asset("assets/icon/icon_share.png", width: 30, height: 30),
                    const SizedBox(width: 3),
                    const Text("공 유",
                        style: const TextStyle(color:Colors.black, fontSize: 12, fontWeight:FontWeight.bold)),
                  ])),
              onPressed: () async {
                String subject = "연락처 공유";
                // String text = "\n\n이름: ${_memberInfo.mb_name}"
                //     "\n휴대폰: ${_memberInfo.mb_hp}"
                //     "\n이메일: ${_memberInfo.mb_email}"
                //     "\n\nMOMO에서 보냄";
                // //"\nmomo.maxidc.net";
                //
                // String imageUrl = URL_HOME+_memberInfo.mb_thumnail.toString();
                // //imageUrl = imageUrl.replaceAll("_thum.jpg", ".jpg");
                // String imagePath = await downloadFile(imageUrl, "face.jpg");
                // //await shareInfo(subject: "", text: "", imagePaths: [imagePath]);
                String text = "https://momo.maxidc.net/b_card/?id=${_memberInfo.mb_no}";
                await shareInfo(subject: subject, text: text, imagePaths:[]);
              },
            )),
            Expanded(child:OutlinedButton(
              child: Container(
                  padding: const EdgeInsets.only(top:8, bottom: 8),
                  child:Row(
                  children: [
                    Image.asset("assets/icon/icon_phone.png", width: 30, height: 30),
                    const SizedBox(width: 3),
                    const Text("통 화",
                        style: const TextStyle(color:Colors.black, fontSize: 12, fontWeight:FontWeight.bold)),
                  ])),
              onPressed: () {
                callPhone(_memberInfo.mb_hp.toString());
              },
            )),
            Expanded(child:OutlinedButton(
              child: Container(
                  padding: const EdgeInsets.only(top:8, bottom: 8),
                  child:Row(
                  children: [
                    Image.asset("assets/icon/icon_message.png", width: 30, height: 30),
                    const SizedBox(width: 3),
                    const Text("문 자",
                        style: const TextStyle(color:Colors.black, fontSize: 12, fontWeight:FontWeight.bold)),
                  ])),
              onPressed: () {
                callSms(_memberInfo.mb_hp.toString());
              },
            )),
          ]),
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
                      fontSize: 14,
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
  
  Widget _buildMemberInfo() {
    List<FieldData> data = <FieldData>[];
    String grade = _memberInfo.member_grade.toString();
    String duty = _memberInfo.member_duty.toString();
    String date = DateForm().parse(_memberInfo.created_at.toString()).getDate();
    if(duty.length>2) {
      duty = duty.substring(2);
    }

    data.add(FieldData(field:"", display:"모임직책", value:duty));
    data.add(FieldData(field:"", display:"관리권한", value:grade));
    if (_extraInfo.isNotEmpty) {
      data.addAll(_memberInfo.getExtraList(_extraInfo));
    }
    data.add(FieldData(field:"", display:"가입일자", value:date));

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

  Widget _buildCompany() {

    if(!_bShopList) return Container();
    
    final double list_height = MediaQuery.of(context).size.width*.9;
    if(_bShopList && _shopList.isNotEmpty) {
      return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(15,0,15,0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("회원 사업장", style: const TextStyle(fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),),
              const SizedBox(height: 10,),
              SizedBox(
                height: list_height,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: _shopList.length,
                    itemBuilder: (context, index) {
                      return _shopItem(index);
                    }),
              )
            ],)
      );
    }
    else
    {
      return Container();
    }
  }

  Widget _shopItem(int index) {
    final double item_width  = MediaQuery.of(context).size.width*.6;
    //final double item_height = item_width*.7;
    final double pict_width  = item_width *.9;
    final double pict_height = pict_width;

    Shops info   = _shopList.elementAt(index);
    String title = info.shop_name.toString();
    String desc  = info.shop_desc.toString();

    List tags  = info.shop_tag.toString().split(";");
    String tag = "";
    for (var element in tags) {
      if(tag.isNotEmpty) {
        tag += ",";
      }
      tag += ("#"+element.toString());
    }

    String url = "";
    if(index<_shopListPhoto.length) {
      if (_shopListPhoto[index].url
          .toString()
          .isNotEmpty) {
        url = URL_HOME + _shopListPhoto[index].url.toString();
      }
    }

    return GestureDetector(
      onTap:() {
        _showShop(info.id.toString());
      },
      child: Container(
        width: item_width,
        padding: const EdgeInsets.all(10),
        //color: Colors.grey[50],
        child: Column(
          children: [
            SizedBox(width: pict_width, height: pict_height,
                child: ClipRRect(borderRadius: BorderRadius.circular(10.0), child:simpleBlurImage(url, 1.0))
            ),
            const SizedBox(height:5),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(title, maxLines: 1, style: const TextStyle(fontSize: 16, color:Colors.black, fontWeight: FontWeight.bold))),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(desc, maxLines: 2, style: const TextStyle(fontSize: 14, color:Colors.black, fontWeight: FontWeight.normal))),
            Container(
                alignment: Alignment.centerLeft,
                child: Text(tag, maxLines: 2, style: const TextStyle(fontSize: 14, color:Colors.deepOrange, fontWeight: FontWeight.normal))),
          ],
        ),
      ),
    );
  }

  Future <void> _loadShopInfo() async {
    _bShopList = false;
    Remote.getShops(
        params: {
          "command": "LIST",
          "list_attr":"Owner",
          "users_id": _usersId},
        onResponse: (List<Shops> list) async {
          _shopListPhoto.clear();
          _shopListPhoto = List.filled(list.length, Files(), growable: false);
          _bShopList = true;
          _shopList  = list;
          for(int index=0; index<_shopList.length; index++) {
            await _loadShopPhotos(index, _shopList[index].id.toString());
          }
          setState(() {
            _bShopList = true;
          });
        });
  }

  Future <void> _loadShopPhotos(int index, String photo_id) async {
    await Remote.getFiles(
        params: {
          "command": "LIST",
          "photo_type": photo_tag_shop,
          "photo_id": photo_id
        },
        onResponse: (List<Files> list) {
          if(list.isNotEmpty) {
            _shopListPhoto[index] = list.elementAt(0);
          }
          else{
            _shopListPhoto[index] = Files();
          }
        });
  }

  Future <void> _loadMemberInfo() async {
    _bMemberInfo = false;
    Remote.getMemberInfo(params: {"command":"INFO", "id":widget.member_id},
        onResponse: (List<MemberInfo> list){
          setState(() {
            _bMemberInfo = true;
            _memberInfo = list.elementAt(0);
            _usersId = _memberInfo.mb_no.toString();

            _loadFace();
            _loadExtra();
            _loadShopInfo();
          });
        });
  }

  Future <void> _loadFace() async {
    _bFacePhoto = false;
    Remote.getFiles(params: {
      "command":"LIST",
      "photo_type":photo_tag_user,
      "photo_id":_usersId},
        onResponse: (List<Files> list){
          setState(() {
            _bFacePhoto = true;
            _facePhoto = list;
          });
        });
  }

  Future <void> _loadExtra() async {
    //_bExtraInfo = false;
    _extraInfo.clear();
    Remote.getMemberExtra(params: {"command":"LIST", "moims_id":"${_memberInfo.moims_id}"},
        onResponse: (List<MemberExtra> list){
          setState(() {
            //_bExtraInfo  = true;
            _extraInfo = list;
          });
        });
  }

  Future <void> _showShop(String shop_id) async {
    Navigator.push(
      context,
      Transition(
          child: ShopHome(isEditMode: false, shops_id: shop_id,),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
  }

}
