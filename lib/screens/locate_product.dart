import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sodhis_app/components/general.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';

class LocateProductPage extends StatefulWidget {
  final Object argument;
  const LocateProductPage({Key key, this.argument}) : super(key: key);
  @override
  _LocateProductPageState createState() => _LocateProductPageState();
}

class _LocateProductPageState extends State<LocateProductPage> {
  var _userId;
  bool _loaded = false;
  String _productName = 'Loading...';
  String _shelfImage;
  var _barcode;
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    _barcode = data['barcode'];
    getUser();
  }

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
    });
    locateProduct();
  }

  locateProduct() async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/locate-product"),
      body: {
        "user_id": _userId,
        "barcode": _barcode,
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
        setState(() {
          _shelfImage = data['Response']['shelf_image'];
          _loaded = true;
          _productName = data['Response']['item_name'];
        });
      }
      else if (errorCode == -101) {
        showAlertWithBackDialog(context, ALERT_DIALOG_TITLE, 'Sorry this product is not available.');
      }
      else {
        showAlertWithBackDialog(context, ALERT_DIALOG_TITLE, errorMessage);
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_productName),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: _loaded ? Image.network(_shelfImage) : Text(''),
        ),
      ),
    );
  }
}
