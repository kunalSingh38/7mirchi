import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cart extends ChangeNotifier {

  var _myCartList;

  getCartList(_userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/cart"),
      body: {
        "user_id": _userId,
      },
      headers: {
        "Accept": "application/json",
        "authorization": basicAuth,
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      _myCartList = data;
      if(data['ErrorCode'] == 0){
        prefs.setString('item', jsonEncode(data['Response']['cart']));
        //print(jsonEncode(data['Response']['cart']));
      }
      return _myCartList;
    }
  }

  void showCartItems(_userId) async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/cart"),
      body: {
        "user_id": _userId,
      },
      headers: {
        "Accept": "application/json",
        "authorization": basicAuth,
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      _myCartList = data;
      notifyListeners();
    }
  }
}
