import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:sodhis_app/services/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrderHistoryPage extends StatefulWidget {
  final Object argument;

  const OrderHistoryPage({Key key, this.argument}) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderHistoryPage> {
  var _userId;
  var _orderId;
  var _date;
  Future _orderDetails;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    _orderId = data['order_id'];
    _date = data['date'];

    Preference().getPreferences().then((prefs) {
      setState(() {
        _userId = prefs.getInt('user_id').toString();
        _orderDetails = _futureOrderDetails();
      });
    });
  }

  Widget _networkImage(url) {
    return Container(
      margin: EdgeInsets.only(
        right: 8,
        left: 8,
      ),
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        //color: Colors.blue.shade200,
        image: DecorationImage(
            image: CachedNetworkImageProvider(url), fit: BoxFit.cover),
      ),
    );
  }

  void callForLoop() {
    for (int i = 0; i <= 10; i++) {
      print('For Loop Called $i Times');
    }
  }

  Future _futureOrderDetails() async {
    var response = await http.post(
        new Uri.https(BASE_URL, API_PATH + "/walletorder-summary"),
        body: {
          "user_id": _userId,
          "order_id": _orderId,
        },
        headers: {
          "Accept": "application/json",
          "authorization": basicAuth
        });
    print(jsonEncode({
      "user_id": _userId,
      "order_id": _orderId,
    }));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      // var result = data['Response'];
      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Widget _orderDetailsBuilder() {
    return FutureBuilder(
      future: _orderDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if(snapshot.data['ErrorCode']==0){
            return Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(12.0),
              child: ListView(
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.only(top: 15, left: 12, right: 12),
                          child: Container(
                            padding: const EdgeInsets.only(top: 10),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                "Delivery Date : " + _date,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          height: 26,
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /*    Padding(
                        padding:
                        const EdgeInsets.only(top: 15, left: 12, right: 12),
                        child: Text(
                          'Item Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ),
                      Divider(
                        height: 26,
                      ),*/
                              for (var i in snapshot.data['Response'])
                                ListTile(
                                  leading: _networkImage(i['product_image']),
                                  title: Text(i['product_name']),
                                  subtitle: Text('Quantity: ' + i['quantity']),
                                  trailing: i['offer_price']!=null?Text("\u20B9 " + i['offer_price']):Text("\u20B9 " + i['price']),
                                ),
                              SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          else{
            return Container();
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
        title: Text(
          'Order Details',
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        child: _orderDetailsBuilder(),
      ),
    );
  }
}
