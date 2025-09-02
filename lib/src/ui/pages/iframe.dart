import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app/src/ui/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config.dart';
import '../../resources/api_provider.dart';

class IframePage extends StatefulWidget {
  final String url;
  final String? title;

  const IframePage({
    Key? key,
    required this.url,
    this.title,
  }) : super(key: key);

  @override
  _IframePageState createState() => _IframePageState();
}

class _IframePageState extends State<IframePage> {
  bool _isLoadingPage = true;
  final Config config = Config();
  final WebviewCookieManager cookieManager = WebviewCookieManager();
  bool injectCookies = false;

  late final WebViewController _wvController;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition for Android to improve performance and compatibility
    /*if (Platform.isAndroid) {
      WebViewPlatform.instance = SurfaceAndroidWebView();
    }*/
    _setupCookiesAndWebView();
  }

  // Asynchronous method to set cookies and initialize WebViewController
  Future<void> _setupCookiesAndWebView() async {
    await _setCookies(); // Set cookies before loading the WebView

    setState(() {
      injectCookies = true; // Enable WebView after setting cookies
    });

    // Initialize the WebViewController with necessary configurations
    _wvController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Enable JavaScript
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // Handle URL changes when a page starts loading if needed
          },
          onPageFinished: (String url) async {
            // Inject JavaScript to hide header and footer after the page finishes loading
            await _wvController.runJavaScript(
                "document.getElementsByTagName('header')[0].style.display='none';");
            await _wvController.runJavaScript(
                "document.getElementsByTagName('footer')[0].style.display='none';");

            setState(() {
              _isLoadingPage = false; // Hide loading indicator
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Intercept navigation requests to handle specific URLs
            // Add your custom navigation logic here if needed
            return NavigationDecision.navigate; // Allow the navigation
          },
          onWebResourceError: (WebResourceError error) {
            // Handle web resource errors
            // Example: Show a dialog or a snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load page: ${error.description}')),
            );
          },
        ),
      )
      ..loadRequest(Uri.dataFromString(
        _generateIframeHTML(),
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')!,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.title != null
          ? AppBar(title: Text(widget.title!))
          : AppBar(),
      body: Stack(
        children: <Widget>[
          // Display WebView only after cookies are injected
          injectCookies
              ? WebViewWidget(controller: _wvController)
              : Container(),
          // Show loading indicator while the page is loading
          _isLoadingPage
              ? Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: LoadingIndicator(), // Replace with CircularProgressIndicator() if LoadingIndicator is not defined
          )
              : Container(),
        ],
      ),
    );
  }

  // Generates the HTML string with an iframe pointing to the desired URL
  String _generateIframeHTML() {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body, html {
          margin: 0;
          padding: 0;
          height: 100%;
          overflow: hidden;
        }
        iframe {
          width: 100%;
          height: 100%;
          border: none;
        }
      </style>
    </head>
    <body>
      <iframe src="${widget.url}"></iframe>
    </body>
    </html>
    ''';
  }

  // Asynchronous method to set cookies using webview_cookie_manager
  Future<void> _setCookies() async {
    final Uri uri = Uri.parse(config.url);
    final String domain = uri.host;
    final ApiProvider apiProvider = ApiProvider();
    final List<Cookie> cookies = apiProvider.generateCookies(); // Generate cookies

    // Set domain and path for each cookie
    for (var cookie in cookies) {
      cookie.domain = domain;
      cookie.path = '/';
      // Optional: Set other properties like expires, httpOnly, etc.
      // cookie.expires = DateTime.now().add(Duration(days: 10));
      // cookie.httpOnly = true;
    }

    // Set all cookies at once
    await cookieManager.setCookies(cookies);

    setState(() {
      injectCookies = true;
    });
  }

  @override
  void dispose() {
    // Clean up resources if necessary
    super.dispose();
  }
}
