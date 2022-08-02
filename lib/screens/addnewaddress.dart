import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:sodhis_app/components/general.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddNewAddressPage extends StatefulWidget {
  @override
  _ChangeAddressPageState createState() => _ChangeAddressPageState();
}

class _ChangeAddressPageState extends State<AddNewAddressPage> {
  final _formKey = GlobalKey<FormState>();
  var _userId;
  Future _addressList;
  int id = 1;
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
      print(json.encode( {
        "user_id": _userId.toString(),
        "address_id": id.toString(),
      }));
      if (response.statusCode == 200) {
        setState(() {
          _loading = false;
        });
        var data = json.decode(response.body);
        var errorCode = data['ErrorCode'];
        var errorMessage = data['ErrorMessage'];
        if (errorCode == 0) {
          Fluttertoast.showToast(msg: 'Default Address Changed successfully');
        /*  SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('delivery_type', 'home_delivery');*/
          Navigator.of(context).pop();
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
              primary: false,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _addNewButton(),
                    ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: snapshot.data.length-1,
                      itemBuilder: (context, index) {
                        return Stack(children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 5, right: 5, top: 5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Slidable(
                              actionPane: SlidableDrawerActionPane(),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 12, bottom: 12, right: 30),
                                child: RadioListTile(
                                  groupValue: id,
                                  title: snapshot.data[index]['is_default'] == 1
                                      ? Text(snapshot.data[index]['name'] +
                                          ' (Default)', style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Gotham',
                                      fontSize: 14.0))
                                      : Text(snapshot.data[index]['name']),
                                  secondary: IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      print(snapshot.data[index]['id']
                                          .toString());
                                      if (snapshot.data[index]
                                          .containsKey('id')) {
                                        Navigator.pushNamed(
                                          context,
                                          '/add-address',
                                          arguments: <String, String>{
                                            'address_id': snapshot.data[index]
                                                    ['id']
                                                .toString(),
                                          },
                                        );
                                      } else {
                                        Fluttertoast.showToast(msg: 'Primary address cant be change');
                                      }
                                    },
                                  ),
                                  subtitle: snapshot.data[index]
                                          .containsKey('city')
                                      ? Text(snapshot.data[index]['address'] +
                                          ', ' +
                                          snapshot.data[index]['city'] +
                                          ', ' +
                                          snapshot.data[index]['state'] +
                                          ' , PIN Code: ' +
                                          snapshot.data[index]['pincode']
                                              .toString())
                                      : Text(snapshot.data[index][
                                          'address'] /*+ ', ' + snapshot.data[index]['city'] + ', ' + snapshot.data[index]['state'] + ' , PIN Code: ' + snapshot.data[index]['pincode'].toString()*/),
                                  value: snapshot.data[index]['id'],
                                  onChanged: (val) {
                                    setState(() {
                                      id = snapshot.data[index]['id'];
                                      _buttonDisabled = false;
                                    });
                                  },
                                ),
                              ),
                              secondaryActions: <Widget>[
                                IconSlideAction(
                                  caption: 'Delete',
                                  color: Colors.red,
                                  icon: Icons.delete,
                                  onTap: () {
                                    if (snapshot.data[index]
                                        .containsKey("id")) {
                                      showConfirmDialog(
                                          snapshot.data[index]['id'],
                                          'Cancel',
                                          'Remove',
                                          'Remove Item',
                                          'Are you sure want to remove this item?');
                                    } else {
                                      Fluttertoast.showToast(
                                          msg:
                                              'Primary address cant be delete');
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ]);
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

  void removeAddress(addressId) async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/addressesdelete"),
      body: {
        "user_id": _userId.toString(),
        "address_id": addressId.toString(),
      },
      headers: {
        "Accept": "application/json",
        "authorization": basicAuth,
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var errorCode = data['ErrorCode'];
      var errorMessage = data['ErrorMessage'];
      if (errorCode == 0) {
        Fluttertoast.showToast(msg: 'Address removed successfully');
      } else {
        Fluttertoast.showToast(msg: errorMessage);
      }
      setState(() {
        _addressList = _futureAddress();
      });
    } else {
      throw Exception('Something went wrong');
    }
  }

  showConfirmDialog(id, cancel, done, title, content) {
    print(id);
    // Set up the Button
    Widget cancelButton = FlatButton(
      child: Text(cancel),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget doneButton = FlatButton(
      child: Text(done),
      onPressed: () {
        Navigator.of(context).pop();
        removeAddress(id);
        // _cart.showCartBadge(_userId);
      },
    );

    // Set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        cancelButton,
        doneButton,
      ],
    );

    // Show the Dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _addNewButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/add-address-home');
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
              "Deliver to this Address",
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
        title: Text('Add New Address'),
      ),
      body: _addressBuilder(),
    );
  }
}
