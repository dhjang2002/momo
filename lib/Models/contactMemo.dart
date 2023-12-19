// ignore_for_file: unnecessary_const, non_constant_identifier_person_ids, avoid_print

import 'Model.dart';

class ContactMemo extends Model {
  String? id;            // 레코드번호
  String? users_id;      // 사용자 id: g5_member
  String? person_id;     // person id
  String? kind;          // 소통방법(대면,통화,SNS, 기타)
  String? memo;          // 근황메모
  String? attached;      // 파일첨부
  String? contact_at;    // 소통일자
  String? created_at;    // 생성시각
  String? updated_at;    // 변경시각

  ContactMemo({
    this.id="",
    this.users_id="",
    this.person_id = "",
    this.attached = "",
    this.kind = "",
    this.memo = "",
    this.contact_at = "",
    this.created_at  = "",
    this.updated_at  = "",
  });

  factory ContactMemo.fromJson(Map<String, dynamic> parsedJson)
  {
      return ContactMemo(
          id: parsedJson['id'],
          users_id: parsedJson['users_id'],
          person_id: parsedJson ['person_id'],
          attached: parsedJson ['attached'],
          kind: parsedJson ['kind'],
          contact_at: parsedJson ['contact_at'],
          memo: parsedJson ['memo'],
          created_at: parsedJson ['created_at'],
          updated_at: parsedJson ['updated_at']
      );
    }

  static List<ContactMemo> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ContactMemo.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'ContactInfo {id:$id, '
        'users_id:$users_id, '
        'person_id:$person_id, '
        'attached:$attached, '
        'kind:$kind, '
        'contact_at:$contact_at, '
        'memo:$memo, '
        'created_at:$created_at, '
        'updated_at:$updated_at}';
  }

  @override
  Map<String, String> toMap() => {
    'id': id.toString(),
    'users_id': users_id.toString(),
    'person_id': person_id.toString(),
    'kind': kind.toString(),
    'memo': memo.toString(),
    'contact_at': contact_at.toString(),
    'attached': attached.toString(),
  };

  Map<String, String> toAddMap() => {
    //'id': id.toString(),
    'users_id': users_id.toString(),
    'person_id': person_id.toString(),
    'kind': kind.toString(),
    'memo': memo.toString(),
    'contact_at': contact_at.toString(),
    'attached': attached.toString(),
  };

  @override
  String getFilename() {
    return "ContactMemo.dat";
  }

  @override
  void clear() {
  }
}