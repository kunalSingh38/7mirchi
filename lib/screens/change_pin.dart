import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/constants.dart';
import 'package:flutter/services.dart';
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'dart:convert';
import 'package:sodhis_app/components/general.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ChangePinPage extends StatefulWidget {
  @override
  _ChangePinPageState createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  final oldpinController = TextEditingController();
  final newpinController = TextEditingController();
  final confirmpinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _userId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void dispose() {
    oldpinController.dispose();
    newpinController.dispose();
    confirmpinController.dispose();
    super.dispose();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
    });
  }

  Widget _oldpinTextbox() {
    return Container(
      margin: new EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: oldpinController,
          cursorColor: Color(0xFF372D61),
          keyboardType: TextInputType.number,
          maxLength: 6,
          obscureText: true,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter your old pin';
            }
            return null;
          },
          onSaved: (String value) {
            oldpinController.text = value;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Old PIN',
            counterText: "",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey[300]),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey[300]),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey[300]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _newpinTextbox() {
    return Container(
      margin: new EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: newpinController,
          cursorColor: Color(0xFF372D61),
          keyboardType: TextInputType.number,
          maxLength: 6,
          obscureText: true,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter your new pin';
            }
            return null;
          },
          onSaved: (String value) {
            newpinController.text = value;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'New PIN',
            counterText: "",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey[300]),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey[300]),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey[300]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _confirmpinTextbox() {
    return Container(
      margin: new EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: confirmpinController,
          cursorColor: Color(0xFF372D61),
          keyboardType: TextInputType.number,
          maxLength: 6,
          obscureText: true,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please confirm your new pin';
            }
            return null;
          },
          onSaved: (String value) {
            confirmpinController.text = value;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Confirm New PIN',
            counterText: "",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey[300]),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey[300]),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.grey[300]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      margin: new EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 30),
      child: Align(
        alignment: Alignment.center,
        child: ButtonTheme(
          minWidth: MediaQuery.of(context).size.width,
          child: RaisedButton(
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                setState(() {
                  _loading = true;
                });
                var response = await http.post(
                  new Uri.https(BASE_URL, API_PATH + "/change-pin"),
                  body: {
                    "user_id": _userId.toString(),
                    "old_pin": oldpinController.text,
                    "new_pin": newpinController.text,
                    "confirm_pin": confirmpinController.text,
                  },
                  headers: {
                    "Accept": "application/json",
                    "authorization": basicAuth
                  },
                );
                if (response.statusCode == 200) {
                  setState(() {
                    _loading = false;
                  });
                  var data = json.decode(response.body);
                  var errorCode = data['ErrorCode'];
                  var errorMessage = data['ErrorMessage'];
                  if (errorCode == 0) {
                    // _formKey.currentState.reset();
                    oldpinController.clear();
                    newpinController.clear();
                    confirmpinController.clear();
                    Fluttertoast.showToast(
                        msg: 'Password changed successfully');
                  } else {
                    showAlertDialog(context, ALERT_DIALOG_TITLE, errorMessage);
                  }
                }
              }
            },
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            shape: StadiumBorder(),
            child: Text(
              "SUBMIT",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change PIN'),
      ),
      body: Center(
        child: ModalProgressHUD(
          inAsyncCall: _loading,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.only(top: 20, bottom: 30),
              children: <Widget>[
                _oldpinTextbox(),
                _newpinTextbox(),
                _confirmpinTextbox(),
                _submitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
