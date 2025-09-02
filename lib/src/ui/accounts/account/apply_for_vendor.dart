import 'package:app/src/config.dart';
import 'package:app/src/models/app_state_model.dart';
import 'package:app/src/models/register_model.dart';
import 'package:app/src/ui/accounts/login/login1/loading_button.dart';
import 'package:flutter/material.dart';

class ApplyForVendor extends StatefulWidget {
  @override
  _ApplyForVendorState createState() => _ApplyForVendorState();
}

class _ApplyForVendorState extends State<ApplyForVendor> {
  final appStateModel = AppStateModel();
  final _register = RegisterModel();
  final _shopUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Builder(
        builder: (context) => ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 15.0),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 60,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 120, maxWidth: 220),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTextFormField(
                      labelText: 'Shop Name',
                      onSaved: (val) => _register.shopName = val ?? '',
                      validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter shop name' : null,
                      onChanged: (val) => _updateShopUrl(val),
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 12.0),
                    _buildTextFormField(
                      labelText: 'Shop Url',
                      controller: _shopUrlController,
                      onSaved: (val) => _register.shopURL = val ?? '',
                      validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter shop URL' : null,
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 4.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${Config().url}/${_shopUrlController.text}',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: 12.0),
                    _buildTextFormField(
                      labelText: 'Phone Number',
                      onSaved: (val) => _register.phoneNumber = val ?? '',
                      validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter phone number' : null,
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 30.0),
                    LoadingButton(
                      onPressed: () => _submit(context),
                      text: appStateModel.blocks.localeText.signUp,
                      //isLoading: _isLoading,
                    ),
                    SizedBox(height: 30.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String labelText,
    TextEditingController? controller,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          onSaved: onSaved,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(labelText: labelText),
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  void _updateShopUrl(String value) {
    setState(() {
      _shopUrlController.text = value.toLowerCase().replaceAll(' ', '');
    });
  }

  Future<void> _submit(BuildContext context) async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      final status = await appStateModel.applyVendor(_register.toJson(), context);
      setState(() {
        _isLoading = false;
      });
      if (status) {
        Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
      }
    }
  }
}
