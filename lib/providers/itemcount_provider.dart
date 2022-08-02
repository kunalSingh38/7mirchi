import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';

class ItemCountProvider with ChangeNotifier{
  int counter = 0;
  int totalprice = 0;
  bool _loading = true;

  getCounter() => counter;
  getTotalPrice() => totalprice;
  //isLoading() => _loading;

  void getItemData(_userId, _restaurantid) async {

    //print("Count of cart");
    var response = await http.post(new Uri.https(BASE_URL, API_PATH + "/cart-total-count"), body: {
      "user_id": _userId,
      "restaurant_id" : _restaurantid
    }, headers: {
      "Accept": "application/json",
      "authorization": basicAuth
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response'];
      counter = data['cart_total_count'];
      totalprice = data['cart_total_amt'];
      notifyListeners();
    }
  }
}