import 'package:app/src/ui/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class IframePage extends StatefulWidget {
  final String url;
  final String title;

  const IframePage({Key? key, required this.url, required this.title}) : super(key: key);

  @override
  _IframePageState createState() => _IframePageState();
}

class _IframePageState extends State<IframePage> {
  bool _isLoadingPage = true;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoadingPage = false;
            });
          },
        ),
      )
      ..loadHtmlString('<html><body>' + widget.url + '</body></html>');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoadingPage)
            Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
