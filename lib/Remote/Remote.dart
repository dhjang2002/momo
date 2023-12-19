// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:http/http.dart' as http;
import 'package:momo/Models/ChatItem.dart';
import 'package:momo/Models/MoimsBoard.dart';
import 'package:momo/Models/MainInfo.dart';
import 'package:momo/Models/MoimInfo.dart';
import 'package:momo/Models/SalesItems.dart';
import 'package:momo/Models/SalesSumarry.dart';
import 'package:momo/Models/SearchItem.dart';
import 'package:momo/Models/ShopEvent.dart';
import 'package:momo/Models/ShopVisit.dart';
import 'package:momo/Models/contactAnniversary.dart';
import 'package:momo/Models/contactItem.dart';
import 'package:momo/Models/contactMemo.dart';
import 'package:momo/Models/contactPerson.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Models/AResult.dart';
import 'package:momo/Models/Codes.dart';
import 'package:momo/Models/Files.dart';
import 'package:momo/Models/MemberExtra.dart';
import 'package:momo/Models/MemberInfo.dart';
import 'package:momo/Models/Members.dart';
import 'package:momo/Models/Moims.dart';
import 'package:momo/Models/Person.dart';
import 'package:momo/Models/ShopItems.dart';
import 'package:momo/Models/Shops.dart';

// http://http://211.175.164.71/data/file/report/1889929298_lHb8uikx_c6f725d752871a270687568fdf7fba915a32690c.pdf
// http://211.175.164.71/app/req_message.php?command=LIST&users_id=20;

// http://211.175.164.71/app/req_checkup_results.php?command=SERVICE
// http://211.175.164.71/app/req_checkup_results.php?command=INFO
// http://211.175.164.71/app/req_checkup_results.php?command=ANIMALS
// http://211.175.164.71/app/req_checkup_results.php?command=OWNER&users_id=20;

// http://211.175.164.71/app/req_install.php?command=CHECKUP
// http://211.175.164.71/app/req_install.php?command=RESULT

// http://211.175.164.71/app/req_animals.php?command=UPDATE&id=4&name=해탈이
// http://211.175.164.71/app/req_animals.php?command=LIST&users_id=20

// http://211.175.164.71/app/req_question.php?command=INFO&id=1
// http://211.175.164.71/app/req_question.php?command=LIST&users_id=20
// http://211.175.164.71/app/req_question.php?command=UPDATE&id=1&is_complete=N

// http://211.175.164.71/app/req_question.php?command=STATUS&users_id=20
// http://211.175.164.71/app/req_question.php?command=STATUS&animals_id=0

// http://211.175.164.71/app/req_users.php?command=INFO&mb_no=2
// http://211.175.164.71/app/req_users.php?command=CHECK&mb_id=dhjang2002
// http://211.175.164.71/app/req_users.php?command=LOGIN&mb_id=dhjang2002&mb_password=sdmk1221
// http://211.175.164.71/app/req_users.php?command=UPDATE&mb_no=2&mb_name=홍길동
// http://211.175.164.71/app/req_users.php?command=UPDATE&mb_no=2&mb_password=sdmk1221

// http://211.175.164.71/app/req_codes.php?command=LIST&group=반려견품종

const bool _DEBUG = true;
//const bool _DEBUG = false;

class Remote{

