class ChatItem {
  bool? isMe;
  String? id;
  String? users_id;
  String? thumnail;
  String? nickname;
  String? message;
  String? created_at;

  ChatItem({
    this.isMe = false,
    this.id = "",
    this.users_id = "",
    this.nickname = "",
    this.thumnail = "",
    this.message = "",
    this.created_at = ""
  });

  factory ChatItem.fromJson(Map<String, dynamic> parsedJson)
  {
    return ChatItem(
        id: parsedJson['id'],
        users_id: parsedJson['users_id'],
        nickname: parsedJson['nickname'],
        thumnail: parsedJson['thumnail'],
        message: parsedJson['message'],
        created_at: parsedJson['created_at']
    );
  }

  @override
  String toString(){
    return 'Codes {'
        'id:$id, '
        'users_id:$users_id, '
        'nickName:$nickname, '
        'thumnail:$thumnail, '
        'message:$message, '
        'created_at:$created_at}';
  }
}