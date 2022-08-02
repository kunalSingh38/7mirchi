import 'dart:convert';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sodhis_app/screens/wallet.dart';
import 'package:sodhis_app/utilities/basic_auth.dart';
import '../constants.dart';
import 'multislider_home.dart';
import 'my_orders.dart';

import 'package:http/http.dart' as http;

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  var _userId;
  Future _walletBalance;
  var amount = 0;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      _walletBalance = walletBalance(prefs);
    });
    print("Wallet Balance "+_walletBalance.toString());
  }

  Future walletBalance(SharedPreferences prefs) async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/walletbalance"),
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
      setState(() {
        amount = int.parse(double.parse(data['Response']['total_balance']).round().toString());
        prefs.setString("walletBalance", amount.toString());
      });

      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
                backgroundColor: Colors.teal,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                    shape: BadgeShape.square,
                    toAnimate: false,
                    borderRadius: BorderRadius.circular(8),
                    animationType: BadgeAnimationType.scale,
                    padding: EdgeInsetsDirectional.only(start: 3, end: 3, top: 2, bottom: 2),
                    badgeContent: Text("\u20B9 " + amount.toString(), style: TextStyle(color: Colors.white, fontSize: 8)),
                    child: Icon(Icons.account_balance_wallet)),
                label: 'My Wallet',
              ),
              /*BottomNavigationBarItem(
            icon: Icon(Icons.location_city),
            title: Text('Location'),
          ),*/
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: <Widget>[
              HomePageMultislider(),
              MyOrdersPage(),
              MyWallet(),
              //ShopPage(),
              // LocationPage(),
            ],
          ),
        ),
        onWillPop: () async{
           exit(0);
        }
    );
  }

  Widget _storeLocationsBuilder() {
    return SizedBox.shrink();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
