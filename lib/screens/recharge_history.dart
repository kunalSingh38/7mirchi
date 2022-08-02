import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RechargeHistoryPage extends StatefulWidget {
  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<RechargeHistoryPage> {
  var _userId;

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

  Future _orderLists() async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/rechargehistory"),
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
      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }


  Widget _emptyOrders() {
    return Center(child: Text('No orders found!'));
  }

  Widget _myOrdersBuilder() {
    return FutureBuilder(
      future: _orderLists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var errorCode = snapshot.data['ErrorCode'];
          var response = snapshot.data['Response'];
          if (errorCode == 0) {
            return SingleChildScrollView(
              child: Container(
                child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: response.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: <Widget>[
                       /* Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(left: 12, right: 15),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12, bottom: 10),
                            child: Text(
                              response[index]['month']+""+response[index]['year'] ,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                        SizedBox(height: 5),*/
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.only(top: 10, left: 12, right: 12,bottom: 10),
                          margin: const EdgeInsets.only(left: 12, right: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12, right: 12, bottom: 5),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(response[index]['date'], style: TextStyle(
                                          color: Colors.black87,
                                          fontFamily: 'Gotham',
                                          fontSize: 14.0)),
                                      Text(response[index]['status'],
                                          style: TextStyle(
                                          color: Color(0xFFc62714),
                                          fontFamily: 'Gotham',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13.0)),
                                    ]),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12, right: 12),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Transaction type: '+response[index]['transaction_type'], style: TextStyle(
                                color: Colors.black45,
                                    fontFamily: 'Gotham',
                                    fontSize: 12.0)),
                                      Text("\u20B9 " +response[index]['amount'], style: TextStyle(
                                      color: Colors.black,
                                          fontFamily: 'Gotham',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15.0)),
                                    ]),
                              ),

                            ],
                          ),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          } else {
            return _emptyOrders();
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recharge History'),
      ),
      body: Container(
        color: Colors.grey[200],
        child: ListView(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              _myOrdersBuilder(),
              SizedBox(
                height: 10,
              ),
            ]
      ),
      ),
    );
  }
}
