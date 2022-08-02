import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:sodhis_app/components/general.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddAddressHomePage extends StatefulWidget {
  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressHomePage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final pincodeController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  TextEditingController addressController = TextEditingController()..text;
  final landmarkController = TextEditingController();
  var _userId;
  var _name;
  var _mobile;
  var _pincode;
  var _city;
  var _state;
  var _address;
  var _landmark;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    pincodeController.dispose();
    cityController.dispose();
    stateController.dispose();
    addressController.dispose();
    landmarkController.dispose();
    super.dispose();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
    });
  }

  /*_getCurrentLocation() async {
    Position position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    setState(() {
      _address = place.name +
          ', ' +
          place.subLocality +
          ', ' +
          place.locality +
          ' - ' +
          place.postalCode;
      addressController = TextEditingController()..text = _address;
    });
  }*/

  Widget _nameTextbox() {
    return Container(
      margin: new EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        controller: nameController,
        textCapitalization: TextCapitalization.sentences,
        cursorColor: Theme.of(context).accentColor,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter your name';
          }
          return null;
        },
        onSaved: (String value) {
          _name = value;
        },
        decoration: InputDecoration(
          labelText: 'Name*',
        ),
      ),
    );
  }

  Widget _mobileTextbox() {
    return Container(
      margin: new EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        controller: mobileController,
        keyboardType: TextInputType.number,
        cursorColor: Theme.of(context).accentColor,
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
          labelText: 'Mobile Number*',
          prefixText: '+91',
        ),
      ),
    );
  }

  Widget _pincodeTextbox() {
    return Container(
      margin: new EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        controller: pincodeController,
        keyboardType: TextInputType.number,
        cursorColor: Theme.of(context).accentColor,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter your pincode';
          }
          return null;
        },
        onSaved: (String value) {
          _pincode = value;
        },
        decoration: InputDecoration(
          labelText: 'PIN Code*',
        ),
      ),
    );
  }

  Widget _cityTextbox() {
    return Container(
      margin: new EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        controller: cityController,
        textCapitalization: TextCapitalization.sentences,
        cursorColor: Theme.of(context).accentColor,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter your city';
          }
          return null;
        },
        onSaved: (String value) {
          _city = value;
        },
        decoration: InputDecoration(
          labelText: 'City*',
        ),
      ),
    );
  }

  Widget _stateTextbox() {
    return Container(
      margin: new EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        controller: stateController,
        textCapitalization: TextCapitalization.sentences,
        cursorColor: Theme.of(context).accentColor,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter your state';
          }
          return null;
        },
        onSaved: (String value) {
          _state = value;
        },
        decoration: InputDecoration(
          labelText: 'State*',
        ),
      ),
    );
  }

  Widget _addressTextbox() {
    return Container(
      margin: new EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        controller: addressController,
        textCapitalization: TextCapitalization.sentences,
        maxLines: 3,
        cursorColor: Theme.of(context).accentColor,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter your address';
          }
          return null;
        },
        onSaved: (String value) {
          _address = value;
        },
        decoration: InputDecoration(
          labelText: 'Address*',
        ),
      ),
    );
  }

  Widget _addressTextbox2() {
    return Container(
      margin: new EdgeInsets.only(left: 20, bottom: 10),
      width: (MediaQuery.of(context).size.width) - 100,
      child: TextFormField(
        controller: addressController,
        textCapitalization: TextCapitalization.sentences,
        maxLines: 3,
        cursorColor: Theme.of(context).accentColor,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter your address';
          }
          return null;
        },
        onSaved: (String value) {
          _address = value;
        },
        decoration: InputDecoration(
          labelText: 'Address*',
        ),
      ),
    );
  }

  Widget _landmarkTextbox() {
    return Container(
      margin: new EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        controller: landmarkController,
        textCapitalization: TextCapitalization.sentences,
        cursorColor: Theme.of(context).accentColor,
        validator: (value) {
          return null;
        },
        onSaved: (String value) {
          _name = value;
        },
        decoration: InputDecoration(
          labelText: 'Landmark (Optional)',
        ),
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      margin: new EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
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
                  new Uri.https(BASE_URL, API_PATH + "/address-add"),
                  body: {
                    "user_id": _userId.toString(),
                    "name": nameController.text,
                    "mobile_number": mobileController.text,
                    "pincode": pincodeController.text,
                    "city": cityController.text,
                    "state": stateController.text,
                    "address": addressController.text,
                    "landmark": landmarkController.text,
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
                    Fluttertoast.showToast(
                        msg: 'Default Address Changed successfully');
                    Navigator.pushReplacementNamed(context, '/addnewaddress');
                  } else {
                    showAlertDialog(context, ALERT_DIALOG_TITLE, errorMessage);
                  }
                }
              }
            },
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
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

  Widget _gpsButton() {
    return Container(
      margin: new EdgeInsets.only(right: 15),
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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Address'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 5),
                _nameTextbox(),
                _mobileTextbox(),
                _pincodeTextbox(),
                _cityTextbox(),
                _stateTextbox(),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _addressTextbox2(),
                      _gpsButton(),
                    ]),
                _landmarkTextbox(),
                _submitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
