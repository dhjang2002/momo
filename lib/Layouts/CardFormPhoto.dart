// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print, invalid_use_of_visible_for_testing_member

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:momo/Models/Files.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/utils.dart';
import 'CardFormTitle.dart';


class CardFormPhoto extends StatefulWidget {
  const CardFormPhoto({Key? key,
    required this.title,
    required this.subTitle,
    required this.photo_type, // user(U), shop(S), item(I), 광고(P), 모임(M)
    required this.photo_id,   // owner id
    required this.users_id,   // users id
    required this.onChanged,

  }) : super(key: key);

  final List<String> title;
  final String subTitle;
  final String photo_type;
  final String photo_id;
  final String users_id;
  //final String files_id;

  final Function(String tag, String value, String attached) onChanged;

  @override
  _CardFormPhotoState createState() => _CardFormPhotoState();
}

class _CardFormPhotoState extends State<CardFormPhoto> {
  bool m_bProgress = false;
  late Files m_file;
  String fname = "";
  
  @override
  void initState() {
    super.initState();
    setState(() {
      m_file = Files();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color:Colors.black.withOpacity(0.3),
              blurRadius: 1,
              spreadRadius: 1
            )
          ]
      ),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardFormTitle(titles: widget.title, subTitle:widget.subTitle,
            titleColor:Colors.black, subColor: Colors.black54,),
          const SizedBox(height:10),
          AttachCard(),
        ]
      ),
    );
  }

  Widget AttachCard(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Divider( height: 20, thickness: 2, color: Colors.grey[300]),
      Container(
          padding: const EdgeInsets.fromLTRB(10,10,10,3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("* 상황을 설명할 수 있는 사진 또는 파일을 첨부해주세요."),
              Row(
                children: [
                  (m_bProgress) ? const Center(child: CircularProgressIndicator(),) : Container(),
                  const Spacer(),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: const Color(0xffc2c2c2),),
                    child: const Text('사진촬영', style:const TextStyle(fontSize: 15)),
                    onPressed: () async {
                        fromCamera();
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: const Color(0xffc2c2c2),),
                    child: const Text('파일선택', style:const TextStyle(fontSize: 15,)),
                    onPressed: () async {
                        fromFile();
                    },
                  )
                ],
              ),
              Container(
                width: 1200,
                padding: const EdgeInsets.all(10),
                color: Colors.brown[50],
                child: Text(fname,
                  style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),)
              ),
            ],
          )
      )
      ],
    );
  }

  Future <void> fromCamera() async {
    var image = await ImagePicker.platform.pickImage(
        source: ImageSource.camera);

    if(image !=null) {
      setState(() {
        m_bProgress = true;
      });

      await Remote.addFiles(filePath: image.path,
      params: {
      "command": "ADD",
      "users_id": widget.users_id.toString(),
      "photo_type": widget.photo_type,
      "photo_id": widget.photo_id,
      },
          onUpload: (int status, Files result) {
        setState(() {
          m_bProgress = false;
          if(status==1) {
            m_file = result;
            fname = m_file.name!;
            print("fromFile():m_file="+m_file.toString());
          }
        });
      });
    }
  }
  
  Future <void> fromFile() async {
    File? pick = await pickupImage();
    if (pick != null) {
      String ext = getExtFromPath(pick.path);
      if(ext=="png" || ext=="jpg" || ext == "jpeg") {
        setState(() {
          m_bProgress = true;
        });
        await Remote.addFiles(filePath: pick.path,
            params: {
              "command": "ADD",
              "users_id": widget.users_id.toString(),
              "photo_type": widget.photo_type,
              "photo_id": widget.photo_id,
            },
            onUpload: (int status, Files result) {
              setState(() {
                m_bProgress = false;
                if(status==1) {
                  m_file = result;
                  fname = m_file.name!;
                  print("fromFile():m_file="+m_file.toString());
                }
              });
        });
      }
    }
  }
}
