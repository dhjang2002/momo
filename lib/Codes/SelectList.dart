

import 'package:flutter/material.dart';
import '/Models/Codes.dart';
import '/Remote/Remote.dart';

class SelectList extends StatefulWidget {
  final String title;
  final bool isMulti;
  final int minCheckCount;
  final String category;
  final String moims_id;
  final bool isCodes;
  final List<String> items;
  
  const SelectList({Key? key,
    required this.title,
    required this.category,
    required this.isCodes,
    required this.items, 
    required this.isMulti, 
    required this.minCheckCount,
    required this.moims_id,  }) : super(key: key);

  @override
  _SelectListState createState() => _SelectListState();
}

class _SelectListState extends State<SelectList> {
  TextEditingController idsController = TextEditingController();
  bool bSearch = false;
  bool bLoaded = true;
  bool bSelectOk = false;
  late List<bool> m_bCheck;
  
  @override
  void initState() {
    super.initState();
    if(widget.isCodes){
      _fatchData();
    }
    else {
      m_bCheck = List.filled(widget.items.length, false, growable: false);
    }
  }

  void _onTab(int index) {
    if (widget.isMulti) {
      setState(() {
        m_bCheck[index] = !m_bCheck[index];
        int count = 0;
        for (var check in m_bCheck) {
          if (check) {
            count++;
          }
        }
        bSelectOk = (count >= widget.minCheckCount) ? true : false;
      });
    }
    else {
      setState(() {
        m_bCheck[index] = !m_bCheck[index];
        for (int n = 0; n < m_bCheck.length; n++) {
          if (n != index) {
            if (m_bCheck[n]) {
              m_bCheck[n] = false;
            }
          }
        }
        bSelectOk = (m_bCheck[index]) ? true : false;
      });
    }
  }

  String _getSelectValues() {
    String codestring = "";
    for (int n = 0; n < m_bCheck.length; n++) {
      if (m_bCheck[n]) {
        if (codestring.isNotEmpty) {
          codestring += ",";
        }
        codestring += widget.items[n];
      }
    }
    return codestring;
  }

  Future<void> _fatchData({String key=""}) async {
    setState(() {
      bLoaded = false;
    });

    await Remote.getCodes (moims_id:widget.moims_id, category: widget.category, key:key,
        onResponse: (List<Codes> list) async {
          setState(() {
            widget.items.clear();
            list.forEach((element) { widget.items.add(element.name.toString());});
            bSelectOk = false;
            m_bCheck = List.filled(widget.items.length, false, growable: false);
            bLoaded = true;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {FocusScope.of(context).unfocus(); },
        child: WillPopScope(
          onWillPop: () => _onBackPressed(context),
          child: Scaffold(
              appBar: (!bSearch)
                  ? AppBar(
            centerTitle: true,
            title: Text(widget.title),
            actions: [
              Visibility(
                visible: (widget.isCodes && !bSearch) ? true : false,
                child: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        bSearch = !bSearch;
                      });
                      //Navigator.pop(context, _getSelectValues());
                    }
                ),
              ),
            ],
          )
                  : PreferredSize(
                      child: Container(),
                        preferredSize: const Size(0.0, 0.0),
                    ),

              body: (bLoaded)
                  ? Column(
                children: [
                  // search Bar
                  Visibility(
                      visible: bSearch,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(10,10,10,10),
                        //padding: const EdgeInsets.fromLTRB(10,0,0,10),
                        child: TextField(
                            controller: idsController,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (value) {
                              String key = value;
                              if(key.isNotEmpty) {
                                _fatchData(key:key);
                              }
                            },
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal, ),
                            decoration: InputDecoration(
                                hintText: "검색어",
                                //border: OutlineInputBorder(),
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                suffixIcon: IconButton (
                                  onPressed: () async {
                                    String key = idsController.text.trim();
                                    if(key.isNotEmpty) {
                                      _fatchData(key:key);
                                    }
                                  },
                                  icon: const Icon(Icons.search,),
                                  //iconSize: 24,
                                ) ,
                                prefixIcon: IconButton (
                                  onPressed: () async {
                                    closeSearch();
                                  },
                                  icon: const Icon(Icons.arrow_back_ios,),
                                  //iconSize: 24,
                                )
                            )
                        ),
                      )
                  ),
                  Visibility(
                    visible: bLoaded,
                    child: Expanded(
                      child: (widget.items.isNotEmpty)
                          ? LayoutBuilder(builder: (context, constraints) {
                        return GridView.builder(
                          itemCount: widget.items.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: (constraints.maxWidth) > 800 ? 3 : 2,
                            childAspectRatio: 4,
                          ),
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                _onTab(index);
                              },
                              selected: m_bCheck[index],
                              leading: Container(
                                width: 32,
                                height: 32,
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                alignment: Alignment.center,
                                child: _getIcon(index),
                              ),
                              title: Text(widget.items[index],
                                style: TextStyle(
                                    color: (m_bCheck[index]) ? Colors.blueAccent : Colors.black,
                                    fontWeight: (m_bCheck[index])
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 16.0
                                ),
                              ),
                            );
                          },
                        );
                      })
                          : ListView(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              children: List.generate(widget.items.length, (index) {
                                return ListTile(
                                  onTap: () {
                                    _onTab(index);
                                  },
                                  selected: m_bCheck[index],
                                  leading: Container(
                                    width: 32,
                                    height: 32,
                                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                                    alignment: Alignment.center,
                                    child: _getIcon(index),
                                  ),

                                  title: Text(widget.items[index],
                                    style: TextStyle(
                                        color: (m_bCheck[index]) ? Colors.blueAccent : Colors.black,
                                        fontWeight: (m_bCheck[index])
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 20.0
                                    ),
                                  ),
                                );
                              }),
                            ),
                    ),
                  ),
                ],
              )
                  : const Center(child: CircularProgressIndicator(),), // empty back
              floatingActionButton: Visibility(
                visible: (bSelectOk && bLoaded) ? true : false,
                child: FloatingActionButton(
                  child: const Icon(Icons.check),
                  backgroundColor: Colors.green,
                  onPressed: () {
                    Navigator.pop(context, _getSelectValues());
                  },
                ),
              )
          )
        )
    );
  }
  
  Widget _getIcon(int index) {
    if (widget.isMulti) {
      return (m_bCheck[index]) ?
        const Icon(Icons.check_box_sharp, color: Colors.blueAccent) :
        const Icon(Icons.check_box_outline_blank, color: Colors.black);
    }
    else {
      return (m_bCheck[index]) ?
        const Icon(Icons.check_circle, color: Colors.blueAccent,) :
        const Icon(Icons.circle_outlined, color: Colors.black);
    }
  }

  Future<void> closeSearch() async {
    await _fatchData(key: "");
    setState(() {
      idsController.text = "";
      bSearch = false;
    });
  }

  Future<bool> _onBackPressed(BuildContext context) {
    if(bSearch){
      closeSearch();
    }
    else {
      Navigator.pop(context);
    }
    return Future(() => false);
  }
}

