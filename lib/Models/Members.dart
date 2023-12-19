// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:momo/Models/FieldData.dart';
import 'package:momo/Models/MemberExtra.dart';
import 'Model.dart';

class Members extends Model {
  String? id;                    // 레코드번호
  String? mb_no;                 // 사용자 id: g5_member
  String? moims_id;              // 모임 id
  String? member_nickname;       // 별명
  String? member_notify;         // 푸시알림(Y/N)
  String? member_approve;        // 멤버승인(Y/N)
  String? member_area;           // 지역:대전, 서울, 충남 ...
  String? member_grade;          // 등급(일반, 관리자)
  String? member_duty;           // 직급(30회원 , 총무, 간사, 01부회장, 00회장)
  String? member_message;        // 상태메시지: 오늘 기분 만땅임!)
  String? mb_distance;
  String? member_field_01;       // 확장필드
  String? member_field_02;       // 확장필드
  String? member_field_03;       // 확장필드
  String? member_field_04;       // 확장필드
  String? member_field_05;       // 확장필드
  String? member_field_06;       // 확장필드
  String? member_field_07;       // 확장필드
  String? member_field_08;       // 확장필드
  String? member_field_09;       // 확장필드
  String? member_field_10;       // 확장필드
  String? member_field_11;       // 확장필드
  String? member_field_12;       // 확장필드
  String? member_field_13;       // 확장필드
  String? member_field_14;       // 확장필드
  String? member_field_15;       // 확장필드
  String? member_data_ready;     // 데이터준비(Y/N)
  String? created_at;            // 생성시각
  String? updated_at;            // 변경시각

  Members({this.id="",
    this.mb_no="",
    this.moims_id="",
    this.member_nickname = "",
    this.member_notify="Y",
    this.member_approve="N",
    this.member_area="",
    this.member_grade = "일반",
    this.member_duty  = "30회원",
    this.member_message="오늘은 좋은날!",
    this.mb_distance = "",
    this.member_field_01="",
    this.member_field_02="",
    this.member_field_03="",
    this.member_field_04="",
    this.member_field_05="",
    this.member_field_06="",
    this.member_field_07="",
    this.member_field_08="",
    this.member_field_09="",
    this.member_field_10="",
    this.member_field_11="",
    this.member_field_12="",
    this.member_field_13="",
    this.member_field_14="",
    this.member_field_15="",
    this.member_data_ready="N",
    this.created_at="",this.updated_at="",
  });

  factory Members.fromJson(Map<String, dynamic> parsedJson)
  {
      return Members(
        id: parsedJson['id'],
          mb_no: parsedJson['mb_no'],
          mb_distance: parsedJson ['mb_distance'],
          moims_id: parsedJson ['moims_id'],
          member_nickname:parsedJson ['member_nickname'],
          member_notify: parsedJson ['member_notify'],
          member_approve: parsedJson ['member_approve'],
          member_area: parsedJson ['member_area'],
          member_grade: parsedJson ['member_grade'],
          member_duty: parsedJson ['member_duty'],
          member_message: parsedJson ['member_message'],
          member_field_01: parsedJson ['member_field_01'],
          member_field_02: parsedJson ['member_field_02'],
          member_field_03: parsedJson ['member_field_03'],
          member_field_04: parsedJson ['member_field_04'],
          member_field_05: parsedJson ['member_field_05'],
          member_field_06: parsedJson ['member_field_06'],
          member_field_07: parsedJson ['member_field_07'],
          member_field_08: parsedJson ['member_field_08'],
          member_field_09: parsedJson ['member_field_09'],
          member_field_10: parsedJson ['member_field_10'],
          member_field_11: parsedJson ['member_field_11'],
          member_field_12: parsedJson ['member_field_12'],
          member_field_13: parsedJson ['member_field_13'],
          member_field_14: parsedJson ['member_field_14'],
          member_field_15: parsedJson ['member_field_15'],
          member_data_ready: parsedJson ['member_data_ready'],
          created_at: parsedJson ['created_at'],
          updated_at: parsedJson ['updated_at']
      );
    }

