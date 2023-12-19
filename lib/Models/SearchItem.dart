class SearchItem {
  String id;           // 레코드 ID (모임,회원,사업장)
  String thumnails;    // 썸네일 이미지 (';'로구분)
  String title;        // 타이틀(모임이름,회원이름, 사업장이름)
  String subTitle;     // 설명(모임설명, 회원구분, 사업장설명)
  String extra;        // 추가정보 ...

  SearchItem({
    this.id         = "",
    this.thumnails  = "",
    this.title      = "",
    this.subTitle   = "",
    this.extra      = "",
  });


  factory SearchItem.fromJson(Map<String, dynamic> parsedJson)
  {
    try {
      return SearchItem(
          id: parsedJson['id'],
          thumnails: parsedJson['thumnails'],
          title: parsedJson['title'],
          subTitle: parsedJson['subTitle'],
          extra: parsedJson['extra'],
      );
    }
    catch(e){
      print("fromJson(): Error ======> "+e.toString());
    }
    return SearchItem();
  }

  static List<SearchItem> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return SearchItem.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'SearchItem {'
        'id:$id, '
        'thumnails:$thumnails, '
        'title:$title, '
        'subTitle:$subTitle, '
        'extra:$extra'
        '}';
  }
}