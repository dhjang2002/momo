class PageInfo {
  bool valid;
  int record_total;        // 레코드 갯수
  int page_size;           // 페이지 크기(페이지당 출력 레코드 수)
  int page_count;          // 페이지 수
  int page_no;             // 페이지 번호 (0,1,...)

  PageInfo({
    this.valid = false,
    this.record_total = 0,
    this.page_size    = 0,
    this.page_count   = 0,
    this.page_no      = 0,
  });

  bool setNext() {
    if(page_no+1<page_count){
      page_no++;
      return true;
    }
    return false;
  }

  @override
  Map<String, String> toMap() => {
    'record_total': record_total.toString(),
    'page_size': page_size.toString(),
    'page_count': page_count.toString(),
    'page_no': page_no.toString()
  };

  factory PageInfo.fromJson(Map<String, dynamic> jMap)
  {
    //print("PageInfo::jMap=" + jMap.toString());
    try {
      return PageInfo(
          valid: true,
          record_total: int.parse(jMap['record_total']),
          page_size: int.parse(jMap['page_size']),
          page_count: int.parse(jMap['page_count']),
          page_no: int.parse(jMap['page_no']),
      );
    }
    catch(e){
      print("fromJson(): Error ======> "+e.toString());
    }
    return PageInfo();
  }

  static List<PageInfo> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return PageInfo.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'PageInfo {'
        'valid:$valid, '
        'record_total:$record_total, '
        'page_size:$page_size, '
        'page_count:$page_count, '
        'page_no:$page_no'
        '}';
  }
}