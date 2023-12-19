// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'Model.dart';

class ContactPerson extends Model {
  String? id;               // 레코드번호
  String? users_id;         // 사용자 id: g5_member
  String? name;             // 사용자 이름
  String? company;          // 상호
  String? part;             // 부서
  String? duty;             // 직책
  String? phone;            // 전화
  String? email;            // 사용자 이메일
  String? addr;             // 사용자 주소
  String? addr_ext;         // 사용자 상세주소
  String? desc;             // 코멘트
  String? is_bussiness;     // 업무
  String? is_invite;        // 경조사 초청대상
  String? is_friend;        // 친밀
  String? importance;       // 업무 중요도(1-5)
  String? check_period;     // 연락주기(7일/14일/30일)
  String? thumnails;         // 사진
  String? source;         // 사진
  String? source_id;         // 사진
  String? contact_at;       // 접촉일자
  String? reservation_at;       // 통화예약
  String? created_at;       // 생성시각
  String? updated_at;       // 변경시각

  ContactPerson({
    this.id="",
    this.users_id="",
    this.name = "",               // 사용자 이름
    this.company = "",               // 사용자 별명
    this.email = "",              // 사용자 이메일
    this.phone = "",           // 사용자 홈페이지
    this.part = "",              // 사용자 등급
    this.addr = "",               // 사용자 주소
    this.addr_ext = "",           // 사용자 상세주소
    this.duty = "",            // 사용자 퓨시토큰
    this.thumnails = "",
    this.source = "",
    this.source_id = "",
    this.desc = "",
    this.is_bussiness= "N",
    this.is_invite   = "N",
    this.is_friend  = "N",
    this.importance  = "",
    this.check_period = "30",
    this.contact_at  = "",
    this.reservation_at  = "",
    this.created_at  = "",
    this.updated_at  = "",
  });

  factory ContactPerson.fromJson(Map<String, dynamic> parsedJson)
  {
      return ContactPerson(
          id: parsedJson['id'],
          users_id: parsedJson['users_id'],
          name: parsedJson ['name'],
          company: parsedJson ['company'],
          email:parsedJson ['email'],
          phone: parsedJson ['phone'],
          part: parsedJson ['part'],
          addr: parsedJson ['addr'],
          addr_ext: parsedJson ['addr_ext'],
          duty: parsedJson ['duty'],
          thumnails: parsedJson ['thumnails'],
          source: parsedJson ['source'],
          source_id: parsedJson ['source_id'],
          desc: parsedJson ['desc'],
          is_bussiness: parsedJson ['is_bussiness'],
          is_invite: parsedJson ['is_invite'],
          is_friend: parsedJson ['is_friend'],
          importance: parsedJson ['importance'],
          check_period: parsedJson ['check_period'],

          contact_at: parsedJson ['contact_at'],
          reservation_at: parsedJson ['reservation_at'],
          created_at: parsedJson ['created_at'],
          updated_at: parsedJson ['updated_at']
      );
    }

  static List<ContactPerson> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ContactPerson.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'ContactInfo {id:$id, '
        'users_id:$users_id, '
        'is_bussiness:$is_bussiness, '
        'name:$name, '
        'company:$company, '
        'email:$email, '
        'phone:$phone, '
        'part:$part, '
        'addr:$addr, '
        'addr_ext:$addr_ext, '
        'duty:$duty, '
        'thumnails:$thumnails, '
        'source:$source, '
        'source_id:$source_id, '
        'desc:$desc, '
        'is_invite:$is_invite, '
        'is_friend:$is_friend, '
        'importance:$importance, '
        'check_period:$check_period, '
        'contact_at:$contact_at, '
        'reservation_at:$reservation_at, '
        'created_at:$created_at, '
        'updated_at:$updated_at}';
  }

  @override
  Map<String, String> toMap() => {
    'id': id.toString(),
    'users_id': users_id.toString(),
    'name': name.toString(),
    'company': company.toString(),
    'part': part.toString(),
    'duty': duty.toString(),
    'phone': phone.toString(),
    'email': email.toString(),
    'addr': addr.toString(),
    'addr_ext': addr_ext.toString(),
    'desc': desc.toString(),
    'is_invite': is_invite.toString(),
    'is_friend': is_friend.toString(),
    'is_bussiness': is_bussiness.toString(),
    'importance': importance.toString(),
    'check_period': check_period.toString(),
    'contact_at': contact_at.toString(),
    'reservation_at': reservation_at.toString(),
    'thumnails': thumnails.toString(),
    'source': source.toString(),
    'source_id': source_id.toString(),
  };

  Map<String, String> toAddMap() => {
    //'id': id.toString(),
    'users_id': users_id.toString(),
    'name': name.toString(),
    'company': company.toString(),
    'part': part.toString(),
    'duty': duty.toString(),
    'phone': phone.toString(),
    'email': email.toString(),
    'addr': addr.toString(),
    'addr_ext': addr_ext.toString(),
    'desc': desc.toString(),
    'is_invite': is_invite.toString(),
    'is_friend': is_friend.toString(),
    'is_bussiness': is_bussiness.toString(),
    'importance': importance.toString(),
    'check_period': check_period.toString(),
    'contact_at': contact_at.toString(),
    'reservation_at': reservation_at.toString(),
    'source': source.toString(),
    'source_id': source_id.toString(),
    //'thumnails': thumnails.toString(),
  };

  @override
  String getFilename(){
    return "ContactPerson.dat";
  }

  @override
  void clear() {
  }
}