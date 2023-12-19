// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print
import 'Model.dart';

class MemberExtra extends Model {
  String? id;
  String? moims_id;          // 모임 key
  String? field_name;       // a_members 테이블의 필드명
  String? field_display;    // 필드표시(예: 기수, 학번)
  String? field_attribute;  // 필드속성(input/select/code)
  String? field_keyboard;   // 키보드타입(none, text, multi, number, digit, email)
  String? field_data;       // 필드속성이 select인 경우 선택값(서울;대전;대구;부산), code인 경우에는 코드테이블 그룹
  String? field_use;        // 사용여부
  String? created_at;       // 생성시각
  String? updated_at;       // 변경시각

  MemberExtra({
    this.id="",
    this.moims_id="",
    this.field_name="",
    this.field_display="",
    this.field_attribute="",
    this.field_keyboard="",
    this.field_data="",
    this.field_use="Y",
    this.created_at="",
    this.updated_at="",
  });

  static List<MemberExtra> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return MemberExtra.fromJson(data);
    }).toList();
  }

  factory MemberExtra.fromJson(Map<String, dynamic> parsedJson)
  {
      return MemberExtra(
        id: parsedJson['id'],
          moims_id: parsedJson['moims_id'],
          field_name: parsedJson ['field_name'],
          field_display: parsedJson ['field_display'],
          field_attribute: parsedJson ['field_attribute'],
          field_keyboard: parsedJson ['field_keyboard'],
          field_data: parsedJson ['field_data'],
          field_use: parsedJson ['field_use'],
          created_at: parsedJson ['created_at'],
          updated_at: parsedJson ['updated_at']
      );
    }

  @override
  String toString(){
    return 'MyInfo {id:$id, '
        'moims_id:$moims_id, '
        'field_name:$field_name, '
        'field_display:$field_display, '
        'field_attribute:$field_attribute, '
        'field_keyboard:$field_keyboard, '
        'field_data:$field_data, '
        'field_use:$field_use, '
        'created_at:$created_at, '
        'updated_at:$updated_at}';
  }

  @override
  Map<String, String> toMap() => {
    'id': id.toString(),
    'moims_id': moims_id.toString(),
    'field_name': field_name.toString(),
    'field_display': field_display.toString(),
    'field_attribute': field_attribute.toString(),
    'field_keyboard': field_keyboard.toString(),
    'field_data': field_data.toString(),
    'field_use': field_use.toString(),
  };

  Map<String, String> toAddMap() => {
    //'id': id.toString(),
    'moims_id': moims_id.toString(),
    'field_name': field_name.toString(),
    'field_display': field_display.toString(),
    'field_attribute': field_attribute.toString(),
    'field_keyboard': field_keyboard.toString(),
    'field_data': field_data.toString(),
    'field_use': field_use.toString(),
  };

  @override
  String getFilename(){
    return "MyInfo.dat";
  }

  @override
  void clear() {
    // TODO: implement clear
  }
}