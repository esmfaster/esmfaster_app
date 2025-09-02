import 'package:app/src/models/app_state_model.dart';
import 'package:app/src/ui/accounts/login/otp_login/firebase/phone_number.dart';
import 'package:app/src/ui/accounts/login/otp_login/other_provider/phone_authentication.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class AllPhoneAuthentication extends StatefulWidget {
  const AllPhoneAuthentication({super.key});

  @override
  State<AllPhoneAuthentication> createState() => _AllPhoneAuthenticationState();
}

class _AllPhoneAuthenticationState extends State<AllPhoneAuthentication> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppStateModel>(
        builder: (context, child, model) {
          if (model.blocks.settings.otpAuth == 'firebase') {
            return FireBasePhoneAuthentication();
          } else if (model.blocks.settings.otpAuth == '2factor') {
            return PhoneAuthentication();
          } else {
            return PhoneAuthentication();
          }
        });
  }
}
