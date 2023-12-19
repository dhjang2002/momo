// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

class AResult {
  String? result;
  String? message;
  List<dynamic>? list;
  List<dynamic>? head;

  AResult({
    this.result,
    this.message,
    this.list,
    this.head
  });

  factory AResult.fromJson(Map<String, dynamic> parsedJson)
  {
    var list = parsedJson ['list'];
    var head = parsedJson ['head'];

    //print("list=>" + list.toString());
    //print("head=>" + head.toString());

    return AResult(
        result: parsedJson['RESULT'],
        message: parsedJson['MESG'],
        list: (list != null) ? list as List : <dynamic>[],
        head: (head != null) ? head as List : <dynamic>[],
    );
  }

  static List<AResult> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return AResult.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'Result {'
        'result:$result, '
        'message:$message, '
        'head:$head, '
        'list: $list}';
  }

}