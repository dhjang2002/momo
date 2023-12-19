// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Models/Files.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/utils.dart';
import 'CardFormTitle.dart';

class CardPhotoEdit extends StatefulWidget {
  final int max_count;
  final String photo_type;
  final String photo_id;
  final String users_id;
  final String message;
  List<String>? title;
  final Function(int count, String thumnails) onChanged;

  CardPhotoEdit(
      {Key? key,
      required this.max_count,
      required this.photo_type,
      required this.photo_id,
      required this.users_id,
      required this.message,
      this.title,
      required this.onChanged})
      : super(key: key);

  @override
  _CardPhotoEditState createState() => _CardPhotoEditState();
}

class _CardPhotoEditState extends State<CardPhotoEdit> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool bReady = false;
  bool bLoaded = false;
  bool bWait = false;
  List<Files> _fileList = <Files>[];
  @override
  void initState() {
    super.initState();
    setState(() {
      bReady = true;
    });
    _reload(widget.photo_id, false);
  }

  @override
  Widget build(BuildContext context) {

    if(!bReady) {
      return const Center(child: CircularProgressIndicator(),);
    }

    return Container(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            (widget.title != null)
                ? CardFormTitle(
                    titles: widget.title!,
                    subTitle: "",
                    titleColor: Colors.black,
                    subColor: Colors.black54,
                  )
                : Container(),
            (widget.title != null) ? const SizedBox(height: 10) : Container(),
            Stack(
              children: [
                Positioned(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.message),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                //(m_bProgress) ? Center(child: CircularProgressIndicator(),) : Container(),
                                const Spacer(),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Color(0xffc2c2c2),
                                  ),
                                  child: const Text(
                                    '사진촬영',
                                    style: const TextStyle( fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () async {
                                    if (_fileList.length <
                                        widget.max_count) {
                                      fromCamera();
                                    } else {
                                      showToastMessage(
                                          "${widget.max_count}장 까지 가능합니다.");
                                    }
                                  },
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Color(0xffc2c2c2),
                                  ),
                                  child: const Text(
                                    '파일선택',
                                    style: TextStyle( fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () async {
                                    if (_fileList.length <
                                        widget.max_count) {
                                      fromGallery();
                                    } else {
                                      showToastMessage(
                                          "${widget.max_count}장 까지 가능합니다.");
                                    }
                                  },
                                )
                              ],
                            ),
                            Divider(
                                height: 3,
                                thickness: 2,
                                color: Colors.grey[300]),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              //height: view_height,
                              child: GridView.count(
                                physics: const ClampingScrollPhysics(),
                                primary: false,
                                shrinkWrap: true,
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                crossAxisSpacing: (widget.max_count > 1) ? 20 : 0.0,
                                mainAxisSpacing: (widget.max_count > 1) ? 20 : 0.0,
                                childAspectRatio: 1.0,
                                crossAxisCount: (widget.max_count > 1) ? 2 : 1,
                                children: List.generate(_fileList.length, (index) {
                                  return Container(
                                    //color: Colors.grey,
                                    child: BuildItem(index),
                                  );
                                }),
                              ),
                            ),
                          ],
                        )),
                  ],
                )),
                Visibility(
                    visible: (!bLoaded | bWait),
                    child: const Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator()))
              ],
            )
          ],
        ));
  }

  Widget BuildItem(int index) {
    String url;
      url = URL_IMAGE + _fileList[index].url.toString();

    Files item = _fileList.elementAt(index);
    return Stack(
      children: [
        Positioned(
          child: SizedBox(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: simpleBlurImage(url, 1.0),
              )
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: SizedBox(
              width: 32,
              height: 32,
              child: RawMaterialButton(
                elevation: 2.0,
                fillColor: Colors.white,
                child: const Icon(
                  Icons.close,
                  size: 18.0,
                  color: Colors.redAccent,
                ),
                shape: const CircleBorder(),
                onPressed: () {
                  _delete(item);
                },
              )),
        ),
      ],
    );
  }

  Future<void> _reload(String photo_id, bool bAct) async {
    setState(() {
      bLoaded = false;
    });

    await Remote.getFiles(
        params: {
          "command": "LIST",
          "photo_type": widget.photo_type,
          "photo_id": photo_id
        },
        onResponse: (List<Files> list) {
          setState(() {
            bLoaded = true;
            _fileList = list;
            String thumnails = "";
            for (var element in _fileList) {
              if (thumnails.isNotEmpty) {
                thumnails += ";";
              }
              thumnails += element.thum_url!;
            }
            if (bAct) {
              widget.onChanged(_fileList.length, thumnails);
            }
          });
        });
  }

  Future<void> _delete(Files info) async {
    await Remote.deleteFiles(
        params: {"command": "DELETE", "id": "${info.id}"},
        onResponse: (bool result) {
          if (result) {
            _reload(widget.photo_id, true);
          }
        });
  }

  Future<void> _add(String path) async {
  
      await Remote.addFiles(
          filePath: path,
          params: {
            "command": "ADD",
            "users_id": widget.users_id.toString(),
            "photo_type": widget.photo_type,
            "photo_id": widget.photo_id,
          },
          onUpload: (int status, Files result) {
            if (status == 1) {
              _reload(widget.photo_id, true);
            }
          });

    setState(() {
      bWait = false;
    });
  }

  Future <void> fromCamera() async {
    var image =
        await ImagePicker.platform.pickImage(source: ImageSource.camera);

    if (image != null) {
      File pick = File(image.path);
      setState(() {
        bWait = true;
      });

      File? crop = await cropImage(pick);
      if (crop != null) {
        pick = crop;
        _add(pick.path);
      }
      else {
        setState(() {
          bWait = false;
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
          bWait = true;
        });

        // cropImage
        File? crop = await cropImage(pick);
        if (crop != null) {
          pick = crop;
          _add(pick.path);
        }
        else {
          setState(() {
            bWait = false;
          });
          showToastMessage("취소 되었습니다.");
          return;
        }
      }
    } else {
      showToastMessage("사용할 수 없는 자료입니다.");
    }
  }
}
