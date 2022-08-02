import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'package:flutter/services.dart';
import 'package:sodhis_app/components/general.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ForgotPinPage extends StatefulWidget {
  final String mobile = '';
  ForgotPinPage() : super();
  @override
  _ForgotPinPageState createState() => _ForgotPinPageState();
}

class _ForgotPinPageState extends State<ForgotPinPage> {
  final mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _mobile;
  bool _loading = false;
  @override
  void dispose() {
    mobileController.dispose();
    super.dispose();
  }

  Widget _welcomeText() {
    return Container(
      padding: const EdgeInsets.only(left: 30),
      child: Text(
        "Welcome to 7mirchi's Mart!",
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _forgotpasswordText() {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 30),
      child: Text(
        "RESET PIN",
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _mobileTextbox() {
    return Container(
      margin: new EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: mobileController,
          keyboardType: TextInputType.number,
          cursorColor: Color(0xFF372D61),
          textCapitalization: TextCapitalization.sentences,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter 10 digit mobile number';
            } else if (value.length < 10) {
              return 'Please enter 10 digit mobile number';
            } else if (value.length > 10) {
              return 'Please enter 10 digit mobile number';
            }
            return null;
          },
          onSaved: (String value) {
            _mobile = value;
          },
          decoration: InputDecoration(
            hintText: 'Mobile Number',
          ),
        ),
      ),
    );
  }

  Widget _nextButton() {
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
                    new Uri.https(BASE_URL, API_PATH + "/forgot-pin"),
                    body: {
                      "mobile_number": mobileController.text,
                    },
                    headers: {
                      "Accept": "application/json",
                      "authorization": basicAuth
                    });
                if (response.statusCode == 200) {
                  setState(() {
                    _loading = false;
                  });
                  var data = json.decode(response.body);
                  var errorCode = data['ErrorCode'];
                  var errorMessage = data['ErrorMessage'];
                  if (errorCode == 0) {
                    //var response = data['Response']['OTP'].toString();
                   // Fluttertoast.showToast(msg: 'OTP: ' + data['Response']['OTP'].toString());
                    Navigator.pushNamed(
                      context,
                      '/otp-forgotpin',
                      arguments: <String, String>{
                        'mobile': mobileController.text,
                      },
                    );
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
              "NEXT",
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
      backgroundColor: Color(0xFF372D61),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        child: SafeArea(
          child: Container(
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Center(
                    child: ListView(shrinkWrap: true, children: <Widget>[
                      _welcomeText(),
                      _forgotpasswordText(),
                    ]),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.only(top: 20, bottom: 30),
                        children: <Widget>[
                          _mobileTextbox(),
                          _nextButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
