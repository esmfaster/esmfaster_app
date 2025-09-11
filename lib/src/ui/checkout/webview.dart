import 'dart:async';
import 'dart:io';
import 'package:app/src/models/app_state_model.dart';
import 'package:app/src/ui/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config.dart';
import '../../functions.dart';
import '../../resources/api_provider.dart';
import 'order_summary.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String selectedPaymentMethod;

  const WebViewPage({
    Key? key,
    required this.url,
    required this.selectedPaymentMethod,
  }) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final ApiProvider apiProvider = ApiProvider();
  final Config config = Config();
  bool _isLoadingPage = true;
  String? orderId;
  String? orderKey;
  String? redirectUrl;
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
    _initialize();
  }

  /// Initializes the WebView by setting cookies and configuring the controller.
  Future<void> _initialize() async {
    _extractOrderDetails();
    await _setCookies();
    _setupWebViewController();
  }

  /// Extracts orderId and orderKey from the initial URL based on the selected payment method.
  void _extractOrderDetails() {
    orderId = _getOrderIdFromUrl(widget.url);
    if (widget.url.contains("/?key=wc_order")) {
      final pos1 = widget.url.lastIndexOf("/?key=wc_order");
      final pos2 = widget.url.length;
      orderKey = widget.url.substring(pos1 + 6, pos2); // Extracts 'wc_order...'
    }

    // Determine the redirectUrl based on the selectedPaymentMethod and URL contents
    if (widget.selectedPaymentMethod == 'woo_mpgs' &&
        widget.url.contains("sessionId=") &&
        widget.url.contains("&order=")) {
      final sessionId = _extractParameter(widget.url, 'sessionId');
      if (sessionId != null) {
        redirectUrl = 'https://credimax.gateway.mastercard.com/checkout/pay/$sessionId';
      } else {
        redirectUrl = widget.url; // Fallback to original URL if sessionId not found
      }
    } else if (['paypal', 'wc-upi', 'wpl_paylabs_paytm'].contains(widget.selectedPaymentMethod)) {
      redirectUrl = widget.url;
    } else if (widget.selectedPaymentMethod == 'paytmpay' && orderKey != null && orderId != null) {
      redirectUrl = '${config.url}/index.php/checkout/order-pay/$orderId/?key=$orderKey';
    } else if (widget.selectedPaymentMethod == 'eh_stripe_checkout' && orderKey != null && orderId != null) {
      redirectUrl = '${config.url}/checkout/order-pay/$orderId/?key=$orderKey';
    } else if (orderKey != null) {
      redirectUrl = widget.url;
      // Optionally, uncomment the line below if you prefer constructing the URL differently
      // redirectUrl = '${config.url}/checkout/order-pay/$orderId/?key=$orderKey';
    } else {
      redirectUrl = widget.url;
    }
  }

  /// Sets cookies using webview_cookie_manager.
  Future<void> _setCookies() async {
    final Uri uri = Uri.parse(config.url);
    final String domain = uri.host;
    final List<Cookie> cookies = apiProvider.generateCookies();

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

  /// Configures the WebViewController with necessary settings and navigation delegates.
  void _setupWebViewController() {
    _wvController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            _onUrlChange(url);
          },
          onPageFinished: (String url) async {
            _onPageFinished(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            return _handleNavigationRequest(request);
          },
          onWebResourceError: (WebResourceError error) {
            _handleWebResourceError(error);
          },
        ),
      )
      ..loadRequest(Uri.parse(redirectUrl!));
  }

  /// Handles navigation requests to intercept and manage specific URL schemes.
  NavigationDecision _handleNavigationRequest(NavigationRequest request) {
    final url = request.url;

    if (url.startsWith("upi:") ||
        url.startsWith("kbzpay:") ||
        url.startsWith("intent:") ||
        !["http", "https", "file", "chrome", "data", "javascript", "about"]
            .any((scheme) => url.startsWith(scheme))) {
      _launchExternalUrl(url);
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  /// Launches external URLs using the url_launcher package.
  Future<void> _launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Handle the error if the URL can't be launched
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  /// Handles web resource errors by displaying a SnackBar with the error description.
  void _handleWebResourceError(WebResourceError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load page: ${error.description}')),
    );
  }

  /// Processes URL changes to determine navigation actions.
  Future<void> _onUrlChange(String newUrl) async {
    print('URL Changed: $newUrl');

    if (_shouldNavigateToOrderSummary(newUrl)) {
      if (orderId != null && widget.selectedPaymentMethod != 'wc-upi') {
        _navigateToOrderSummaryById();
      } else {
        _navigateToOrderSummary(newUrl);
      }
    } else if (_shouldCancelNavigation(newUrl)) {
      Navigator.of(context).pop();
    }
    // Add more conditions as necessary based on payment methods
  }

  /// Processes page finished events to determine navigation actions.
  Future<void> _onPageFinished(String newUrl) async {
    await _onUrlChange(newUrl);

    if (_shouldNavigateToOrderSummary(newUrl)) {
      if (orderId != null && widget.selectedPaymentMethod != 'wc-upi') {
        _navigateToOrderSummaryById();
      } else {
        _navigateToOrderSummary(newUrl);
      }
    } else if (_shouldCancelNavigation(newUrl)) {
      Navigator.of(context).pop();
    }
    // Add more conditions as necessary based on payment methods
  }

  /// Determines whether the app should navigate to the OrderSummary page based on the URL.
  bool _shouldNavigateToOrderSummary(String url) {
    return (url.contains('/order-received/') && url.contains('key=wc_order_')) ||
        url.contains('payment-response?order_id=') ||
        url.contains('/?wc-api=upiwc-payment') ||
        url.contains('/?wc-api=razorpay') ||
        url.contains('wc-api=WC_Gateway_paytmpay') ||
        url.contains('wc-api=WC_Gateway_cashfree&act=ret') ||
        url.contains('type=success');
  }

  /// Determines whether the navigation should be canceled based on the URL.
  bool _shouldCancelNavigation(String url) {
    return url.contains('cancel_order=') ||
        url.contains('failed') ||
        url.contains('type=error') ||
        url.contains('cancelled=1') ||
        url.contains('cancelled') ||
        url.contains('cancel_order=true') ||
        url.contains('/wc-api/wpl_paylabs_wc_paytm/') ||
        url.contains('/shop/') ||
        url.contains('/details.html');
  }

  /// Navigates to the OrderSummary page using the orderId.
  void _navigateToOrderSummaryById() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSummary(
          id: orderId!,
        ),
      ),
    );
  }

  /// Navigates to the OrderSummary page using the URL to extract the orderId.
  void _navigateToOrderSummary(String url) {
    orderId = _getOrderIdFromUrl(url);
    if (orderId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSummary(
            id: orderId!,
          ),
        ),
      );
    }
  }

  /// Extracts a parameter value from the URL based on the provided key.
  String? _extractParameter(String url, String key) {
    final uri = Uri.parse(url);
    return uri.queryParameters[key];
  }

  /// Extracts the orderId from the URL.
  String? _getOrderIdFromUrl(String url) {
    // Implement your logic to extract orderId from the URL
    // For example, using regular expressions or parsing query parameters
    // Here's a simple example using query parameters:
    final uri = Uri.parse(url);
    return uri.queryParameters['order_id'];
  }

  /// Cleans up resources when the widget is disposed.
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStateModel().blocks.localeText.payment),
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
              child: LoadingIndicator(), // Replace with CircularProgressIndicator() if LoadingIndicator is not defined
            ),
        ],
      ),
    );
  }
}