  static List<Members> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return Members.fromJson(data);
    }).toList();
  }

  String getFieldValue(String filed){
    switch(filed){
      case "member_field_01":
        return member_field_01.toString();
      case "member_field_02":
        return member_field_02.toString();
      case "member_field_03":
        return member_field_03.toString();
      case "member_field_04":
        return member_field_04.toString();
      case "member_field_05":
        return member_field_05.toString();
      case "member_field_06":
        return member_field_06.toString();
      case "member_field_07":
        return member_field_07.toString();
      case "member_field_08":
        return member_field_08.toString();
      case "member_field_09":
        return member_field_09.toString();
      case "member_field_10":
        return member_field_10.toString();
      case "member_field_11":
        return member_field_11.toString();
      case "member_field_12":
        return member_field_12.toString();
      case "member_field_13":
        return member_field_13.toString();
      case "member_field_14":
        return member_field_14.toString();
      case "member_field_15":
        return member_field_15.toString();
    }
    return "";
  }
  void setFieldValue(String filed, String value){
    switch(filed){
      case "member_field_01":
        member_field_01 = value; break;
      case "member_field_02":
        member_field_02 = value; break;
      case "member_field_03":
        member_field_03 = value; break;
      case "member_field_04":
        member_field_04 = value; break;
      case "member_field_05":
        member_field_05 = value; break;
      case "member_field_06":
        member_field_06 = value; break;
      case "member_field_07":
        member_field_07 = value; break;
      case "member_field_08":
        member_field_08 = value; break;
      case "member_field_09":
        member_field_09 = value; break;
      case "member_field_10":
        member_field_10 = value; break;
      case "member_field_11":
        member_field_11 = value; break;
      case "member_field_12":
        member_field_12 = value; break;
      case "member_field_13":
        member_field_13 = value; break;
      case "member_field_14":
        member_field_14 = value; break;
      case "member_field_15":
        member_field_15 = value; break;
    }
  }

  List<FieldData> getExtraList(List<MemberExtra> list) {
    List<FieldData> data = <FieldData>[];
    if(list.isNotEmpty){
      for (var element in list) {
        String field = element.field_name.toString();
        String name  = element.field_display.toString();
        String value = getFieldValue(field);
        data.add(FieldData(display:name, value:value));
      }
    }
    return data;
  }

  @override
  String toString(){
    return 'Members {id:$id, '
        'mb_no:$mb_no, '
        'mb_distance:$mb_distance, '
        'moims_id:$moims_id, '
        'member_nickname:$member_nickname'
        'member_notify:$member_notify, '
        'member_approve:$member_approve, '
        'member_area:$member_area, '
        'member_grade:$member_grade, '
        'member_duty:$member_duty, '
        'member_message:$member_message, '
        'member_field_01:$member_field_01, '
        'member_field_02:$member_field_02, '
        'member_field_03:$member_field_03, '
        'member_field_04:$member_field_04, '
        'member_field_05:$member_field_05, '
        'member_field_06:$member_field_06, '
        'member_field_07:$member_field_07, '
        'member_field_08:$member_field_08, '
        'member_field_09:$member_field_09, '
        'member_field_10:$member_field_10, '
        'member_field_11:$member_field_11, '
        'member_field_12:$member_field_12, '
        'member_field_13:$member_field_13, '
        'member_field_14:$member_field_14, '
        'member_field_15:$member_field_15, '
        'member_data_ready:$member_data_ready, '
        'created_at:$created_at, '
        'updated_at:$updated_at}';
  }

  @override
  Map<String, String> toMap() => {
    'id': id.toString(),
    'mb_no': mb_no.toString(),
    'moims_id': moims_id.toString(),
    'member_nickname':member_nickname.toString(),
    'member_notify': member_notify.toString(),
    'member_approve': member_approve.toString(),
    'member_grade': member_grade.toString(),
    'member_duty': member_duty.toString(),
    'member_area': member_area.toString(),
    'member_message': member_message.toString(),
    'member_field_01': member_field_01.toString(),
    'member_field_02': member_field_02.toString(),
    'member_field_03': member_field_03.toString(),
    'member_field_04': member_field_04.toString(),
    'member_field_05': member_field_05.toString(),
    'member_field_06': member_field_06.toString(),
    'member_field_07': member_field_07.toString(),
    'member_field_08': member_field_08.toString(),
    'member_field_09': member_field_09.toString(),
    'member_field_10': member_field_10.toString(),
    'member_field_11': member_field_11.toString(),
    'member_field_12': member_field_11.toString(),
    'member_field_13': member_field_11.toString(),
    'member_field_14': member_field_11.toString(),
    'member_field_15': member_field_11.toString(),
    'member_data_ready': member_data_ready.toString()
  };

  Map<String, String> toAddMap() => {
    'member_nickname':member_nickname.toString(),
    'member_notify': member_notify.toString(),
    'member_approve': member_approve.toString(),
    'member_grade': member_grade.toString(),
    'member_duty': member_duty.toString(),
    'member_area': member_area.toString(),
    'member_message': member_message.toString(),
    'member_field_01': member_field_01.toString(),
    'member_field_02': member_field_02.toString(),
    'member_field_03': member_field_03.toString(),
    'member_field_04': member_field_04.toString(),
    'member_field_05': member_field_05.toString(),
    'member_field_06': member_field_06.toString(),
    'member_field_07': member_field_07.toString(),
    'member_field_08': member_field_08.toString(),
    'member_field_09': member_field_09.toString(),
    'member_field_10': member_field_10.toString(),
    'member_field_11': member_field_11.toString(),
    'member_field_12': member_field_11.toString(),
    'member_field_13': member_field_11.toString(),
    'member_field_14': member_field_11.toString(),
    'member_field_15': member_field_11.toString(),
    'member_data_ready': member_data_ready.toString()
  };

  @override
  String getFilename(){
    return "Members.dat";
  }

  @override
  void clear() {
    // TODO: implement clear
  }
}