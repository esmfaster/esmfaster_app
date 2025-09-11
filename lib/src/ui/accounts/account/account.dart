import 'package:app/src/ui/accounts/account/account_page.dart';
import 'package:app/src/ui/accounts/account/account_page2.dart';
import 'package:app/src/ui/accounts/account/account_page3.dart';
import 'package:app/src/ui/accounts/account/account_page4.dart';
import 'package:app/src/ui/accounts/account/account_page5.dart';
import 'package:app/src/ui/accounts/account/account_page6.dart';
import 'package:app/src/ui/accounts/account/account_page7.dart';
import 'package:app/src/ui/accounts/account/account_page8.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './../../../models/app_state_model.dart';
import 'account1.dart';
import 'account2.dart';
import 'account3.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final Map<String, Widget Function()> _layoutMap = {
    'layout1': () => AccountPage(),
    'layout2': () => AccountPage2(),
    'layout3': () => AccountPage3(),
    'layout4': () => AccountPage4(),
    'layout5': () => AccountPage5(),
    'layout6': () => AccountPage6(),
    'layout7': () => AccountPage7(),
    'layout8': () => AccountPage8(),
  };

  final Map<String, Widget Function()> _userLayoutMap = {
    'layout1': () => UserAccount1(),
    'layout2': () => UserAccount2(),
    'layout3': () => UserAccount3(),
  };

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppStateModel>(
      builder: (context, child, model) {
        final layout = model.blocks.settings.pageLayout.account;
        final isCustomAccount = model.blocks.settings.customAccount;

        if (isCustomAccount) {
          return _layoutMap[layout]?.call() ?? AccountPage();
        } else {
          return _userLayoutMap[layout]?.call() ?? UserAccount1();
        }
      },
    );
  }
}