  static Future reqQuery({
    required Map<String,String> params,
    required Function(List <SearchItem> list) onResponse}) async {

    List <SearchItem> list = <SearchItem>[];
    await request(
        target: "req_request",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty){
            for(int n=0; n<result.list!.length; n++){
              list.add(SearchItem.fromJson(result.list!.elementAt(n)));
            }
          }
          onResponse(list);
        });
  }

  static Future reqMainInfo({
    required Map<String,String> params,
    required Function(MainInfo info) onResponse}) async {

    await request(
        target: "req_request",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty){
            return onResponse(MainInfo.fromJson(result.list!.elementAt(0)));
          }
          return onResponse(MainInfo());
        });
  }

  static Future reqMoimInfo({
    required Map<String,String> params,
    required Function(MoimInfo info) onResponse}) async {

    await request(
        target: "req_request",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty){
            return onResponse(MoimInfo.fromJson(result.list!.elementAt(0)));
          }
          return onResponse(MoimInfo());
        });
  }

  static Future getChatInfo({
    required Map<String,String> params,
    required Function(List <ChatItem> list) onResponse}) async {

    List <ChatItem> list = <ChatItem>[];
    await request(
        target: "req_moim_chats",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty){
            for(int n=0; n<result.list!.length; n++){
              list.add(ChatItem.fromJson(result.list!.elementAt(n)));
            }
          }
          onResponse(list);
        });
  }

  static Future reqChat({
    required Map<String,String> params,
    required Function(bool result) onResponse}) async {
    await request(
        target: "req_moim_chats",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK" ) {
            return onResponse(true);
          }
          return onResponse(false);
        });
  }

  static Future getUserBoards({
    required Map<String,String> params,
    required Function(List <MoimsBoard> list) onResponse}) async {

    List <MoimsBoard> list = <MoimsBoard>[];
    await request(
        target: "req_notice",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty){
            for(int n=0; n<result.list!.length; n++){
              list.add(MoimsBoard.fromJson(result.list!.elementAt(n)));
            }
          }
          onResponse(list);
        });
  }

  static Future getMoimBoards({
    required Map<String,String> params,
    required Function(List <MoimsBoard> list) onResponse}) async {

    List <MoimsBoard> list = <MoimsBoard>[];
    await request(
        target: "req_boards",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty){
            for(int n=0; n<result.list!.length; n++){
              list.add(MoimsBoard.fromJson(result.list!.elementAt(n)));
            }
          }
          onResponse(list);
        });
  }

  static Future getEvents({
    required Map<String,String> params,
    required Function(List <ShopEvent> list) onResponse}) async {

    List <ShopEvent> list = <ShopEvent>[];
    await request(
        target: "req_events",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty){
            for(int n=0; n<result.list!.length; n++){
              list.add(ShopEvent.fromJson(result.list!.elementAt(n)));
            }
          }
          onResponse(list);
        });
  }

  static Future reqEvents({
    required Map<String,String> params,
    required Function(bool result) onResponse}) async {

    await request(
        target: "req_events",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK" ) {
            return onResponse(true);
          }
          return onResponse(false);
        });
  }

  static Future getVisits({
    required Map<String,String> params,
    required Function(List <ShopVisit> list) onResponse}) async {
    List <ShopVisit> list = <ShopVisit>[];
    await request(
        target: "req_visits",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty){
            for(int n=0; n<result.list!.length; n++){
              list.add(ShopVisit.fromJson(result.list!.elementAt(n)));
            }
          }
          onResponse(list);
        });
  }

  static Future reqVisits({
    required Map<String,String> params,
    required Function(bool result) onResponse}) async {

    await request(
        target: "req_visits",
        params: params,
        onResult: (AResult result)
        {
          if(result.result=="OK" ) {
            return onResponse(true);
          }
          return onResponse(false);
        });
  }

  static Future addVisits({
    required Map<String,String> params,
    required Function(ShopVisit info) onResponse}) async {

    await request(
        target: "req_visits",
        params: params,
        onResult: (AResult result) {
          //print(result.toString());
          if(result.result=="OK" && result.list!.isNotEmpty) {
            onResponse(ShopVisit.fromJson(result.list!.elementAt(0)));
          }
        });
  }

  // ShopItems Api
  ////////////////////////////////////////////////////////////////////////////
  static Future getSalesItems({
    required bool isItems,
    required Map<String,String> params,
    required Function(List <dynamic> list, bool hasHead, SalesSumarry head) onResponse}) async {
    List <dynamic> items = <dynamic>[];
    SalesSumarry head = SalesSumarry();
    bool isHead = false;
    await request(target: "req_sales", params: params,
        onResult: (AResult result) {
          if(result.result=="OK") {
            if(result.list!.isNotEmpty) {
                if (isItems) {
                    for (int n = 0; n < result.list!.length; n++) {
                      items.add(SalesItems.fromJson(result.list!.elementAt(n)));
                    }
                }
                else {
                    for (int n = 0; n < result.list!.length; n++) {
                      items.add(SalesSumarry.fromJson(result.list!.elementAt(n)));
                    }
                }
            }

            if(result.head!.isNotEmpty) {
              isHead = true;
              head = SalesSumarry.fromJson(result.head!.elementAt(0));
            }
          }
          onResponse(items, isHead, head);
        });
  }

  static Future getSalesSumarry({
    required Map<String,String> params,
    required Function(List <SalesSumarry> list) onResponse}) async {
    List <SalesSumarry> list = <SalesSumarry>[];
    await request(target: "req_sales", params: params,
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty){
            for(int n=0; n<result.list!.length; n++){
              list.add(SalesSumarry.fromJson(result.list!.elementAt(n)));
            }
          }
          onResponse(list);
        });
  }

  static Future addSalesItems({
    required Map<String,String> params,
    required Function(SalesItems info) onResponse}) async {

    await request(
        target: "req_sales",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty) {
            onResponse(SalesItems.fromJson(result.list!.elementAt(0)));
          }
        });
  }

  static Future reqSalesItems({
    required Map<String,String> params,
    required Function(bool result) onResponse}) async {
    
    await request(
        target: "req_sales", 
        params: params,
        onResult: (AResult result) {
          //print(result.toString());
          if(result.result=="OK" ) {
            return onResponse(true);
          }
          return onResponse(false);
        });
  }
  
  static Future reqMembers({
    required Map<String,String> params,
    required Function(bool result) onResponse}) async {
    await request(
        target: "req_members", 
        params: params,
        onResult: (AResult result) {
          //print(result.toString());
          if(result.result=="OK" ) {
            return onResponse(true);
          }
          return onResponse(false);
        });
  }

  static Future joinToMember({
    required Map<String,String> params,
    required Function(Members info) onResponse}) async {

    await request(
        target: "req_members", 
        params: params,
        onResult: (AResult result) {
          //print(result.toString());
          if(result.result=="OK" && result.list!.isNotEmpty) {
            return onResponse(Members.fromJson(result.list!.elementAt(0)));
          }
        });
  }

  static Future reqUsers({
    required Map<String,String> params,
    required Function(bool result) onResponse}) async {
    await request(
        target: "req_users",
        params: params,
        onResult: (AResult result) {
          //print(result.toString());
          if(result.result=="OK" ) {
            return onResponse(true);
          }
          return onResponse(false);
        });
  }

  static Future login({
    required String uid, 
    required String pwd,
    required Function(int status, Person person) onResponse}) async {
    await request(
        target: "req_users", 
        params: {
          "command":"LOGIN",
          "mb_id":uid,
          "mb_password":pwd},
        onResult: (AResult result) {
          if(result.result=="NETWORK"){
            return onResponse(-1, Person());
          }

          //print("Login:list>"+result.list!.isNotEmpty.toString());
          //print("Login:head>"+result.head!.isNotEmpty.toString());

          if(result.result=="OK" && result.list!.isNotEmpty) {
            return onResponse(1, Person.fromJson(result.list!.elementAt(0)));
          }
          return onResponse(0, Person());
    });
  }

  static Future <void> updatePerson({
    required Person person,
    required Function(int result) onResponse}) async {
    Map<String, String> params = person.toMap();
    params.addAll({"command":"UPDATE"});
    await request(
        target: "req_users",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK") {
            return onResponse(1);
          }
          return onResponse(0);
    });
  }

  static Future getPerson({
    required Map<String,String> params,
    required Function(bool status, Person info) onResponse}) async {
    await request(
        target: "req_users",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty) {
            return onResponse(true, Person.fromJson(result.list!.elementAt(0)));
          }
          return onResponse(false, Person());
        });
  }

  static Future getCodes({
    required String moims_id,
    required String category,
    required String key,
    required Function(List <Codes> list) onResponse}) async {
    List <Codes> list = <Codes>[];
    await request(
        target: "req_codes",
        params: {
          "command":"LIST",
          "moims_id":moims_id,
          "group":category,
          "key":key},
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty) {
            for(int n=0; n<result.list!.length; n++){
              list.add(Codes.fromJson(result.list!.elementAt(n)));
            }
          }
          onResponse(list);
      });
  }

  static Future getFiles({
    required Map<String,String> params,
    required Function(List <Files> info) onResponse}) async {
    List <Files> list = <Files>[];
    await request(
        target: "req_files", 
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty){
            for(int n=0; n<result.list!.length; n++){
              list.add(Files.fromJson(result.list!.elementAt(n)));
            }
          }
          onResponse(list);
        });
  }

  static Future deleteFiles({
    required Map<String,String> params,
    required Function(bool result) onResponse}) async {
    await request(
        target: "req_files", 
        params: params,
        onResult: (AResult result) {
          //print(result.toString());
          if(result.result=="OK" ) {
            return onResponse(true);
          }
          return onResponse(false);
        });
  }

  static Future addFiles({
    required String filePath,
    required Map<String,String> params,
    required Function(int result, Files info) onUpload}) async{
    List<String> splite = filePath.split(".");
    if(splite.length>1) {
      String ext = splite[splite.length - 1];
      params.addAll({"ext":ext});
    }

    await upload(
        params: params, 
        filePath: filePath,
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty) {
            return onUpload(1, Files.fromJson(result.list!.elementAt(0)));
          } 
          return onUpload(0, Files());
        });
  }

  static Future<void> getMoims({
    required Map<String,String> params,
    required Function(List <Moims> info) onResponse}) async {
    List <Moims> list = <Moims>[];
    await request(
        target: "req_moims", 
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty){
            for(int n=0; n<result.list!.length; n++){
              list.add(Moims.fromJson(result.list!.elementAt(n)));
            }
          }
          onResponse(list);
        });
  }

  static Future addMoims({
    required Map<String,String> params,
    required Function(Moims info) onResponse}) async {

    await request(
        target: "req_moims",
        params: params,
        onResult: (AResult result)
        {
          //print(result.toString());
          if(result.result=="OK" && result.list!.isNotEmpty) {
            onResponse(Moims.fromJson(result.list!.elementAt(0)));
          }
        });
  }

  static Future<void> reqMoims({
    required Map<String,String> params,
    required Function(bool result) onResponse}) async {

    await request(
        target: "req_moims", 
        params: params,
        onResult: (AResult result)
        {
          if(result.result=="OK" ) {
            return onResponse(true);
          }
          return onResponse(false);
        });
  }

  // Shops Api
  ////////////////////////////////////////////////////////////////////////////
  static Future getShops({
    required Map<String,String> params,
    required Function(List <Shops> info) onResponse}) async {
    List <Shops> list = <Shops>[];
    await request(
        target: "req_shops", 
        params: params, onResult: (AResult result) {
        if(result.result=="OK" && result.list!.isNotEmpty) {
          for(int n=0; n<result.list!.length; n++) {
            list.add(Shops.fromJson(result.list!.elementAt(n)));
          }
        }
        onResponse(list);
    });
  }

  static Future addShops({
    required Map<String,String> params,
    required Function(Shops info) onResponse}) async {

    await request(
        target: "req_shops", 
        params: params,
        onResult: (AResult result)
        {
          if(result.result=="OK" && result.list!.isNotEmpty) {
            onResponse(Shops.fromJson(result.list!.elementAt(0)));
          }
        });
  }

  static Future reqShops({
    required Map<String,String> params,
    required Function(bool result) onResponse}) async {

    await request(
        target: "req_shops", 
        params: params,
        onResult: (AResult result)
        {
          //print(result.toString());
          if(result.result=="OK" ) {
            return onResponse(true);
          }
          return onResponse(false);
        });
  }
  ///////////////////////////////////////////////////////////////////////

  // ShopItems Api
  ////////////////////////////////////////////////////////////////////////////
  static Future getShopItems({
    required Map<String,String> params,
    required Function(List <ShopItems> list) onResponse}) async {
    List <ShopItems> list = <ShopItems>[];
    await request(
        target: "req_shop_items", 
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty){
            for(int n=0; n<result.list!.length; n++){
              list.add(ShopItems.fromJson(result.list!.elementAt(n)));
            }
          }
          onResponse(list);
        });
  }

  static Future addShopItems({
    required Map<String,String> params,
    required Function(ShopItems info) onResponse}) async {

    await request(
        target: "req_shop_items", 
        params: params,
        onResult: (AResult result)
        {
          //print(result.toString());
          if(result.result=="OK" && result.list!.isNotEmpty) {
            onResponse(ShopItems.fromJson(result.list!.elementAt(0)));
          }
        });
  }

  static Future reqShopItems({
    required Map<String,String> params,
    required Function(bool result) onResponse}) async {
    await request(
        target: "req_shop_items", 
        params: params,
        onResult: (AResult result)
        {
          //print(result.toString());
          if(result.result=="OK" ) {
            return onResponse(true);
          }
          return onResponse(false);
        });
  }
  ///////////////////////////////////////////////////////////////////////

  // contact 연락처 조회
  static Future getContactPerson({
    required Map<String,String> params,
    required Function(List <ContactPerson> list) onResponse}) async {

    List <ContactPerson> list = <ContactPerson>[];
    await request(
        target: "req_contact_person",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty){
            for(int n=0; n<result.list!.length; n++){
              list.add(ContactPerson.fromJson(result.list!.elementAt(n)));
            }
          }
          onResponse(list);
        });
  }

  // contact 연락처 편집
  static Future <void> reqContactPerson({
    required Map<String,String> params,
    required Function(bool status, String result) onResponse}) async {
    await request(
        target: "req_contact_person",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK"){
            return onResponse(true, result.message.toString());
          }
          return onResponse(false, result.message.toString());
        });
  }

  // contact 메모 조회
  static Future getContactMemo({
    required Map<String,String> params,
    required Function(List <ContactMemo> list) onResponse}) async {

    List <ContactMemo> list = <ContactMemo>[];
    await request(
        target: "req_contact_memo",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty){
            for(int n=0; n<result.list!.length; n++){
              list.add(ContactMemo.fromJson(result.list!.elementAt(n)));
            }
          }
          onResponse(list);
        });
  }

  // contact 메모 편집
  static Future <void> reqContactMemo({
    required Map<String,String> params,
    required Function(bool result) onResponse}) async {
    await request(
        target: "req_contact_memo",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK"){
            return onResponse(true);
          }
          return onResponse(false);
        });
  }

  // contact 기념일 조회
  static Future getContactAnniversary({
    required Map<String,String> params,
    required Function(List <ContactAnniversary> list) onResponse}) async {

    List <ContactAnniversary> list = <ContactAnniversary>[];
    await request(
        target: "req_contact_anniversary",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty){
            for(int n=0; n<result.list!.length; n++){
              list.add(ContactAnniversary.fromJson(result.list!.elementAt(n)));
            }
          }
          onResponse(list);
        });
  }

  // contact 기념일 편집
  static Future <void> reqContactAnniversary({
    required Map<String,String> params,
    required Function(bool result) onResponse}) async {
    await request(
        target: "req_contact_anniversary",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK"){
            return onResponse(true);
          }
          return onResponse(false);
        });
  }

  // contact 연락처 항목 조회
  static Future getContactItem({
    required Map<String,String> params,
    required Function(List <ContactItem> list) onResponse}) async {

    List <ContactItem> list = <ContactItem>[];
    await request(
        target: "req_contact_item",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty){
            for(int n=0; n<result.list!.length; n++){
              list.add(ContactItem.fromJson(result.list!.elementAt(n)));
            }
          }
          onResponse(list);
        });
  }

  // contact 연락처 항목 편집
  static Future <void> reqContactItem({
    required Map<String,String> params,
    required Function(bool result) onResponse}) async {
    await request(
        target: "req_contact_item",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK"){
            return onResponse(true);
          }
          return onResponse(false);
        });
  }

  static Future reqMemberExtra({
    required Map<String,String> params,
    required Function(bool result) onResponse}) async {

    await request(
        target: "req_member_extra",
        params: params,
        onResult: (AResult result)
        {
          if(result.result=="OK" ) {
            return onResponse(true);
          }
          return onResponse(false);
        });
  }

  static Future getMemberExtra({
    required Map<String,String> params,
    required Function(List <MemberExtra> list) onResponse}) async {
    List <MemberExtra> list = <MemberExtra>[];
    await request(
        target: "req_member_extra",
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK" && result.list!.isNotEmpty){
            for(int n=0; n<result.list!.length; n++){
              list.add(MemberExtra.fromJson(result.list!.elementAt(n)));
            }
          }
          onResponse(list);
        });
  }

  static Future addMemberExtra({
    required Map<String,String> params,
    required Function(MemberExtra info) onResponse}) async {

    await request(
        target: "req_member_extra", 
        params: params,
        onResult: (AResult result)
        {
          if(result.result=="OK" && result.list!.isNotEmpty) {
            onResponse(MemberExtra.fromJson(result.list!.elementAt(0)));
          }
        });
  }

  static Future getMemberInfo({
    required Map<String,String> params,
    required Function(List <MemberInfo> list) onResponse}) async {

    List <MemberInfo> list = <MemberInfo>[];
    await request(
        target: "req_member_info", 
        params: params,
        onResult: (AResult result) {
            if(result.result=="OK" && result.list!.isNotEmpty){
                for(int n=0; n<result.list!.length; n++){
                  list.add(MemberInfo.fromJson(result.list!.elementAt(n)));
                }
            }
            onResponse(list);
        });
  }

  static Future <void> reqMemberInfo({
    required Map<String,String> params,
    required Function(bool result) onResponse}) async {
    await request(
        target: "req_member_info", 
        params: params,
        onResult: (AResult result) {
          if(result.result=="OK"){
            return onResponse(true);
          }
          return onResponse(false);
        });
  }

  static Future <void> request({
    required String target,
    required Map<String,String> params,
    required Function(AResult result) onResult}) async {

    final Map<String,String> headers = { "Content-type": "multipart/form-data" };
    var request = http.MultipartRequest('POST', Uri.parse("$URL_API/$target.php"),);

    if(_DEBUG) {
      //print("");
      print(">>> Req: " + Uri.parse("$URL_API/$target.php").toString() +
          " params=${params.toString()}");
    }
    request.headers.addAll(headers);
    request.fields.addAll(params);

    try {
      var res = await request.send();
      if (res.statusCode == 200) {
        String data = await res.stream.bytesToString();
        data = data.trim();

        if(_DEBUG) {
          print("<<< Rep: " + Uri.parse("$URL_API/$target.php").toString() +
              " data=" + data);
          //print("");
        }

        int start = data.indexOf('{', 0);
        if (start > 0) {
          data = data.substring(start);
        }
        dynamic jsonData = jsonDecode(data);
        return onResult(AResult.fromJson(jsonData));
      }

      print("<<< Rep: Http Error CODE=" + res.statusCode.toString());

      return onResult(AResult(
          result: "FAIL",
          message: "Http Error CODE: ${res.statusCode}",
          head: <dynamic>[],
          list: <dynamic>[]));
    }
    catch(e) {
      print("<<< Rep: Exception: " + e.toString());
      return onResult(
          AResult(
            result: "FAIL",
            message: "Exception:(e):" + e.toString(),
            head: <dynamic>[],
            list: <dynamic>[]));
    }
   }

  static Future <void> upload({
    required String filePath, 
    required Map<String,String> params,
    required Function(AResult result) onResult}) async {
    final Map<String,String> headers = { "Content-type": "multipart/form-data" };
    var request = http.MultipartRequest('POST',
      Uri.parse("$URL_API/req_files.php"),);

    request.headers.addAll(headers);
    request.fields.addAll(params);

    // 파일 업로드
    if (filePath.isNotEmpty) {
        if (await io.File(filePath).exists()) {
          request.files.add(await http.MultipartFile.fromPath('file_data', filePath));
        }
    }

    print(">>> Upload: "+Uri.parse("$URL_API/req_files.php").toString()+" params=${params.toString()}");

    try {
      var res = await request.send();

      if (res.statusCode == 200) {
        String data = await res.stream.bytesToString();

        print("<<< Rep: "+data);

        int start = data.indexOf('{', 0);
        if (start > 0) {
          data = data.substring(start);
        }
        return onResult(AResult.fromJson(jsonDecode(data)));
      }

      print("<<< Rep: Http Error CODE=" + res.statusCode.toString());
      return onResult(AResult(
          result: "FAIL",
          message: "Http Error CODE: ${res.statusCode}"));
    }
    catch (e){
      print("<<< Rep: Exception: " + e.toString());
      return onResult(AResult(
          result: "FAIL", 
          message: "Exception:(e):" + e.toString()));
    }
  }
}