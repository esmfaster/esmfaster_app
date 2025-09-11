import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config.dart';
import '../../resources/api_provider.dart';


class WebViewPage extends StatefulWidget {
  final String url;
  final String? title;
  final String? elementId;

  const WebViewPage({
    Key? key,
    required this.url,
    this.title,
    this.elementId,
  }) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
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
      // Ensure that you have imported webview_flutter_android
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
            // You can handle page start events here if needed
          },
          onPageFinished: (String url) async {
            // Inject JavaScript to hide header and footer after the page finishes loading
            await _wvController.runJavaScript(
                "document.getElementsByTagName('header')[0].style.display='none';");
            await _wvController.runJavaScript(
                "document.getElementsByTagName('footer')[0].style.display='none';");
            await _wvController.runJavaScript(
                "document.getElementById('${widget.elementId}').style.display='none';");
            setState(() {
              _isLoadingPage = false; // Hide loading indicator
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Intercept navigation requests to handle specific URLs
            if (request.url.contains('/order-received/')) {
              // Implement your custom logic here
              // For example, navigate to an order summary page
              // Navigator.push(context, ...);
              return NavigationDecision.prevent; // Prevent the WebView from navigating
            }

            if (request.url.contains('?errors=true')) {
              // Handle error scenarios if needed
              // Example: Navigator.of(context).pop();
            }

            // Handle PayUIndia Payment URLs
            if (request.url.contains('payumoney.com/transact')) {
              // Additional handling if necessary
            }

            // Handle PAYTM Payment URLs
            if (request.url.contains('securegw-stage.paytm.in/theia')) {
              // Additional handling if necessary
            }

            if (request.url.contains('type=success') /* && orderId != null */) {
              // Handle success scenario if needed
              // Example: orderSummaryById();
            }

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
      ..loadRequest(Uri.parse(widget.url)); // Load the initial URL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title != null ? Text(widget.title!) : Container(),
        backgroundColor: Color(0xffe94a4b),
        bottom: _isLoadingPage
            ? PreferredSize(
          preferredSize: Size.fromHeight(2.0),
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColorDark),
          ),
        )
            : null,
      ),
      body: Stack(
        children: <Widget>[
          // Display WebView only after cookies are injected
          injectCookies
              ? WebViewWidget(controller: _wvController)
              : Container(),
          // Show loading indicator while the page is loading
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


class WebViewPageSAL extends StatefulWidget {
  final String url;
  final String? title;
  final String? elementId;

  const WebViewPageSAL({
    Key? key,
    required this.url,
    this.title,
    this.elementId,
  }) : super(key: key);

  @override
  _WebViewPageSALState createState() => _WebViewPageSALState();
}

class _WebViewPageSALState extends State<WebViewPageSAL> {
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
      // Ensure that you have imported webview_flutter_android
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
            await _wvController.runJavaScript(
                "document.getElementById('header').style.display='none';");
            await _wvController.runJavaScript(
                "document.getElementById('footer').style.display='none';");

            // Inject JavaScript to hide additional elements by their IDs
            if (widget.elementId != null && widget.elementId!.isNotEmpty) {
              final splitted = widget.elementId!.split(' ');
              for (var element in splitted) {
                await _wvController.runJavaScript(
                    "document.getElementById('$element').style.display='none';");
              }
            }

            setState(() {
              _isLoadingPage = false; // Hide loading indicator
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Intercept navigation requests to handle specific URLs
            if (request.url.contains('/order-received/')) {
              // Implement your custom logic here
              // For example, navigate to an order summary page
              // Navigator.push(context, ...);
              return NavigationDecision.prevent; // Prevent the WebView from navigating
            }

            if (request.url.contains('?errors=true')) {
              // Handle error scenarios if needed
              // Example: Navigator.of(context).pop();
            }

            // Handle PayUIndia Payment URLs
            if (request.url.contains('payumoney.com/transact')) {
              // Additional handling if necessary
            }

            // Handle PAYTM Payment URLs
            if (request.url.contains('securegw-stage.paytm.in/theia')) {
              // Additional handling if necessary
            }

            if (request.url.contains('type=success') /* && orderId != null */) {
              // Handle success scenario if needed
              // Example: orderSummaryById();
            }

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
      ..loadRequest(Uri.parse(widget.url)); // Load the initial URL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title != null ? Text(widget.title!) : Container(),
        backgroundColor: Color(0xffe94a4b),
        bottom: _isLoadingPage
            ? PreferredSize(
          preferredSize: Size.fromHeight(2.0),
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColorDark),
          ),
        )
            : null,
      ),
      body: Stack(
        children: <Widget>[
          // Display WebView only after cookies are injected
          injectCookies
              ? WebViewWidget(controller: _wvController)
              : Container(),
          // Show loading indicator while the page is loading
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
