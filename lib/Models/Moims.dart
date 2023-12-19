// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'Model.dart';

class Moims extends Model {
  String? id;
  String? moim_owner;       // 레코드번호
  String? shops_id;         // 모임이 상점인경우, 예:미용실 등
  String? moim_category;    // 모임분류(S:Shop, M:Membership)
  String? moim_kind;        // 모임운영(Y:공개, N:비공개)
  String? moim_code;        // 가입코드(비공개 운영시 멤버 가입요청시 체크)
  String? moim_accept;      // 승인방식(A:Auto, M:Managed)
  String? moim_name;        // 모일명칭: 예:함경연, 대저너
  String? moim_title;       // 모임 타이틀: 예:함께하는 경영자 모임
  String? moim_description; // 모임 설명: 예:
  String? moim_data_ready;  // 데이터준비(Y/N)
  String? moim_thumnails;   //
  String? use_nick;
  String? moim_tag;

  String? member_approve;

  String? created_at;       // 생성시각
  String? updated_at;       // 변경시각

  Moims({this.id="",
    this.moim_owner="",
    this.shops_id="0",
    this.moim_category="",
    this.moim_kind="",
    this.moim_code="",
    this.moim_accept="",
    this.moim_name="",
    this.moim_title="",
    this.moim_description="",
    this.moim_data_ready="",
    this.moim_thumnails="",
    this.moim_tag = "",
    this.use_nick = "아니오",
    this.member_approve="",
    this.created_at="",
    this.updated_at="",
  });

  factory Moims.fromJson(Map<String, dynamic> parsedJson)
  {
      return Moims(
        id: parsedJson['id'],
          moim_owner: parsedJson['moim_owner'],
          shops_id: parsedJson ['shops_id'],
          moim_category: parsedJson ['moim_category'],
          moim_kind: parsedJson ['moim_kind'],
          moim_code: parsedJson ['moim_code'],
          moim_accept: parsedJson ['moim_accept'],
          moim_name: parsedJson ['moim_name'],
          moim_title: parsedJson ['moim_title'],
          moim_description: parsedJson ['moim_description'],
          moim_data_ready: parsedJson ['moim_data_ready'],
          moim_thumnails: parsedJson ['moim_thumnails'],
          moim_tag:parsedJson ['moim_tag'],
          use_nick:parsedJson ['use_nick'],
          member_approve:parsedJson ['member_approve'],
          created_at: parsedJson ['created_at'],
          updated_at: parsedJson ['updated_at']
      );
    }

  static List<Moims> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return Moims.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'MyInfo {id:$id, '
        'moim_owner:$moim_owner, '
        'shops_id:$shops_id, '
        'moim_category:$moim_category, '
        'moim_kind:$moim_kind, '
        'moim_code:$moim_code, '
        'moim_accept:$moim_accept, '
        'moim_name:$moim_name, '
        'moim_title:$moim_title, '
        'moim_description:$moim_description, '
        'moim_thumnails:$moim_thumnails, '
        'moim_tag:$moim_tag, '
        'use_nick:$use_nick, '
        'member_approve:$member_approve, '
        'moim_data_ready:$moim_data_ready, '
        'created_at:$created_at, '
        'updated_at:$updated_at}';
  }

  @override
  Map<String, String> toMap() => {
    'id': id.toString(),
    'shops_id': shops_id.toString(),
    'moim_category': moim_category.toString(),
    'moim_kind': moim_kind.toString(),
    'moim_code': moim_code.toString(),
    'moim_accept': moim_accept.toString(),
    'moim_name': moim_name.toString(),
    'moim_title': moim_title.toString(),
    'moim_thumnails': moim_thumnails.toString(),
    'moim_tag': moim_tag.toString(),
    'use_nick': use_nick.toString(),
    //'member_approve': member_approve.toString(),
    'moim_description': moim_description.toString(),
    'moim_data_ready': moim_data_ready.toString()
  };

  Map<String, String> toAddMap() => {
    'id': id.toString(),
    'shops_id': shops_id.toString(),
    'moim_category': moim_category.toString(),
    'moim_kind': moim_kind.toString(),
    'moim_code': moim_code.toString(),
    'moim_accept': moim_accept.toString(),
    'moim_name': moim_name.toString(),
    'moim_title': moim_title.toString(),
    'moim_thumnails': moim_thumnails.toString(),
    'moim_tag': moim_tag.toString(),
    'use_nick': use_nick.toString(),
    //'member_approve': member_approve.toString(),
    'moim_description': moim_description.toString(),
    'moim_data_ready': moim_data_ready.toString()
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