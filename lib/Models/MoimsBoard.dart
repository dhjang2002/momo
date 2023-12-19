// ignore_for_file: unnecessary_const, non_constant_wr_identifier_names, avowr_id_print

class MoimsBoard{
  String? wr_id;          // 레코드번호 wr_id , 게시글 링크: https://momo.maxwr_idc.net/bbs/board_app.php?bo_table=moim&wr_id=27
  String? moims_id;       // moim id
  String? wr_subject;     // 제목
  String? wr_content;     // 내용
  String? push;           // push 알림여부
  String? wr_datetime;    // 작성일시
  String? wr_last;        // 변경시각

  MoimsBoard({
    this.wr_id="",
    this.moims_id="",
    this.wr_subject="",
    this.wr_content="",
    this.push = "",
    this.wr_datetime="",
    this.wr_last="",
  });

  factory MoimsBoard.fromJson(Map<String, dynamic> parsedJson)
  {
      return MoimsBoard(
        wr_id: parsedJson['wr_id'],
          moims_id: parsedJson ['moims_id'],
          wr_subject: parsedJson ['wr_subject'],
          wr_content: parsedJson ['wr_content'],
          push: parsedJson ['push'],
          wr_datetime: parsedJson ['wr_datetime'],
          wr_last: parsedJson ['wr_last']
      );
    }

  static List<MoimsBoard> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return MoimsBoard.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'Board {wr_id:$wr_id, '
        'moims_id:$moims_id, '
        'wr_subject:$wr_subject, '
        'wr_content:$wr_content, '
        'push:$push, '
        'wr_datetime:$wr_datetime, '
        'wr_last:$wr_last}';
  }
  
  Map<String, String> toAddMap() => {
    'wr_id': wr_id.toString(),
    'moims_id': moims_id.toString(),
  };
}