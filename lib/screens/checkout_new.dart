import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sodhis_app/components/CustomRadioWidget.dart';
import 'package:sodhis_app/components/RadioItem.dart';
import 'package:sodhis_app/components/ThemeColor.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sodhis_app/services/cart_badge.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sodhis_app/services/cart.dart';

import 'package:razorpay_flutter/razorpay_flutter.dart';

class CheckOutNewPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CheckOutNewPage>
    with SingleTickerProviderStateMixin {
  var _razorpay = Razorpay();

  var _userId, takeaway_address;

  //var _dateDropdownVal = 'Today';
  var _timeDropdownVal;

  var type_of_order = "";
  var _placeOrderBtnParent = 'Place Order';

  //var _placeOrderBtn = 'Place Order';
  Future _myCartList;
  final nameController = TextEditingController();
  final couponcodeController = TextEditingController();
  final instructionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var errorCode;
  var response;
  var data, total;
  AnimationController _animationController;
  List dataModel = new List();
  Map<String, dynamic> value = new Map();
  String _paymentMode = "Online Payment";
  bool isPress1 = false;
  bool isPress2 = false;

  String _name, _mobile, _email;
  List<RadioModel> sampleData = new List<RadioModel>();
  String radioButtonItem = 'Today';
  String radioButtonItem1 = 'OnlIne Delivery';
  int id;
  int id1 = 1;
  var today, tomorrow;
  String formatted;

  List<bool> isChecked;

  List addextraitem = [];

  double totalPrice = 0.0;
  String couponcode = "";

  double finalPrice = 0;

  String userinstructions = "";
  FocusNode myFocusNode;

  @override
  void initState() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    final now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    today = DateTime(now.year, now.month, now.day);
    formatted = formatter.format(today);
    _timeDropdownVal = DateFormat('hh:mm:ss').format(DateTime.now());

    myFocusNode = FocusNode();

    _getUser();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("success");
    print(response.orderId);
    _onlinePayment(response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Failed");
    print(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
  }

  void dispose() {
    couponcodeController.dispose();
    nameController.dispose();
    instructionController.dispose();
    myFocusNode.dispose();
    _razorpay.clear();

    super.dispose();
  }

  _onlinePayment(String paymentid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _loading = true;
    });
    var res = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/createorder"),
      body: {
        "user_id": _userId.toString(),
        "type_of_order": "hd",
        "instruction": "",
        "discounted_price": "",
        "delivery_date": formatted.toString(),
        "delivery_time": _timeDropdownVal.toString(),
        "subtotal": response['subtotal'].toString(),
        "total_discount": response['total_discount'].toString(),
        "coupon_code": response['coupon_code'].toString(),
        "razorpay_payment_id": paymentid,
        "wallet_total": prefs.getString('walletBalance'),
        "razorpay_total": (int.parse(response['total_payable'].toString()) -
                int.parse(prefs.getString('walletBalance')))
            .toString()
      },
      headers: {"Accept": "application/json", "authorization": basicAuth},
    );
    print(json.encode({
      "user_id": _userId.toString(),
      "type_of_order": "hd",
      "instruction": "",
      "discounted_price": "",
      "delivery_date": formatted.toString(),
      "delivery_time": _timeDropdownVal.toString(),
      "subtotal": response['subtotal'].toString(),
      "total_discount": response['total_discount'].toString(),
      "coupon_code": response['coupon_code'].toString(),
      "razorpay_payment_id": paymentid,
      "wallet_total": prefs.getString('walletBalance'),
      "razorpay_total": (int.parse(response['total_payable'].toString()) -
              int.parse(prefs.getString('walletBalance')))
          .toString()
    }));
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      print(data);
      setState(() {
        _loading = false;
      });
      if (data['ErrorCode'] == 0) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/order-complete', (route) => false);
      } else {
        setState(() {
          _loading = false;
        });
        Fluttertoast.showToast(msg: data['ErrorMessage']);
      }
    }
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      takeaway_address = prefs.getString('takeAwayAddress').toString();
      //_branchId = prefs.getInt('branch_id').toString();
      //_warehouseId = prefs.getInt('warehouse_id').toString();
      //_stockItem = prefs.getString('cart');
      _myCartList = _cartLists();
      _name = prefs.getString('name');
      _email = prefs.getString('email_address');
      _mobile = prefs.getString('mobile_number');
      //_deliveryType = prefs.getString('delivery_type');
    });
  }

  showConfirmDialog(id, cancel, done, title, content) {
    print(id);
    final _cart = Provider.of<CartBadge>(context, listen: false);
    // Set up the Button
    Widget cancelButton = FlatButton(
      child: Text(cancel),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget doneButton = FlatButton(
      child: Text(done),
      onPressed: () {
        Navigator.of(context).pop();
        removeItemFromCart(id);
        _cart.showCartBadge(_userId);
      },
    );

    // Set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        cancelButton,
        doneButton,
      ],
    );

    // Show the Dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void removeItemFromCart(cartId) async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/cart-delete"),
      body: {
        "user_id": _userId.toString(),
        "cart_id": cartId.toString(),
      },
      headers: {
        "Accept": "application/json",
        "authorization": basicAuth,
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var errorCode = data['ErrorCode'];
      var errorMessage = data['ErrorMessage'];
      if (errorCode == 0) {
        Fluttertoast.showToast(msg: 'Item removed successfully');
      } else {
        Fluttertoast.showToast(msg: errorMessage);
      }
      setState(() {
        _myCartList = _cartLists();
      });
    } else {
      throw Exception('Something went wrong');
    }
  }

  void cartaction(String id, String restaurantid, String mrp, String discount,
      String qty, List items) async {
    //final _cart = Provider.of<CartBadge>(context, listen: false);
    print(jsonEncode({
      "user_id": _userId.toString(),
      "offer_price": discount.toString(),
      "rate": mrp.toString(),
      "restaurant_id": restaurantid,
      "quantity": qty.toString(),
      "product_id": id.toString(),
      "addon_items": items.length == 0 ? [] : items
    }));
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/cart-add"),
      headers: {
        "Accept": "application/json",
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "user_id": _userId.toString(),
        "offer_price": discount.toString(),
        "rate": mrp.toString(),
        "restaurant_id": restaurantid,
        "quantity": qty.toString(),
        "product_id": id.toString(),
        "addon_items": items.length == 0 ? [] : items
      }),
    );
    print(response.body);
    if (response.statusCode == 200 &&
        json.decode(response.body)['ErrorCode'].toString() == "0") {
      //_cart.showCartBadge(_userId);
      var data = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt(
          'cart_count', int.parse(data['Response']['count'].toString()));
      print("Proper run");
      setState(() {
        _myCartList = _cartLists();
      });
    } else {
      print(response.toString());
    }
  }

  /*Iterable<TimeOfDay> getTimes(
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
  }*/

  /*Future<Null> refreshList() async {
    await Future.delayed(
      Duration(milliseconds: 500),
    );
    setState(() {
      _myCartList = _cartLists();
    });
    //setState(() {});
    return null;
  }*/

  Future _cartLists() async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/cart"),
      body: {
        "user_id": _userId,
      },
      headers: {
        "Accept": "application/json",
        "authorization": basicAuth,
      },
    );
    if (response.statusCode == 200) {
      data = json.decode(response.body);
      var result = data['Response'];
      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Future _applycouponcode(String couponcode, String userid, String totalprice,
      String restaurantid) async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/coupon-apply"),
      body: {
        "coupon_code": couponcode,
        "total": totalprice,
        "user_id": userid,
        "restaurant_id": restaurantid,
      },
      headers: {
        "Accept": "application/json",
        "authorization": basicAuth,
      },
    );
    if (response.statusCode == 200) {
      data = json.decode(response.body);
      var result = data['CouponResponse'];
      if (data['ErrorMessage'].toString() == "success") {
        setState(() {
          _loading = false;
        });
        if (data['CouponResponse'].containsKey('msg')) {
          if (data['CouponResponse']['msg'].toString() ==
              "You have already used this coupon") {
            _showExpiredCouponDialog(context);
          }
        } else {
          print(data['CouponResponse']);
          couponcode = "";
          _cartLists();
        }
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  Future _removecouponcode(
      String userid, String couponcode, String restaurantid) async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/cancel-coupon"),
      body: {
        "coupon_code": couponcode,
        "user_id": userid,
        "restaurant_id": restaurantid,
      },
      headers: {
        "Accept": "application/json",
        "authorization": basicAuth,
      },
    );
    if (response.statusCode == 200) {
      data = json.decode(response.body);
      var result = data['Response'];
      if (result['msg'].toString() == "Coupon cancelled successfully.") {
        setState(() {
          _loading = false;
        });
        Fluttertoast.showToast(msg: result['msg'].toString());
        _cartLists();
      } else {
        setState(() {
          _loading = false;
        });
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  Widget _emptyCart() {
    return Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              // height: 150,
              // width: 150,
              margin: const EdgeInsets.only(bottom: 20),
              child: Image.asset("assets/images/empty_cart.png"),
            ),
            Text(
              "No Items Yet!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 10, bottom: 80),
              child: Text(
                "Browse and add items in your shopping bag.",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
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
          title: Container(
            height: 60,
            width: 60,
            margin: const EdgeInsets.only(bottom: 20),
            child: Image.asset("assets/images/wallet.png"),
          ),
          content: new Container(
            child: new Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 20, bottom: 20),
                  child: Column(
                    children: [
                      Text(
                        "Insufficient Balance",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          "Your wallet is low on balance. Kindly recharge to place order.",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        margin: new EdgeInsets.only(
                            top: 20, left: 30, right: 30, bottom: 30),
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
                                  vertical: 16.0, horizontal: 48.0),
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

  void _showExpiredCouponDialog(context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          content: new Container(
            child: new Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 5, bottom: 5),
                  child: Column(
                    children: [
                      Text(
                        "Coupon Expired",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          "Coupon is already used, You can not use expired coupon code.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        margin: new EdgeInsets.only(
                            top: 10, left: 30, right: 30, bottom: 5),
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
                                  vertical: 16.0, horizontal: 10.0),
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

  Widget _cartListBuilder() {
    // final _counter = Provider.of<CartBadge>(context);
    final _cartProvider = Provider.of<Cart>(context);
    return FutureBuilder(
      future: _cartProvider.getCartList(_userId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          errorCode = snapshot.data['ErrorCode'];
          response = snapshot.data['Response'];
          if (errorCode == 0) {
            return Stack(
              children: [
                Column(children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                            child: Card(
                              color: Colors.white,
                              elevation: 4.0,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
                                        SizedBox(width: 2),
                                        Expanded(
                                            child: Text("Deliver to:")
                                        ),
                                        GestureDetector(
                                     onTap: (){
                                       snapshot.data['address'] != null
                                           ? Navigator.pushNamed(
                                           context, '/change-address')
                                           : Navigator.pushNamed(
                                           context, '/addnewaddress');
                                     },
                                     child: Container(
                                        height: 25,
                                        width: 90,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6.0),
                                          border: Border.all(color: Colors.green, width: 1)
                                        ),
                                       child: GestureDetector(
                                         child: Text(
                                           response['address'] != null
                                               ? 'Change'
                                               : 'Add New',
                                           style: TextStyle(
                                             color: Colors.green,
                                             fontSize: 11,
                                           ),
                                         ),
                                         onTap: () {
                                           snapshot.data['address'] != null
                                               ? Navigator.pushNamed(
                                               context, '/change-address')
                                               : Navigator.pushNamed(
                                               context, '/addnewaddress');
                                         },
                                       ),
                                     ),
                                   )
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    /*Row(
                                      children: [
                                        Text("Home", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                                        SizedBox(width: 5),
                                        Text("(Default)", style: TextStyle(color: Colors.black, fontSize: 12))
                                      ],
                                    ),
                                    SizedBox(height: 2),*/
                                    SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.65,
                                        child: response['address'] == null || response['address'] == "" ? Text("") : Text(response['address'].toString().toUpperCase(), style: TextStyle(color: Colors.black, fontSize: 12)))
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          /*Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              CustomRadioWidget(
                                value: 1,
                                groupValue: id1,
                                onChanged: (val) {
                                  setState(() {
                                    radioButtonItem1 = 'OnlIne Delivery';
                                    id1 = 1;
                                  });
                                },
                              ),
                              Text(
                                "Online Payment",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black87),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              CustomRadioWidget(
                                value: 2,
                                groupValue: id1,
                                onChanged: (val) {
                                  setState(() {
                                    radioButtonItem1 = 'Cash On Delivery';
                                    id1 = 2;
                                  });
                                },
                              ),
                              Text(
                                "Cash On Delivery",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black87),
                              ),
                            ]),
                      ),
                      SizedBox(height: 10),*/
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.only(left: 15, right: 15),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 12, right: 12, bottom: 10),
                              child: Text(
                                'Offer & Benefits',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 0),
                          response['coupon_applied'].toString() == "1"
                              ? Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0),
                            child: Container(
                              height: 60,
                              width: MediaQuery.of(context).size.width,
                              child: Card(
                                child: Padding(
                                  padding:
                                  EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text("Coupon applied",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight:
                                                  FontWeight.w500)),
                                          SizedBox(height: 4.0),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: [
                                              Icon(Icons.wallet_giftcard,
                                                  color: Colors.green,
                                                  size: 14.0),
                                              SizedBox(width: 5.0),
                                              Row(
                                                children: [
                                                  Text(
                                                      "\u20B9" +
                                                          response[
                                                          'total_discount']
                                                              .toString(),
                                                      style: TextStyle(
                                                          color: Colors.green,
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                          FontWeight
                                                              .w500)),
                                                  SizedBox(width: 3.0),
                                                  Text("coupon savings",
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 14.0))
                                                ],
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _loading = true;
                                            });
                                            _removecouponcode(
                                                _userId,
                                                response['coupon_code'].toString(), response['items'][0]['restaurant_id'].toString());
                                          },
                                          child: Text("Remove",
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight:
                                                  FontWeight.bold)))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                              : Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, right: 15.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/apply_coupon',
                                  arguments: <String, String>{
                                    'userid': _userId,
                                    'payable_amount': response['total_payable'].toString(),
                                    'restaurant_id': response['items'][0]['restaurant_id'].toString()
                                  },
                                );
                              },
                              child: Card(
                                elevation: 4.0,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Colors.white, width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 17.0,
                                      left: 15.0,
                                      right: 15.0,
                                      bottom: 17.0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Text("Apply Coupon",
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500)),
                                      Icon(Icons.arrow_forward_ios,
                                          size: 14.0,
                                          color: Colors.grey.shade500)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.only(left: 15, right: 15),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 12, right: 12, bottom: 10),
                              child: Text(
                                'Cart Items',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          //this is my changeable code
                          Container(
                            child: ListView.builder(
                                shrinkWrap: true,
                                primary: false,
                                itemCount: response['items'].length,
                                itemBuilder: (context, index) {
                                  if (response['items'][index]['item_addon']
                                      .isEmpty) {
                                    return itemContainer(
                                        response['items'],
                                        index,
                                        response['items'][index]['id'].toString(),
                                        response['items'][index]['cart_id'].toString(),
                                        response['items'][index]['product_name'],
                                        response['items'][index]['product_image'],
                                        response['items'][index]['quantity'].toString(),
                                        response['items'][index]['rate'].toString(),
                                        response['items'][index]['amount'].toString(),
                                        response['items'][index]['offer_price'].toString());
                                  } else {
                                    //isChecked = List.filled(response['items'][index]['item_addon'].length, true);
                                    return extraItemContainer(
                                        response['items'],
                                        index,
                                        response['items'][index]['id'].toString(),
                                        response['items'][index]['cart_id']
                                            .toString(),
                                        response['total_payable'].toString(),
                                        response['items'][index]['product_name'],
                                        response['items'][index]['product_image'],
                                        response['items'][index]['quantity']
                                            .toString(),
                                        response['items'][index]['rate'].toString(),
                                        response['items'][index]['amount']
                                            .toString(),
                                        response['items'][index]['offer_price']
                                            .toString(),
                                        response['items'][index]['item_addon']);
                                  }
                                }),
                          ),
                          Container(
                            color: Colors.white,
                            margin: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15, left: 12, right: 12),
                                  child: Text(
                                    'Order Summary',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
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
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Subtotal',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          "\u20B9 " +
                                              response['subtotal'].toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ]),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12, right: 12, bottom: 12),
                                  child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Delivery Fee",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          "\u20B9 " +
                                              response['delivery_fee'].toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ]),
                                ),
                                response['total_discount'].toString() == "0"
                                    ? Container()
                                    : Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12, right: 12, bottom: 12),
                                  child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Coupon Discount",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          "\u20B9 " +
                                              response['total_discount']
                                                  .toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ]),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12, right: 12, bottom: 12),
                                  child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          "\u20B9 " +
                                              response['total_payable'].toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ]),
                                ),
                              ],
                            ),
                          ),
                          buildInstructionContainer()
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(left: 15, bottom: 5, right: 15),
                      child: InkWell(
                        onTap: () async{
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          if (prefs.getString('type') == "grocery") {
                            Navigator.pushNamed(
                              context,
                              '/delivery-timeslot',
                              arguments: <String, String>{
                                'userid': _userId,
                                'subtotal': response['subtotal'].toString(),
                                'wallet_balance': prefs.getString('walletBalance'),
                                'coupon_code': response['coupon_code'].toString(),
                                'payable_amount': response['total_payable'].toString(),
                                'total_discount': response['total_discount'].toString(),
                                'instructions': userinstructions.toString(),
                                'address' : response['address'].toString(),
                              },
                            );
                            userinstructions = "";
                          } else {
                            Navigator.pushNamed(
                              context,
                              '/payment_options',
                              arguments: <String, String>{
                                'userid': _userId,
                                'subtotal': response['subtotal'].toString(),
                                'wallet_balance':
                                prefs.getString('walletBalance'),
                                'coupon_code':
                                response['coupon_code'].toString(),
                                'payable_amount':
                                response['total_payable'].toString(),
                                'total_discount': response['total_discount'].toString(),
                                'instructions': userinstructions.toString(),
                                'time' : "",
                                "date" : ""
                              },
                            );
                            userinstructions = "";
                          }
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.green,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                response['items'].length.toString() == "1" ? Text(response['items'].length.toString()+" Item", style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                )) : Text(response['items'].length.toString()+" Items", style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white, fontWeight: FontWeight.w500
                                )),
                                SizedBox(width: 10),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: VerticalDivider(width: 2, color: Colors.white),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    response['total_payable'] != null
                                        ? "\u20B9 " +
                                        response['total_payable'].toString()
                                        : 0.toString(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                ),
                                Text("Proceed to pay", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                                SizedBox(width: 5),
                                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ]
                )
              ],
            );
          } else {
            return _emptyCart();
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Container(child: CircularProgressIndicator()));
        } else {
          return Center(child: Container(child: CircularProgressIndicator()));
        }
      },
    );
  }

  bool _loading = false;

  Widget build(BuildContext context) {
    /*pr = new ProgressDialog(context,type: ProgressDialogType.Normal);
    pr.style(
      progress: 80.0,
      message: "Please wait...",
      progressWidget: Container(
          padding: EdgeInsets.all(10.0), child: CircularProgressIndicator(color: kPrimaryColor)),
      maxProgress: 100.0,
      progressTextStyle: TextStyle(color: Colors.black, fontSize: 12.0, fontWeight: FontWeight.w100),
    );*/

    return Scaffold(
        appBar: AppBar(
          title: Text('My Shopping Basket'),
        ),
        body: _cartListBuilder()
        // ModalProgressHUD(
        //   inAsyncCall: _loading,
        //   child: RefreshIndicator(
        //     child: Container(
        //       color: Colors.grey[200],
        //       child: ,
        //     ),
        //     onRefresh: refreshList,
        //   ),
        // ),
        );
  }

  Widget itemContainer(
      List<dynamic> allitems,
      int index,
      String id,
      String cardid,
      String productname,
      String productimage,
      String qty,
      String rate,
      String amount,
      String offerprice) {
    return Container(
        child: Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 16, right: 16, top: 5),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: Slidable(
            actionPane: SlidableDrawerActionPane(),
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/product-details',
                      arguments: <String, String>{
                        'product_id': id,
                        'title': productname,
                      },
                    );
                  },
                  child: Container(
                    margin:
                        EdgeInsets.only(right: 8, left: 8, top: 8, bottom: 8),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      //color: Colors.blue.shade200,
                      image: DecorationImage(
                          image: CachedNetworkImageProvider(productimage),
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 0.0),
                    child: Container(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/product-details',
                                arguments: <String, String>{
                                  'product_id': id.toString(),
                                  'title': productname,
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.only(right: 8, top: 0),
                              child: Text(
                                productname,
                                maxLines: 2,
                                softWrap: true,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  flex: 100,
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "\u20B9 " + "$amount",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 15.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              setState(() {
                                if (allitems[index]['quantity'] >= 1) {
                                  allitems[index]['quantity']--;
                                }
                              });
                              if (prefs.getString('type') == "restaurant") {
                                print("rest");
                                cartaction(
                                    allitems[index]['id'].toString(),
                                    "41",
                                    allitems[index]['rate'].toString(),
                                    allitems[index]['offer_price'].toString(),
                                    allitems[index]['quantity'].toString(),
                                    addextraitem);
                              } else {
                                print("grocery");
                                cartaction(
                                    allitems[index]['id'].toString(),
                                    "35",
                                    allitems[index]['rate'].toString(),
                                    allitems[index]['offer_price'].toString(),
                                    allitems[index]['quantity'].toString(),
                                    addextraitem);
                              }
                            },
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(25 / 2),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.remove,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(allitems[index]['quantity'].toString()),
                          SizedBox(
                            width: 15,
                          ),
                          GestureDetector(
                            onTap: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              setState(() {
                                allitems[index]['quantity']++;
                              });
                              if (prefs.getString('type') == "restaurant") {
                                print("rest");
                                cartaction(
                                    allitems[index]['id'].toString(),
                                    "41",
                                    allitems[index]['rate'].toString(),
                                    allitems[index]['offer_price'].toString(),
                                    allitems[index]['quantity'].toString(),
                                    addextraitem);
                              } else {
                                print("grocery");
                                cartaction(
                                    allitems[index]['id'].toString(),
                                    "35",
                                    allitems[index]['rate'].toString(),
                                    allitems[index]['offer_price'].toString(),
                                    allitems[index]['quantity'].toString(),
                                    addextraitem);
                              }
                            },
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25 / 2),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: 'Delete',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () {
                  showConfirmDialog(cardid, 'Cancel', 'Remove', 'Remove Item',
                      'Are you sure want to remove this item?');
                },
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget extraItemContainer(
      List<dynamic> allitems,
      int index,
      String id,
      String cardid,
      String totalprice,
      String productname,
      String productimage,
      String qty,
      String rate,
      String amount,
      String offerprice,
      List<dynamic> extraitem) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 16, right: 16, top: 5),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: Slidable(
              actionPane: SlidableDrawerActionPane(),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/product-details',
                        arguments: <String, String>{
                          'product_id': id,
                          'title': productname,
                        },
                      );
                    },
                    child: Container(
                      margin:
                          EdgeInsets.only(right: 8, left: 8, top: 8, bottom: 8),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        //color: Colors.blue.shade200,
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(productimage),
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/product-details',
                                arguments: <String, String>{
                                  'product_id': id.toString(),
                                  'title': productname,
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.only(right: 8, top: 0),
                              child: Text(
                                productname,
                                maxLines: 2,
                                softWrap: true,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListView.builder(
                                            itemCount: extraitem.length,
                                            shrinkWrap: true,
                                            primary: false,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return extraitem[index]['enabled']
                                                          .toString() ==
                                                      "1"
                                                  ? Text(
                                                      extraitem[index]
                                                              ['addon_name']
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey.shade500,
                                                          fontSize: 12.0))
                                                  : Container();
                                            }),
                                        GestureDetector(
                                          onTap: () {
                                            extraItem(
                                                context,
                                                amount,
                                                rate,
                                                extraitem,
                                                totalprice,
                                                id,
                                                offerprice,
                                                qty,
                                                addextraitem);
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text("CUSTOMIZED",
                                                  style: TextStyle(
                                                      color:
                                                          Colors.grey.shade700,
                                                      fontSize: 14.0)),
                                              SizedBox(width: 2.0),
                                              Icon(
                                                  Icons
                                                      .keyboard_arrow_down_sharp,
                                                  size: 24.0,
                                                  color: Colors.grey.shade700)
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    flex: 100,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      height: 80,
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "\u20B9 " + "${allitems[index]['amount']}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 15.0),
                          Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  //_cartLists();
                                  setState(() {
                                    if (allitems[index]['quantity'] >= 1) {
                                      allitems[index]['quantity']--;
                                    }
                                  });
                                  var _amount = allitems[index]['rate'] *
                                      allitems[index]['quantity'];
                                  if (allitems[index]['quantity'] == 0) {
                                    _amount = 0;
                                  }
                                  if (prefs.getString('type') == "restaurant") {
                                    cartaction(
                                        allitems[index]['id'].toString(),
                                        "41",
                                        allitems[index]['rate'].toString(),
                                        allitems[index]['offer_price']
                                            .toString(),
                                        allitems[index]['quantity'].toString(),
                                        addextraitem);
                                  } else {
                                    cartaction(
                                        allitems[index]['id'].toString(),
                                        "35",
                                        allitems[index]['rate'].toString(),
                                        allitems[index]['offer_price']
                                            .toString(),
                                        allitems[index]['quantity'].toString(),
                                        addextraitem);
                                  }
                                },
                                child: Container(
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(25 / 2),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.remove,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Text(allitems[index]['quantity'].toString()),
                              SizedBox(
                                width: 15,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  //_cartLists();
                                  setState(() {
                                    allitems[index]['quantity']++;
                                  });
                                  var _amount = allitems[index]['rate'] *
                                      allitems[index]['quantity'];
                                  if (allitems[index]['quantity'] == 0) {
                                    _amount = 0;
                                  }
                                  if (prefs.getString('type') == "restaurant") {
                                    cartaction(
                                        allitems[index]['id'].toString(),
                                        "41",
                                        allitems[index]['rate'].toString(),
                                        allitems[index]['offer_price']
                                            .toString(),
                                        allitems[index]['quantity'].toString(),
                                        addextraitem);
                                  } else {
                                    cartaction(
                                        allitems[index]['id'].toString(),
                                        "35",
                                        allitems[index]['rate'].toString(),
                                        allitems[index]['offer_price']
                                            .toString(),
                                        allitems[index]['quantity'].toString(),
                                        addextraitem);
                                  }
                                },
                                child: Container(
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25 / 2),
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.add,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: 'Delete',
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () {
                    showConfirmDialog(cardid, 'Cancel', 'Remove', 'Remove Item',
                        'Are you sure want to remove this item?');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  extraItem(
      context,
      String amount,
      String rate,
      List<dynamic> items,
      String totalprice,
      String id,
      String offerprice,
      String qty,
      List addextraitem) {
    addextraitem.clear();
    List group_ids = [];
    items.forEach((element) {
      group_ids.add(element['group_id'].toString());
    });
    List mylist = [];
    Map newMap = groupBy(items, (obj) => obj['group_id']);
    group_ids.toSet().toList().forEach((element) {
      Map mymap = {};
      mymap['group_id'] = element.toString();
      mymap['data'] = newMap[int.parse(element.toString())];
      mymap['title_name'] = newMap[int.parse(element.toString())][0]['title_name'];
      mymap['group_name'] = newMap[int.parse(element.toString())][0]['group_name'];
      mymap['addon_limit'] = newMap[int.parse(element.toString())][0]['addon_limit'];
      mylist.add(mymap);
    });
    //var temp = addextraitem.toSet().toList();
    //print(temp);
    showModalBottomSheet(
        isDismissible: false,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => StatefulBuilder(
              builder: (BuildContext context, StateSetter extrasetState) {
                return Container(
                    height: 600,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25.0),
                            topRight: Radius.circular(25.0))),
                    child: Stack(
                      children: [
                        Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              children: mylist.map((e) {
                                List tempList = e['data'];
                                return Column(children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(left: 8, top: 10),
                                      child: Text(e['group_name'],
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                  SizedBox(height: 2.0),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: e['addon_limit'].toString() == "0"
                                          ? Container()
                                          : Text(
                                              e['title_name']
                                                  .toString()
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12.0)),
                                    ),
                                  ),
                                  SizedBox(height: 5.0),
                                  Column(
                                    children: tempList
                                        .map((ee) => Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Container(
                                                height: 40,
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 12.0,
                                                      width: 12.0,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.green,
                                                              width: 1.0)),
                                                      child: Icon(
                                                        Icons.circle,
                                                        color: Colors.green,
                                                        size: 6.0,
                                                      ),
                                                    ),
                                                    SizedBox(width: 6.0),
                                                    Text(ee['addon_name']),
                                                    SizedBox(width: 10.0),
                                                    Expanded(
                                                        child: ee['addon_price']
                                                                    .toString() ==
                                                                "0.00"
                                                            ? Text("")
                                                            : Text("\u20B9" +
                                                                ee['addon_price'])),
                                                    Checkbox(
                                                      activeColor: Colors.green,
                                                      value: ee['enabled']
                                                                  .toString() ==
                                                              "1"
                                                          ? true
                                                          : false,
                                                      onChanged: (val) {
                                                        if (int.parse(e[
                                                                    'addon_limit']
                                                                .toString()) ==
                                                            0) {
                                                          print("1");
                                                          if (ee['enabled']
                                                                  .toString() ==
                                                              "1") {
                                                            extrasetState(() {
                                                              ee['enabled'] =
                                                                  "0";
                                                            });
                                                            addextraitem.add({
                                                              "id": ee['id']
                                                                  .toString(),
                                                              "price": ee[
                                                                      'addon_price']
                                                                  .toString(),
                                                              "status": 0
                                                            });
                                                            extrasetState(() {
                                                              totalprice = (double
                                                                          .parse(
                                                                              totalprice) -
                                                                      double.parse(
                                                                          ee['addon_price']))
                                                                  .toString();
                                                            });
                                                            /*for (int i = 0; i < addextraitem.length; i++) {
                                                      if (addextraitem[i]['id'].toString() == ee['id'].toString()) {
                                                        addextraitem.removeAt(i);
                                                        */ /*extrasetState(() {
                                                           totalprice =(double.parse(totalprice)-double.parse(ee['addon_price'])).toString();
                                                        });*/ /*
                                                      }
                                                    }*/
                                                          } else {
                                                            extrasetState(() {
                                                              ee['enabled'] =
                                                                  "1";
                                                            });
                                                            addextraitem.add({
                                                              "id": ee['id']
                                                                  .toString(),
                                                              "price": ee[
                                                                      'addon_price']
                                                                  .toString(),
                                                              "status": 1
                                                            });
                                                          }
                                                        } else {
                                                          if (ee['enabled']
                                                                  .toString() ==
                                                              "1") {
                                                            extrasetState(() {
                                                              ee['enabled'] =
                                                                  "0";
                                                            });
                                                            addextraitem.add({
                                                              "id": ee['id']
                                                                  .toString(),
                                                              "price": ee[
                                                                      'addon_price']
                                                                  .toString(),
                                                              "status": 0
                                                            });
                                                            extrasetState(() {
                                                              totalprice = (double
                                                                          .parse(
                                                                              totalprice) -
                                                                      double.parse(
                                                                          ee['addon_price']))
                                                                  .toString();
                                                            });
                                                            /*for (int i = 0; i < addextraitem.length; i++) {
                                                      if (addextraitem[i]['id'].toString() == ee['id'].toString()) {
                                                        addextraitem.removeAt(i);
                                                        */ /*extrasetState(() {
                                                          totalprice =(double.parse(totalprice)-double.parse(ee['addon_price'])).toString();
                                                        });*/ /*
                                                      }
                                                    }*/
                                                          } else {
                                                            int total = 0;
                                                            tempList.forEach(
                                                                (element) {
                                                              if (element['enabled']
                                                                      .toString() ==
                                                                  "1") {
                                                                total++;
                                                                //totalprice = totalprice+double.parse(element['addon_price'].toString());

                                                              }
                                                            });
                                                            if (total <
                                                                int.parse(e[
                                                                        'addon_limit']
                                                                    .toString())) {
                                                              extrasetState(() {
                                                                ee['enabled'] =
                                                                    "1";
                                                              });
                                                              addextraitem.add({
                                                                "id": ee['id']
                                                                    .toString(),
                                                                "price": ee[
                                                                        'addon_price']
                                                                    .toString(),
                                                                "status": 1
                                                              });
                                                            } else {
                                                              Fluttertoast.showToast(
                                                                  msg: e['title_name']
                                                                          .toString() +
                                                                      " items\nUnselect selected items");
                                                            }
                                                          }
                                                        }
                                                        print("my print");
                                                        double temp1 = 0;
                                                        for (int i = 0;
                                                            i <
                                                                addextraitem
                                                                    .length;
                                                            i++) {
                                                          if (addextraitem[i]
                                                                      ['status']
                                                                  .toString() ==
                                                              "1") {
                                                            temp1 = temp1 +
                                                                double.parse(addextraitem[
                                                                            i][
                                                                        'price']
                                                                    .toString());
                                                            print(addextraitem[
                                                                i]);
                                                          }
                                                        }
                                                        print(temp1);
                                                        extrasetState(() {
                                                          finalPrice = temp1;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  )
                                ]);
                              }).toList(),
                            )),
                        Positioned(
                          bottom: 10.0,
                          left: 10.0,
                          right: 10.0,
                          child: GestureDetector(
                            onTap: () {
                              //Navigator.of(context).pop();
                              Navigator.pop(context);
                              cartaction(id, "41", rate, offerprice, qty,
                                  addextraitem);
                            },
                            child: StatefulBuilder(
                              builder: (BuildContext context,
                                      StateSetter extrasetState) =>
                                  Container(
                                height: 45,
                                width: 100,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0))),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "Total Price : " +
                                              (double.parse(totalprice
                                                          .toString()) +
                                                      finalPrice)
                                                  .toString(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500)),
                                      Text("UPDATE ITEM & CLOSE",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ));
              },
            ));
  }

  Widget buildInstructionContainer() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: Card(
        elevation: 4.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0, bottom: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 24,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.75,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 8.0),
                  child: TextFormField(
                    focusNode: myFocusNode,
                    controller: instructionController,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Write instructions for restaurant',
                    ),
                    onChanged: (value) {
                      userinstructions = value;
                    },
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline,
                    size: 20.0, color: Colors.grey.shade500),
                onPressed: () {
                  myFocusNode.requestFocus();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
