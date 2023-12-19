
import 'package:flutter/material.dart';

class SelectCheck extends StatefulWidget {
  const SelectCheck({Key? key, required this.cotegory, required this.items, required this.minCheckCount}) : super(key: key);
  final int minCheckCount;
  final String cotegory;
  final List<String> items;
  @override
  _SelectCheckState createState() => _SelectCheckState();
}

class _SelectCheckState extends State<SelectCheck> {
  bool m_bLoaded = true;
  bool bSelectOk  = false;
  late List<bool> m_bCheck;// = <bool>[];
  @override
  void initState() {
    super.initState();
    m_bCheck = List.filled(widget.items.length, false, growable: false);
    //_fetchData();
  }

  /*
  Future<void> _fetchData() async {
    await Remote.getCodes(category: widget.cotegory,
        onResponse: (List<Codes> list) {
          setState(() {
            m_bLoaded = true;
            codes = list;
          });
        });
  }
  */

  String _getSelectValues() {
    String codestring = "";
    for (int n = 0; n < widget.items.length; n++) {
      if(m_bCheck[n]){
        if(codestring.isNotEmpty) {
          codestring += ",";
        }
        codestring += widget.items[n];
      }
    }
    return codestring;
  }

  void _onTab(int index) {
    setState(() {
      m_bCheck[index] = !m_bCheck[index];
      int count = 0;
      for (var check in m_bCheck) {
        if(check) {
          count++;
        }
      }
      bSelectOk = (count>=widget.minCheckCount) ? true : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.cotegory),
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
        visible: m_bLoaded,
        child: ListView (

          children: List.generate(widget.items.length, (index) {
            return ListTile (
              onTap: () {
                _onTab(index);
              },
              selected: m_bCheck[index],
              leading: Container(width: 32, height: 32,
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                alignment: Alignment.center,
                child: (m_bCheck[index]) ?
                const Icon(Icons.check_box_sharp, color: Colors.blueAccent) :
                const Icon(Icons.check_box_outline_blank, color: Colors.brown),
              ),
              title: Text(widget.items[index],
                style: TextStyle(
                    color: (m_bCheck[index])?Colors.blueAccent:Colors.black,
                    fontWeight:(m_bCheck[index]) ? FontWeight.bold:FontWeight.normal,
                    fontSize: 20.0
                ),
              ),
            );
          }),
        ),
      )
    );
  }
}
