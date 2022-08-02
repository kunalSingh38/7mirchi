import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/components/general.dart';
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  var _userId;
  String _name;
  String _shortName = '';
  String _mobile_number;
  String _email_address;
  String _address;
  Future<dynamic> _editProfile;

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      _name = prefs.getString('name');
      _shortName = _name[0];
      _mobile_number = prefs.getString('mobile_number');
      _email_address = prefs.getString('email_address');
      _address = prefs.getString('address');
      _editProfile = _editProfileData();
    });
  }

  Widget _nameTextbox(_initialValue) {
    return Container(
      margin: new EdgeInsets.only(top: 10, left: 30, right: 30, bottom: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          initialValue: _initialValue,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: Color(0xFF372D61),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
          onSaved: (String value) {
            nameController.text = value;
          },
          decoration: InputDecoration(
            labelText: 'Full Name',
            filled: true,
            fillColor: Colors.white,
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

  Widget _mobileTextbox(_initialValue) {
    return Container(
      margin: new EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          initialValue: _initialValue,
          keyboardType: TextInputType.number,
          cursorColor: Color(0xFF372D61),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter your mobile number';
            }
            return null;
          },
          onSaved: (String value) {
            mobileController.text = value;
          },
          decoration: InputDecoration(
            labelText: 'Mobile Number',
            filled: true,
            fillColor: Colors.white,
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

  Widget _emailTextbox(_initialValue) {
    return Container(
      margin: new EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          initialValue: _initialValue,
          keyboardType: TextInputType.emailAddress,
          cursorColor: Color(0xFF372D61),
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter your email address';
            }
            return null;
          },
          onSaved: (String value) {
            emailController.text = value;
          },
          decoration: InputDecoration(
            labelText: 'Email Address',
            filled: true,
            fillColor: Colors.white,
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

  Widget _addressTextbox(_initialValue) {
    return Container(
      margin: new EdgeInsets.only(left: 30, right: 30, bottom: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          initialValue: _initialValue,
          cursorColor: Color(0xFF372D61),
          maxLines: 5,
          validator: (value) {
            if (value.isEmpty) {
              return 'Please enter your address';
            }
            return null;
          },
          onSaved: (String value) {
            addressController.text = value;
          },
          decoration: InputDecoration(
            labelText: 'Address',
            filled: true,
            fillColor: Colors.white,
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
                  new Uri.https(BASE_URL, API_PATH + "/edit-profile"),
                  body: {
                    "user_id": _userId.toString(),
                    "name": nameController.text,
                    "mobile_number": mobileController.text,
                    "email_address": emailController.text,
                    "address": addressController.text,
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
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString('name', nameController.text);
                    prefs.setString(
                        'email_address', mobileController.text);
                    prefs.setString(
                        'mobile_number', emailController.text);
                    prefs.setString('address', addressController.text);
                    Fluttertoast.showToast(msg: 'Profile updated successfully');
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
              "UPDATE",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _editProfileData() async {
    var response = await http
        .post(new Uri.https(BASE_URL, API_PATH + "/my-profile"), body: {
      "user_id": _userId,
    }, headers: {
      "Accept": "application/json",
      "authorization": basicAuth
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['Response'];
      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Widget _editprofileBuilder() {
    return FutureBuilder(
      future: _editProfile,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    AvatarGlow(
                      startDelay: Duration(milliseconds: 1000),
                      glowColor: Colors.blue,
                      endRadius: 90.0,
                      duration: Duration(milliseconds: 2000),
                      repeat: true,
                      showTwoGlows: true,
                      repeatPauseDuration: Duration(milliseconds: 100),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFF372D61),
                        child: Text(
                          snapshot.data['name'][0],
                          style: TextStyle(color: Colors.white, fontSize: 50),
                        ),
                      ),
                      shape: BoxShape.circle,
                      animate: true,
                      curve: Curves.fastOutSlowIn,
                    ),
                    _nameTextbox(snapshot.data['name']),
                    _mobileTextbox(snapshot.data['mobile_number']),
                    _emailTextbox(snapshot.data['email_address']),
                    _addressTextbox(snapshot.data['address']),
                    _submitButton(),
                  ],
                ),
              ),
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Center(
        child: ModalProgressHUD(
          inAsyncCall: _loading,
          child: _editprofileBuilder(),
        ),
      ),
    );
  }
}
