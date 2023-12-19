// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Utils/utils.dart';

class Card2Buttons extends StatelessWidget {
  final Function() onNext;
  final Function() onPrev;
  bool? goNext;
  bool? goPrev;
  Card2Buttons({
    Key? key,
    required this.onNext,
    required this.onPrev,
    this.goNext = true,
    this.goPrev = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size_width = MediaQuery.of(context).size.width * .4;
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Visibility(
              visible: true,
              child: ElevatedButton(
                child: const Text("뒤로가기",
                    style: const TextStyle(fontSize: 14.0, color: Colors.black)),
                style: ElevatedButton.styleFrom(
                    primary: (goPrev!) ? Colors.white : Colors.grey,
                    fixedSize: Size(size_width, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                onPressed: (){
                  if(goPrev!) {
                    onPrev();
                  } },
              )),
          const Spacer(),
          Visibility(
            visible: true,
            child: ElevatedButton(
              child: const Text("다음으로",
                  style: TextStyle(fontSize: 14.0, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                  primary: (goNext!) ? Colors.green : Colors.grey,
                  fixedSize: Size(size_width, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              onPressed: () {
                if(goNext!) {
                  onNext();
                } else {
                  showToastMessage("필수 항목을 입력해주세요.");
                }
                },
            ),
          )
        ],
      ),
    );
  }
}
