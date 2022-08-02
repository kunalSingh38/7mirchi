import 'package:flutter/material.dart';
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

class AddAddressPage extends StatefulWidget {
  final Object argument;
  const AddAddressPage({Key key, this.argument}) : super(key: key);
  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
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
  Future _addressData;
  var _addressId;

  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    _addressId = data['address_id'];
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

  Future _myAddressData() async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/addressesedit"),
      body: {
        "user_id": _userId,
        "address_id": _addressId.toString(),
      },
      headers: {
        "Accept": "application/json",
        "authorization": basicAuth,
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['Response'];
      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
    });
    _addressData = _myAddressData();
  }

  _getCurrentLocation() async{
    Position position = await _getGeoLocationPosition();
    GetAddressFromLatLong(position);
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
      else{

      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> GetAddressFromLatLong(Position position)async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    setState(() {
      addressController.text = '${place.street+" "+place.subLocality+" "+place.locality+" "+place.postalCode+" "+place.country}';
    });

  }

  Widget _nameTextbox(_initialValue) {
    return Container(
      margin: new EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        initialValue: _initialValue,
        // controller: nameController,
        textCapitalization: TextCapitalization.sentences,
        cursorColor: Theme.of(context).accentColor,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter your name';
          }
          return null;
        },
        onSaved: (String value) {
          nameController.text = value;
        },
        decoration: InputDecoration(
          labelText: 'Name*',
        ),
      ),
    );
  }

  Widget _mobileTextbox(_initialValue) {
    return Container(
      margin: new EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        initialValue: _initialValue,
        // controller: mobileController,
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
          mobileController.text = value;
        },
        decoration: InputDecoration(
          labelText: 'Mobile Number*',
          prefixText: '+91',
        ),
      ),
    );
  }

  Widget _pincodeTextbox(_initialValue) {
    return Container(
      margin: new EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        initialValue: _initialValue,
        // controller: pincodeController,
        keyboardType: TextInputType.number,
        cursorColor: Theme.of(context).accentColor,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter your pincode';
          }
          return null;
        },
        onSaved: (String value) {
          pincodeController.text = value;
        },
        decoration: InputDecoration(
          labelText: 'PIN Code*',
        ),
      ),
    );
  }

  Widget _cityTextbox(_initialValue) {
    return Container(
      margin: new EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        initialValue: _initialValue,
        //controller: cityController,
        textCapitalization: TextCapitalization.sentences,
        cursorColor: Theme.of(context).accentColor,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter your city';
          }
          return null;
        },
        onSaved: (String value) {
          cityController.text = value;
        },
        decoration: InputDecoration(
          labelText: 'City*',
        ),
      ),
    );
  }

  Widget _stateTextbox(_initialValue) {
    return Container(
      margin: new EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        initialValue: _initialValue,
        // controller: stateController,
        textCapitalization: TextCapitalization.sentences,
        cursorColor: Theme.of(context).accentColor,
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter your state';
          }
          return null;
        },
        onSaved: (String value) {
          stateController.text = value;
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

  Widget _addressTextbox2(_initialValue) {
    return Container(
      margin: new EdgeInsets.only(left: 20, bottom: 10),
      width: (MediaQuery.of(context).size.width) - 100,
      child: TextFormField(
        initialValue: _initialValue,
        //controller: addressController,
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
          addressController.text = value;
        },
        decoration: InputDecoration(
          labelText: 'Address*',
        ),
      ),
    );
  }

  Widget _landmarkTextbox(_initialValue) {
    return Container(
      margin: new EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: TextFormField(
        initialValue: _initialValue,
        textCapitalization: TextCapitalization.sentences,
        cursorColor: Theme.of(context).accentColor,
        validator: (value) {
          return null;
        },
        onSaved: (String value) {
          landmarkController.text = value;
        },
        decoration: InputDecoration(
          labelText: 'Landmark (Optional)',
        ),
      ),
    );
  }

  Widget _submitButton(address_id) {
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
                  new Uri.https(BASE_URL, API_PATH + "/addressesupdate"),
                  body: {
                    "user_id": _userId.toString(),
                    "address_id": address_id.toString(),
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
                    Navigator.of(context).pop();
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
          _getCurrentLocation();
        },
      ),
    );
  }

  Widget _editAddressBuilder() {
    return FutureBuilder(
      future: _addressData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 5),
                    _nameTextbox(snapshot.data[0]['name']),
                    _mobileTextbox(snapshot.data[0]['mobile_number']),
                    _pincodeTextbox(snapshot.data[0]['pincode'].toString()),
                    _cityTextbox(snapshot.data[0]['city']),
                    _stateTextbox(snapshot.data[0]['state']),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _addressTextbox2(snapshot.data[0]['address']),
                          _gpsButton(),
                        ]),
                    _landmarkTextbox(snapshot.data[0]['landmark']),
                    _submitButton(snapshot.data[0]['id']),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Address'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        child:
            _editAddressBuilder(), /*SingleChildScrollView(
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
                  ]
                ),
                _landmarkTextbox(),
                _submitButton(),
              ],
            ),
          ),
        ),*/
      ),
    );
  }
}
