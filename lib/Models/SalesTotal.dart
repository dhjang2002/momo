// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print
import 'Model.dart';

class SalesTotal {
  String? total;    // 총금액
  String? count;    // 건수
  SalesTotal({
    this.total="",
    this.count="",
  });

  factory SalesTotal.fromJson(Map<String, dynamic> parsedJson)
  {
      return SalesTotal(
          total: parsedJson['total'],
          count: parsedJson ['count']
      );
    }

  static List<SalesTotal> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return SalesTotal.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'SalesTotal {'
        'total:$total, '
        'count:$count}';
  }
}