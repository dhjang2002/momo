// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print
class SalesSumarry {
  String? total;      // 거래금액 합계
  String? count;      // 거래 건수
  String? owner_id;   // 판매자/구매자 id
  String? owner_name; // 판매자/구매자 이름.

  SalesSumarry({
    this.owner_id="",
    this.total="",
    this.count="",
    this.owner_name="",
  });

  factory SalesSumarry.fromJson(Map<String, dynamic> parsedJson)
  {
      return SalesSumarry(
          owner_id: parsedJson['owner_id'],
          total: parsedJson['total'],
          count: parsedJson ['count'],
          owner_name: parsedJson ['owner_name']
      );
    }

  static List<SalesSumarry> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return SalesSumarry.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'SalesSumarry {'
        'owner_id:$owner_id, '
        'owner_name:$owner_name, '
        'total:$total, '
        'count:$count }';
  }
}