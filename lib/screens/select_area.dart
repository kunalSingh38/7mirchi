import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SelectAreaPage extends StatefulWidget {
  @override
  _SelectAreaPageState createState() => _SelectAreaPageState();
}

class _SelectAreaPageState extends State<SelectAreaPage> {
  var _userId;
  var _cartCount;
  var _storeId;
  String dropdownValue = '';
  Future _store;
  @override
  void initState() {
    super.initState();
    _getUser();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
    });
  }

  void emptyCart() async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/cart-empty"),
      body: {
        "user_id": _userId.toString(),
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
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('cart_count', 0);
        Navigator.pushNamed(context,'/shop2');
      } else {
        Fluttertoast.showToast(msg: errorMessage);
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  showConfirmDialog(storeId,content) {
    // Set up the Button
    Widget cancelButton = FlatButton(
      child: Text('Cancel'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget doneButton = FlatButton(
      child: Text('OK'),
      onPressed: () async {
        Navigator.of(context).pop();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('store_id', storeId);
        emptyCart();
      },
    );
    // Set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Confirm'),
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

  Future _storeFuture() async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/getstore"),
      body: {
        "user_id": _userId,
        "area": dropdownValue,
      },
      headers: {
        "Accept": "application/json",
        "authorization": basicAuth,
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Widget _storeFutureBuilder() {
    return FutureBuilder(
      future: _storeFuture(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ListView.builder(
            itemCount: snapshot.data['Response'].length > 0 ? snapshot.data['Response'].length : 0,
            itemBuilder: (context, index) {
              var _errorCode = snapshot.data['ErrorCode'];
              var _response = snapshot.data['Response'];
              if (_errorCode == 0) {
                return _storeNameWidget(index, _response);
              } else {
                return Container();
              }
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _storeNameWidget(index, _response) {
    return InkWell(
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        _cartCount = prefs.getInt('cart_count');
        _storeId = prefs.getInt('store_id');
        // print(_cartCount);
        // print(_response[index]['id']);
        if(_cartCount > 0 && _storeId != _response[index]['id']){
          showConfirmDialog(_response[index]['id'],'You have selected a different store. Items from previous stores will be cleared.');
        }
        else{
          //print(_response[index]['id']);
          prefs.setInt('store_id', _response[index]['id']);
          prefs.setInt('branch_id', _response[index]['branch_id']);
          prefs.setInt('warehouse_id', _response[index]['warehouse_id']);
          Navigator.pushNamed(context,'/shop2');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 20, left: 30, right: 30, bottom:20),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Colors.grey[400],
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 8),
            child: Text(
              _response[index]['name'].toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
                _response[index]['address'].toString()),
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Icon(
              Icons.store,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin:
                const EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 10),
            child: Column(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image(
                    image: AssetImage('assets/images/gurgaon.jpg'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Select Area"),
                DropdownButton<String>(
                  underline: Container(
                    height: 1,
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      child: Text('Choose'),
                      value: '',
                    ),
                    DropdownMenuItem<String>(
                      child: Text('Sector 44'),
                      value: 'Sector 44',
                    ),
                    DropdownMenuItem<String>(
                      child: Text('Sector 45'),
                      value: 'Sector 45',
                    ),
                    DropdownMenuItem<String>(
                      child: Text('Sector 46'),
                      value: 'Sector 46',
                    ),
                    DropdownMenuItem<String>(
                      child: Text('Sector 47'),
                      value: 'Sector 47',
                    ),
                    DropdownMenuItem<String>(
                      child: Text('Sector 48'),
                      value: 'Sector 48',
                    ),
                    DropdownMenuItem<String>(
                      child: Text('Sector 49'),
                      value: 'Sector 49',
                    ),
                  ],
                  value: dropdownValue,
                  onChanged: (String value) {
                    setState(() {
                      dropdownValue = value;
                      _store = _storeFuture();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _storeFutureBuilder(),
          ),
        ],
      ),
    );
  }
}
