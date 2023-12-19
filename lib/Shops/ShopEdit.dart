// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print
import 'package:flutter/material.dart';
import 'package:momo/Constants/Constants.dart';
import 'package:momo/Layouts/CardEditItem.dart';
import 'package:momo/Layouts/CardExtraField.dart';
import 'package:momo/Layouts/CardFormAddr.dart';
import 'package:momo/Layouts/CardFormText.dart';
import 'package:momo/Layouts/CardPhotoEdit.dart';
import 'package:momo/Models/PageInfo.dart';
import 'package:momo/Models/Shops.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/utils.dart';
import 'package:provider/provider.dart';

class ShopEdit extends StatefulWidget {
  final String shop_id;
  const ShopEdit({Key? key,
    required this.shop_id
  }) : super(key: key);

  @override
  _ShopEditState createState() => _ShopEditState();
}

class _ShopEditState extends State<ShopEdit> {
  late String title = "정보수정";


  int m_isChanged = 0;
  bool m_bLoaded = false;
  bool m_isDirty = false;

  Shops m_shops = Shops();

  var loginInfo;
  @override
  void initState() {
    super.initState();

    loginInfo = Provider.of<LoginInfo>(context, listen:false);
    _loadMoimHome();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () { FocusScope.of(context).unfocus(); },
        child: WillPopScope (
          onWillPop: () => _onBackPressed(context),
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: AppBar_Color,
              elevation: 1.0,
              title: Text(title, style:TextStyle(color:AppBar_Title)),
              leading: Visibility(
                visible:  true,
                child: IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: AppBar_Icon,), // (isPageBegin) ? Icons.close :
                    onPressed: () {
                      _close(context);
                    }
                ),
              ),
              actions: [
                Visibility(
                  visible: false,
                  child: IconButton(
                      icon: Icon(Icons.close, color: AppBar_Icon),
                      onPressed: () {
                        //doConfirmQuit();
                      }
                  ),
                ),
              ],
            ),
            body: (m_bLoaded) ? BuildHome() : const Center(child: CircularProgressIndicator(),),
          )
        )
    );
  }

  Widget BuildHome() {
    return Stack(
      children: [
        Positioned(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(15),
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CardFormText(
                        maxLength: 64,
                        title: const ["bQ1. ","b사업장명칭","n을 입력해주세요."],
                        subTitle: "",
                        keyboardType: TextInputType.text,
                        value: m_shops.shop_name.toString(),
                        tag: "shop_name",
                        hint: "사업장명칭",
                        useSelect: false,
                        onChanged: (String tag, String value) {
                          m_shops.shop_name = value;
                          _checkValidate();
                        }),
                    CardFormText(
                        maxLength: 8192,
                        title: const ["bQ2. ","n사업장 ","b설명글","n을 입력해주세요."],
                        subTitle: "",
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        value: m_shops.shop_desc.toString(),
                        tag: "shop_desc",
                        hint: "사업장설명",
                        useSelect: false,
                        onChanged: (String tag, String value) {
                          m_shops.shop_desc = value;
                          _checkValidate();
                        }),
                    const SizedBox(height:20),
                    CardFormAddr(
                        title: const ["bQ3. ","b사업장주소","n를 입력해주세요."],
                        subTitle: "",
                        initAddr: m_shops.shop_addr.toString(),
                        initExt:  m_shops.shop_addr_ext.toString(),
                        onAddrChanged: (String addr, String area, String latitude, String longitude){
                          m_shops.shop_addr = addr;
                          m_shops.shop_area = area;
                          m_shops.shop_addr_gps_latitude  = latitude;
                          m_shops.shop_addr_gps_longitude = longitude;
                          print("onAddrChanged():addr=$addr, area=$area, "
                              "latitude=$latitude, longitude=$longitude");
                          _checkValidate();
                        },
                        onExtChanged: (String ext) {
                          m_shops.shop_addr_ext = ext;
                          print("onExtChanged():ext=$ext");
                          setState(() {
                            _checkValidate();
                          });

                        }),
                    const SizedBox(height:10),
                    CardFormText(
                        maxLength: 16,
                        title: const ["bQ4. ","n사업장의 ","b전화번호","n를 입력해주세요."],
                        subTitle: "",
                        keyboardType: TextInputType.phone,
                        value: m_shops.shop_tel.toString(),
                        tag: "shop_tel",
                        hint: "전화번호",
                        useSelect: false,
                        onChanged: (String tag, String value) {
                          m_shops.shop_tel = value;
                          _checkValidate();
                        }),
                    CardFormText(
                        maxLength: 255,
                        title: const ["bQ5. ","n홍보 ","b홈페이지","n를 입력해주세요."],
                        subTitle: "",
                        keyboardType: TextInputType.emailAddress,
                        value: m_shops.shop_url.toString(),
                        tag: "shop_url",
                        hint: "홈페이지",
                        useSelect: false,
                        onChanged: (String tag, String value) {
                          m_shops.shop_url = value;
                          _checkValidate();
                        }),
                    CardEditItem(
                      title: const ["bQ6. ","n홍보용 ","bTag","n를 지정해주세요."],
                      value: m_shops.shop_tag.toString(),
                      hint: "Tag",
                      tag: 'shop_tag',
                      onChanged: (String tag, String value) {
                        m_shops.shop_tag = value;
                        print("tag=>$value");
                        setState(() {
                          _checkValidate();
                        });
                      },
                    ),

                    CardExtraField(
                        title: const ["bQ7. ","n사업장 ","b카테고리","n를 지정해주세요."],
                        initValue: m_shops.shop_category.toString(),
                        moims_id: "0",
                        tag: "shop_category",
                        useSelect: true,
                        selType: "코드",
                        selData: "업종",
                        useSelectTitle: "업종구분",
                        keyboardType: TextInputType.text,
                        onChanged: (String tag, String value){
                          m_shops.shop_category = value;
                          _checkValidate();
                        }
                    ),

                    CardPhotoEdit(
                        title: const ["bQ8.","n 사업장의 대표","b사진","n을 추가해주세요."],
                        max_count: max_photo_shop,
                        photo_type: photo_tag_shop,
                        photo_id: m_shops.id.toString(),
                        users_id: loginInfo.users_id,

                        message: "사업장의 대표 사진을 등록해 주세요. 최대 $min_photo_shop~$max_photo_shop장까지 저장할 수 있습니다.",
                        onChanged: (int count, String thumnails) {
                          m_shops.shop_thumnails = thumnails;
                          m_isChanged++;
                        }),
                    const SizedBox(height:30),
                    Visibility(
                      visible: true,
                      child: Center(
                        child:ElevatedButton(
                          child: const Text("수정하기", style:TextStyle(fontSize:16.0, color:Colors.white)),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              fixedSize: const Size(300, 48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                          onPressed:() {
                            _doUpdate();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height:100),
                  ],),
              ),
            )
        ),
      ],
    );
  }

  Future<bool> _onBackPressed(BuildContext context) {
    _close(context);
    return Future(() => false);
  }

  Future <void> _loadMoimHome() async {
    m_bLoaded = false;
    Remote.getShops(params: {"command":"INFO", "id":widget.shop_id},
        onResponse: (List<Shops> list){
          setState(() {
            m_bLoaded = true;
            m_shops = list.elementAt(0);
            title = m_shops.shop_name.toString();
          });
          m_isChanged = 0;
        });
  }

  bool validate() {
    if(m_shops.shop_name!.isEmpty){
      showToastMessage("상호를 입력해주세요.");
      return false;
    }
    if(m_shops.shop_desc!.isEmpty){
      showToastMessage("사업장 설명을 입력해주세요.");
      return false;
    }
    if(m_shops.shop_addr!.isEmpty){
      showToastMessage("수소를 입력해주세요.");
      return false;
    }

    if(m_shops.shop_tel!.isEmpty){
      showToastMessage("전화번호를 입력해주세요.");
      return false;
    }

    int photo_count = m_shops.shop_thumnails!.split(";").length;
    if(photo_count<min_photo_shop) {
      showToastMessage("사진을 $min_photo_shop장 이상 추가해주세요.");
      return false;
    }
    return true;
  }

  Future <void> _doUpdate() async {

    if(!validate())
      return;

    m_shops.shop_data_ready = "Y";
    Map<String,String> params = m_shops.toMap();
    params.addAll({
      "command":"UPDATE",
    });

    await Remote.reqShops(params: params,
        onResponse: (bool result) {
      if(result){
        m_isChanged = 0;
        m_isDirty = true;
        Navigator.pop(context, m_isDirty);
      }
    });
  }

  void _close(BuildContext context) {

    print("_close():m_isChanged=$m_isChanged");

    if(m_isChanged>0) {
      showDialogPop(
          context:context,
          title: "확인",
          body:const Text("변경된 내용을 저장하시겠습니까?",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
          content:const Text("내용이 변경되었습니다.",
            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.grey),),
          choiceCount:2, yesText: "예", cancelText: "아니오",
          onResult:(bool isOK) async {
            if(isOK) {
              _doUpdate();
            } else {
              Navigator.pop(context);
            }
          }
      );
    }
    else {
        if (m_isDirty) {
          Navigator.pop(context, m_isDirty);
        } else {
          Navigator.pop(context);
        }
      }
  }

  void _checkValidate() {
    m_isChanged++;
  }

}
