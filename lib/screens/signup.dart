import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'package:flutter/services.dart';
import 'package:sodhis_app/components/general.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class SignupPage extends StatefulWidget {
  final String name;
  final String mobile;
  final String email;
  final String address;
  SignupPage({Key key, this.name, this.mobile, this.email, this.address})
      : super(key: key);
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  TextEditingController addressController = TextEditingController()..text;
  final _formKey = GlobalKey<FormState>();
  var _name;
  var _mobile;
  var _email;
  var _address;
  bool _loading = false;
  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  /*_getCurrentLocation() async {
    Position position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    setState(() {
        _address = place.street+', '+place.name+', '+place.subLocality+', '+place.locality+' - '+place.postalCode;
        addressController = TextEditingController()..text = _address;
    });
  }*/

  Widget _welcomeText() {
    return Container(
      padding: const EdgeInsets.only(left: 30),
      child: Text(
        "Welcome to 7mirchi's Mart!",
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _signupText() {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 30),
      child: Text(
        "SIGN UP",
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _nameTextbox() {
    return Container(
      margin: new EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: nameController,
          cursorColor: Color(0xFF372D61),
          textCapitalization: TextCapitalization.sentences,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter full name';
            }
            return null;
          },
          onSaved: (String value) {
            _name = value;
          },
          decoration: InputDecoration(
            hintText: 'Full Name',
          ),
        ),
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

  Widget _emailTextbox() {
    return Container(
      margin: new EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          cursorColor: Color(0xFF372D61),
          validator: (value) {
            Pattern pattern =
                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
            RegExp regex = new RegExp(pattern);
            if (value.isEmpty) {
              return 'Please enter email address';
            } else if (!regex.hasMatch(value)) {
              return 'Please enter valid email address';
            } else {
              return null;
            }
          },
          onSaved: (String value) {
            _email = value;
          },
          decoration: InputDecoration(
            hintText: 'Email Address',
          ),
        ),
      ),
    );
  }

  Widget _addressTextbox() {
    return Container(
      margin: new EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: addressController,
          cursorColor: Color(0xFF372D61),
          textCapitalization: TextCapitalization.sentences,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter address';
            }
            return null;
          },
          onSaved: (String value) {
            _address = value;
          },
          decoration: InputDecoration(
            hintText: 'Address',
          ),
        ),
      ),
    );
  }

  Widget _addressTextbox2() {
    return Container(
      margin: new EdgeInsets.only(left: 30, bottom:20),
      width: (MediaQuery.of(context).size.width)-100,
      child: TextFormField(
        maxLines: null,
        controller: addressController,
        cursorColor: Color(0xFF372D61),
        textCapitalization: TextCapitalization.sentences,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter address';
          }
          return null;
        },
        onSaved: (String value) {
          _address = value;
        },
        decoration: InputDecoration(
          hintText: 'Address',
        ),
      ),
    );
  }

  Widget _gpsButton() {
    return Container(
      margin: new EdgeInsets.only(right:15),
      child: IconButton(
        icon: Icon(
          Icons.gps_fixed,
        ),
        //iconSize: 50,
        color: Colors.green,
        splashColor: Colors.purple,
        onPressed: () {
          //_getCurrentLocation();
        },
      ),
    );
  }

  Widget _signupButton() {
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
                    new Uri.https(BASE_URL, API_PATH + "/signup"),
                    body: {
                      "name": nameController.text,
                      "mobile_number": mobileController.text,
                      "email_address": emailController.text,
                      "address": addressController.text,
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
                  //  Fluttertoast.showToast(msg: 'OTP: ' + data['Response']['OTP'].toString());
                    Navigator.pushNamed(
                      context,
                      '/otp-signup',
                      arguments: <String, String>{
                        'name': nameController.text,
                        'mobile': mobileController.text,
                        'email': emailController.text,
                        'address': addressController.text,
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
            //borderSide: BorderSide(color: Colors.pink),
            child: Text(
              "SIGN UP",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginContainer() {
    return Container(
      padding: const EdgeInsets.only(top: 0, left: 30, right: 30),
      child: Align(
        alignment: Alignment.center,
        child: RichText(
          text: TextSpan(
            text: "Already have an account? ",
            style: TextStyle(color: Colors.grey[700]),
            children: <TextSpan>[
              TextSpan(
                text: 'Sign in',
                style: TextStyle(
                  color: Color(0xFF372D61),
                ),
                recognizer: new TapGestureRecognizer()
                  ..onTap = () => Navigator.pop(context),
              ),
            ],
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
                      _signupText(),
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
                          _nameTextbox(),
                          _mobileTextbox(),
                          _emailTextbox(),
                          //_addressTextbox(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              _addressTextbox2(),
                              _gpsButton(),
                            ]
                          ),
                          _signupButton(),
                          _loginContainer(),
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
