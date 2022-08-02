import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sodhis_app/components/CustomRadioWidget.dart';
import 'package:sodhis_app/components/RadioItem.dart';
import 'package:sodhis_app/components/ThemeColor.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:sodhis_app/services/shared_preferences.dart';
import 'package:sodhis_app/components/general.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:sodhis_app/services/cart.dart';
import 'package:sodhis_app/screens/checkoutview.dart';
import 'package:shortuuid/shortuuid.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class CheckoutPage extends StatefulWidget {
  final Object argument;

  const CheckoutPage({Key key, this.argument}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with SingleTickerProviderStateMixin {
  var _userId;
  var _storeId;
  String radioButtonItem = 'Today';
  var _timeDropdownVal = '';
  var today, tomorrow;
  int id;
  var _dateDropdownVal = 'Today';
  String formatted;
  String _subTotal;
  String _deliveryFee;
  String _total;
  String tot = "";
  String _discountedPrice;
  String _address;
  bool _proceed = false;
  bool _loading = false;
  var _additionalInstruction;
  String _paymentMode = "Online Payment";
  bool isPress1 = false;
  bool isPress2 = false;
  AnimationController _animationController;
  static const platform = const MethodChannel("razorpay_flutter");
  String _name;
  Razorpay _razorpay;
  var total, mobile_no, email_add;
  String _offersMode = "";
  List<RadioModel> sampleData = new List<RadioModel>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    _additionalInstruction = data['additional_instruction'];
    Preference().getPreferences().then((prefs) {
      setState(() {
        _userId = prefs.getInt('user_id').toString();
        _name = prefs.getString('name');
        email_add = prefs.getString('email_address');
        mobile_no = prefs.getString('mobile_number');
      });
    });
    sampleData.add(new RadioModel(
      true,
      'Online Payment',
      'A',
      Icons.credit_card,
    ));
    sampleData
        .add(new RadioModel(false, 'Cash On Delivery', 'B', MdiIcons.cash));
  }

  Future<String> generateOrderId(String key, String secret, int amount) async {
    var authn = 'Basic ' + base64Encode(utf8.encode('$key:$secret'));

    var headers = {
      'content-type': 'application/json',
      'Authorization': authn,
    };

    var data =
        '{ "amount":$amount, "currency": "INR", "receipt": "receipt#R1", "payment_capture": 1 }'; // as per my experience the receipt doesn't play any role in helping you generate a certain pattern in your Order ID!!
    var res = await http.post('https://api.razorpay.com/v1/orders',
        headers: headers, body: data);
    if (res.statusCode != 200) {
      print('ORDER ID response => ${res.body}');
      // openCheckout(json.decode(res.body)['id'].toString());
    } else {
      print('ORDER ID response => ${res.body}');
      //   openCheckout(json.decode(res.body)['id'].toString());
    }

    return json.decode(res.body)['id'].toString();
  }

  void openCheckout(var orderId, num amount) async {
    var options = {
      'key': 'rzp_test_MhKrOdDQM8C8PL',
      /* 'amount': amount*100,*/
      'name': "7mirchi",
      'order_id': orderId.toString(),
      'description': "Payment for ",
      'prefill': {'contact': mobile_no, 'email': email_add},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final ProgressDialog pr = ProgressDialog(context, isDismissible: false);
    pr.style(
      message: 'Please wait...',
    );
    Fluttertoast.showToast(msg: "SUCCESS: " + response.signature);
    print("Success: " + response.orderId.toString());
    print("Success: " + response.paymentId.toString());
    print("Success: " + response.signature.toString());

    var responses = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/transaction-status-rp"),
      body: {
        "user_id": _userId.toString(),
        "razorpay_order_id": response.orderId.toString(),
        "razorpay_payment_id": response.paymentId.toString()
      },
      headers: {
        "Accept": "application/json",
        "authorization": basicAuth,
      },
    );
    if (responses.statusCode == 200) {
      await pr.hide();
      var data = json.decode(responses.body);
      var errorCode = data['ErrorCode'];
      if (errorCode == 0) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/order-complete', (route) => false);
      } else {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/multislider-home', (route) => false);
      }
    } else {
      await pr.hide();
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/order-failed', (route) => false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message);
    print("ERROR: " + response.message);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "EXTERNAL_WALLET: " + response.walletName);
    print("EXTERNAL_WALLET: " + response.walletName);
  }

  changeThemeMode1() {
    if (isPress1) {
      _animationController.forward(from: 0.0);
    } else {
      _animationController.reverse(from: 1.0);
    }
  }

  changeThemeMode2() {
    if (isPress2) {
      _animationController.forward(from: 0.0);
    } else {
      _animationController.reverse(from: 1.0);
    }
  }

  ThemeColor lightMode = ThemeColor(
    gradient: [
      const Color(0xDDFF0080),
      const Color(0xDDFF8C00),
    ],
    backgroundColor: const Color(0xFFFFFFFF),
    textColor: const Color(0xFF000000),
    toggleButtonColor: const Color(0xFFFFFFFF),
    toggleBackgroundColor: const Color(0xFFe7e7e8),
    shadow: const [
      BoxShadow(
        color: const Color(0xFFd8d7da),
        spreadRadius: 5,
        blurRadius: 10,
        offset: Offset(0, 5),
      ),
    ],
  );

  ThemeColor darkMode = ThemeColor(
    gradient: [
      const Color(0xFF8983F7),
      const Color(0xFFA3DAFB),
    ],
    backgroundColor: Colors.grey[300],
    textColor: const Color(0xFFFFFFFF),
    toggleButtonColor: const Color(0xFf34323d),
    toggleBackgroundColor: const Color(0xFF222029),
    shadow: const <BoxShadow>[
      BoxShadow(
        color: const Color(0x66000000),
        spreadRadius: 5,
        blurRadius: 10,
        offset: Offset(0, 5),
      ),
    ],
  );


  void _showCouponModeDialog(context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Offers',
              style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          content: new Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    title: new Text('FLAT45',
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    trailing: new Text('APPLY',
                        style: TextStyle(fontSize: 12.0, color: Colors.red)),
                    onTap: () async {
                      Navigator.pop(context);
                      var res = await http.post(
                        new Uri.https(BASE_URL, API_PATH + "/getdiscount"),
                        body: {
                          "user_id": _userId.toString(),
                          "total_amount": _total.toString(),
                          "coupon_code": "FLAT45"
                        },
                        headers: {
                          "Accept": "application/json",
                          "authorization": basicAuth
                        },
                      );
                      if (res.statusCode == 200) {
                        var data = json.decode(res.body);
                        print(data);
                        if (data['ErrorCode'] == 0) {
                          setState(() {
                            _offersMode = 'FLAT45';
                            if (data['CouponResponse']
                                .containsKey('Total_amount')) {
                              tot = data['CouponResponse']['Total_amount']
                                  .toString();
                              _discountedPrice = data['CouponResponse']
                                      ['Total_discount']
                                  .toString();
                            } else if (data['CouponResponse']
                                .containsKey('msg')) {
                              Fluttertoast.showToast(
                                  msg: data['CouponResponse']['msg']);
                            }
                          });
                        }
                      }
                    }),
                new ListTile(
                  title: new Text('FIRST10',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  trailing: new Text('APPLY',
                      style: TextStyle(fontSize: 12.0, color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);

                    var res = await http.post(
                      new Uri.https(BASE_URL, API_PATH + "/getdiscount"),
                      body: {
                        "user_id": _userId.toString(),
                        "total_amount": _total.toString(),
                        "coupon_code": "FIRST10"
                      },
                      headers: {
                        "Accept": "application/json",
                        "authorization": basicAuth
                      },
                    );
                    if (res.statusCode == 200) {
                      var data = json.decode(res.body);
                      print(data);
                      if (data['ErrorCode'] == 0) {
                        setState(() {
                          _offersMode = 'FIRST10';
                          if (data['CouponResponse']
                              .containsKey('Total_amount')) {
                            tot = data['CouponResponse']['Total_amount']
                                .toString();
                            _discountedPrice = data['CouponResponse']
                                    ['Total_discount']
                                .toString();
                          } else if (data['CouponResponse']
                              .containsKey('msg')) {
                            Fluttertoast.showToast(
                                msg: data['CouponResponse']['msg']);
                          }
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Iterable<TimeOfDay> getTimes(
      TimeOfDay startTime, TimeOfDay endTime, Duration step) sync* {
    var hour = startTime.hour;
    var minute = startTime.minute;
    do {
      yield TimeOfDay(hour: hour, minute: minute);
      minute += step.inMinutes;
      while (minute >= 60) {
        minute -= 60;
        hour++;
      }
    } while (hour < endTime.hour ||
        (hour == endTime.hour && minute <= endTime.minute));
  }

  timeSlot(date) {
    var currDt = DateTime.now();
    var hourSlot = 10;
    var minuteSlot = 0;
    if (date == 'Today') {
      hourSlot = currDt.hour + 1;
      var minute = currDt.minute;
      minuteSlot = 0;
      if (minute > 30) {
        hourSlot = currDt.hour + 2;
      } else {
        minuteSlot = 30;
      }
    }

    final startTime = TimeOfDay(hour: hourSlot, minute: minuteSlot);
    final endTime = TimeOfDay(hour: 20, minute: 0);
    final step = Duration(minutes: 30);

    final times = getTimes(startTime, endTime, step)
        .map((tod) => tod.format(context))
        .toList();
    return times;
  }

  Future _futureCheckout() async {
    var response =
        await http.post(new Uri.https(BASE_URL, API_PATH + "/checkout"), body: {
      "user_id": _userId,
    }, headers: {
      "Accept": "application/json",
      "authorization": basicAuth
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['Response'];
      total = data['Response']['total'].toString();
      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Widget _checkoutBuilder() {
    return FutureBuilder(
      future: _futureCheckout(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _storeId = snapshot.data['restaurant_id'];
          _total = snapshot.data['total'].toString();
          if (snapshot.data['address'] != null) {
            _proceed = true;
          }
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Ink(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        Icons.location_on,
                        color: Theme.of(context).accentColor,
                      ),
                      title: Text('Deliver to'),
                      subtitle: Text(snapshot.data['address'] != null
                          ? snapshot.data['address'].toString()
                          : 'No address found'),
                      trailing: GestureDetector(
                        child: Text(
                          snapshot.data['address'] != null
                              ? 'Change'
                              : 'Add New',
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {
                          snapshot.data['address'] != null
                              ? Navigator.pushNamed(context, '/change-address')
                              : Navigator.pushNamed(context, '/addnewaddress');
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                /* Ink(
                color: Colors.white,
                child: GestureDetector(
                  onTap: () {
                    _showPaymentModeDialog(context);
                  },
                  child: ListTile(
                    leading: Icon(
                      Icons.credit_card,
                      color: Theme.of(context).accentColor,
                    ),
                    title: Text('Payment'),
                    subtitle: Text(_paymentMode),
                  ),
                ),
              ),*/

                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CustomRadioWidget(
                        value: 1,
                        groupValue: id,
                        // focusColor: Color(0xFFe7bf2e),
                        onChanged: (val) {
                          setState(() {
                            radioButtonItem = 'Today';
                            id = 1;
                            _timeDropdownVal = '';
                            if (radioButtonItem == "Today") {
                              final now = DateTime.now();
                              DateFormat formatter = DateFormat('yyyy-MM-dd');
                              today = DateTime(now.year, now.month, now.day);
                              formatted = formatter.format(today);
                              print(formatted);
                            }
                          });
                        },
                      ),
                      Text(
                        "Today",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      CustomRadioWidget(
                        value: 2,
                        groupValue: id,
                        onChanged: (val) {
                          setState(() {
                            radioButtonItem = 'Tomorrow';
                            if (radioButtonItem == "Tomorrow") {
                              final now = DateTime.now();
                              DateFormat formatter = DateFormat('yyyy-MM-dd');
                              today =
                                  DateTime(now.year, now.month, now.day + 1);
                              formatted = formatter.format(today);
                              print(formatted);
                            }
                            id = 2;
                          });
                        },
                      ),
                      Text(
                        "Tomorrow",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ]),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 12, right: 12, top: 2, bottom: 2),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    underline: Container(
                      height: 1,
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        child: Text('Choose Time'),
                        value: '',
                      ),
                      for (var i = 0;
                          i < timeSlot(_dateDropdownVal).length;
                          i++)
                        DropdownMenuItem<String>(
                          child: Text(timeSlot(_dateDropdownVal)[i]),
                          value: timeSlot(_dateDropdownVal)[i],
                        ),
                    ],
                    value: _timeDropdownVal,
                    onChanged: (String value) {
                      setState(() {
                        _timeDropdownVal = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 1),
                GestureDetector(
                  onTap: () {
                    //   _showPaymentModeDialog(context);
                  },
                  child: Container(
                    color: Colors.white,
                    child: Column(children: <Widget>[
                      SizedBox(
                        height: 0,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
                        child: Container(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Payment Options',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                        ),
                      ),

                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: sampleData.length,
                        //  primary: false,
                        itemBuilder: (BuildContext context, int index) {
                          return new InkWell(
                            //highlightColor: Colors.red,
                            splashColor: Colors.red,
                            onTap: () {
                              setState(() {
                                sampleData.forEach((element) {
                                  element.isSelected = false;
                                  sampleData[index].isSelected = true;
                                });
                                _paymentMode = sampleData[index].text;
                                print("payment" + _paymentMode);
                              });
                            },
                            child: new RadioItem(sampleData[index]),
                          );
                        },
                      ),
                    ]),
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    //   _showPaymentModeDialog(context);
                  },
                  child: Container(
                    color: Colors.white,
                    child: Column(children: <Widget>[
                      SizedBox(
                        height: 0,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
                        child: Container(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Offers',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.black),
                          ),
                        ),
                      ),
                      _discountedPrice != null
                          ? new Container(
                              child: new Wrap(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      child: new ListTile(
                                        leading: Icon(
                                          Icons.check_circle,
                                          color: Theme.of(context).accentColor,
                                        ),
                                        title: new Text(
                                          'Coupon Applied',
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black),
                                        ),
                                        trailing: Container(
                                          child: new Text(
                                            '-' + _discountedPrice,
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.red),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : new Container(
                              child: new Wrap(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      child: new ListTile(
                                          leading: Icon(
                                            Icons.local_offer,
                                            color:
                                                Theme.of(context).accentColor,
                                          ),
                                          title: new Text(
                                            'Select a promo code',
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.black),
                                          ),
                                          trailing: GestureDetector(
                                            onTap: () {
                                              _showCouponModeDialog(context);
                                            },
                                            child: Container(
                                              child: new Text(
                                                'View offers',
                                                style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: Colors.red),
                                              ),
                                            ),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ]),
                  ),
                ),
                SizedBox(height: 12),
                Ink(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Text(
                          "Subtotal",
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        trailing: Text(
                          "\u20B9 " + snapshot.data['subtotal'].toString(),
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Text(
                          "Delivery Fee",
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        trailing: Text(
                          "\u20B9 " + snapshot.data['delivery_fee'].toString(),
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey,
                      ),
                      ListTile(
                        leading: Text("Total"),
                        trailing: _discountedPrice != null
                            ? Text("\u20B9 " + tot)
                            : Text(
                                "\u20B9 " + snapshot.data['total'].toString()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget build(BuildContext context) {
    final ProgressDialog pr = ProgressDialog(context, isDismissible: false);
    pr.style(
      message: 'Please wait...',
    );
    final _cartProvider = Provider.of<Cart>(context, listen: false);
    return ModalProgressHUD(
      inAsyncCall: _loading,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Checkout'),
        ),
        body: WillPopScope(
            onWillPop: () async {
              await pr.show();
              var response = await http.post(
                new Uri.https(BASE_URL, API_PATH + "/cancelOrder"),
                body: {
                  "user_id": _userId.toString(),
                  "coupon_code": _offersMode.toString(),
                },
                headers: {
                  "Accept": "application/json",
                  "authorization": basicAuth,
                },
              );
              if (response.statusCode == 200) {
                await pr.hide();
                var data = json.decode(response.body);
                var errorCode = data['ErrorCode'];
                if (errorCode == 0) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                }
              } else {
                await pr.hide();
                Navigator.of(context).pop();
              }

              return true;
            },
            child: _checkoutBuilder()),
        bottomNavigationBar: BottomAppBar(
          color: Colors.grey[100],
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 24,
            ),
            child: FlatButton(
              padding: EdgeInsets.all(14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              color: Theme.of(context).accentColor,
              child: Text(
                "Pay Now".toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                var date = new DateTime.now().toString();
                var dateParse = DateTime.parse(date);
                var formattedDate =
                    "${dateParse.day}-${dateParse.month}-${dateParse.year}";
                var now = new DateTime.now();
                var time = new DateFormat("H:m:s").format(now);
                print(time.toString());
                print(formattedDate.toString());
                if (_timeDropdownVal != '') {
                  if (_paymentMode == 'Cash On Delivery') {
                    if (_proceed) {
                      /*setState(() {
                        _loading = true;
                      });*/
                      var response = await http.post(
                        new Uri.https(BASE_URL, API_PATH + "/createorder"),
                        body: {
                          "user_id": _userId.toString(),
                          "type_of_order":"hd",
                          "instruction": _additionalInstruction,
                          "discounted_price": tot.toString(),
                          "delivery_date": formatted.toString(),
                          "delivery_time": _timeDropdownVal.toString(),
                          "coupon_code": _offersMode.toString(),
                          "coupon_discount": _discountedPrice.toString()
                        },
                        headers: {
                          "Accept": "application/json",
                          "authorization": basicAuth
                        },
                      );
                      print(
                          {
                            "user_id": _userId.toString(),
                            "type_of_order":"hd",
                            "instruction": _additionalInstruction,
                            "discounted_price": tot.toString(),
                            "delivery_date": formatted.toString(),
                            "delivery_time": _timeDropdownVal.toString(),
                            "coupon_code": _offersMode.toString(),
                            "coupon_discount": _discountedPrice.toString()
                          }
                      );
                      if (response.statusCode == 200) {
                        /*setState(() {
                          _loading = false;
                        });*/
                        var data = json.decode(response.body);
                        var errorCode = data['ErrorCode'];
                        var errorMessage = data['ErrorMessage'];
                        if (errorCode == 0) {
                          Navigator.pushReplacementNamed(
                              context, '/order-complete');
                          _cartProvider.showCartItems(_userId);
                        } else {
                          showAlertDialog(
                              context, ALERT_DIALOG_TITLE, errorMessage);
                        }
                      }
                    }
                  } else if (_paymentMode == "Online Payment") {
                    //  generateOrderId("rzp_test_MhKrOdDQM8C8PL","KkwbMqF9Ll9mCejzLQWsrOsk",num.parse(total)*100);
                    var res = await http.post(
                      new Uri.https(BASE_URL, API_PATH + "/createorder"),
                      body: {
                        "user_id": _userId.toString(),
                        "type_of_order":"hd",
                        "instruction": _additionalInstruction,
                        "discounted_price": tot.toString(),
                        "delivery_date": formatted.toString(),
                        "delivery_time": _timeDropdownVal.toString(),
                        "coupon_code": _offersMode.toString(),
                        "coupon_discount": _discountedPrice.toString()
                      },
                      headers: {
                        "Accept": "application/json",
                        "authorization": basicAuth
                      },
                    );
                    if (res.statusCode == 200) {
                      var data = json.decode(res.body);
                      print(data);
                      if (data['ErrorCode'] == 0) {
                        openCheckout(data['Response']['razorpay_order']['id'],
                            data['Response']['razorpay_order']['amount']);
                      }
                    }

                    /* var merchantTxnId = ShortUuid.shortv4();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => MyWebView(
                        title: "Make Payment",
                        url: "https://qrestro.com/sodhis/proceed-to-pay?restaurant_id="+_storeId.toString()+"&user_id="+_userId.toString()+"&merchantTxnId="+merchantTxnId+"&channel=ANDROID&instruction="+_additionalInstruction,
                        userId: _userId,
                        merchantTxnId: merchantTxnId,
                      ),
                    ),
                  );*/
                  } else {
                    Fluttertoast.showToast(msg: 'Please Select Payment Mode');
                  }
                } else {
                  Fluttertoast.showToast(msg: 'Please Select Time of delivery');
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
