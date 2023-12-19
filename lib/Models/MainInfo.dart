class MainInfo {
  String count_mine_moims;       // 개설 모임 수
  String count_active_moims;     // 활동 모임 수
  String count_reservation;      // 예약 건 수
  String count_notify;           // 공지사항 수
  String count_extra;            // 추가정보 ...

  MainInfo({
    this.count_mine_moims        = "0",
    this.count_active_moims      = "0",
    this.count_reservation       = "0",
    this.count_notify            = "0",
    this.count_extra             = "0",
  });

  factory MainInfo.fromJson(Map<String, dynamic> parsedJson)
  {
    try {
      return MainInfo(
          count_mine_moims: parsedJson['count_mine_moims'],
          count_active_moims: parsedJson['count_active_moims'],
          count_reservation: parsedJson['count_reservation'],
          count_notify: parsedJson['count_notify'],
          count_extra: parsedJson['count_extra'],
      );
    }
    catch(e){
      print("fromJson(): Error ======> "+e.toString());
    }
    return MainInfo();
  }

  static List<MainInfo> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return MainInfo.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'MainInfo {'
        'count_mine_moims:$count_mine_moims, '
        'count_active_moims:$count_active_moims, '
        'count_reservation:$count_reservation, '
        'count_notify:$count_notify, '
        'count_extra:$count_extra'
        '}';
  }
}