// ignore_for_file: unnecessary_const, non_constant_identifier_person_ids, avoid_print

import 'Model.dart';

class ContactItem extends Model {
  String? id;            // 레코드번호
  String? users_id;      // 사용자 id: g5_member
  String? person_id;     // person id
  String? item;          // 종류(휴대폰,유선전화/이메일, ...)
  String? kind;          // 구분 (개인,사무실,자택,기타)
  String? value;         // 내용("010-2001-0937","abc@abc.com")
  String? value_ext;
  String? created_at;    // 생성시각
  String? updated_at;    // 변경시각

  ContactItem({
    this.id="",
    this.users_id="",
    this.person_id = "",
    this.value = "",
    this.value_ext = "",
    this.kind = "",
    this.item = "",
    this.created_at  = "",
    this.updated_at  = "",
  });

  factory ContactItem.fromJson(Map<String, dynamic> parsedJson)
  {
      return ContactItem(
          id: parsedJson['id'],
          users_id: parsedJson['users_id'],
          person_id: parsedJson ['person_id'],
          value: parsedJson ['value'],
          value_ext: parsedJson ['value_ext'],
          kind: parsedJson ['kind'],
          item: parsedJson ['item'],
          created_at: parsedJson ['created_at'],
          updated_at: parsedJson ['updated_at']
      );
    }

  static List<ContactItem> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ContactItem.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'ContactInfo {id:$id, '
        'users_id:$users_id, '
        'person_id:$person_id, '
        'value:$value, '
        'value_ext:$value_ext, '
        'kind:$kind, '
        'item:$item, '
        'created_at:$created_at, '
        'updated_at:$updated_at}';
  }

  @override
  Map<String, String> toMap() => {
    'id': id.toString(),
    'users_id': users_id.toString(),
    'person_id': person_id.toString(),
    'kind': kind.toString(),
    'item': item.toString(),
    'value': value.toString(),
    'value_ext': value_ext.toString(),
  };

  Map<String, String> toAddMap() => {
    //'id': id.toString(),
    'users_id': users_id.toString(),
    'person_id': person_id.toString(),
    'kind': kind.toString(),
    'item': item.toString(),
    'value': value.toString(),
    'value_ext': value_ext.toString(),
  };

  @override
  String getFilename() {
    return "ContactItem.dat";
  }

  @override
  void clear() {
  }
}