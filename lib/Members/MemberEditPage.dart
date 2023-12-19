// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:momo/Constants/Constants.dart';
import 'package:momo/Models/Person.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Controller/ColtrollerStatusChange.dart';
import 'package:momo/Models/FieldData.dart';
import 'package:momo/Models/Files.dart';
import 'package:momo/Models/MemberExtra.dart';
import 'package:momo/Models/MemberInfo.dart';
import 'package:momo/Members/MemberEditExtra.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/utils.dart';
import 'package:momo/Webview/WebExplorer.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class MemberEditPage extends StatefulWidget {
  final String moimsId;
  final bool isMember;
  final Function(bool result) onUpdate;
  ControllerStatusChange? controller;

  MemberEditPage({
    Key? key,
    required this.isMember,
    required this.moimsId,
    required this.onUpdate,
    this.controller,

  }) : super(key: key);

  @override
  _MemberEditPageState createState() => _MemberEditPageState();
}

class _MemberEditPageState extends State<MemberEditPage> with AutomaticKeepAliveClientMixin {

  bool _bMemberInfo = false;
  late MemberInfo _memberInfo;

  List<MemberExtra> _memberExtras = <MemberExtra>[];

  bool _bFacePhotoWait = false;

  bool _bFacePhoto = false;
  List<Files> _facePhoto = <Files>[];

  @override
  bool get wantKeepAlive => true;

  //late String usersId;

  late LoginInfo _loginInfo;
  @override
  void initState() {
    //usersId = widget.usersId;
    _loginInfo = Provider.of<LoginInfo>(context, listen:false);
    Future.microtask(() {
      _loadMemberInfo();
    });

    if(widget.controller != null) {
      widget.controller!.addListener(() {
        //print("MemberEditPage::addListener(): action=${widget.controller!.action}");
        switch(widget.controller!.action){
          case ControllerStatusChange.aFrontView:
            break;

          case ControllerStatusChange.aBackView:
            break;

          case ControllerStatusChange.aChange:{
              //usersId = widget.controller!.users_id;
              _loadMemberInfo();
              break;
          }

          case ControllerStatusChange.aInvalidate:{
            _loadMemberInfo();
            break;
          }
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
        child:Stack(
          children: [
            Positioned(
                child: SingleChildScrollView(
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: (_bMemberInfo)
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  BuildHeader(),
                                  const SizedBox(height: 15),
                                  const SizedBox(height: 30),
                                  BuildUserInfo(),
                                  //(widget.isMember) ? const Divider(height: 30) : Container(),
                                  (widget.isMember) ? _buildMemberInfo() : Container(),
                                ],
                        )
                            : Container())))
          ],
    ));
  }

