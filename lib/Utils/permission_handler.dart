
import 'package:geolocator/geolocator.dart';

class PermissionHandler {
  static String gps_error = "";

  static Future <bool> checkLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      gps_error = 'GPS를 사용할 수 없습니다. 폰에서 기능을 활성화 하십시오.';
      //print(gps_error);
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        gps_error = 'GPS 사용 권한이 없습니다.';
        print(gps_error);
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      gps_error =
      'GPS 사용 권한이 거부된 상태입니다. 앱 설정에서 권한을 부여하십시오.';
      print(gps_error);
      return false;
    }

    gps_error = "";
    return true;
  }
}