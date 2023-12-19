// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

class ShopVisit{
  String? id;            // 레코드번호
  String? users_id;      // 사용자 id: mb_no
  String? shops_id;      // shop id
  String? shop_name;     // 사업장명칭
  String? user_name;     // 고객이름
  String? consume;       // 쿠폰사용
  String? moims;
  String? created_at;    // 방문일시
  String? updated_at;    // 변경시각

  ShopVisit({
    this.id="",
    this.users_id="",
    this.shops_id="",
    this.shop_name="",
    this.user_name="",
    this.consume="",
    this.moims="",
    this.created_at="",
    this.updated_at="",
  });

  factory ShopVisit.fromJson(Map<String, dynamic> parsedJson)
  {
      return ShopVisit(
        id: parsedJson['id'],
          users_id: parsedJson['users_id'],
          shops_id: parsedJson ['shops_id'],
          shop_name: parsedJson ['shop_name'],
          user_name: parsedJson ['user_name'],
          consume: parsedJson ['consume'],
          moims: parsedJson ['moims'],
          created_at: parsedJson ['created_at'],
          updated_at: parsedJson ['updated_at']
      );
    }

  static List<ShopVisit> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ShopVisit.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'ShopVisit {id:$id, '
        'users_id:$users_id, '
        'shops_id:$shops_id, '
        'shop_name:$shop_name, '
        'user_name:$user_name, '
        'consume:$consume, '
        'moims:$moims, '
        'created_at:$created_at, '
        'updated_at:$updated_at}';
  }
  
  Map<String, String> toAddMap() => {
    'id': id.toString(),
    'users_id': users_id.toString(),
    'shops_id': shops_id.toString(),
    'consume': consume.toString(),
  };
}