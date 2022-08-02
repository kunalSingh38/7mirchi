import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:sodhis_app/components/general.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeAddressPage extends StatefulWidget {
  @override
  _ChangeAddressPageState createState() => _ChangeAddressPageState();
}

class _ChangeAddressPageState extends State<ChangeAddressPage> {
  final _formKey = GlobalKey<FormState>();
  var _userId;
  Future _addressList;
  int id;
  bool _loading = false;
  bool _buttonDisabled = true;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void dispose() {
    super.dispose();
  }

  void _defaultAddress() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _loading = true;
      });
      var response = await http.post(
        new Uri.https(BASE_URL, API_PATH + "/address-default"),
        body: {
          "user_id": _userId.toString(),
          "address_id": id.toString(),
        },
        headers: {"Accept": "application/json", "authorization": basicAuth},
      );
      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
        });
        var data = json.decode(response.body);
        var errorCode = data['ErrorCode'];
        var errorMessage = data['ErrorMessage'];
        if (errorCode == 0) {
          Navigator.pushNamed(context, '/checkout', arguments: <String, String>{
            'additional_instruction': "",
          },);
        } else {
          showAlertDialog(context, ALERT_DIALOG_TITLE, errorMessage);
        }
      }
    }
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      _addressList = _futureAddress();
    });
  }

  Future _futureAddress() async {
    var response = await http
        .post(new Uri.https(BASE_URL, API_PATH + "/addresses"), body: {
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

  Widget _addressBuilder() {
    return FutureBuilder(
      future: _addressList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ModalProgressHUD(
            inAsyncCall: _loading,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _addNewButton(),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              top: 12, bottom: 12, right: 30),
                          child: RadioListTile(
                            groupValue: id,
                            title: snapshot.data[index]['is_default'] == 1
                                ? Text(
                                    snapshot.data[index]['name'] + ' (Default)')
                                : Text(snapshot.data[index]['name']),
                            subtitle:snapshot.data[index].containsKey('city')?
                            Text(snapshot.data[index]['address'] + ', ' + snapshot.data[index]['city'] + ', ' + snapshot.data[index]['state'] + ' , PIN Code: ' + snapshot.data[index]['pincode'].toString())
                                :Text(snapshot.data[index]['address'] /*+ ', ' + snapshot.data[index]['city'] + ', ' + snapshot.data[index]['state'] + ' , PIN Code: ' + snapshot.data[index]['pincode'].toString()*/),
                            value: snapshot.data[index]['id'],
                            onChanged: (val) {
                              setState(() {
                                id = val;
                                _buttonDisabled = false;
                              });
                            },
                          ),
                        );
                      },
                    ),
                    _submitButton(),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _addNewButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/add-address');
      },
      child: Ink(
        color: Colors.white,
        child: ListTile(
          leading: Icon(
            Icons.add,
            color: Theme.of(context).accentColor,
          ),
          title: Text("Add New Address"),
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
            onPressed: _buttonDisabled ? null : _defaultAddress,
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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Address'),
      ),
      body: _addressBuilder(),
    );
  }
}
