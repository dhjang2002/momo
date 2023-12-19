
import 'package:flutter/material.dart';
import 'package:momo/Utils/utils.dart';

class PhotoViewer extends StatefulWidget {
  final String url;
  final String title;
  const PhotoViewer({
    Key? key,
    required this.url,
    required this.title
  }) : super(key: key);
  _PhotoViewerState createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child:Container(
            child: simpleBlurImage(widget.url, 1.0)
        ),
      )
    );
  }
}