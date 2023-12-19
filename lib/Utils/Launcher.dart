import 'package:dio/dio.dart';
import 'package:momo/Utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

Future <void> callPhone(String phoneNumber) async {
  // Use `Uri` to ensure that `phoneNumber` is properly URL-encoded.
  // Just using 'tel:$phoneNumber' would create invalid URLs in some cases,
  // such as spaces in the input, which would cause `launch` to fail on some
  // platforms.
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  await launch(launchUri.toString());
}

Future <void> callSms(String phoneNumber) async {
  // Use `Uri` to ensure that `phoneNumber` is properly URL-encoded.
  // Just using 'tel:$phoneNumber' would create invalid URLs in some cases,
  // such as spaces in the input, which would cause `launch` to fail on some
  // platforms.
  final Uri launchUri = Uri(
    scheme: 'sms',
    path: phoneNumber,
  );
  await launch(launchUri.toString());
}

Future <void> showUrl(String url) async {
  await launch("http://"+url, forceWebView: false, forceSafariVC: false);
}


Future <void> callKakaoNavi(String title, String lat, String lon) async {
  title = title.replaceAll(",", ".");
  String launchUriString = "https://map.kakao.com/link/to/$title,$lat,$lon";

  print("callNavi:url=$launchUriString");

  await launch(launchUriString, forceWebView: false, forceSafariVC: false);
}

String removeWildChar(String value) {
  if(value.isNotEmpty) {
    value = value.replaceAll(",", " ");
    value = value.replaceAll("/", "");
    value = value.replaceAll(":", "");
    value = value.replaceAll("?", "");
    value = value.replaceAll("'", "");
    value = value.replaceAll("&", "");
  }
  return value;
}

Future <void> callNaviSelect(String target, String title, String lat, String lon) async {
  title = removeWildChar(title);
  String mesg = "";
  String launchUriString = "";
  switch(target) {
    case "tmap":
      mesg = "TMAP을 실행할 수 없습니다. 설치후 사용해주세요.";
      launchUriString = Uri.parse("tmap://route?goalx=$lon&goaly=$lat&goalname=$title").toString();
      break;

    case "kakao":
      mesg = "카카오내비를 실행할 수 없습니다. 설치후 사용해주세요.";
      launchUriString = "https://map.kakao.com/link/to/$title,$lat,$lon";
      break;

    default:
      mesg = "카카오내비를 실행할 수 없습니다. 설치후 사용해주세요.";
      launchUriString = "https://map.kakao.com/link/to/$title,$lat,$lon";
      break;
  }

  bool result = await launch(launchUriString, forceWebView: false, forceSafariVC: false);
  if(!result) {
     showToastMessage(mesg);
  }
}

Future <void> shareInfo({required String subject, required String text, required List<String> imagePaths}) async {
  if (imagePaths.isNotEmpty) {
    await Share.shareFiles(imagePaths, text: text, subject: subject);
  }
  else {
    await Share.share(text, subject: subject,);
  }
}

Future <String> downloadFile(String srcUrl, String fileName) async {
  String savePath = "";
  try {
    Dio dio = Dio();
    savePath = await getFilePath(fileName);
    //print("downloadFile():savePath=$savePath");
    await dio.download(srcUrl, savePath);
    return savePath;
  } catch (e) {
    print(e.toString());
  }
  return savePath;
}