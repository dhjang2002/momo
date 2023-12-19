// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

class ShopEvent{
  String? id;            // 레코드번호
  String? users_id;      // 사용자 id: mb_no
  String? shops_id;      // shop id
  String? template_id;     // 고객이름
  String? event_title;       // 쿠폰사용

  String? event_content;
  String? event_start;
  String? event_stop;
  String? event_url;

  String? created_at;    // 방문일시
  String? updated_at;    // 변경시각

  ShopEvent({
    this.id="",
    this.users_id="",
    this.shops_id="",
    this.template_id="",
    this.event_title="",
    this.event_content="",
    this.event_start="",
    this.event_stop="",
    this.event_url="",
    this.created_at="",
    this.updated_at="",
  });

  factory ShopEvent.fromJson(Map<String, dynamic> parsedJson)
  {
      return ShopEvent(
        id: parsedJson['id'],
          users_id: parsedJson['users_id'],
          shops_id: parsedJson ['shops_id'],
          template_id: parsedJson ['template_id'],
          event_title: parsedJson ['event_title'],
          event_content: parsedJson ['event_content'],
          event_start: parsedJson ['event_start'],
          event_stop: parsedJson ['event_stop'],
          event_url: parsedJson ['event_url'],
          created_at: parsedJson ['created_at'],
          updated_at: parsedJson ['updated_at']
      );
    }

  static List<ShopEvent> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return ShopEvent.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'ShopEvent {id:$id, '
        'users_id:$users_id, '
        'shops_id:$shops_id, '
        'event_content:$event_content, '
        'template_id:$template_id, '
        'event_title:$event_title, '
        'created_at:$created_at, '
        'updated_at:$updated_at}';
  }

}