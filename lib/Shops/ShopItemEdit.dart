// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Constants/Constants.dart';
import 'package:momo/Layouts/CardFormText.dart';
import 'package:momo/Layouts/CardPhotoEdit.dart';
import 'package:momo/Models/ShopItems.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/utils.dart';
import 'package:provider/provider.dart';

class ShopItemEdit extends StatefulWidget {
  final String items_id;
  const ShopItemEdit({Key? key,
    required this.items_id
  }) : super(key: key);

  @override
  _ShopItemEditState createState() => _ShopItemEditState();
}

class _ShopItemEditState extends State<ShopItemEdit> {
  int m_photo_count = 0;
  late String title = "정보수정";

  int m_isChanged = 0;
  bool m_bLoaded = false;
  bool m_isDirty = false;

  ShopItems m_items = ShopItems();

  late LoginInfo loginInfo;
  @override
  void initState() {
    super.initState();
    loginInfo = Provider.of<LoginInfo>(context, listen:false);
    _loadItems();
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
              title: Text(title, style:const TextStyle(color:AppBar_Title)),
              leading: Visibility(
                visible:  true,
                child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: AppBar_Icon,), // (isPageBegin) ? Icons.close :
                    onPressed: () {
                      _close(context);
                    }
                ),
              ),
              actions: [
                Visibility(
                  visible: false, //(!bSearch) ? true : false,
                  child: PopupMenuButton(
                      itemBuilder: (context) =>
                      [
                        PopupMenuItem(child: const Text("삭제"),
                            onTap: () {
                              _deleteItem();
                            }),
                        //PopupMenuItem(child: Text("Second"), value: 2,),
                      ]
                  ),
                ),
              ],
            ),
            body: (m_bLoaded) ? BuildHome() : const Center(child: const CircularProgressIndicator(),),
          )
        )
    );
  }

  Widget BuildHome() {
    if(m_items.item_price=="0") {
      m_items.item_price = "";
    }

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
                        maxLength: 128,
                        title: const ["bQ1. ","b상품명","n을 입력해주세요."],
                        subTitle: "",
                        keyboardType: TextInputType.text,
                        value: m_items.item_name.toString(),
                        tag: "item_name",
                        hint: "상품명",
                        useSelect: false,
                        onChanged: (String tag, String value) {
                          m_items.item_name = value;
                          _checkValidate();
                        }),
                    CardFormText(
                        maxLength: 16,
                        title: const ["bQ2. ","b판매가격","n을 입력해주세요."],
                        subTitle: "",
                        keyboardType: TextInputType.number,
                        value: m_items.item_price.toString(),
                        tag: "item_price",
                        hint: "사업장명칭",
                        useSelect: false,
                        onChanged: (String tag, String value) {
                          m_items.item_price = value;
                          _checkValidate();
                        }),
                    CardFormText(
                        maxLength: 8192,
                        title: const ["bQ3. ","b상품설명","n을 입력해주세요."],
                        subTitle: "",
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        value: m_items.item_desc.toString(),
                        tag: "item_desc",
                        hint: "상품설명",
                        useSelect: false,
                        onChanged: (String tag, String value) {
                          m_items.item_desc = value;
                          _checkValidate();
                        }),
                    CardFormText(
                        maxLength: 128,
                        title: const ["bQ4. ","n상품의 ","b홈페이지","n를 입력해주세요."],
                        subTitle: "",
                        keyboardType: TextInputType.emailAddress,
                        value: m_items.item_url.toString(),
                        tag: "item_url", hint: "홈페이지",
                        useSelect: false,
                        onChanged: (String tag, String value) {
                          m_items.item_url = value;
                          _checkValidate();
                        }),

                    CardPhotoEdit(
                        title: const ["bQ5.","n 상품의 대표","b사진","n을 추가해주세요."],
                        max_count: max_photo_item,
                        photo_type: photo_tag_item,
                        photo_id: m_items.id.toString(),
                        users_id: loginInfo.users_id!,
                        message: "상품 사진을 첨부해주세요 $max_photo_item장까지 추가할 수 있습니다.",
                        onChanged: (int count, String thumnails) {
                          print("CardPhotoEdit():onChanged():count=$count");
                          m_photo_count = count;
                          m_items.item_thumnails = thumnails;
                          _checkValidate();
                        }),

                    const SizedBox(height:50),
                    Visibility(
                      visible: true,
                      child: Center(
                        child:ElevatedButton(
                          child: const Text("수정하기", style:const TextStyle(fontSize:16.0, color:Colors.white)),
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

                    const SizedBox(height: 50,),
                    Visibility(
                      visible: true,
                      child: Center(
                        child:ElevatedButton(
                          child: const Text("삭제하기", style:const TextStyle(fontSize:16.0, color:Colors.white)),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              fixedSize: const Size(300, 48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                          onPressed:() {
                            _deleteItem();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 100,),
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

  Future <void> _loadItems() async {
    m_bLoaded = false;
    Remote.getShopItems(params: {"command":"INFO", "id":widget.items_id},
        onResponse: (List<ShopItems> list){
          setState(() {
            m_bLoaded = true;
            m_items = list.elementAt(0);
            title = m_items.item_name.toString();
            m_photo_count = m_items.item_thumnails!.split(";").length;
          });
          m_isChanged = 0;
        });
  }

  Future <void> _doUpdate() async {
    if(!validate()) {
      return;
    }

    m_items.item_data_ready = "Y";
    Map<String,String> params = m_items.toMap();
    params.addAll({
      "command":"UPDATE",
    });

    await Remote.reqShopItems(params: params,
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
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.grey),),
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

  bool validate() {
    if(m_items.item_name!.isEmpty){
      showToastMessage("상품명을 입력해주세요.");
      return false;
    }
    if(m_items.item_price!.isEmpty){
      showToastMessage("판매가격을 입력해주세요.");
      return false;
    }
    if(m_items.item_desc!.isEmpty){
      showToastMessage("상품의 설명내용을 입력해주세요.");
      return false;
    }
    if(m_items.item_thumnails!.isEmpty){
      showToastMessage("상품사진을 입력해주세요.");
      return false;
    }
    return true;
  }

  Future <void> _onDelete() async {
    await Remote.reqShopItems(
        params: {
          "command": "DELETE",
          "id": "${m_items.id}",
        }, onResponse: (bool result) {
          Navigator.pop(context, true);
      });
  }

  void _deleteItem() {
    _onDelete();
  }

}
