//import 'dart:async';
import 'dart:async';
import 'dart:io';
import 'package:app/src/ui/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../config.dart';
import '../../../functions.dart';
import '../../../resources/api_provider.dart';
import '../order_summary.dart';

import 'dart:async';
import 'dart:io';
import 'package:app/src/ui/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../config.dart';
import '../../../functions.dart';
import '../../../resources/api_provider.dart';
import '../order_summary.dart';

class WebViewCheckout extends StatefulWidget {
  @override
  _WebViewCheckoutState createState() => _WebViewCheckoutState();
}

class _WebViewCheckoutState extends State<WebViewCheckout> {
  String? orderId;
  final ApiProvider apiProvider = ApiProvider();
  final Config config = Config();
  bool _isLoadingPage = true;
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
    // Initialize cookies and WebView
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
            _onUrlChange(url); // Handle URL changes when a page starts loading
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
            if (request.url.contains('/order-received/')) {
              orderSummary(request.url); // Navigate to OrderSummary
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

            if (request.url.contains('type=success') && orderId != null) {
              // Handle success scenario if needed
              // Example: orderSummaryById();
            }

            return NavigationDecision.navigate; // Allow the navigation
          },
        ),
      )
      ..loadRequest(Uri.parse('${config.url}/checkout/')); // Load the initial URL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
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
              child: const LoadingIndicator(),
            ),
        ],
      ),
    );
  }

  // Method to handle URL changes
  void _onUrlChange(String url) {
    if (url.contains('/order-received/')) {
      orderSummary(url); // Navigate to OrderSummary when order is received
    }

    if (url.contains('?errors=true')) {
      // Handle error scenarios if needed
      // Example: Navigator.of(context).pop();
    }

    // Additional URL handling can be placed here

    if (url.contains('type=success') && orderId != null) {
      // Handle success scenario if needed
      // Example: orderSummaryById();
    }
  }

  // Method to navigate to the OrderSummary page
  void orderSummary(String url) {
    orderId = getOrderIdFromUrl(url); // Extract order ID from URL
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSummary(
          id: orderId!,
        ),
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

