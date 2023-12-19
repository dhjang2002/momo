
import 'package:intl/intl.dart';

class DateForm{
  late String   timeString;
  late DateTime timeStamp;

  DateForm() {
    timeStamp  = DateTime.now();
    timeString = DateFormat('yyyy.MM.dd hh:mm:ss a').format(timeStamp);
  }

  DateForm parse(String stampString) {
    timeString = stampString;
    timeStamp = DateTime.parse(timeString.trim());
    return this;
  }

  String getStamp() {
    return timeString;
  }

  String getWeek() {
    String value = DateFormat('EE').format(timeStamp);
    switch(value) {
      case 'Mon': return "월";
      case 'Tue': return "화";
      case 'Wed': return "수";
      case 'Thu': return "목";
      case 'Fri': return "금";
      case 'Sat': return "토";
      case 'Sun': return "일";
    }
    return "?";
  }

  String getMonth() {
    return DateFormat('M').format(timeStamp);
  }

  String getDate() {
    return DateFormat('yyyy.MM.dd').format(timeStamp);
  }

  String getTime() {
    return DateFormat('HH:mm a').format(timeStamp);
  }

  String getVisitDay() {
    return "${getDate()} (${getWeek()}) ${getTime()}";
  }

  int passInHour() {
      //DateTime today = DateTime.now();
      return DateTime.now().difference(timeStamp).inHours;
  }

  String chatStamp() {

    DateTime today = DateTime.now();
    DateTime yesterday = today.subtract(Duration(days:1));
    Duration diff  = today.difference(timeStamp);
    if(diff.inDays<2) {
      if (today.day == timeStamp.day) {
        return DateFormat('오늘\nHH:mm a').format(timeStamp);
      }
      if (yesterday.day == timeStamp.day) {
        return "어제\n" + DateFormat('HH:mm a').format(timeStamp);
      }
    }

    return DateFormat('yyyy.MM.dd').format(timeStamp)+"\n"+DateFormat('HH:mm a').format(timeStamp);
  }
}