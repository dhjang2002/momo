// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:momo/Models/Files.dart';
import 'package:momo/Models/contactItem.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/photo_viewer.dart';
import 'package:octo_image/octo_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:transition/transition.dart';

String getAreaFromAddress(String addr1) {
  String area = "";

  if(addr1.isEmpty) {
    return area;
  }

  List<String> token = addr1.split(" ");

  if(token.length<2) {
    return area;
  }

  if(token[0]=="세종특별자치시") {
    return "세종시";
  }

  if(token[0]=="제주특별자치도") {
    return token[1];
  }

  if(token[0]=="경남" && token[1]=="창원시") {
    return token[1] + " " + token[2];
  }

  if(token[0]=="충남" && token[1]=="천안시") {
    return token[1] + " " + token[2];
  }

  return token[0]+" "+token[1];
}

Future <void> showPhotoUrl({
  required BuildContext context,
  required String type,
  required String id,
  required String title,
}) async {
  await Remote.getFiles(
      params: {"command": "LIST", "photo_type": type, "photo_id": id},
      onResponse: (List<Files> info) {
        if (info.isNotEmpty) {
          String url = URL_HOME + info.elementAt(0).url.toString();
          Navigator.push(
            context,
            Transition(
                child: PhotoViewer(
                  title: title,
                  url: url,
                ),
                transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
          );
        }
      });
}

void showPhoto(
    {required BuildContext context,
    required String title,
    required String url}) {
  Navigator.push(
    context,
    Transition(
        child: PhotoViewer(
          title: title,
          url: url,
        ),
        transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
  );
}

Future <Position> getGeolocator() async {
  var currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low);

  var lastPosition =
      await Geolocator.getLastKnownPosition(forceAndroidLocationManager: true);

  print(currentPosition);
  print(lastPosition);
  return currentPosition;
}

Widget customImage(String url, double size) {
  return SizedBox(
    height: size,
    child: OctoImage(
      image: NetworkImage(url),
      progressIndicatorBuilder: (context, progress) {
        double? value;
        var expectedBytes = progress?.expectedTotalBytes;
        if (progress != null && expectedBytes != null) {
          value = progress.cumulativeBytesLoaded / expectedBytes;
        }
        return CircularProgressIndicator(value: value);
      },
      errorBuilder: (context, error, stacktrace) => const Icon(Icons.error),
    ),
  );
}
Widget circleAvatar(String url, double size) {
  return SizedBox(
    child: OctoImage.fromSet(
      fit: BoxFit.fill,
      image: NetworkImage(
        url,
      ),
      octoSet: OctoSet.circleAvatar(
        backgroundColor: Colors.black,
        text: const Text(""),
      ),
    ),
    height: size,
  );
}
Widget simpleBlurImage(String url, double aspectRatio) {
  return AspectRatio(
      aspectRatio: aspectRatio, //269 / 173,
      child: (url.isNotEmpty)
          ? OctoImage(
              image: NetworkImage(url),
              placeholderBuilder: OctoPlaceholder.blurHash(
                'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
              ),
              errorBuilder: (context, error, stacktrace) => Image.asset(
                  "assets/icon/icon_empty_person.png",
                  fit: BoxFit.fill),
              fit: BoxFit.cover,
            )
          : Image.asset("assets/icon/icon_empty_person.png", fit: BoxFit.fill
      )
  );
}

Widget simpleBlurImageWithName(String value, double fontSize, String url, double aspectRatio) {
  String tag = "";
  if(value.isNotEmpty) {
    tag = value.substring(0, 1);
  }
  return AspectRatio(
      aspectRatio: aspectRatio, //269 / 173,
      child: (url.isNotEmpty)
          ? OctoImage(
        image: NetworkImage(url),
        placeholderBuilder: OctoPlaceholder.blurHash(
          'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
        ),
        errorBuilder: (context, error, stacktrace) => Image.asset(
            "assets/icon/icon_empty_person.png",
            fit: BoxFit.fill),
        fit: BoxFit.cover,
      )
          : Container(
        color: const Color(0xffcbc9d9),//grey[300],
        child: Center(
          child: Text(tag,
            style: TextStyle(color:Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
        ),
      ));
}

void showSnackbar(BuildContext context, String message) {
  var snack = SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 2),
  );
  ScaffoldMessenger.of(context).showSnackBar(snack);
}

void showToastMessage(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

String currencyFormat(String digit) {
  if (digit.isNotEmpty) {
    int price = int.parse(digit);
    final formatCurrency = NumberFormat.simpleCurrency(
        locale: "ko_KR", name: "", decimalDigits: 0);
    return formatCurrency.format(price);
  }
  return "0";
}

Future <File?> pickupImage() async {
  var pickedImage =
      await ImagePicker.platform.pickImage(source: ImageSource.gallery);
  File? imageFile = pickedImage != null ? File(pickedImage.path) : null;
  return imageFile;
}

Future <File?> takeImage() async {
  var pickedImage =
      await ImagePicker.platform.pickImage(source: ImageSource.camera);
  File? imageFile = pickedImage != null ? File(pickedImage.path) : null;
  return imageFile;
}





Future <File?> cropImage(File imageFile) async {
  ImageCropper imageCropper = ImageCropper();
  var croppedFile = await imageCropper.cropImage(
      sourcePath: imageFile.path,
      maxWidth: 512,
      maxHeight: 512,
      aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      aspectRatioPresets: Platform.isAndroid
          ? [
        CropAspectRatioPreset.square,
        //CropAspectRatioPreset.ratio3x2,
        //CropAspectRatioPreset.original,
        //CropAspectRatioPreset.ratio4x3,
        //CropAspectRatioPreset.ratio16x9
      ]
          : [
        //CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
        //CropAspectRatioPreset.ratio3x2,
        //CropAspectRatioPreset.ratio4x3,
        //CropAspectRatioPreset.ratio5x3,
        //CropAspectRatioPreset.ratio5x4,
        //CropAspectRatioPreset.ratio7x5,
        //CropAspectRatioPreset.ratio16x9
      ],
      compressQuality: 75,
      uiSettings:
      [
        AndroidUiSettings(
            toolbarTitle: '이미지 자르기',
            toolbarColor: Colors.white,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            //lockAspectRatio: true,
            hideBottomControls: true
        ),
        IOSUiSettings(
          title: '이미지 자르기',
          doneButtonTitle: "자르기",
          cancelButtonTitle: "취소",
          //aspectRatioPickerButtonHidden:true,
          //hidesNavigationBar:true,
          //showActivitySheetOnDone:false,
          //showCancelConfirmationDialog:false,
          //rotateClockwiseButtonHidden:false,
          hidesNavigationBar:true,
          rotateButtonsHidden:true,
          resetButtonHidden:false,
          aspectRatioPickerButtonHidden:true,
          resetAspectRatioEnabled:false,
          aspectRatioLockDimensionSwapEnabled:true,
          aspectRatioLockEnabled:true,
        )
      ]
  );

  return File(croppedFile!.path);
}

Future <String> getFilePath(uniqueFileName) async {
  String path = '';
  Directory dir = await getApplicationDocumentsDirectory();
  path = '${dir.path}/$uniqueFileName';
  return path;
}

String getNameFromPath(String path) {
  if (path.length > 3) {
    File file = File(path);
    return file.path.split('/').last.toLowerCase();
  }
  return "";
}

String getExtFromPath(String path) {
  if (path.length > 3) {
    File file = File(path);
    return file.path.split('.').last.toLowerCase();
  }
  return "";
}

String getDayCount(String dateString) {
  if (dateString.length >= 10) {
    if (dateString.indexOf(".") > 0) {
      dateString = dateString.replaceAll(".", "-");
    }
    DateTime birthday = DateFormat('yyyy-MM-dd').parse(dateString);
    DateTime today = DateTime.now();
    var diff = (today.difference(birthday).inDays) + 1;
    return "만난지 $diff일 ";
  }
  return "";
}

void showDialogPop({
  required BuildContext context,
  required String title,
  required Text body,
  required Text content,
  required int choiceCount,
  String? yesText = "확인",
  String? cancelText = "취소",
  required Function(bool isOK) onResult}) {
  showDialog(
    context: context,
    barrierDismissible: false, //다이얼로그 바깥을 터치 시에 닫히도록 하는지 여부 (true: 닫힘, false: 닫히지않음)
    builder: (BuildContext context) {
      return WillPopScope(
          onWillPop: () async => false,
      child: AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.normal, fontSize: 20),
        ),
        content: SingleChildScrollView(
          //내용 정의
          child: ListBody(
            children: <Widget>[
              body,
              const SizedBox(height: 5),
              content,
            ],
          ),
        ),
        actions: <Widget>[
          //버튼 정의
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onResult(true); // 현재 화면을 종료하고 이전 화면으로 돌아가기
            },
            child: Text(
              yesText!,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          Visibility(
            visible: (choiceCount > 1) ? true : false,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 현재 화면을 종료하고 이전 화면으로 돌아가기
                onResult(false);
              },
              child: Text(
                cancelText!,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ),
        ],
      )
      );
    },
  );
}

