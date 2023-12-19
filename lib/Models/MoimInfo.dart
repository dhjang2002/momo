class MoimInfo {
  String count_members;       // 전체 회원수
  String count_shops;         // 전체 사업장 수
  String total_sales_count;   // 판매건수
  String total_sales_price;   // 판매금액
  String extra;               // 추가정보 ...

  MoimInfo({
    this.count_members        = "0",
    this.count_shops          = "0",
    this.total_sales_count    = "0",
    this.total_sales_price    = "0",
    this.extra                = "",
  });

  factory MoimInfo.fromJson(Map<String, dynamic> parsedJson)
  {
    try {
      return MoimInfo(
          count_members: parsedJson['count_members'],
          count_shops: parsedJson['count_shops'],
          total_sales_count: parsedJson['total_sales_count'],
          total_sales_price: parsedJson['total_sales_price'],
          extra: parsedJson['extra'],
      );
    }
    catch(e){
      print("fromJson(): Error ======> "+e.toString());
    }
    return MoimInfo();
  }

  static List<MoimInfo> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return MoimInfo.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'MoimInfo {'
        'count_members:$count_members, '
        'count_shops:$count_shops, '
        'total_sales_count:$total_sales_count, '
        'total_sales_price:$total_sales_price, '
        'extra:$extra'
        '}';
  }
}