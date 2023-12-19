// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Utils/DateForm.dart';
import 'package:momo/Utils/utils.dart';

class ChatBubble extends StatelessWidget {
  final bool isMe;
  final Function(String usersId) onUser;
  final Function(String mesgId) onSelect;
  final String id;
  final String usersID;
  final String nickname;
  final String thumnail;
  final String message;
  final String create_at;
  const ChatBubble({Key? key,
        required this.isMe,
        required this.id,
        required this.nickname,
        required this.message,
        required this.create_at,
        required this.thumnail,
        required this.usersID,
        required this.onSelect,
        required this.onUser
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String url = URL_HOME + thumnail;
    final sz_mesg = MediaQuery.of(context).size.width*0.85;
    final double mz_width = sz_mesg*0.75;
    return Container(
        padding: const EdgeInsets.only(top: 15),
        //width: sz_width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            // user info
            Visibility(
                visible: !isMe,
                child: SizedBox(
                    height: 34, width: 34,
                    child: GestureDetector(
                        onTap: () {
                          onUser(usersID);
                        },
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: simpleBlurImageWithName(
                                nickname, 28, url, 1.0))))),

            SizedBox(
                width: sz_mesg,
                  child: Container(
                    margin: const EdgeInsets.only(left:8),
                    //color: Colors.green,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // nickname
                        Visibility(
                          visible: !isMe,
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(nickname, style: const TextStyle(fontSize: 12))),
                        ),

                        // message
                        _renderMessage(mz_width),
                      ],
                    )
                  )
              ),
          ],
        ));
  }

  Widget _renderMessage(final double mz_width) {
    //final double mz_width = 190;
    String stamp = DateForm().parse(create_at).chatStamp();
    if(isMe) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // stamp
          Container(
              padding: const EdgeInsets.only(right: 10),
              child: Text(stamp, style: const TextStyle(fontSize: 10))
          ),

          // message
          SizedBox(
            width: mz_width,
            child: GestureDetector(
                onLongPress: (){
                  onSelect(id);
                },
                child:Container(
                  margin: const EdgeInsets.only(top: 5),
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerRight,
                  decoration: const BoxDecoration(
                      color: Colors.yellowAccent,
                      borderRadius: BorderRadius.only(
                          topLeft:Radius.circular(8),
                          topRight: Radius.circular(0),
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8))
                  ),
                  child: Text(message,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal)
                  ),
                )
            ),
          ),
        ],
      );
    }

    else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // message
          SizedBox(
            width: mz_width,
            child: Container(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  )),
              child: Text(message,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal)
              ),
            ),
          ),

          // stamp
          Container(
              padding: const EdgeInsets.only( left: 10),
              child: Text(stamp, style: const TextStyle(fontSize: 10))
          ),
        ],
      );
    }
  }
}
