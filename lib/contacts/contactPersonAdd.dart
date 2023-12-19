import 'package:flutter/material.dart';
import 'package:momo/Models/contactItem.dart';
import 'package:momo/Models/contactPerson.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/utils.dart';

class ContactPersonAdd extends StatefulWidget {
  final String usersID;
  final String personID;
  final String personName;
  final String personMobile;
  const ContactPersonAdd({
    Key? key,
    required this.usersID,
    required this.personID,
    required this.personName,
    required this.personMobile,
  }) : super(key: key);

  @override
  State<ContactPersonAdd> createState() => _ContactPersonAddState();
}

class _ContactPersonAddState extends State<ContactPersonAdd> {
  late ContactPerson person;
  bool isReady = false;

  @override
  void initState() {
    person = ContactPerson(id:widget.personID, name: widget.personName, phone: widget.personMobile );
    Future.microtask((){
      createData();
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("인맥추가"),
      ),
      body: (isReady) ? _buildBody() : Container(),
    );
  }

  Future <void> createData() async {
    if(person.id!.isEmpty) {
      if (person.name!.isEmpty || person.phone!.isEmpty) {
        newContactKeyDialog(
            context:context,
            personName: widget.personName,
            personPhone: widget.personMobile,
            onResult: (bool status, String personName, String personMobile) {
              if(status) {
                newPerson(widget.usersID.toString(), personName, personMobile);
              }
              else {
                Navigator.pop(context);
              }
            });
      }
      else {
        newPerson(widget.usersID.toString(), widget.personName, widget.personMobile);
      }
    }
    else{
      getPerson(widget.personID);
    }
  }

  Future <void> newPerson(String usersId, String personName, String personMobil) async {
    await Remote.reqContactPerson(
        params: {
          "command":"ADD",
          "users_id":usersId,
          "name":personName,
          "phone":personMobil
        },
        onResponse: (bool status, String result) {
          if(status) {
            getPerson(result);
          }
          else {
            showToastMessage(result);
          }
        }
    );
  }

  Future <void> updatePerson() async {
    Map<String,String> params = person.toAddMap();
    params.addAll({"command":"UPDATE"});
    await Remote.reqContactPerson(
        params: params,
        onResponse: (bool status, String result) {
          if(status) {
            getPerson(result);
          }
          else {
            showToastMessage(result);
          }
        }
    );
  }

  Future <void> getPerson(String personID) async {
      await Remote.getContactPerson(
          params: {
            "command":"INFO",
            "id":personID
          },
          onResponse: (List <ContactPerson> list) {
            setState(() {
              person = list[0];
            });
          }
      );
  }

  Widget _buildBody() {
    return Container();
  }

