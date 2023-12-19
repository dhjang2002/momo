// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print
import 'Model.dart';

class ShopItems extends Model {
  String? id;              // 레코드번호
  String? users_id;        // 사용자 id: mb_no
  String? shops_id;        // shop id
  String? item_name;       // 상품명
  String? item_price;      // 상품가격
  String? item_desc;       // 상품설명
  String? item_url;        // 상품설명 url
  String? item_thumnails;
  String? item_data_ready; // 데이터준비(Y/N)
  String? created_at;      // 생성시각
  String? updated_at;      // 변경시각

  ShopItems({this.id="",
    this.users_id="",
    this.shops_id="",
    this.item_name="",
    this.item_price="0",
    this.item_desc="",
    this.item_url="",
    this.item_thumnails = "",
    this.item_data_ready="",
    this.created_at="",
    this.updated_at="",
  });

  factory ShopItems.fromJson(Map<String, dynamic> parsedJson)
  {
      return ShopItems(
        id: parsedJson['id'],
          users_id: parsedJson['users_id'],
          shops_id: parsedJson ['shops_id'],
          item_name: parsedJson ['item_name'],
          item_price: parsedJson ['item_price'],
          item_desc: parsedJson ['item_desc'],
          item_url: parsedJson ['item_url'],
          item_thumnails: parsedJson ['item_thumnails'],
          item_data_ready: parsedJson ['item_data_ready'],
          created_at: parsedJson ['created_at'],
          updated_at: parsedJson ['updated_at']
      );
    }

  static List<ShopItems> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ShopItems.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'ShopItems {id:$id, '
        'users_id:$users_id, '
        'shops_id:$shops_id, '
        'item_name:$item_name, '
        'item_price:$item_price, '
        'item_desc:$item_desc, '
        'item_url:$item_url, '
        'item_thumnails:$item_thumnails, '
        'item_data_ready:$item_data_ready, '
        'created_at:$created_at, '
        'updated_at:$updated_at}';
  }

  @override
  Map<String, String> toMap() => {
    'id': id.toString(),
    'users_id': users_id.toString(),
    'shops_id': shops_id.toString(),
    'item_name': item_name.toString(),
    'item_price': item_price.toString(),
    'item_desc': item_desc.toString(),
    'item_url': item_url.toString(),
    'item_thumnails': item_thumnails.toString(),
    'item_data_ready': item_data_ready.toString(),
  };

  Map<String, String> toAddMap() => {
    'id': id.toString(),
    'users_id': users_id.toString(),
    'shops_id': shops_id.toString(),
    'item_name': item_name.toString(),
    'item_price': item_price.toString(),
    'item_desc': item_desc.toString(),
    'item_url': item_url.toString(),
    'item_thumnails': item_thumnails.toString(),
    'item_data_ready': item_data_ready.toString(),
  };

  @override
  String getFilename(){
    return "ShopItems.dat";
  }

  @override
  void clear() {
    // TODO: implement clear
  }
}