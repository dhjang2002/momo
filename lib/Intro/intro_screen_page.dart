
import 'package:flutter/material.dart';
import 'package:momo/Provider/LoginInfo.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';
import 'package:provider/provider.dart';

class IntroScreenPage extends StatefulWidget {
  const IntroScreenPage({Key? key,}) : super(key: key);

  @override
  _IntroScreenPageState createState() => _IntroScreenPageState();
}

class _IntroScreenPageState extends State<IntroScreenPage> {
  final List<String> pageList = <String>[
    "bg_01.jpg",
    "bg_02.jpg",
    "bg_03.jpg",
    "bg_04.jpg"];
  final PageController pageController = PageController(initialPage: 0,);
  final _currentPageNotifier    = ValueNotifier<int>(0);

  bool isLast     = false;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    color: Colors.white,
                    child: SafeArea(
                      child: PageView.builder(
                          scrollDirection: Axis.horizontal,
                          controller: pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPageNotifier.value = index;
                              isLast = (index>=pageList.length-1) ? true : false;
                            });
                          },
                          itemCount: pageList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String imageName = pageList[index];
                            return Center(
                                child: Container(
                                    decoration: BoxDecoration(
                                        image:DecorationImage(
                                            image: AssetImage("assets/intro/$imageName"),
                                            fit: BoxFit.fitHeight)))
                            );
                          }
                      ),
                    ),
                  ),
                ),

                SafeArea(child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    height: 150,
                    child: CirclePageIndicator(
                      itemCount: pageList.length,
                      dotColor: Colors.black,
                      selectedDotColor: Colors.red,
                      currentPageNotifier: _currentPageNotifier,
                    ),
                  ),
                ),),
                Visibility(
                  visible: isLast,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                      height: 62,
                      child: GestureDetector(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(20,0,20,0),
                          //padding: const EdgeInsets.fromLTRB(0,20,0,20),
                          child: const Center(child:Text('시작하기', style: TextStyle(color:Colors.white, fontSize:15.0))),
                          decoration:  BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                        ),
                        onTap: () async {
                          var loginInfo = Provider.of<LoginInfo>(context, listen:false);
                          loginInfo.skip_intro = "Y";
                          await loginInfo.setPref();

                          print("IntroScreenPage::onTap()::_loginInfo="+loginInfo.toString());

                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                )
              ],
            ))
    );
  }

  Future <bool> onWillPop() async {
    return false; // true will exit the app
  }
}
