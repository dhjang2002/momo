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
import 'package:momo/Utils/utils.dart';
import 'package:transition/transition.dart';

class MemberHomePage extends StatefulWidget {
  final String member_id;
  const MemberHomePage({Key? key,
    required this.member_id
  }) : super(key: key);

  @override
  _MemberHomePageState createState() => _MemberHomePageState();
}

class _MemberHomePageState extends State<MemberHomePage> with AutomaticKeepAliveClientMixin {


  String users_id = "";

  late MemberInfo m_memberInfo;
  bool m_mLoaded = false;

  List<MemberExtra> m_extras = <MemberExtra>[];
  bool eLoaded = false;

  List<Files> photos = <Files>[];
  bool pLoaded = false;

  List<Shops> m_shopList = <Shops>[];
  bool sLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadMemberInfo();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            //color: Colors.grey,
            child: (m_mLoaded)
                ? Column(
              //mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                BuildHeader(),
                const SizedBox(height: 15,),
                BuildContact(),
                const Divider(height: 50,),
                BuildInfo(),
                //Divider(height: 50,),
                BuildMemberInfo(),
                BuildCompany(),
                const SizedBox(height: 50,),
                //ShowItems(),
              ],)
                : Container()
        )
    );
  }

  Widget BuildHeader() {
    String title = m_memberInfo.mb_nick.toString();
    if(title.isEmpty) {
      title = m_memberInfo.mb_name.toString();
    }

    String email = m_memberInfo.mb_email.toString();
    String hp = m_memberInfo.mb_hp.toString();

    String url = "";
    if(photos.isNotEmpty && photos.elementAt(0).url.toString().isNotEmpty) {
      url = URL_HOME + photos.elementAt(0).url.toString();
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //SizedBox(height: 5,),
          // members photo
          SizedBox(
            width: 100,
            height: 100,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: (url.isNotEmpty) ? circleAvatar(url, 100)
                : CircleAvatar(
                  radius: 16.0,
                  child: ClipRRect(
                    child: Image.asset('assets/icon/icon_empty_person.png'),
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
            ),
          ),

          const SizedBox(height: 15,),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),),
          const SizedBox(height: 5,),
          Text(email, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),),
          const SizedBox(height: 5,),
          Text(hp, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),),


        ],
      ),
    );
  }

  Widget BuildContact(){
    return Container(
      //width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20),
      child: Row(
          //mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: Image.asset("assets/icon/icon_share.png",),
              label: const Text("  공 유  ",
                  style: const TextStyle(color: Colors.black, fontSize: 12),
              )
            ),
            const Spacer(),
            OutlinedButton.icon(
                onPressed: () {},
                icon: Image.asset("assets/icon/icon_phone.png"),
                label: const Text("  통 화  ",
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                )
            ),
            const Spacer(),
            OutlinedButton.icon(
                onPressed: () {},
                icon: Image.asset("assets/icon/icon_message.png"),
                label: const Text("  문 자  ",
                  style: TextStyle(color: Colors.black, fontSize: 12),
                )
            ),
          ]),
    );
  }

  Widget BuildInfo() {
    return Container(
      width: MediaQuery.of(context).size.width,
      //color: Colors.green,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("회원 소개", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),),
          const SizedBox(height: 15,),
          const Text("- 디자인협회 간사",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),),
          const SizedBox(height: 5,),
          const Text("- 모임협회 이사",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),),
          const SizedBox(height: 15,),
          const Text("#미용, #컨설팅, #앱 개발, #인공지능",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),),
          const SizedBox(height: 5,),
        ],
      ),
    );
  }
  Widget FieldInfo(String label, String value) {
    return Container(
      child: Row(
        children: [
          Expanded(
              flex: 25,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.grey.shade50,
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
              )),
          Expanded(
              flex: 75,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Text(
                  value,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
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
  Widget BuildMemberInfo() {
    if (m_extras.isEmpty) return Container();

    List<FieldData> data = m_memberInfo.getExtraList(m_extras);
    print(data.toString());

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                //padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                itemCount: data.length, //리스트의 개수
                itemBuilder: (BuildContext context, int index) {
                  return ItemCard(data.elementAt(index).display.toString(),
                      data.elementAt(index).value.toString());
                }),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.grey.shade200,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget ItemCard(String label, String value) {
    return FieldInfo(label, value);
  }
  Widget BuildCompany() {
    final double list_width = MediaQuery.of(context).size.width;
    final double list_height = MediaQuery.of(context).size.width*0.7;
    if(sLoaded && m_shopList.isNotEmpty) {
      return Container(
          width: list_width,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("회원 사업장", style: const TextStyle(fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),),
              const SizedBox(height: 10,),
              SizedBox(
                width: list_width,
                height: list_height,
                //color: Colors.redAccent,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    //physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: m_shopList.length,
                    itemBuilder: (context, index) {
                      return ShopItem(index);
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

  Widget ShopItem(int index) {
    final double item_width  = MediaQuery.of(context).size.width*.6;
    final double item_height = item_width*.7;
    final double pict_width  = MediaQuery.of(context).size.width*.55;
    final double pict_height = pict_width*.8;

    Shops info = m_shopList.elementAt(index);
    String title = info.shop_name.toString();
    String url = "";
    if(info.shop_thumnails!.split(";").elementAt(0).isNotEmpty) {
      url = URL_HOME+info.shop_thumnails!.split(";").elementAt(0);
    }


    return GestureDetector(
      onTap:() {
        _showShop(info.id.toString());
      },
      child: Container(
        width: item_width,
        height: item_height,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(10),
        color: Colors.grey[50],
        child: Column(
          children: [
            SizedBox(
                width: pict_width,
                height: pict_height,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(1.0),
                    child: Image.network(url),
                    /*
                    child: ExtendedImage.network(url, cache: true,
                        fit: BoxFit.fill,
                        shape: BoxShape.rectangle,
                        loadStateChanged:(ExtendedImageState state) {
                          switch(state.extendedImageLoadState) {
                            case LoadState.loading:
                              return Center(child: CircularProgressIndicator(),);
                            case LoadState.completed:
                              break;
                            case LoadState.failed:
                              return Image.asset("assets/icon/icon_empty_person.png", fit: BoxFit.fill,);
                          }
                        })

                     */
                )
            ),
            const SizedBox(height:5),
            Container(
              alignment: Alignment.center,
              child: Text(title, maxLines: 1, style: const TextStyle(fontSize: 14,),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future <void> _loadShop() async {
    sLoaded = false;
    Remote.getShops(
        params: {"command": "LIST", "list_attr":"Owner", "users_id": "${m_memberInfo.mb_no}"},
        onResponse: (List<Shops> list) {
          setState(() {
            sLoaded = true;
            m_shopList = list;
          });
        });
  }

  Future <void> _loadMemberInfo() async {
    m_mLoaded = false;
    Remote.getMemberInfo(params: {"command":"INFO", "id":widget.member_id},
        onResponse: (List<MemberInfo> list) {
          setState(() {
            m_mLoaded = true;
            m_memberInfo = list.elementAt(0);
            users_id = m_memberInfo.mb_no.toString();
            print(m_memberInfo.toString());
            _loadExtra();
            _loadPhotos();
            _loadShop();
          });
        });
  }

  Future <void> _loadPhotos() async {
    pLoaded = false;
    Remote.getFiles(params: {
      "command":"LIST",
      "photo_type":photo_tag_user,
      "photo_id":users_id},
        onResponse: (List<Files> list){
          setState(() {
            pLoaded = true;
            photos = list;
          });
        });
  }

  Future <void> _loadExtra() async {
    eLoaded = false;
    Remote.getMemberExtra(params: {"command":"LIST", "moims_id":"${m_memberInfo.moims_id}"},
        onResponse: (List<MemberExtra> list){
          setState(() {
            eLoaded  = true;
            m_extras = list;
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
