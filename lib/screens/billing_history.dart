import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BillingHistoryPage extends StatefulWidget {
  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<BillingHistoryPage> {
  var _userId;
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  var _startDate;
  var _endDate;
  var finalDate, finalDate2;
  Future _billingList;
  bool click = false;

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

  Future _orderLists(String startDate, String endDate) async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/billinghistory"),
      body: {"user_id": _userId, "from_date": startDate, "to_date": endDate},
      headers: {
        "Accept": "application/json",
        "authorization": basicAuth,
      },
    );
    print(jsonEncode({"user_id": _userId, "from_date": startDate, "to_date": endDate}));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
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

  void callDatePicker() async {
    var order = await getDate();
    setState(() {
      finalDate = order;
      var formatter = new DateFormat('dd-MMM-yyyy');
      String formatted = formatter.format(finalDate);
      print(formatted);
      startDateController.text = formatted.toString();
    });
  }

  Future<DateTime> getDate() {
    // Imagine that this function is
    // more complex and slow.
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime(2050),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData(
              primaryColor: Color(0xFFc62714),
              accentColor: Color(0xFFc62714),
              primarySwatch: MaterialColor(
                0xFFc62714,
                const <int, Color>{
                  50: const Color(0xFFc62714),
                  100: const Color(0xFFc62714),
                  200: const Color(0xFFc62714),
                  300: const Color(0xFFc62714),
                  400: const Color(0xFFc62714),
                  500: const Color(0xFFc62714),
                  600: const Color(0xFFc62714),
                  700: const Color(0xFFc62714),
                  800: const Color(0xFFc62714),
                  900: const Color(0xFFc62714),
                },
              )),
          child: child,
        );
      },
    );
  }

  void callDatePicker2() async {
    var order = await getDate2();
    setState(() {
      finalDate2 = order;
      var formatter = new DateFormat('dd-MMM-yyyy');
      String formatted = formatter.format(finalDate2);
      print(formatted);
      endDateController.text = formatted.toString();
    });
  }

  Future<DateTime> getDate2() {
    // Imagine that this function is
    // more complex and slow.
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime(2050),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData(
              primaryColor: Color(0xFFc62714),
              accentColor: Color(0xFFc62714),
              primarySwatch: MaterialColor(
                0xFFc62714,
                const <int, Color>{
                  50: const Color(0xFFc62714),
                  100: const Color(0xFFc62714),
                  200: const Color(0xFFc62714),
                  300: const Color(0xFFc62714),
                  400: const Color(0xFFc62714),
                  500: const Color(0xFFc62714),
                  600: const Color(0xFFc62714),
                  700: const Color(0xFFc62714),
                  800: const Color(0xFFc62714),
                  900: const Color(0xFFc62714),
                },
              )),
          child: child,
        );
      },
    );
  }

  void _showCouponModeDialog(context,credit,date) {
    showDialog(
      context: context,
      barrierDismissible: true,
      // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Container(
            padding: const EdgeInsets.only(
                top: 10),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "Recharge Details",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black),
              ),
            ),
          ),
          content: new Container(
            child: new Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                        top: 10, bottom: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, bottom: 12),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recharge Amount : ',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              Text(
                                "\u20B9 " + credit,
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, bottom: 12),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recharge Date : ',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              Text(
                                date,
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ]),
                      ),
                      SizedBox(height: 20),
                      Container(
                        margin: new EdgeInsets.only(
                            top: 20, left: 80, right: 80),
                        child: Align(
                          alignment: Alignment.center,
                          child: ButtonTheme(
                            minWidth: MediaQuery.of(context).size.width,
                            child: RaisedButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              shape: StadiumBorder(),
                              child: Text(
                                "OK",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /*Future<void> showInformationDialog(BuildContext context,date) async {
    return await showDialog(
        context: context,
        builder: (context) {
          bool isChecked = false;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Container(
                padding: const EdgeInsets.only(
                    top: 10),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    "Delivery Date "+date,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black),
                  ),
                ),
              ),
              content: Center(
                child: Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.only(top: 15, left: 5, right: 5),
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
                        *//*for (var i in snapshot.data['items'])
                          ListTile(
                            leading: _networkImage(i['product_image']),
                            title: Text(i['product_name']),
                            subtitle: Text('Quantity: ' + i['quantity']),
                            trailing: Text("\u20B9 " + i['price']),
                          ),*//*
                        SizedBox(height: 12),
                      ],
                    ),

                ),
              ),
              *//* title: Center(
                  child: Text(
                    AppTranslations.of(context).text('Reported Content'),
                    style: TextStyle(color: Color(0xff696b9e)),
                  )),*//*

            );
          });
        });
  }*/

  Widget _myOrdersBuilder() {
    return FutureBuilder(
      future: _billingList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var errorCode = snapshot.data['ErrorCode'];
          var response = snapshot.data['Response'];
          if (errorCode == 0) {
            return Column(children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(5)),
                  color: Colors.grey[300],
                ),
                padding: const EdgeInsets.only(
                    top: 8, left: 12, right: 12, bottom: 8),
                margin: const EdgeInsets.only(left: 12, right: 12),

                child: Row(children: <Widget>[
                  Expanded(
                      child: Text("Date",
                          style: TextStyle(
                              color: Colors.black87,
                              fontFamily: 'Gotham',
                              fontSize: 14.0))),
                  Expanded(
                      child: Text("Debit",
                          style: TextStyle(
                              color: Colors.black87,
                              fontFamily: 'Gotham',
                              fontSize: 14.0))),
                  Expanded(
                      child: Text("Credit",
                          style: TextStyle(
                              color: Colors.black87,
                              fontFamily: 'Gotham',
                              fontSize: 14.0))),
                  Expanded(
                      child: Text("Balance",
                          style: TextStyle(
                              color: Colors.black87,
                              fontFamily: 'Gotham',
                              fontSize: 14.0))),
                  Expanded(
                      child: Text("      ",
                          style: TextStyle(
                              color: Colors.black87,
                              fontFamily: 'Gotham',
                              fontSize: 14.0))),
                ]),
              ),
              SizedBox(
                height: 5,
              ),
              ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: snapshot.data['Response'].length,
                itemBuilder: (context, index) {
                  return Column(children: <Widget>[
                    InkWell(
                      onTap: () {
                        if( snapshot.data['Response'][index]['credit']!="0.00"){
                          _showCouponModeDialog(context,snapshot.data['Response'][index]['credit'],
                              snapshot.data['Response'][index]['date']);
                        }

                        else {
                          Navigator.pushNamed(
                            context,
                            '/order-history',
                            arguments: <String, String>{
                              'order_id': response[index]['order_id'].toString(),
                              'date': response[index]['date'].toString(),
                            },
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(5)),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.only(
                            top: 8, left: 12, right: 12, bottom: 8),
                        margin: const EdgeInsets.only(left: 12, right: 12),

                        child: Row(children: <Widget>[
                          Expanded(
                              child: Text(
                                  snapshot.data['Response'][index]['date']
                                      .substring(
                                          0,
                                          snapshot
                                                  .data['Response'][index]
                                                      ['date']
                                                  .length -
                                              5),
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontFamily: 'Gotham',
                                      fontSize: 14.0))),
                          snapshot.data['Response'][index]['debit'] != "0.00"
                              ? Expanded(
                                  child: Text(
                                      "\u20B9 " +
                                          snapshot.data['Response'][index]
                                              ['debit'].substring(
                                              0,
                                              snapshot
                                                  .data['Response'][index]
                                              ['debit']
                                                  .length -
                                                  3),
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontFamily: 'Gotham',
                                          fontSize: 14.0)))
                              : Expanded(
                                  child: Text("",
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontFamily: 'Gotham',
                                          fontSize: 14.0))),
                          snapshot.data['Response'][index]['credit'] != "0.00"
                              ? Expanded(
                                  child: Text(
                                      "\u20B9 " +
                                          snapshot.data['Response'][index]
                                              ['credit'].substring(
                                              0,
                                              snapshot
                                                  .data['Response'][index]
                                              ['credit']
                                                  .length -
                                                  3),
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontFamily: 'Gotham',
                                          fontSize: 14.0)))
                              : Expanded(
                                  child: Text("",
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontFamily: 'Gotham',
                                          fontSize: 14.0))),
                          Expanded(
                              child: Text(
                                  "\u20B9 " +
                                      snapshot.data['Response'][index]
                                          ['total_amount'].substring(
                                          0,
                                          snapshot
                                              .data['Response'][index]
                                          ['total_amount']
                                              .length -
                                              3),
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontFamily: 'Gotham',
                                      fontSize: 14.0))),

                          Expanded(
                              child: Text(
                                 "DETAILS",
                                  style: TextStyle(
                                      color: Color(0xFFc62714),
                                      fontFamily: 'Gotham',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.0, decoration: TextDecoration.underline)))
                        ]),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                  ]);
                },
              ),
            ]);
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
        title: Text('Billing History'),
      ),
      body: Container(
        color: Colors.grey[200],
        child: ListView(children: <Widget>[
          Container(
            margin: const EdgeInsets.all(15),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 12, right: 12),
                  child: Text(
                    'Start date',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 12, right: 12),
                  child: Container(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: () {
                          callDatePicker();
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                        child: TextFormField(
                          enabled: false,
                          controller: startDateController,
                          keyboardType: TextInputType.text,
                          cursorColor: Color(0xFF372D61),
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter start date';
                            }
                            return null;
                          },
                          onSaved: (String value) {
                            _startDate = value;
                          },
                          decoration: InputDecoration(
                            hintText: 'Start Date',
                            isCollapsed: true,
                            contentPadding: EdgeInsets.only(bottom: 5.0),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            hintStyle:
                                TextStyle(color: Colors.black45, fontSize: 12),
                            suffixIconConstraints: BoxConstraints(
                              minWidth: 2,
                              minHeight: 2,
                            ),
                            isDense: true,
                            suffixIcon: Icon(
                              Icons.date_range,
                              size: 14,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 12, right: 12),
                  child: Text(
                    'End date',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 12, right: 12),
                  child: Container(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: () {
                          if (finalDate != null) {
                            callDatePicker2();
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Please select from date first');
                          }
                        },
                        child: TextFormField(
                          enabled: false,
                          controller: endDateController,
                          keyboardType: TextInputType.text,
                          cursorColor: Color(0xFF372D61),
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter end date';
                            }
                            return null;
                          },
                          onSaved: (String value) {
                            _startDate = value;
                          },
                          decoration: InputDecoration(
                            hintText: 'End Date',
                            isCollapsed: true,
                            contentPadding: EdgeInsets.only(bottom: 5.0),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            hintStyle:
                                TextStyle(color: Colors.black45, fontSize: 12),
                            suffixIconConstraints: BoxConstraints(
                              minWidth: 2,
                              minHeight: 2,
                            ),
                            isDense: true,
                            suffixIcon: Icon(
                              Icons.date_range,
                              size: 14,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 150,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: RaisedButton(
                        onPressed: () {
                          if (finalDate2 != null) {
                            setState(() {
                              click = true;
                            });
                            _billingList = _orderLists(startDateController.text,
                                endDateController.text);
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Please select end date first');
                          }
                        },
                        color: Color(0xFFc62714),
                        elevation: 10,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20),
                        ),
                        child: Text(
                          "GET BILL",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Gotham',
                              fontSize: 15.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          click
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(left: 12, right: 15),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12, bottom: 10),
                    child: Text(
                      'Transactions',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 18),
                    ),
                  ),
                )
              : Container(),
          click ? _myOrdersBuilder() : Container()
        ]),
      ),
    );
  }
}
