import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share/share.dart';
import 'package:intl/intl.dart';

class NotesHome extends StatefulWidget {
  String text;
  NotesHome(this.text);

  @override
  _NotesHomeState createState() => _NotesHomeState();
}

class _NotesHomeState extends State<NotesHome> {
  Completer<WebViewController> _controller = Completer<WebViewController>();
//  final Set<String> _favorites = Set<String>();
  String url = "https://www.google.com/";
  String subject = '';

  @override
  void initState() {
    super.initState();
//    url = "http://yusun.io/";
    url = "https://andy-ma-project.herokuapp.com/process/" +
        widget.text.replaceAll(" ", "%20");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Easy Notes'),
//        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
//        actions: <Widget>[
//          NavigationControls(_controller.future),
//          Menu(_controller.future, () => _favorites),
//        ],
      ),
      body: WebView(
        initialUrl: url,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
      ),

//      floatingActionButton: _bookmarkButton(),

      floatingActionButton: _bookmarkButton(),
    );
  }

  _share(String url) {
    final RenderBox box = context.findRenderObject();
    Share.share(url,
        subject: _getDate(),
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  _getDate() {
    var now = DateTime.now();
    return DateFormat('dd-MM-yyyy HH: mm').format(now);
  }

  _bookmarkButton() {
    return FutureBuilder<WebViewController>(
      future: _controller.future,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        if (controller.hasData) {
          return FloatingActionButton(
            onPressed: () async {
              await controller.data.currentUrl().then((value) => _share(value));
            },
            child: Icon(Icons.share),
          );
        }
        return Container();
      },
    );
  }
}
