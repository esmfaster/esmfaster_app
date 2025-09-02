import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../src/blocs/checkout_form_bloc.dart';
import '../../../../src/resources/api_provider.dart';
import '../../../config.dart';

class WebViewSubmit extends StatefulWidget {
  final CheckoutFormBloc checkoutBloc;

  const WebViewSubmit({Key? key, required this.checkoutBloc})
      : super(key: key);

  @override
  _WebViewSubmitState createState() => _WebViewSubmitState();
}

class _WebViewSubmitState extends State<WebViewSubmit> {
  final Config config = Config();
  bool _isLoadingPage = true;

  //FlutterWebviewPlugin? flutterWebViewPlugin = FlutterWebviewPlugin();
  // Removed unused StreamSubscription variables
  // late StreamSubscription<String> _onUrlChanged;
  // late StreamSubscription<double> _onProgressChanged;
  // double progress = 0.0;
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
            // Handle URL changes when a page starts loading
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
              SnackBar(
                  content: Text('Failed to load page: ${error.description}')),
            );
          },
        ),
      )
      ..loadRequest(Uri.dataFromString(_loadHTML(),
          mimeType: 'text/html', encoding: Encoding.getByName('utf-8')!)); // Load the initial HTML content
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
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

  String _loadHTML() {
    widget.checkoutBloc.formData['shipping_first_name'] =
    widget.checkoutBloc.formData['billing_first_name']!;
    widget.checkoutBloc.formData['shipping_last_name'] =
    widget.checkoutBloc.formData['billing_last_name']!;
    widget.checkoutBloc.formData['shipping_address_1'] =
    widget.checkoutBloc.formData['billing_address_1']!;
    widget.checkoutBloc.formData['shipping_address_2'] =
    widget.checkoutBloc.formData['billing_address_2']!;
    widget.checkoutBloc.formData['shipping_city'] =
    widget.checkoutBloc.formData['billing_city']!;
    widget.checkoutBloc.formData['shipping_postcode'] =
    widget.checkoutBloc.formData['billing_postcode']!;
    widget.checkoutBloc.formData['shipping_country'] =
    widget.checkoutBloc.formData['billing_country']!;
    widget.checkoutBloc.formData['shipping_state'] =
    widget.checkoutBloc.formData['billing_state']!;

    /*if(appStateModel.oneSignalPlayerId != null)
      formData['onesignal_user_id'] = appStateModel.oneSignalPlayerId;
    if(appStateModel.fcmToken.isNotEmpty)
      formData['fcm_token'] = appStateModel.fcmToken;
    */

    if (widget.checkoutBloc.orderReviewData != null) {
      for (var i = 0;
      i < widget.checkoutBloc.orderReviewData!.shipping.length;
      i++) {
        if (widget.checkoutBloc.orderReviewData!.shipping[i].chosenMethod != '') {
          widget.checkoutBloc.formData[
          'shipping_method[' + i.toString() + ']'] =
              widget.checkoutBloc.orderReviewData!.shipping[i].chosenMethod;
        }
      }
    }

    /** for WCFM Only **/
    /*if(appStateModel.customerLocation['latitude'] != null && appStateModel.customerLocation['longitude'] != null && appStateModel.customerLocation['address'] != null) {
      formData['wcfmmp_user_location_lat'] = appStateModel.customerLocation['latitude'];
      formData['wcfmmp_user_location_lng'] = appStateModel.customerLocation['longitude'];
      formData['wcfmmp_user_location'] = appStateModel.customerLocation['address'];
    }

    if(appStateModel.selectedDate != null && appStateModel.selectedTime != null) {
      formData['jckwds-delivery-date'] = appStateModel.selectedDateFormatted;
      formData['jckwds-delivery-date-ymd'] = appStateModel.selectedDate;
      formData['jckwds-delivery-time'] = appStateModel.selectedTime;
    }*/

    var url = config.url + '/?wc-ajax=checkout';

    var html;
    html = '<html><body onload="document.f.submit();"><form id="f" name="f" method="post" action="$url">';

    var htmlEnd = '</form></body></html>';

    widget.checkoutBloc.formData.forEach((key, value) {
      html = html + '<input type="hidden" name="$key" value="$value" />';
    });

    return html + htmlEnd;
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
