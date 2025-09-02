import 'package:app/src/config.dart';
import 'package:app/src/models/app_state_model.dart';
import 'package:app/src/ui/widgets/buttons/button.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPVerification extends StatefulWidget {
  final String phoneNumber;
  final String prefixCode;

  const OTPVerification({Key? key, required this.phoneNumber, required this.prefixCode}) : super(key: key);

  @override
  _OTPVerificationState createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  int _start = 30;
  bool isLoading = false;
  final appStateModel = AppStateModel();
  TextEditingController otpTextController = TextEditingController();
  StreamController<ErrorAnimationType> errorController = StreamController<ErrorAnimationType>();

  bool hasError = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    errorController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              appStateModel.blocks.localeText.verifyNumber,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Text(appStateModel.blocks.localeText.enterOtpThatWasSentTo),
            Text(widget.prefixCode + ' ' + widget.phoneNumber, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            SizedBox(height: 20),
            Form(
              key: formKey,
              child: PinCodeTextField(
                appContext: context,
                length: 6,
                animationType: AnimationType.fade,
                controller: otpTextController,
                keyboardType: TextInputType.number,
                onChanged: (value) {},
                beforeTextPaste: (text) => true,
                errorAnimationController: errorController,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _start = 30;
                });
                startTimer();
                // Resend OTP
                _sendOtp(context);
              },
              child: Text(_start == 0 ? 'Resend OTP' : 'Wait $_start seconds'),
            ),
            Spacer(),
            AccentButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _verifyOtp(context);
                }
              },
              showProgress: isLoading,
              text: appStateModel.blocks.localeText.localeTextContinue,
            ),
          ],
        ),
      ),
    );
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          timer.cancel();
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Future<void> _sendOtp(BuildContext context) async {
    final phoneNumber = (widget.prefixCode + widget.phoneNumber).replaceAll('+', ''); //widget.prefixCode + widget.phoneNumber;
    await http.get(
      Uri.parse(Config().url + "/wp-json/taqnix/v1/send_sms_otp?phone_number=$phoneNumber"),
    );
  }

  Future<void> _verifyOtp(BuildContext context) async {
    setState(() => isLoading = true);

    // Prepare data payload
    var data = {
      "phone_number": (widget.prefixCode + widget.phoneNumber).replaceAll('+', ''),
      "otp": otpTextController.text,
    };

    // Call phoneLogin to verify OTP
    bool loginSuccess = await appStateModel.phoneLogin(data, context);

    if (loginSuccess) {
      // Navigate to the main screen if login is successful
      Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
    }

    setState(() => isLoading = false);
  }
}
