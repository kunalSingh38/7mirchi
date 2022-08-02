import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'package:underline_otp_text_field/underline_otp_text_field.dart';
import 'package:sodhis_app/components/general.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ResetPin extends StatefulWidget {
  final Object arg;
  const ResetPin({Key key, this.arg}) : super(key: key);
  @override
  _ResetPinState createState() => _ResetPinState();
}

class _ResetPinState extends State<ResetPin> {
  final TextEditingController _otpTextFieldController = TextEditingController();
  var _mobile;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.arg);
    var data = json.decode(encodedJson);
    _mobile = data['mobile'];
    print(_mobile);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF372D61),
      //backgroundColor: Colors.grey,
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
                    'Create PIN',
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
                    'Please set your 6 digit PIN to complete pin reset',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 50, left: 10),
                child: Align(
                  alignment: Alignment.center,
                  child: UnderlineOtpTextField(
                    textColor: Colors.white,
                    underLineColor: Colors.white,
                    onValueChanged: (value) async {
                      if (value.length == 6) {
                        setState(() {
                          _loading = true;
                        });
                        var response = await http.post(
                          new Uri.https(BASE_URL, API_PATH + "/create-pin"),
                          body: {
                            "mobile_number": _mobile,
                            "pin": value,
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
                            Widget okButton = FlatButton(
                              child: Text("OK"),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/login', (Route<dynamic> route) => false);
                              },
                            );
                            return showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Alert"),
                                  content: Text("Reset PIN Successfull"),
                                  actions: [
                                    okButton,
                                  ],
                                );
                              },
                            );
                          } else {
                            showAlertDialog(
                                context, ALERT_DIALOG_TITLE, errorMessage);
                          }
                        }
                      }
                    },
                    controller: _otpTextFieldController,
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
