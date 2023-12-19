// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';

class TileCard extends StatelessWidget {
  final Widget title;
  final Color? color;
  EdgeInsetsGeometry? padding;
  Widget? subtitle;
  Widget? leading;
  Widget? tailing;
  Function()? onTab;
  Function()? onTrailing;

  TileCard({
    Key? key,
    required this.title,
    this.color = Colors.transparent,
    this.subtitle,
    this.leading,
    this.tailing,
    this.onTab,
    this.onTrailing,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          color: color,
          padding: (padding != null) ? padding : EdgeInsets.all(5),
          child: Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Visibility(
                    visible: (leading != null),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                      child: leading,
                    )),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: (leading == null)
                        ? const EdgeInsets.only(left: 5)
                        : const EdgeInsets.only(left: 1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        title,
                        Visibility(
                          visible: (subtitle != null),
                          child: const SizedBox(height: 3),
                        ),
                        Visibility(
                            visible: (subtitle != null),
                            child: Container(
                              child: subtitle,
                            )),
                      ],
                    ),
                  ),
                ),
                Visibility(
                    visible: (tailing != null),
                    child: GestureDetector(
                        onTap: () => onTrailing!(),
                        child: Container(
                          color: Colors.transparent,
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: tailing,
                        ))),
              ],
            ),
          ),),
      onTap: () => (onTab != null) ? onTab!() : () {},
    );
  }
}
