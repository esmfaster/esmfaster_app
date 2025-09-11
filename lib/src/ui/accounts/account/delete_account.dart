import 'package:app/src/models/app_state_model.dart';
import 'package:app/src/ui/checkout/payment/loading_button.dart';
import 'package:flutter/material.dart';

class DeleteAccount extends StatelessWidget {
  const DeleteAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = AppStateModel();

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDeleteAccountMessage(context),
              SizedBox(height: 16),
              LoadingButton(
                onPressed: () => _deleteAccount(context),
                text: model.blocks.localeText.deleteAccount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountMessage(BuildContext context) {
    final model = AppStateModel();
    return Text(
      model.blocks.localeText.deleteAccountMessage,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final model = AppStateModel();
    bool status = await model.deleteAccount(context);
    // Handle account deletion status
  }
}
