// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'Model.dart';

class Person extends Model {
  String? mb_no;        // 사용자 번호:  '2'
  String? mb_level;     // 사용자 레벨:  '2:일반사용자, 10:관리자'
  String? mb_id;        // 사용자 아이디 : 'dhjang2002'
  String? mb_password;  // 비밀번호
  String? mb_name;      // 사용자 이름 : '홍길동'
  String? mb_email;     // 사용자 email: 'dhjang2002@gmail.com'
  String? mb_hp;        // 사용자 휴대폰 : '010-2001-0937'
  String? mb_addr1;     // 사용자 주소: '대전 유성구 대덕대로 530'
  String? mb_addr2;     // 사용자 상세주소: '마 221'
  String? mb_thumnail;
  String? mb_datetime;  // 생성일자: '2021-10-20 03:17:32'

  Person({
    this.mb_no = "",
    this.mb_level="",
    this.mb_id = "",
    this.mb_password = "",
    this.mb_name = "",
    this.mb_email = "",
    this.mb_hp = "",
    this.mb_addr1 = "",
    this.mb_addr2 = "",
    this.mb_thumnail = "",
    this.mb_datetime=""
  });

  @override
  void clear() {
    mb_no = "";
    mb_level = "2";
    mb_id = "";
    mb_password = "";
    mb_name = "";
    mb_email = "";
    mb_hp = "";
    mb_addr1 = "";
    mb_addr2 = "";
    mb_thumnail = "";
    mb_datetime = "";
  }
  factory Person.fromJson(Map<String, dynamic> parsedJson)
  {
      return Person(
          mb_no: parsedJson['mb_no'],
          mb_level: parsedJson['mb_level'],
          mb_id: parsedJson ['mb_id'],
          mb_password: parsedJson ['mb_password'],
          mb_name: parsedJson ['mb_name'],
          mb_email: parsedJson ['mb_email'],
          mb_hp: parsedJson ['mb_hp'],
          mb_addr1: parsedJson ['mb_addr1'],
          mb_addr2: parsedJson ['mb_addr2'],
          mb_thumnail: parsedJson ['mb_thumnail'],
          mb_datetime: parsedJson ['mb_datetime']
      );
    }

  static List<Person> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return Person.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'Person{mb_no:$mb_no, '
        'mb_level:$mb_level, '
        'mb_id:$mb_id, '
        'mb_password:$mb_password, '
        'mb_name:$mb_name, '
        'mb_email:$mb_email,'
        'mb_hp:$mb_hp, '
        'mb_addr1:$mb_addr1, '
        'mb_addr2:$mb_addr2, '
        'mb_thumnail:$mb_thumnail, '
        'mb_datetime:$mb_datetime}';
  }

  @override
  Map<String, String> toMap() => {
    'mb_no': mb_no.toString(),
    'mb_level': mb_level.toString(),
    'mb_id': mb_id.toString(),
    'mb_password': mb_password.toString(),
    'mb_name': mb_name.toString(),
    'mb_email': mb_email.toString(),
    'mb_hp': mb_hp.toString(),
    'mb_addr1': mb_addr1.toString(),
    'mb_addr2': mb_addr2.toString(),
    'mb_thumnail': mb_thumnail.toString(),
    'mb_datetime': mb_datetime.toString()
  };

  @override
  String getFilename(){
    return "person.dat";
  }

}