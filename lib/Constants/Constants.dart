// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';

const String photo_tag_item = "item";
const String photo_tag_moim = "moim";
const String photo_tag_shop = "shop";
const String photo_tag_user = "user";
const String photo_tag_sales = "sales";

// 사진 최대 지정 갯수
const int max_photo_item = 4;
const int min_photo_item = 1;
const int max_photo_moim = 4;
const int min_photo_moim = 2;
const int max_photo_shop = 6;
const int min_photo_shop = 2;
const int max_photo_user  = 1;
const int max_photo_sales = 1;

const List<String> item_attribute = ["직접입력", "선택"];//,  "코드"];
const List<String> item_keyboard  = ["텍스트", "숫자", "영숫자", "이메일"];

const List<String> contact_category_display  = ["전체", "업무", "친밀", "경조사"];
const List<String> contact_category_item     = ["all", "business", "friend", "invite"];

const List<String> contact_source_display     = ["신규", "연락처", "모임"];
const List<String> contact_source_item        = ["none", "contact", "moim"];

const List<String> contact_order_display     = ["추천", "이름", "최근연락", "기념일","중요도", ];
const List<String> contact_order_item        = ["advise", "name", "recent", "event", "importance", ];

const List<String> contact_contact_item      = ["휴대폰", "전화", "이메일", "홈페이지", "주소", "기타"];
const List<String> contact_contact_kind      = ["개인", "회사", "자택", "기타"];
const List<String> contact_contact_type      = ["대면", "전화", "이메일", "SNS", "기타"];

const List<String> contact_anniversary_item  = ["생일", "결혼기념일", "제사", "승진", "기타"];
const List<String> contact_anniversary_kind  = ["본인", "배우자", "자녀", "부모", "기타"];
const List<String> contact_anniversary_date  = ["양력", "음력"];

const List<String> contact_person_duty  = ["대표", "회장", "임원", "부장", "과장", "차장", "대리", "사원", "팀장"];

const Color AppBar_Color = Colors.white;
const Color AppBar_Title = Colors.black;
const Color AppBar_Icon  = Colors.black;
