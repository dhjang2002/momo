import 'package:flutter/material.dart';

class ContactHome extends StatefulWidget {
  const ContactHome({Key? key}) : super(key: key);

  @override
  State<ContactHome> createState() => _ContactHomeState();
}

class _ContactHomeState extends State<ContactHome> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("인맥관리 홈"));
  }
}
