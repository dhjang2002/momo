import 'package:contacts_service/contacts_service.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:momo/Constants/Constants.dart';
import 'package:momo/Controller/ColtrollerStatusChange.dart';
import 'package:momo/contacts/contactHome.dart';
import 'package:momo/Models/contactPerson.dart';
import 'package:momo/contacts/contactList.dart';
import 'package:momo/contacts/contactPersonAdd.dart';
import 'package:momo/contacts/contactPersonInfo.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:transition/transition.dart';

class ContactMain extends StatefulWidget {
  final String usersId;
  const ContactMain({Key? key, required this.usersId}) : super(key: key);

  @override
  State<ContactMain> createState() => _ContactMainState();
}

class _ContactMainState extends State<ContactMain>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FabCircularMenuState> _fabKey = GlobalKey();
  late final List<ControllerStatusChange> _pageController;
  late final _tabController = TabController(length: 5, vsync: this);
  bool _bItit = false;
  bool _waiting = false;
  bool _bSearch = false;
  bool _hasNotify = false;
  int _tabIndex = 0;

  @override
  void initState() {
    _pageController = [
      ControllerStatusChange(),
      ControllerStatusChange(),
      ControllerStatusChange(),
      ControllerStatusChange(),
      ControllerStatusChange(),
    ];
    setState(() {
      _bItit = true;
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0.3,
        title: Row(children: [
          Image.asset("assets/icon/icon_sign_in.png",
              height: 30, fit: BoxFit.fitHeight),
          const SizedBox(width: 10),
          const Text(
            "인맥관리",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ]),
        actions: [
          // 검색
          Visibility(
            visible: (_bSearch && _tabIndex != 0),
            child: IconButton(
                icon: const Icon(Icons.search, size: 26),
                onPressed: () {
                  setState(() {
                    //_onSearch(target);
                  });
                }),
          ),

          // 알림
          Visibility(
            visible: (_tabIndex == 0), //(_m_isSigned && _bSearch),
            child: IconButton(
                icon: const Icon(Icons.notifications_active,
                    size: 20, color: Colors.redAccent),
                onPressed: () {
                  _addContact();
                  //_userBoard();
                }),
          ),
        ],
        // bottom: TabBar(
        //   controller: _tabController,
        //   isScrollable: false,
        //   labelColor: Colors.black,
        //   onTap: (int index) {
        //     // if(_tabIndex==index)
        //     //   return;
        //
        //     setState(() {
        //       _tabIndex = index;
        //     });
        //   },
        //   tabs: <Widget>[
        //     Container(
        //       height: 44,
        //       alignment: Alignment.center,
        //       child:
        //           Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        //         Icon(
        //           Icons.contact_mail,
        //           size: 16,
        //         ),
        //         SizedBox(width: 5),
        //         Text(contact_category_display[0])
        //       ]),
        //     ),
        //     Container(
        //       height: 44,
        //       child:
        //           Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        //         Icon(
        //           Icons.business_center,
        //           size: 16,
        //         ),
        //         SizedBox(width: 5),
        //         Text(contact_category_display[1])
        //       ]),
        //     ),
        //     Container(
        //       height: 44,
        //       child:
        //           Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        //         Icon(
        //           Icons.favorite,
        //           size: 16,
        //         ),
        //         SizedBox(width: 5),
        //         Text(contact_category_display[2])
        //       ]),
        //     ),
        //     Container(
        //       height: 44,
        //       child:
        //           Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        //         Icon(
        //           Icons.people,
        //           size: 16,
        //         ),
        //         SizedBox(width: 5),
        //         Text(contact_category_display[3])
        //       ]),
        //     ),
        //   ],
        // ),
      ),
      body: WillPopScope(
        onWillPop: onWillPop,
        child: (_bItit) ? TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const ContactHome(),
            ContactList(
                usersId: widget.usersId,
                controller: _pageController[1],
                category: contact_category_item[0],
                onTap: (ContactPerson info) {
                  _showContact(info.id.toString());
                }),
            ContactList(
                usersId: widget.usersId,
                controller: _pageController[2],
                category: contact_category_item[1],
                onTap: (ContactPerson info) {
                  _showContact(info.id.toString());
                }),
            ContactList(
                usersId: widget.usersId,
                controller: _pageController[3],
                category: contact_category_item[2],
                onTap: (ContactPerson info) {
                  _showContact(info.id.toString());
                }),
            ContactList(
                usersId: widget.usersId,
                controller: _pageController[4],
                category: contact_category_item[3],
                onTap: (ContactPerson info) {
                  _showContact(info.id.toString());
                }),
          ],
        ) : Container(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black,
        selectedFontSize: 14,
        unselectedFontSize: 11,

        onTap: (int index) {
          if (_tabIndex == index) {
            return;
          }

          _tabIndex = index;
          _tabController.animateTo(_tabIndex,
              duration: const Duration(milliseconds: 200), curve: Curves.ease);
          _pageController[_tabIndex].Invalidate();

          setState(() {
            _bSearch = (_tabIndex > 0) ? true : false;
          });
        },

        currentIndex: _tabIndex, //_selectedIndex, //현재 선택된 Index
        items: [
          BottomNavigationBarItem(
              label: '홈',
              icon: Image.asset(
                "assets/icon/main_bot_home.png",
                width: (_tabIndex == 0) ? 28 : 28,
                height: (_tabIndex == 0) ? 28 : 28,
                color: (_tabIndex == 0) ? Colors.green : Colors.black,
              )),
          BottomNavigationBarItem(
              label: contact_category_display[0],
              icon: Image.asset(
                "assets/icon/main_bot_map.png",
                width: (_tabIndex == 1) ? 28 : 28,
                height: (_tabIndex == 1) ? 28 : 28,
                color: (_tabIndex == 1) ? Colors.green : Colors.black,
              )),
          BottomNavigationBarItem(
              label: contact_category_display[1],
              icon: Image.asset(
                "assets/icon/main_bot_create.png",
                width: (_tabIndex == 2) ? 28 : 28,
                height: (_tabIndex == 2) ? 28 : 28,
                color: (_tabIndex == 2) ? Colors.green : Colors.black,
              )),
          BottomNavigationBarItem(
              label: contact_category_display[2],
              icon: Image.asset(
                "assets/icon/main_bot_search.png",
                width: (_tabIndex == 3) ? 28 : 28,
                height: (_tabIndex == 3) ? 28 : 28,
                color: (_tabIndex == 3) ? Colors.green : Colors.black,
              )),
          BottomNavigationBarItem(
              label: contact_category_display[3],
              icon: Image.asset(
                "assets/icon/main_bot_user.png",
                width: (_tabIndex == 4) ? 28 : 28,
                height: (_tabIndex == 4) ? 28 : 28,
                color: (_tabIndex == 4) ? Colors.green : Colors.black,
              )),
        ],
      ),
      floatingActionButton: Visibility(
          visible: (_tabIndex != 0), child: _renderFabCircularButton()),
    );
  }

  Widget _renderFabCircularButton() {
    return FabCircularMenu(
      key: _fabKey,
      alignment: Alignment.bottomRight,
      ringColor: Colors.grey.withAlpha(15),
      ringDiameter: 300.0,
      ringWidth: 100.0,
      fabSize: 56.0,
      fabElevation: 8.0,
      fabIconBorder: const CircleBorder(),
      // Also can use specific color based on wether
      // the menu is open or not:
      // fabOpenColor: Colors.white
      // fabCloseColor: Colors.white
      // These properties take precedence over fabColor
      fabColor: Colors.redAccent,
      fabOpenIcon: const Icon(Icons.add, size: 32, color: Colors.white),
      fabCloseIcon:
          const Icon(Icons.arrow_drop_down, size: 32, color: Colors.white),
      fabMargin: const EdgeInsets.all(15.0),
      animationDuration: const Duration(milliseconds: 300),
      animationCurve: Curves.easeInOutCirc,
      onDisplayChange: (isOpen) {},
      children: <Widget>[
        RawMaterialButton(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(8.0),
          child: Image.asset("assets/icon/member_ring_user_list.png",
              width: 44, height: 44, color: Colors.white),
          fillColor: Colors.orangeAccent,
          onPressed: () async {
            _fabKey.currentState!.close();
            _selectContact();
            // if (!_isListMode) {
            //   setState(() {
            //     _isListMode = true;
            //   });
            //   await Future.delayed(const Duration(milliseconds: 50));
            //   _pageController[1].Invalidate();
            // }
          },
        ),
        RawMaterialButton(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(8.0),
          fillColor: Colors.green,
          child: Image.asset("assets/icon/member_ring_users.png",
              width: 44, height: 44, color: Colors.white),
          onPressed: () async {
            //_fabKey.currentState!.close();
            Future.microtask(() {
              _selectContact();
            });
          },
        ),
      ],
    );
  }

  Future<void> _traceContact() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      _getContact();
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<void> _selectContact() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      _getDeviceContact();
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      const snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      const snackBar =
          SnackBar(content: Text('contacts data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _getContact() async {
    setState(() {
      _waiting = true;
    });

    await ContactsService.getContacts(withThumbnails: true).then((value) {
      setState(() {
        //contacts = value;
        _waiting = false;
      });
    });
  }

  Future<void> _getDeviceContact() async {
    setState(() {
      _waiting = true;
    });

    Contact? person = await ContactsService.openDeviceContactPicker();
    setState(() {
      if (person != null) {
        //contacts.add(value);
      }
      _waiting = false;
    });
  }

  Future<void> _getMoimContact() async {
    setState(() {
      _waiting = true;
    });

    Contact? person = await ContactsService.openDeviceContactPicker();
    setState(() {
      if (person != null) {
        //contacts.add(value);
      }
      _waiting = false;
    });
  }

  Future <void> _addContact() async {
    var result = await Navigator.push(
      context,
      Transition(
        child: ContactPersonAdd(
          usersID: widget.usersId,
          personID: '',
          personMobile: '',
          personName: '',
        ),
        transitionEffect: TransitionEffect.RIGHT_TO_LEFT,
      ),
    );
    _pageController[_tabIndex].Invalidate();
  }

  Future <void> _showContact(String personID) async {
    var result = await Navigator.push(
      context,
      Transition(
        child: ContactPersonInfo(
          usersID: widget.usersId,
          personID: personID,
        ),
        transitionEffect: TransitionEffect.RIGHT_TO_LEFT,
      ),
    );
    _pageController[_tabIndex].Invalidate();
  }

  // backKey event 처리
  Future<bool> onWillPop() async {
    if (_fabKey.currentState != null && _fabKey.currentState!.isOpen) {
      _fabKey.currentState!.close();
      return false;
    }

    if (_tabIndex != 0) {
      setState(() {
        _tabIndex = 0;
        _tabController.animateTo(_tabIndex,
            duration: const Duration(milliseconds: 200), curve: Curves.ease);
      });
      return false;
    }
    return true; // true will exit the app
  }
}
