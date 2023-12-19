// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print
import 'Model.dart';

class SalesItems {
  String? id;          // 레코드번호
  String? customer_id; // 고객 id: mb_no
  String? owner_id;    // 사업장주인 id: mb_no
  String? shops_id;    // shop id
  String? moims_id;    // moim id
  String? item;        // 거래내용
  String? price;       // 거래금액
  String? customer;    // 고객이름
  String? shop_name;   // 사업장명칭
  String? moim_name;   // 모임이름
  String? shop_owner;  // 사업장주인 (회원명)
  String? thumnails;   // 영수증
  String? created_at;  // 생성시각 (거래일자)
  String? updated_at;  // 변경시각

  SalesItems({
    this.id="",
    this.thumnails = "",
    this.customer_id="",
    this.owner_id="",
    this.customer="",
    this.shops_id="",
    this.item="상품구입",
    this.price="",
    this.moims_id="",
    this.shop_name="",
    this.moim_name = "",
    this.shop_owner="",
    this.created_at="",
    this.updated_at="",
  });

  factory SalesItems.fromJson(Map<String, dynamic> parsedJson)
  {
      return SalesItems(
        id: parsedJson['id'],
          thumnails:parsedJson['thumnails'],
          customer_id: parsedJson['customer_id'],
          owner_id: parsedJson['owner_id'],
          shops_id: parsedJson ['shops_id'],
          item: parsedJson ['item'],
          price: parsedJson ['price'],
          moims_id: parsedJson ['moims_id'],
          customer: parsedJson['customer'],
          shop_name: parsedJson ['shop_name'],
          moim_name: parsedJson ['moim_name'],
          shop_owner: parsedJson ['shop_owner'],
          created_at: parsedJson ['created_at'],
          updated_at: parsedJson ['updated_at']
      );
    }

  static List<SalesItems> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return SalesItems.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'SalesItems {'
        'id:$id, '
        'thumnails:$thumnails, '
        'customer_id:$customer_id, '
        'owner_id:$owner_id, '
        'shops_id:$shops_id, '
        'moims_id:$moims_id, '
        'item:$item, '
        'price:$price, '
        'customer:$customer, '
        'shop_name:$shop_name, '
        'moim_name:$moim_name, '
        'shop_owner:$shop_owner, '
        'created_at:$created_at, '
        'updated_at:$updated_at}';
  }

  Map<String, String> toAddMap() {
    if(this.price!.isEmpty)
      price = "0";

    Map<String, String> data = {
      'id': id.toString(),
      'customer_id': customer_id.toString(),
      'owner_id': owner_id.toString(),
      'thumnails': thumnails.toString(),
      'shops_id': shops_id.toString(),
      'moims_id': moims_id.toString(),
      'item': item.toString(),
      'price': price.toString(),
    };
    return data;
  }
}