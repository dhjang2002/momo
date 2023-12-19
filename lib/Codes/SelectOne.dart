import 'package:flutter/material.dart';

class SelectOne extends StatefulWidget {
  const SelectOne({Key? key,
    required this.cotegory,
    required this.list}) : super(key: key);
  final String cotegory;
  final List<String> list;
  @override
  _SelectOneState createState() => _SelectOneState();
}

class _SelectOneState extends State<SelectOne> {
  bool bLoaded = true;
  bool bSelectOk  = false;
  late List<bool> m_bCheck;

  @override
  void initState() {
    super.initState();
    m_bCheck = List.filled(widget.list.length, false, growable: false);
    //_fetchData();
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
        codestring += widget.list[n];
      }
    }
    return codestring;
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
        visible: bLoaded,
        child:ListView.builder(
          itemCount: widget.list.length,
          padding: EdgeInsets.all(8),
            itemBuilder: (context, index) {
              return Card(
                key: UniqueKey(),
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(widget.list[index])
                ),
              );
            }),
        ),
    );
  }
}
