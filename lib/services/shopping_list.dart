import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';

class ShoppingListProvider extends ChangeNotifier {
  var _start = true;

  startCheck() => _start;

  getShoppingList(_userId) async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/shopping-list"),
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
      var result = data['Response'];
      return result;
    }
  }

  void showShoppingList(_userId) async {
    _start = false;
    notifyListeners();
  }
}