  void newContactKeyDialog({
    required BuildContext context,
    required String personName,
    required String personPhone,
    required Function(bool status, String personName, String personPhone) onResult}) {
    TextEditingController v1Controller = TextEditingController();
    TextEditingController v2Controller = TextEditingController();
    v1Controller.text = personName;
    v2Controller.text = personPhone;
    showDialog (
      context: context,
      barrierDismissible: false, //다이얼로그 바깥을 터치 시에 닫히도록 하는지 여부 (true: 닫힘, false: 닫히지않음)
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text("인맥추가"),
            actions: <Widget>[
              TextButton(
                child: Text('취소', style: TextStyle(fontSize: 18)),
                style: TextButton.styleFrom(primary: Colors.redAccent, backgroundColor:Colors.white),
                onPressed: () {
                  onResult(false, "", "");
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('추가', style: TextStyle(fontSize: 18)),
                style: TextButton.styleFrom(primary: Colors.green, backgroundColor:Colors.white),
                onPressed: () {
                  onResult(true, v1Controller.text.trim(), v2Controller.text.trim());
                  Navigator.pop(context);
                },
              ),
            ],
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                    height:  160,
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            //padding: EdgeInsets.only(top: 5),
                            child: TextField(
                              controller: v1Controller,
                              maxLines: 1,
                              onChanged: (value){
                              },
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.normal),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.fromLTRB(
                                    20, 15, 20, 15),
                                isDense: true,
                                hintText: "이름",
                                hintStyle: const TextStyle(color: Color(0xffcbc9d9)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                  const BorderRadius.all(const Radius.circular(10)),
                                  borderSide: BorderSide(
                                      width: 1, color: Colors.grey.shade200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  borderSide: BorderSide(
                                      width: 1, color: Colors.grey.shade200),
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius:
                                  const BorderRadius.all(const Radius.circular(10)),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: true,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(top: 10),
                              child: TextField(
                                controller: v2Controller,
                                maxLines: 1,
                                onChanged: (value){
                                },
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.normal),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.fromLTRB(
                                      20, 15, 20, 15),
                                  isDense: true,
                                  hintText: "휴대폰",
                                  hintStyle: const TextStyle(
                                      color: Color(0xffcbc9d9)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                    const BorderRadius.all(const Radius.circular(10)),
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.grey.shade200),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.grey.shade200),
                                  ),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                    const BorderRadius.all(const Radius.circular(10)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //SizedBox(height: 20,),
                        ],
                      ),
                    ));
              },
            ),
          ),
        );
      },
    );
  }

  /*
      ContactItem item = ContactItem(item:"휴대폰", kind:"개인", value: "010-2001-0937");
    editContactItemDialog(context: context, isAddr:false, item: item, kindList:contact_contact_kind,
        onResult: (bool bdirty, ContactItem item) {
          if(bdirty) {
            print(item.toString());
          }
        });
   */
  void editContactItemDialog({
    required BuildContext context,
    required bool isAddr,
    required ContactItem item,
    required List<String> kindList,
    required Function(bool bDirty, ContactItem item) onResult}) {

    TextEditingController v1Controller = TextEditingController();
    TextEditingController v2Controller = TextEditingController();
    v1Controller.text = item.value.toString();
    v2Controller.text = item.value_ext.toString();
    String _selectValue = item.kind.toString();
    bool bDirty = false;
    showDialog (
      context: context,
      barrierDismissible: false, //다이얼로그 바깥을 터치 시에 닫히도록 하는지 여부 (true: 닫힘, false: 닫히지않음)
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(item.item.toString()),
            actions: <Widget>[
              TextButton(
                child: Text('취소', style: TextStyle(fontSize: 18)),
                style: TextButton.styleFrom(primary: Colors.redAccent, backgroundColor:Colors.white),
                onPressed: () {
                  // v1Controller.dispose();
                  // v2Controller.dispose();
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('확인', style: TextStyle(fontSize: 18)),
                style: TextButton.styleFrom(primary: Colors.green, backgroundColor:Colors.white),
                onPressed: () {
                  onResult(bDirty, item);
                  // v1Controller.dispose();
                  // v2Controller.dispose();
                  Navigator.pop(context);
                },
              ),
            ],
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                    height: (isAddr)? 200 : 140,
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.maxFinite,
                            alignment: Alignment.centerLeft,
                            child: DropdownButton(
                              style: TextStyle(color: Colors.blueAccent,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal),
                              //dropdownColor:Colors.green,
                              value: _selectValue,
                              //items:menuItems,
                              items: kindList.map((String value) {
                                return new DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _selectValue = value.toString();
                                  item.kind = _selectValue;
                                  bDirty = true;
                                  //print("_selectValue=$_selectValue");
                                });
                              },
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            //padding: EdgeInsets.only(top: 5),
                            child: TextField(
                              controller: v1Controller,
                              maxLines: 1,
                              onChanged: (value){
                                item.value = value.trim();
                                bDirty = true;
                              },
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.normal),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.fromLTRB(
                                    20, 15, 20, 15),
                                isDense: true,
                                hintText: item.item,
                                hintStyle: const TextStyle(color: Color(0xffcbc9d9)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                  const BorderRadius.all(const Radius.circular(10)),
                                  borderSide: BorderSide(
                                      width: 1, color: Colors.grey.shade200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  borderSide: BorderSide(
                                      width: 1, color: Colors.grey.shade200),
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius:
                                  const BorderRadius.all(const Radius.circular(10)),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isAddr,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(top: 10),
                              child: TextField(
                                controller: v2Controller,
                                maxLines: 1,
                                onChanged: (value){
                                  item.value_ext = value.trim();
                                  bDirty = true;
                                },
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.normal),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.fromLTRB(
                                      20, 15, 20, 15),
                                  isDense: true,
                                  hintText: "상세주소",
                                  hintStyle: const TextStyle(
                                      color: Color(0xffcbc9d9)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                    const BorderRadius.all(const Radius.circular(10)),
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.grey.shade200),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.grey.shade200),
                                  ),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                    const BorderRadius.all(const Radius.circular(10)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //SizedBox(height: 20,),
                        ],
                      ),
                    ));
              },
            ),
          ),
        );
      },
    );

  }
}
