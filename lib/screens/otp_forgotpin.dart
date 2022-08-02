import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'package:sodhis_app/components/general.dart';
import 'dart:convert';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OtpForgotpin extends StatefulWidget {
  final Object argument;
  const OtpForgotpin({Key key, this.argument}) : super(key: key);
  @override
  _OtpForgotpinState createState() => _OtpForgotpinState();
}

class _OtpForgotpinState extends State<OtpForgotpin> {
  var _mobile;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    _mobile = data['mobile'];
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF372D61),
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        child: Container(
          child: ListView(
            padding: const EdgeInsets.only(top: 100, left: 30, right: 30),
            children: <Widget>[
              Container(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Verification Code',
                    style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Please enter the one time password sent to $_mobile',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 50),
                decoration: BoxDecoration(
                  //color: Colors.white,
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: VerificationCode(
                    textStyle: TextStyle(fontSize: 20.0, color: Colors.white),
                    keyboardType: TextInputType.number,
                    autofocus: false,
                    length: 4,

                    onCompleted: (String value) async {
                      setState(() {
                        _loading = true;
                      });
                      var response = await http.post(
                        new Uri.https(BASE_URL, API_PATH + "/verify-otp"),
                        body: {
                          "mobile_number": _mobile,
                          "otp": value,
                        },
                        headers: {
                          "Accept": "application/json",
                          "authorization": basicAuth,
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
                          Navigator.pushNamed(
                            context,
                            '/reset-pin',
                            arguments: <String, String>{
                              'mobile': _mobile,
                            },
                          );
                        } else {
                          showAlertDialog(
                              context, ALERT_DIALOG_TITLE, errorMessage);
                        }
                      }
                    },
                    onEditing: (bool value) {},
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 40, left: 30, right: 30),
                child: Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () async{
                      setState(() {
                        _loading = true;
                      });
                      var response = await http.post(
                      new Uri.https(BASE_URL, API_PATH + "/forgot-pin"),
                      body: {
                        "mobile_number": _mobile,
                      },
                      headers: {
                        "Accept": "application/json",
                        "authorization": basicAuth
                      });
                      if (response.statusCode == 200) {
                        setState(() {
                          _loading = false;
                        });
                        Fluttertoast.showToast(msg: 'OTP sent successfully');
                      }
                      else{
                        setState(() {
                          _loading = false;
                        });
                      }
                    },
                    child: Text(
                      'Resend OTP',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0, color: Colors.white,decoration: TextDecoration.underline,),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