void showDialogMenu({
  required BuildContext context,
  required List<String> items,
  required Function(int index, String value) onResult}) {
  showDialog(
    context: context,
    barrierDismissible: false, //다이얼로그 바깥을 터치 시에 닫히도록 하는지 여부 (true: 닫힘, false: 닫히지않음)
    builder: (BuildContext context) {
      return AlertDialog(
        content: SizedBox(
            height: 180,
            width: double.maxFinite,
            child: ListView.builder(
            //shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index)
            {
              return ListTile(
                title: Column(
                  children: [
                    Center(child: Text(items[index],
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18))),
                    SizedBox(height: 15),
                    Divider(height: 1)
                  ],
                ),

                onTap: () {
                  Navigator.of(context).pop();
                  onResult(index, items[index]);
                },

              );
            }
        )),
      );
    },
  );
}

void showPopupMessage(BuildContext context, Text message) async {
  double height = (MediaQuery.of(context).size.height / 3 > 150)
      ? MediaQuery.of(context).size.height / 3
      : 150;
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    elevation: 10,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    builder: (BuildContext context) {
      return SizedBox(
        height: height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              message,
            ],
          ),
        ),
      );
    },
  );
}

// void editContactItemDialog({
//   required BuildContext context,
//   required bool isAddr,
//   required String item,
//   required List<String> kindList,
//   required Function(String kind, String value, String value_ext) onResult}) {
//
//   String kind = "직장";
//   String value = "042-863-0977";
//   String value_ext = "";
//   String _selectValue = "회사";
//   TextEditingController v1Controller = TextEditingController();
//   TextEditingController v2Controller = TextEditingController();
//   // List<DropdownMenuItem<String>> menuItems = [
//   //   DropdownMenuItem(child: Text("자택"),value: "자택"),
//   //   DropdownMenuItem(child: Text("회사"),value: "회사"),
//   //   DropdownMenuItem(child: Text("사무실"),value: "사무실"),
//   //   DropdownMenuItem(child: Text("기타"),value: "기타"),
//   // ];
//   showDialog(
//     context: context,
//     barrierDismissible: false, //다이얼로그 바깥을 터치 시에 닫히도록 하는지 여부 (true: 닫힘, false: 닫히지않음)
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text(item),
//         content: Container(
//             height: 240,
//             width: double.maxFinite,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   width: double.maxFinite,
//                   alignment: Alignment.centerRight,
//                   child: DropdownButton(
//                     style: TextStyle(color: Colors.blueAccent,fontSize: 18, fontWeight: FontWeight.bold),
//                     //dropdownColor:Colors.green,
//                     value: _selectValue,
//                     items: kindList.map((value) {
//                       return DropdownMenuItem(child: Text(value), value: value);
//                   }).toList(),
//                     onChanged: (Object? value) {
//                       _selectValue = value.toString();
//                     },
//                   ),
//                 ),
//                 Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.only(top: 5),
//                   child: TextField(
//                     controller: v1Controller,
//                     maxLines: 1,
//                     keyboardType: TextInputType.text,
//                     textInputAction: TextInputAction.next,
//                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
//                     decoration: InputDecoration(
//                       filled: true,
//                       fillColor: Colors.white,
//                       contentPadding: const EdgeInsets.fromLTRB(20,15,20,15),
//                       isDense: true,
//                       hintText: item,
//                       hintStyle: const TextStyle(color: Color(0xffcbc9d9)),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius:
//                         const BorderRadius.all(const Radius.circular(10)),
//                         borderSide: BorderSide(width: 1, color: Colors.grey.shade200),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: const BorderRadius.all(Radius.circular(10)),
//                         borderSide: BorderSide(width: 1, color: Colors.grey.shade200),
//                       ),
//                       border: const OutlineInputBorder(
//                         borderRadius:
//                         const BorderRadius.all(const Radius.circular(10)),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Visibility(
//                   visible: isAddr,
//                   child: Container(
//                     width: double.infinity,
//                     padding: EdgeInsets.only(top: 10),
//                     child: TextField(
//                       controller: v2Controller,
//                       maxLines: 1,
//                       keyboardType: TextInputType.text,
//                       textInputAction: TextInputAction.next,
//                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Colors.white,
//                         contentPadding: const EdgeInsets.fromLTRB(20,15,20,15),
//                         isDense: true,
//                         hintText: "상세주소",
//                         hintStyle: const TextStyle(color: Color(0xffcbc9d9)),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius:
//                           const BorderRadius.all(const Radius.circular(10)),
//                           borderSide: BorderSide(width: 1, color: Colors.grey.shade200),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: const BorderRadius.all(Radius.circular(10)),
//                           borderSide: BorderSide(width: 1, color: Colors.grey.shade200),
//                         ),
//                         border: const OutlineInputBorder(
//                           borderRadius:
//                           const BorderRadius.all(const Radius.circular(10)),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 //SizedBox(height: 20,),
//               ],
//             )),
//         actions: <Widget>[
//           TextButton(
//             child: Text('취소'),
//             style: TextButton.styleFrom(primary: Colors.redAccent, backgroundColor:Colors.white),
//             onPressed: () {
//                 Navigator.pop(context);
//             },
//           ),
//           TextButton(
//             child: Text('확인'),
//             style: TextButton.styleFrom(primary: Colors.green, backgroundColor:Colors.white),
//             onPressed: () {
//                 Navigator.pop(context);
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
