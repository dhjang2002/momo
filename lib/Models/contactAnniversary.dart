// ignore_for_file: unnecessary_const, non_constant_identifier_person_ids, avoid_print

import 'Model.dart';

class ContactAnniversary extends Model {
  String? id;            // 레코드번호
  String? users_id;      // 사용자 id: g5_member
  String? person_id;     // person id
  String? item;          // 기념일 명칭
  String? item_kind;     // 기념일 구분
  String? memo;          // 설명
  String? date_type;     // 날짜구분(음력,양력)
  String? date_at;       // 기념일자
  String? created_at;    // 생성시각
  String? updated_at;    // 변경시각

  ContactAnniversary({
    this.id="",
    this.users_id="",
    this.person_id = "",
    this.item = "",
    this.date_type = "",
    this.item_kind = "",
    this.date_at = "",
    this.memo = "",
    this.created_at  = "",
    this.updated_at  = "",
  });

  factory ContactAnniversary.fromJson(Map<String, dynamic> parsedJson)
  {
      return ContactAnniversary(
          id: parsedJson['id'],
          users_id: parsedJson['users_id'],
          person_id: parsedJson ['person_id'],
          item: parsedJson ['item'],
          date_type: parsedJson ['date_type'],
          item_kind: parsedJson ['item_kind'],
          date_at: parsedJson ['date_at'],
          memo: parsedJson ['memo'],
          created_at: parsedJson ['created_at'],
          updated_at: parsedJson ['updated_at']
      );
    }

  static List<ContactAnniversary> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ContactAnniversary.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'ContactInfo {id:$id, '
        'users_id:$users_id, '
        'person_id:$person_id, '
        'item:$item, '
        'date_type:$date_type, '
        'item_kind:$item_kind, '
        'date_at:$date_at, '
        'memo:$memo, '
        'created_at:$created_at, '
        'updated_at:$updated_at}';
  }

  @override
  Map<String, String> toMap() => {
    'id': id.toString(),
    'users_id': users_id.toString(),
    'person_id': person_id.toString(),
    'item': item.toString(),
    'date_type': date_type.toString(),
    'item_kind': item_kind.toString(),
    'date_at': date_at.toString(),
    'memo': memo.toString(),
  };

  Map<String, String> toAddMap() => {
    //'id': id.toString(),
    'users_id': users_id.toString(),
    'person_id': person_id.toString(),
    'item': item.toString(),
    'date_type': date_type.toString(),
    'item_kind': item_kind.toString(),
    'date_at': date_at.toString(),
    'memo': memo.toString(),
  };

  @override
  String getFilename() {
    return "ContactAnniversary.dat";
  }

  @override
  void clear() {
  }
}