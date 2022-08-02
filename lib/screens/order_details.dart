import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:sodhis_app/services/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrderDetailsPage extends StatefulWidget {
  final Object argument;
  const OrderDetailsPage({Key key, this.argument}) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  var _userId;
  var _orderId;
  Future _orderDetails;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    _orderId = data['order_id'];

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
        borderRadius: BorderRadius.all(
            Radius.circular(10)),
        //color: Colors.blue.shade200,
        image: DecorationImage(
            image: CachedNetworkImageProvider(
                url),
            fit: BoxFit.cover
        ),
      ),
    );
  }

  void callForLoop() {
    for (int i = 0; i <= 10; i++) {
      print('For Loop Called $i Times');
    }
  }

  Future _futureOrderDetails() async {
    print(_userId.toString());
    print(_orderId.toString());
    var response = await http.post(new Uri.https(BASE_URL, API_PATH + "/order-details"),
        body: {
          "user_id": _userId,
          "order_id": _orderId,
    }, headers: {
      "Accept": "application/json",
      "authorization": basicAuth
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['Response'];
      print(result);
      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Widget _orderDetailsBuilder() {
    return FutureBuilder(
      future: _orderDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: ListView(
              children: <Widget>[
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 15, left: 12, right: 12),
                        child: Text(
                          'Order Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ),
                      Divider(
                        height: 26,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, bottom: 12),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Order ID'),
                              snapshot.data.containsKey('order_id')?Text(snapshot.data['order_id']):Text(""),
                            ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, bottom: 12),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Order Date'),
                              Text(snapshot.data['order_date']),
                            ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, bottom: 12),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Order Status'),
                              Text(snapshot.data['order_status']),
                            ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, bottom: 12),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Payment Mode'),
                              Text(snapshot.data['payment_mode']),
                            ]),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                        const EdgeInsets.only(top: 15, left: 12, right: 12),
                        child: Text(
                          'Shipment Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ),
                      Divider(
                        height: 26,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, bottom: 12),
                        child: Text(
                          snapshot.data['name'].toString().toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, bottom: 12),
                        child: Text(snapshot.data['address']),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, bottom: 12),
                        child:
                        Text('Phone Number: ' + snapshot.data['mobile_no']),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
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
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          padding: EdgeInsets.zero,
                          itemCount: snapshot.data['items'].length,
                          itemBuilder: (BuildContext context,int index){
                             return Padding(
                                 padding: EdgeInsets.only(left: 10, right: 10.0),
                                 child: Container(
                                    height: 90,
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 85,
                                          width: 85,
                                          child: Card(
                                            semanticContainer: true,
                                            clipBehavior: Clip.antiAliasWithSaveLayer,
                                            child: Image.network(
                                              snapshot.data['items'][index]['product_image'],
                                              fit: BoxFit.fill,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            elevation: 5,
                                            margin: EdgeInsets.all(10),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(snapshot.data['items'][index]['product_name'], style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16.0)),
                                                SizedBox(height: 3.0),
                                                snapshot.data['items'][index]['addons'].toString() != "null" ? Text(snapshot.data['items'][index]['addons'], style: TextStyle(color: Colors.grey, fontSize: 14.0)) : Text('Quantity: ' + snapshot.data['items'][index]['quantity'].toString()),
                                                SizedBox(height: 3.0),
                                                snapshot.data['items'][index]['addons'].toString() != "null" ? Text('Quantity: ' + snapshot.data['items'][index]['quantity'].toString()) : Text(""),
                                              ],
                                            )
                                        ),
                                        Text("\u20B9 " + snapshot.data['items'][index]['price'].toString()),
                                      ],
                                    ),
                                 ),
                             );
                          }
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 15, left: 12, right: 12),
                        child: Text(
                          'Price Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ),
                      Divider(
                        height: 26,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, bottom: 12),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Subtotal'),
                              Text("\u20B9 " + snapshot.data['sub_total']),
                            ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, bottom: 12),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Delivery Fee'),
                              Text("\u20B9 " + snapshot.data['delivery_fee']),
                            ]),
                      ),
                      snapshot.data['coupon_discount'].toString() == "null"  || snapshot.data['coupon_discount'].toString() == "0.00" ? Container()
                          : Padding(
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, bottom: 12),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Coupon Discount'),
                              Text("\u20B9 "+snapshot.data['coupon_discount'].toString()),
                            ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, bottom: 12),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total'),
                              Text("\u20B9 " + snapshot.data['total']),
                            ]),
                      ),
                    ],
                  ),
                ),
                /*Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Text('Payment Mode'),
                        trailing: Text(snapshot.data['payment_mode']),
                      ),
                    ],
                  ),
                ),*/
              ],
            ),
          );
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
