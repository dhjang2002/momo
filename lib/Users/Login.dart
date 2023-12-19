// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:momo/Remote/HostInfo.dart';
import 'package:momo/Models/Person.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:momo/Remote/Remote.dart';
import 'package:momo/Utils/utils.dart';
import 'package:momo/Webview/WebExplorer.dart';
import 'package:provider/provider.dart';
import 'package:transition/transition.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late LoginInfo loginInfo;
  TextEditingController idsController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  bool _isChecked = false;
  @override
  void initState() {
    loginInfo = Provider.of<LoginInfo>(context, listen:false);
    setState(() {
      _isChecked = (loginInfo.auto_login == "Y") ? true : false;
      idsController.text = loginInfo.uid!;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext ctx) {
    const double radious = 10.0;
    return Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: WillPopScope(
        onWillPop: () => _onBackPressed(context),
        child: GestureDetector(
            onTap: () { FocusScope.of(context).unfocus();},
            child: Stack(
              alignment: Alignment.center,
            children: [
              // background image
              Positioned.fill(child: Image.asset("assets/images/login_bg.jpg", fit: BoxFit.cover)),
              Positioned(
                top: 40,
                child: Container(
                  color: Colors.transparent,
                  width: MediaQuery.of(context).size.width-20,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SingleChildScrollView(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget> [

                      // logo
                      SizedBox(
                          width: 180,
                          child: Image.asset("assets/images/logo_white.png", fit: BoxFit.fitWidth)),

                      // ids
                      const SizedBox(height: 30.0),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextField(
                          controller: idsController,
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.fromLTRB(20,15,20,15),
                              isDense: true,
                              hintText: 'ID 입력',
                              hintStyle: const TextStyle(color: Color(0xffcbc9d9)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                const BorderRadius.all(const Radius.circular(radious)),
                                borderSide: BorderSide(width: 1, color: Colors.grey.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(radious)),
                                borderSide: BorderSide(width: 1, color: Colors.grey.shade200),
                              ),
                              border: const OutlineInputBorder(
                                borderRadius:
                                const BorderRadius.all(const Radius.circular(radious)),
                              ),
                              /*
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  idsController.text = "";
                                },
                              )
                               */
                          ),
                        ),
                      ),

                      // pwd
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextField(
                          obscureText: true,
                          controller: pwdController,
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.go,
                          onSubmitted: (value) {
                            //print("search");
                            doLogin();
                          },
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.fromLTRB(20,15,20,15),
                              isDense: true,
                              hintText: '비밀번호',
                              hintStyle: const TextStyle(color: Color(0xffcbc9d9)),//Colors.green),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                const BorderRadius.all(const Radius.circular(radious)),
                                borderSide: BorderSide(width: 1, color: Colors.grey.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(radious)),
                                borderSide: BorderSide(width: 1, color: Colors.grey.shade200),
                              ),
                              border: const OutlineInputBorder(
                                borderRadius:
                                const BorderRadius.all(const Radius.circular(radious)),
                              ),
                              /*
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  pwdController.text = "";
                                },
                              )
                              */
                          ),
                        ),
                      ),

                      // auto login
                      //const SizedBox(height: 2.0),
                      SizedBox(
                        child: Row(
                          children: [
                            const Spacer(),
                            const Text('자동 로그인', style: TextStyle(color: Colors.white, fontSize: 15)),
                            Switch(
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: Colors.grey,
                              activeTrackColor: Colors.green,
                              activeColor: Colors.greenAccent,
                              value: _isChecked,
                              onChanged: (value) {
                                setState(() {
                                  _isChecked = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      // 로그인 버튼
                      const SizedBox(height: 20.0),
                      GestureDetector(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(15,0,15,0),
                          padding: const EdgeInsets.fromLTRB(0,20,0,20),
                          child: const Center(child:Text('로그인', style: const TextStyle(color:Colors.white, fontSize:15.0))),
                          decoration:  BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(radious)
                          ),
                        ),
                        onTap: (){
                          doLogin();
                        },
                      ),

                      // 회원가입
                      //const SizedBox(height: 10.0),
                      TextButton(
                        style: TextButton.styleFrom(primary: Colors.white,),
                        child: Row(
                            children: const [
                              Spacer(),
                              Text('회원이 아니신가요?  ', style: TextStyle(color:Colors.grey, fontSize:15.0)),
                              Text('회원가입', style: TextStyle(color:Colors.white, fontSize:14.0, fontWeight: FontWeight.bold)),
                              Spacer(),
                            ]
                        ),
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          Navigator.push(
                            context,
                            Transition(
                                child: WebExplorer(
                                    title: '회원가입',
                                    supportZoom: false,
                                    website: "$URL_HOME/bbs/register2.php"),
                                // "https://momo.maxidc.net"),/
                                transitionEffect:
                                TransitionEffect.RIGHT_TO_LEFT),
                          );
                        },
                      ),
                      TextButton(
                        style: TextButton.styleFrom(primary: Colors.white,),
                        child: Row(
                            children: const [
                              Spacer(),
                              //const Text('회원이 아니신가요?  ', style: TextStyle(color:Colors.grey, fontSize:15.0)),
                              Text('비밀번호 찾기', style: TextStyle(color:Colors.white, fontSize:14.0, fontWeight: FontWeight.bold)),
                              Spacer(),
                            ]
                        ),
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          Navigator.push(
                            context,
                            Transition(
                                child: WebExplorer(
                                    title: '비밀번호',
                                    supportZoom: false,
                                    website: "$URL_HOME/bbs/password_lost_app.php"),
                                //https://momo.maxidc.net/bbs/password_lost_app.php
                                transitionEffect:
                                TransitionEffect.RIGHT_TO_LEFT),
                          );
                        },
                      ),
                      //SizedBox(height: 100),
                    ],
                    ),
                  ),
                ),
              ),
            ],
          ))),
        );
  }

  Future <void> doLogin() async {
    FocusScope.of(context).unfocus();
    if(idsController.text.length<2 ){
      showToastMessage("아이디를 입력해주세요.");
      return;
    }

    if(pwdController.text.length<2){
      showToastMessage("비밀번호를 입력해주세요.");
      return;
    }

    await Remote.login(
        uid: idsController.text,
        pwd: pwdController.text,
        onResponse: (int status, Person person) async {
          if (status==1 && person.mb_id!.isNotEmpty) {
            loginInfo.users_id = person.mb_no;
            loginInfo.uid = person.mb_id;
            loginInfo.pwd = pwdController.text;
            loginInfo.skip_intro = "Y";
            loginInfo.auto_login =
            (_isChecked) ? "Y" : "";
            await loginInfo.setPref();
            Navigator.pop(context, person);
          }
          else if(status==0){
            showToastMessage("아이디, 비밀번호를 확인하세요 !");
          }
          else{
            showToastMessage("네트워크 오류입니다.");
          }
        });
  }
  _onBackPressed(BuildContext context) {
    return Future(() => false);
  }
}