  Widget BuildHeader() {
    if(_bFacePhotoWait) {
      return const Center(child: const CircularProgressIndicator());
    }

    if(!_bFacePhoto) {
      return const SizedBox(
          height: 150,
          width: double.infinity,
          child: Center(child: CircularProgressIndicator())
      );
    }

    String url = "";
    if (_facePhoto.isNotEmpty && _facePhoto.elementAt(0).url.toString().isNotEmpty) {
      url = URL_HOME + _facePhoto.elementAt(0).url.toString();
    }

    //print("BuildHeader()url=$url");

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 15,
        ),
        // members photo
        CircleAvatar(
            radius: 60.0,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: simpleBlurImageWithName(_memberInfo.mb_name.toString(), 52, url, 1.0)
            ),
          ),

        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(icon: const Icon(Icons.camera, color: Colors.black, size: 16,),
              label: const Text("사진촬영", style: const TextStyle(color:Colors.black, fontSize: 16, fontWeight:FontWeight.normal)),
              onPressed: () async {
                fromCamera();
              },
            ),
            TextButton.icon(icon: const Icon(Icons.photo, color: const Color(0xffc2c2c2), size: 16),
              label: const Text("파일선택", style: TextStyle(color:Color(0xffc2c2c2), fontSize: 16, fontWeight:FontWeight.normal)),
              onPressed: () async {
                fromGallery();
              },
            ),

          ],
        ),
      ],
    );
  }

  Widget FieldInfo(String label, String value) {
    return Container(
      //padding: EdgeInsets.only(top:5, bottom: 5),
      child: Row(
        children: [
          Expanded(
              flex: 22,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10,18,10,18),
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
              flex: 78,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
              )),
        ],
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.0, color: Colors.grey.shade200),),
      ),
    );
  }

  Widget BuildUserInfo() {
    return Container(
      width: MediaQuery.of(context).size.width,
      //color: Colors.green,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "기본정보",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const Spacer(),
              TextButton.icon(icon: Image.asset("assets/icon/icon_write.png", width: 22, height: 22),
                label: const Text("정보수정", style: const TextStyle(color:const Color(0xffc2c2c2), fontSize: 16, fontWeight:FontWeight.bold)),
                onPressed: () async {
                  _modifyPerson(_loginInfo.users_id.toString());
                },
              ),
            ],
          ),
          Container(
            child: Column(
              children: [
                FieldInfo("이  름", _memberInfo.mb_name.toString()),
                FieldInfo("휴대폰", _memberInfo.mb_hp.toString()),
                FieldInfo("이메일", _memberInfo.mb_email.toString()),
                //FieldInfo("홈페이지", _memberInfo.mb_homepage.toString()),
              ],
            ),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.grey.shade200,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberInfo() {
    if (_memberExtras.isEmpty) {
      return Container();
    }

    List<FieldData> data = _memberInfo.getExtraList(_memberExtras);
    //print(data.toString());

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "회원정보",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const Spacer(),
              TextButton.icon(icon: Image.asset("assets/icon/icon_write.png", color:const Color(0xffc2c2c2), width: 26, height: 26),
                label: const Text("정보수정", style: const TextStyle(color:Color(0xffc2c2c2), fontSize: 16, fontWeight:FontWeight.bold)),
                onPressed: () async {
                  _modifyExtra();
                },
              ),

            ],
          ),
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
  
  Future <void> _loadMemberInfo() async {
    _bMemberInfo = false;
    Map<String, String> params;
    if(widget.isMember) {
      params = {"command": "OWNER", "users_id":_loginInfo.users_id.toString(), "moims_id": widget.moimsId};
    } else {
      params = {"command": "INFO", "target": "user", "id": _loginInfo.users_id.toString()};
    }

    //params: {"command": "OWNER", "users_id":"${users_id}", "moims_id": "${moim.id}"},
    await Remote.getMemberInfo(
        params: params,
        onResponse: (List<MemberInfo> list) {
          setState(() {
            _bMemberInfo = true;
            if(list.isNotEmpty) {
              _memberInfo = list.elementAt(0);
              _loadExtra();
              _loadUserFace(false);
              //_loadShop();
            }
          });
        });
  }

  Future <void> _loadUserFace(bool bUpdate) async {
    _bFacePhoto = false;
    await Remote.getFiles(
        params: {
          "command": "LIST",
          "photo_type": photo_tag_user,
          "photo_id": _loginInfo.users_id.toString()
        },
        onResponse: (List<Files> list) async {
          setState(() {
            _bFacePhoto = true;
            _facePhoto.clear();
            if(list.isNotEmpty) {
              _facePhoto = list;
              _facePhoto.elementAt(0).thum_url;
            }
          });
          if (bUpdate) {
            await Remote.reqMemberInfo(params: {
              "command": "UPDATE",
              "mb_no": _loginInfo.users_id.toString(),
              "mb_thumnail": "${_facePhoto.elementAt(0).thum_url}"
            }, onResponse: (bool result) async {
              await _fetchPerson();
              widget.onUpdate(true);
            });
          }
        });
  }

  Future <void> _loadExtra() async {
    await Remote.getMemberExtra(
        params: {"command": "LIST", "moims_id": "${_memberInfo.moims_id}"},
        onResponse: (List<MemberExtra> list) {
          setState(() {
            _memberExtras = list;
          });
        });
  }

  Future <void> fromCamera() async {
    var image =
        await ImagePicker.platform.pickImage(source: ImageSource.camera);

    if (image != null) {
      File pick = File(image.path);
      setState(() {
        _bFacePhotoWait = true;
      });

      // cropImage
      File? crop = await cropImage(pick);
      if (crop != null) {
        pick = crop;
        await _addUserPhoto(pick.path);
        _bFacePhotoWait = false;
        _loadUserFace(true);
      }
      else {
        setState(() {
          _bFacePhotoWait = false;
        });
        showToastMessage("취소 되었습니다.");
      }
    }
  }

  Future <void> fromGallery() async {
    File? pick = await pickupImage();
    if (pick != null) {
      String ext = getExtFromPath(pick.path);
      if (ext == "png" || ext == "jpg" || ext == "jpeg") {
        setState(() {
          _bFacePhotoWait = true;
        });
        File? crop = await cropImage(pick);
        if (crop != null) {
          pick = crop;
          await _addUserPhoto(pick.path);
          _bFacePhotoWait = false;
          _loadUserFace(true);
        }
        else {
          setState(() {
            _bFacePhotoWait = false;
          });
          showToastMessage("취소 되었습니다.");
        }
      }
      else {
        showToastMessage("사용할 수 없는 자료입니다.");
      }
    }
  }

  Future <void> _delUserPhoto() async {
    if (_facePhoto.isNotEmpty && _facePhoto.elementAt(0).id!.isNotEmpty) {
      String id = _facePhoto.elementAt(0).id.toString();
      await Remote.deleteFiles(
          params: {
            "command": "DELETE",
            "id": id,
          },
          onResponse: (bool result) {
            setState(() {
              _facePhoto = <Files>[];
            });
          });
    }
  }

  Future <bool> _addUserPhoto(String path) async {
    await _delUserPhoto();
    bool process = false;
    await Remote.addFiles(
        filePath: path,
        params: {
          "command": "ADD",
          "users_id": _loginInfo.users_id.toString(),
          "photo_type": photo_tag_user,
          "photo_id": _loginInfo.users_id.toString(),
        },
        onUpload: (int status, Files result) {
          process = (status==1) ? true : false;
        });
    return process;
  }

  Future <void> _modifyExtra() async {
    var result = await Navigator.push(
      context,
      Transition(
          child: MemberEditExtra(extras: _memberExtras, info: _memberInfo),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );

    if (result != null) {
      print("_modifyExtra():After =========>");
      List<FieldData> data = _memberInfo.getExtraList(_memberExtras);
      //print(_memberInfo.toString());
      Map<String, String> params = {};
      params.addAll({
        "command": "UPDATE",
        "id": "${_memberInfo.id}",
      });
      for (var element in data) {
        params.addAll(element.toValueMap());
      }

      print("_modifyExtra():params=${params.toString()}");

      await Remote.reqMembers(
          params: params,
          onResponse: (bool result) {});
      setState(() {});
    }
  }

  Future <void> _fetchPerson() async {
    await Remote.getPerson(
        params: {
          "command": "INFO",
          "mb_no": _loginInfo.users_id.toString(),
        },
        onResponse: (bool status, Person person) {
          if(status) {
            _loginInfo.users_id = person.mb_no;
            _loginInfo.person = person;
          }
        });
  }

  Future <void> _modifyPerson(String users_id) async {
    print("_modifyPerson():users_id=$users_id");
    String url = "${URL_HOME}bbs/member_confirm2.php?url=${URL_HOME}bbs/register_form2.php&mb_no="+users_id;
    if(url.isNotEmpty) {
      var result = await Navigator.push(context, Transition(
          child: WebExplorer(title: '정보수정', website: url),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
      );
      
      if(result != null && result==true) {
        _loadMemberInfo();
        await _fetchPerson();
        widget.onUpdate(true);
      }
    }
  }
}
