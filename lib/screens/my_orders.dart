import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/screens/dashboard.dart';
import 'package:sodhis_app/screens/multislider_home.dart';
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyOrdersPage extends StatefulWidget {
  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
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
      new Uri.https(BASE_URL, API_PATH + "/my-orders"),
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

  Widget _networkImage(url) {
    return Image(
      image: CachedNetworkImageProvider(url),
    );
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
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  padding: EdgeInsets.zero,
                  itemCount: response.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: <Widget>[
                        SizedBox(
                          height: 12,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/order-details',
                              arguments: <String, String>{
                                'order_id': response[index]['id'].toString(),
                              },
                            );
                          },
                          child: Container(
                            height: 120,
                            width: double.infinity,
                            child: Card(
                               elevation: 4.0,
                               child: Container(
                                  decoration: BoxDecoration(
                                     color: Colors.white,
                                     borderRadius: BorderRadius.all(Radius.circular(8.0))
                                  ),
                                 child: Padding(
                                   padding: const EdgeInsets.all(10.0),
                                   child: Column(
                                     children: [
                                        Align(
                                           alignment: Alignment.topLeft,
                                           child: Text(
                                               response[index]['order_date'].toString(),
                                               style: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.bold)
                                           ),
                                        ),
                                        SizedBox(height: 10),
                                        Divider(
                                           color: Colors.grey,
                                           height: 1,
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children: [
                                              Column(
                                                 mainAxisAlignment: MainAxisAlignment.start,
                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                 children: [
                                                    Text("Total Items", style: TextStyle(color: Colors.grey, fontSize: 16.0)),
                                                    SizedBox(height: 4.0),
                                                    Text(response[index]['total_items'].toString(), textAlign: TextAlign.start, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18.0)),
                                                 ],
                                              ),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                               children: [
                                                 Text("Total Amount", style: TextStyle(color: Colors.grey, fontSize: 16.0)),
                                                 SizedBox(height: 4.0),
                                                 Text(
                                                     "\u20B9 "+response[index]['total'].toString(),
                                                     style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18.0)
                                                 ),
                                               ],
                                             ),
                                             Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red)
                                           ],
                                        )
                                     ],
                                   ),
                                 ),
                               ),
                            ),
                          ),
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

  Widget _getStatus(String statusvalue){
    if(statusvalue == "1"){
       return Text("New", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w700));
    }

  }

  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text('My Orders'),
            /*leading: InkWell(
               onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/multislider-home', (route) => false),
               child: Icon(Icons.arrow_back, color: Colors.white, size: 24.0),
            ),*/
          ),
          body: Container(
            child: _myOrdersBuilder(),
          ),
        ),
        onWillPop: () async {
          return Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => DashboardPage()));
        });
  }
}
