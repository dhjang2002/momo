// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Constants/Constants.dart';
import 'package:momo/Layouts/CardEditItem.dart';
import 'package:momo/Layouts/CardFieldsView.dart';
import 'package:momo/Layouts/CardFormRadio.dart';
import 'package:momo/Layouts/CardFormText.dart';
import 'package:momo/Layouts/CardPhotoEdit.dart';
import 'package:momo/Models/Moims.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/utils.dart';
import 'package:provider/provider.dart';

class MoimEdit extends StatefulWidget {
  final String moims_id;
  const MoimEdit({Key? key,
    required this.moims_id
  }) : super(key: key);

  @override
  _MoimEditState createState() => _MoimEditState();
}

class _MoimEditState extends State<MoimEdit> {
  String title = "정보수정";
  //late String users_id = "";
  Moims m_moims = Moims();

  bool m_bKind   = true;
  bool m_bLoaded = false;
  int m_iDirty = 0;
  bool m_isDirty = false;

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
                      }
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
                  children: [
                    CardFormText(
                        edit_lock:true,
                        maxLength: 64,
                        title: const ["bQ1. ","n우리 모임명"],
                        subTitle: "*모임 이름은 변경할 수 없습니다.",
                        hint: "모임 이름을 입력해주세요.",
                        keyboardType: TextInputType.text,
                        value: m_moims.moim_name.toString(),
                        tag: "moim_name",
                        useSelect: false,
                        onChanged: (String tag, String value) {
                          m_moims.moim_name = value;
                          m_iDirty++;
                        }),
                    /*
                    Visibility(
                        visible: true,
                        child: Row(
                            children: [
                              const Spacer(),
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.white,
                                  backgroundColor: Colors.blueAccent,
                                ),
                                child: const Text('중복확인', style: TextStyle(fontSize: 14),),
                                onPressed: () async {
                                  Remote.reqMoims(
                                      params: {
                                        "command":"duplicate",
                                        "canidate":m_moims.moim_name.toString(),
                                      },
                                      onResponse: (bool result){
                                        setState(() {
                                          //_bCheckMoimName = result;
                                        });
                                      });
                                },
                              )
                            ])),
                    */
                    CardFormText(
                        maxLength: 255,
                        title: const ["bQ2. ","n우리 모임 한 줄 소개"],
                        subTitle: "*50자 이내로 작성해주세요.",
                        hint: "예) 친목을 위한 활동모임.",
                        keyboardType: TextInputType.multiline,
                        maxLines:3,
                        value: m_moims.moim_title.toString(),
                        tag: "moim_description",
                        useSelect: false,
                        onChanged: (String tag, String value) {
                          m_moims.moim_title = value;
                          m_iDirty++;
                        }),

                    CardFormText(
                        maxLength: 8192,
                        title: const ["bQ3. ","n우리 모임 상세소개"],
                        subTitle: "*모임의 목적, 취지, 운영방법 등, 잠재 회원에게 소개할 내용을 입력합니다.",
                        hint: "모임의 상세 소개를 해주세요.",
                        keyboardType: TextInputType.multiline,
                        maxLines:12,
                        value: m_moims.moim_description.toString(),
                        tag: "moim_description",
                        useSelect: false,
                        onChanged: (String tag, String value) {
                          m_moims.moim_description = value;
                          m_iDirty++;
                        }),
                    //SizedBox(height:10),
                    CardFormRadio(title: const ["bQ4. ","n우리 모임의 운영 목적은 무엇인가요?"],
                      subTitle: "",isVertical: false,
                      aList: const ["비즈니스","친목모임", "기타", ],
                      tag:"moim_category", value: m_moims.moim_category.toString(),
                      onSubmit: (String tag, String value) {
                        m_moims.moim_category = value;
                        m_iDirty++;
                      },
                    ),
                    //SizedBox(height:10),
                    CardFormRadio(title: const ["bQ5. ","n우리 모임의 검색을 허용하시겠습니까?"],
                      subTitle: "",isVertical: false,
                      aList: const ["공개", "비공개"],
                      tag:"moim_kind", value: m_moims.moim_kind.toString(),
                      onSubmit: (String tag, String value) {
                        setState(() {
                          m_moims.moim_kind = value;
                          m_bKind = (m_moims.moim_kind.toString()=="공개") ? false : true;
                          if(!m_bKind) {
                            m_moims.moim_code = "";
                          }
                          m_iDirty++;
                        });
                      },
                    ),
                    //SizedBox(height:10),
                    Visibility(visible:m_bKind,
                        child: CardFormText(
                            maxLength: 4,
                            title: const ["bQ6. ","n우리 모임의 가입 확인코드"],
                            subTitle: "",
                            keyboardType: TextInputType.number,
                            value: m_moims.moim_code.toString(),
                            tag: "moim_code", hint: "숫자4자",
                            useSelect: false,
                            onChanged: (String tag, String value) {
                              m_moims.moim_code = value;
                              m_iDirty++;
                            }),),
                    //SizedBox(height:10),
                    CardFormRadio(title: const ["bQ7. ","n우리 모임 가입시 자동 승인처리 하시겠습니까?"],
                      subTitle: "",isVertical: false,
                      aList: const ["자동승인", "관리자 확인후 승인"],
                      tag:"moim_accept", value: m_moims.moim_accept.toString(),
                      onSubmit: (String tag, String value) {
                        m_moims.moim_accept = value;
                        m_iDirty++;
                      },
                    ),

                    CardFormRadio(title: const ["bQ8. ","n회원정보에 익명(닉네임)을 사용할까요?"],
                      subTitle: "",isVertical: false,
                      aList: const ["예", "아니오"],
                      tag:"use_nick", value: m_moims.use_nick.toString(),
                      onSubmit: (String tag, String value) {
                        m_moims.use_nick = value;
                        m_iDirty++;
                      },
                    ),

                    const SizedBox(height:20),
                    CardFieldsView(
                        title: const ["bQ9.","n 회원가입 ","b필수 항목","n을 추가하십시오."],
                        moims_id: m_moims.id.toString(),
                    onChange: (String tag, String value) { }),
                    const SizedBox(height:20),
                    CardEditItem(
                      title: const ["bQ10.","n 검색용 ","bTag","n를 등록해 주세요."],
                      value: m_moims.moim_tag.toString(),
                      hint: "#친목",
                      tag: 'moim_tag',
                      onChanged: (String tag, String value) {
                        m_moims.moim_tag = value;
                      },
                    ),
                    const SizedBox(height:20),
                    CardPhotoEdit(
                        title: const ["bQ11.","n 모임의 대표","b사진","n을 추가해주세요."],
                        max_count: max_photo_moim, photo_type: photo_tag_moim,
                        photo_id: m_moims.id.toString(),
                        users_id: loginInfo.users_id,
                        message: "모임의 대표 사진을 등록해 주세요. $max_photo_moim장까지 저장할 수 있습니다.",
                        onChanged: (int count, String thumnails) {
                          m_moims.moim_thumnails = thumnails;
                          m_iDirty++;
                        }),
                    const SizedBox(height:50),
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
                            _onUpdate();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height:50),
                    Visibility(
                      visible: true,
                      child: Center(
                        child:ElevatedButton(
                          child: const Text("모임삭제", style:const TextStyle(fontSize:16.0, color:Colors.white)),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              fixedSize: const Size(300, 48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                          onPressed:() {
                            _doRemove(context);
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
    Remote.getMoims(params: {"command":"INFO", "id":widget.moims_id},
        onResponse: (List<Moims> list){
          setState(() {
            m_bLoaded = true;
            m_moims = list.elementAt(0);
            m_bKind = (m_moims.moim_kind.toString()=="공개") ? false : true;
            if(!m_bKind) {
              m_moims.moim_code = "";
            }
            title = m_moims.moim_name.toString();
          });
          m_iDirty = 0;
        });
  }

  Future <void> _onUpdate() async {
    m_moims.moim_data_ready = "Y";
    Map<String,String> params = m_moims.toMap();
    params.addAll({
      "command":"UPDATE",
    });

    await Remote.reqMoims(params: params,
        onResponse: (bool result) {
      if(result){
        m_iDirty = 0;
        m_isDirty = true;
        Navigator.pop(context, 1);
      }
    });
  }

  Future <void> _onDelete() async {
    await Remote.reqMoims(
        params: {
          "command":"DELETE",
          "id":"${m_moims.id}",
          "users_id":loginInfo.users_id,
        },
        onResponse: (bool result) {
          if(result){
            Navigator.pop(context, -1);
          }
        });
  }

  void _close(BuildContext context) {

    print("_close():m_bDirty=$m_iDirty");

    if(m_iDirty>0) {
      showDialogPop(
          context:context,
          title: "확인",
          body:const Text("변경된 내용을 저장하시겠습니까?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
          content:const Text("내용이 변경되었습니다.",
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.grey),),
          choiceCount:2, yesText: "예", cancelText: "아니오",
          onResult:(bool isOK) async {
            if(isOK) {
              _onUpdate();
            } else {
              Navigator.pop(context);
            }
          }
      );
    }
    else {
        if (m_isDirty) {
          Navigator.pop(context, 1);
        } else {
          Navigator.pop(context);
        }
      }
  }

  void _doRemove(BuildContext context) {

    print("_doRemove():");
    showDialogPop(
        context:context,
        title: "주의!",
        body:const Text("모임을 삭제하시겠습니까?",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),),
        content:const Text("경고: 이 모임의 모든 활동이 중지됩니다. 또한 삭제된 내용은 복구할 수 없습니다.",
          style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.red),),
        choiceCount:2, yesText: "예", cancelText: "아니오",
        onResult:(bool isOK) async {
          if(isOK) {
            _onDelete();
          }
        }
    );
  }
}
