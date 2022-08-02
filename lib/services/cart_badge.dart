import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';

class CartBadge with ChangeNotifier {
  int counter = 0;
  bool _loading = true;

  getCounter() => counter;
  isLoading() => _loading;

  void showCartBadge(_userId) async {
    try{
      var response = await http.post(new Uri.https(BASE_URL, API_PATH + "/cart-badge"), body: {
        "user_id": _userId,
      }, headers: {
        "Accept": "application/json",
        "authorization": basicAuth
      });
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        counter = data['Response'];
        _loading = false;
        notifyListeners();
      }
     }
    on Exception catch (e) { 			// Anything else that is an exception
      print('Unknown exception: $e');
    } catch (e) {						// No specified type, handles all
      print('Something really unknown: $e');
    } finally {							// Always clean up, even if case of exception
    }
  }
}
