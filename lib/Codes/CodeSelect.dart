import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CodeSelect extends StatefulWidget {
  const CodeSelect({Key? key,
    required this.category, 
    required this.itemList, 
    required this.iconList,
    required this.isMulti, 
    required this.minCheckCount}) : super(key: key);

  final String category;
  final bool isMulti;
  final int minCheckCount;
  final List<String> itemList;
  final List<String> iconList;
  @override
  _CodeSelectState createState() => _CodeSelectState();
}

class _CodeSelectState extends State<CodeSelect> {
  bool bLoaded = true;
  bool bSelectOk  = false;
  late List<bool> m_bCheck;
  
  @override
  void initState() {
    super.initState();
    m_bCheck = List.filled(widget.itemList.length, false, growable: false);
  }

  void _onTab(int index) {
    setState(() {
      m_bCheck[index] = !m_bCheck[index];
      for (int n = 0; n < m_bCheck.length; n++){
        if(n != index) {
          if (m_bCheck[n]) {
            m_bCheck[n] = false;
          }
        }
      }
      bSelectOk = (m_bCheck[index]) ? true : false;
    });
  }

  String _getSelectValues() {
    String codestring = "";
    for (int n = 0; n < m_bCheck.length; n++) {
      if(m_bCheck[n]){
        if(codestring.isNotEmpty) {
          codestring += ",";
        }
        codestring += widget.itemList[n];
      }
    }
    return codestring;
  }

  Widget _getIcon(int index) {
    if (widget.isMulti) {
      return (m_bCheck[index]) ?
        const Icon(Icons.check_box_sharp, color: Colors.blueAccent) :
        const Icon(Icons.check_box_outline_blank, color: Colors.brown);
    }
    else {
      return (m_bCheck[index]) ?
        const Icon(Icons.check_circle, color: Colors.blueAccent,) :
        Icon(Icons.circle_outlined, color: Colors.brown);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.category),
        actions: [
          Visibility(
            visible: (bSelectOk) ? true : false,
            child: IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  Navigator.pop(context, _getSelectValues());
                }
            ),
          ),
        ],
      ),
      body: Visibility(
        visible: bLoaded,
        child: ListView.separated(
        scrollDirection: Axis.vertical,
        separatorBuilder: (BuildContext context, int index) =>
        const Divider(), //separatorBuilder : item과 item 사이에 그려질 위젯 (개수는 itemCount -1 이 된다)
        itemCount: widget.itemList.length, //리스트의 개수
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: ()=>_onTab(index),
            child: Container(
              padding: EdgeInsets.fromLTRB(5,10,5,10),
              height: 100,
              color: Colors.white,
              child: Row(
                  children: [
                    Container(  // action icon
                        width: 32,
                        alignment: Alignment.center,
                        child: _getIcon(index)
                    ),
                    Expanded(
                      child: Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.center,
                    color:Colors.grey,
                    child: Text(widget.itemList.elementAt(index),
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),),
                    Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Image.asset("assets/images/bbanto.png",),)
              ],
            ),
            ),
          );
        },
        ),
      ) // empty back
    );
  }
}
