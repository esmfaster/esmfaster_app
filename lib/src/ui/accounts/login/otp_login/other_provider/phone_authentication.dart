import 'package:app/src/config.dart';
import 'package:app/src/models/app_state_model.dart';
import 'package:app/src/ui/widgets/buttons/button.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'otp_verification.dart';

class PhoneAuthentication extends StatefulWidget {
  PhoneAuthentication({Key? key}) : super(key: key);

  @override
  _PhoneAuthenticationState createState() => _PhoneAuthenticationState();
}

class _PhoneAuthenticationState extends State<PhoneAuthentication> {
  String prefixCode = '+91';
  final appStateModel = AppStateModel();
  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneNumberController = TextEditingController();
  bool isLoading = false; // Add a loading state variable

  @override
  void initState() {
    super.initState();
    prefixCode = appStateModel.blocks.settings.dialCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    appStateModel.blocks.localeText.signIn,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: phoneNumberController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return appStateModel.blocks.localeText.pleaseEnterPhoneNumber;
                      }
                      return null;
                    },
                    autofocus: true,
                    style: TextStyle(fontWeight: FontWeight.w400),
                    decoration: InputDecoration(
                      labelText: appStateModel.blocks.localeText.phoneNumber,
                      hintText: '90 1235 6789',
                      prefix: CountryCodePicker(
                        onChanged: _onCountryChange,
                        initialSelection: appStateModel.blocks.siteSettings.defaultCountry,
                        favorite: [prefixCode, appStateModel.blocks.siteSettings.defaultCountry],
                        alignLeft: false,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Card(
                elevation: 0,
                margin: EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: AccentButton(
                        onPressed: () {
                          if (!isLoading && _formKey.currentState!.validate()) {
                            _sendOtp(context);
                          }
                        },
                        showProgress: isLoading, // Show progress when loading
                        text: appStateModel.blocks.localeText.localeTextContinue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onCountryChange(CountryCode countryCode) {
    setState(() {
      prefixCode = countryCode.toString();
    });
  }

  Future<void> _sendOtp(BuildContext context) async {
    setState(() {
      isLoading = true; // Set loading to true when the OTP request starts
    });

    final phoneNumber = (prefixCode + phoneNumberController.text).replaceAll('+', '');
    final response = await http.get(
      Uri.parse(Config().url + "/wp-json/taqnix/v1/send_sms_otp?phone_number=$phoneNumber"),
    );

    setState(() {
      isLoading = false; // Set loading to false after the OTP request completes
    });

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerification(
            phoneNumber: phoneNumberController.text,
            prefixCode: prefixCode,
          ),
        ),
      );
    } else {
      // Handle error
      print('Failed to send OTP');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP. Please try again.')),
      );
    }
  }
}
