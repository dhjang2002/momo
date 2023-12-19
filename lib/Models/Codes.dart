class Codes {
  String? id;        // 사용자 번호:  '2'
  String? name;     // 사용자 레벨:  '2:일반사용자, 10:관리자'

  bool selected = false;
  Codes({this.id, this.name});

  factory Codes.fromJson(Map<String, dynamic> parsedJson)
  {
      return Codes(
          id: parsedJson['id'],
          name: parsedJson['name']
      );
  }

  static List<Codes> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return Codes.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'Codes {id:$id, name:$name}';
  }
}