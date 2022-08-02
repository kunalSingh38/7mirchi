import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sodhis_app/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sodhis_app/utilities/basic_auth.dart';

class PaymentOptionsScreen extends StatefulWidget {
  final Object argument;
  const PaymentOptionsScreen({Key key, this.argument}) : super(key: key);

  @override
  _PaymentOptionsScreenState createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {


  bool _cashVisibility = false;
  bool _walletVisibility = false;
  bool _onlineVisibility = false;
  int selectedIndex = 0;

  String userId;
  String walletBalance;
  String payableAmount;
  String subtotalAmount;
  String totalDiscount;
  String couponCode;
  String instructions;
  String deliverytime;
  String deliverydate;


  var _razorpay = Razorpay();

  var _timeDropdownVal = "";
  String formatted = "";

  bool _loading = false;

  String _mobile;
  String _email;

  String _checkPaymentOption = "0";

  @override
  void initState() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);

    print(data['instructions'].toString());

    userId = data['userid'].toString();
    walletBalance = data['wallet_balance'].toString();
    payableAmount = data['payable_amount'].toString();
    subtotalAmount = data['subtotal'].toString();
    totalDiscount = data['total_discount'].toString();
    couponCode = data['coupon_code'].toString();
    instructions = data['instructions'].toString();
    deliverydate = data['date'].toString();
    deliverytime = data['time'].toString();

    print(deliverytime);
    print(deliverydate);

    if(int.parse(data['wallet_balance']) >= int.parse(data['payable_amount'])){
       setState(() {
          selectedIndex = 0;
          _walletVisibility = true;
          _checkPaymentOption = "1";
       });
    }
    else{
      setState(() {
        selectedIndex = 1;
        _onlineVisibility = true;
        _checkPaymentOption = "2";
      });
    }

    _getUser();

  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("success");
    print(response.orderId);
    if(_checkPaymentOption == "1"){
      _walletPayment(response.paymentId);
    }
    else{
      _onlinePayment(response.paymentId);
    }

  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Failed");
    print(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
  }


  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('email_address');
      _mobile = prefs.getString('mobile_number');
    });
  }

  _onlinePayment(String paymentid) async{
    setState(() {
      _loading = true;
    });
    var res = await http.post(new Uri.https(BASE_URL, API_PATH + "/createorder"),
      body: {
        "user_id": userId,
        "type_of_order": "hd",
        "instruction": instructions,
        "discounted_price": "",
        "delivery_date": deliverydate,
        "delivery_time": deliverytime,
        "subtotal" : subtotalAmount,
        "total_discount" : totalDiscount,
        "coupon_code" : couponCode,
        "razorpay_payment_id" : paymentid,
        "wallet_total" : "0",
        "razorpay_total" : payableAmount
      },
      headers: {
        "Accept": "application/json",
        "authorization": basicAuth
      },
    );
    print(json.encode({
      "user_id": userId,
      "type_of_order": "hd",
      "instruction": instructions,
      "discounted_price": "",
      "delivery_date": deliverydate,
      "delivery_time": deliverytime,
      "subtotal" : subtotalAmount,
      "total_discount" : totalDiscount,
      "coupon_code" : couponCode,
      "razorpay_payment_id" : paymentid,
      "wallet_total" : "0",
      "razorpay_total" : payableAmount
    }));
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      print(data);
      setState(() {
        _loading = false;
      });
      if (data['ErrorCode'] == 0) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(
            '/order-complete',
                (route) => false);
      } else {
        setState(() {
          _loading = false;
        });
        Fluttertoast.showToast(
            msg: data['ErrorMessage']);
      }
    }
  }

  _walletPayment(String paymentid) async{
    setState(() {
      _loading = true;
    });
    var res = await http.post(new Uri.https(BASE_URL, API_PATH + "/createorder"),
      body: {
        "user_id": userId,
        "type_of_order": "hd",
        "instruction": instructions,
        "discounted_price": "",
        "delivery_date": deliverydate,
        "delivery_time": deliverytime,
        "subtotal" : subtotalAmount,
        "total_discount" : totalDiscount,
        "coupon_code" : couponCode,
        "razorpay_payment_id" : paymentid,
        "wallet_total" : walletBalance,
        "razorpay_total" : (int.parse(payableAmount) - int.parse(walletBalance)).toString()
      },
      headers: {
        "Accept": "application/json",
        "authorization": basicAuth
      },
    );
    print(json.encode({
      "user_id": userId,
      "type_of_order": "hd",
      "instruction": instructions,
      "discounted_price": "",
      "delivery_date": deliverydate,
      "delivery_time": deliverytime,
      "subtotal" : subtotalAmount,
      "total_discount" : totalDiscount,
      "coupon_code" : couponCode,
      "razorpay_payment_id" : paymentid,
      "wallet_total" : walletBalance,
      "razorpay_total" : (int.parse(payableAmount) - int.parse(walletBalance)).toString()
    }));
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      print(data);
      setState(() {
        _loading = false;
      });
      if (data['ErrorCode'] == 0) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(
            '/order-complete',
                (route) => false);
      } else {
        setState(() {
          _loading = false;
        });
        Fluttertoast.showToast(msg: data['ErrorMessage']);
      }
    }
  }

  _onlyWalletPayment() async{
    setState(() {
      _loading = true;
    });
    var res = await http.post(new Uri.https(BASE_URL, API_PATH + "/createorder"),
      body: {
        "user_id": userId,
        "type_of_order": "hd",
        "instruction": instructions,
        "discounted_price": "",
        "delivery_date": deliverydate,
        "delivery_time": deliverytime,
        "subtotal" : subtotalAmount,
        "total_discount" : totalDiscount,
        "coupon_code" : couponCode,
        "razorpay_payment_id" : "",
        "wallet_total" : walletBalance,
        "razorpay_total" : ""
      },
      headers: {
        "Accept": "application/json",
        "authorization": basicAuth
      },
    );
    print(json.encode({
      "user_id": userId,
      "type_of_order": "hd",
      "instruction": "",
      "discounted_price": "",
      "delivery_date": deliverydate,
      "delivery_time": deliverytime,
      "subtotal" : subtotalAmount,
      "total_discount" : totalDiscount,
      "coupon_code" : couponCode,
      "razorpay_payment_id" : "",
      "wallet_total" : walletBalance,
      "razorpay_total" : ""
    }));
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      print(data);
      setState(() {
        _loading = false;
      });
      if (data['ErrorCode'] == 0) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(
            '/order-complete',
                (route) => false);
      } else {
        setState(() {
          _loading = false;
        });
        Fluttertoast.showToast(msg: data['ErrorMessage']);
      }
    }
  }

  _cashOnDelivery() async{
    var res = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/cash-on-delivery"),
      body: {
        "user_id": userId,
        "type_of_order": "hd",
        "subtotal" : subtotalAmount,
        "total_discount" : totalDiscount,
        "coupon_code" : couponCode,
        "instruction" : instructions,
        "delivery_date" : deliverydate,
        "delivery_time": deliverytime,
      },
      headers: {
        "Accept": "application/json",
        "authorization": basicAuth
      },
    );
    print(json.encode({
      "user_id": userId,
      "type_of_order": "hd",
      "subtotal" : subtotalAmount,
      "total_discount" : totalDiscount,
      "coupon_code" : couponCode,
      "instruction" : instructions,
      "delivery_date" : deliverydate,
      "delivery_time": deliverytime,
    }));
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      print(data);
      setState(() {
        _loading = false;
      });
      if (data['ErrorCode'] == 0) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(
            '/order-complete',
                (route) => false);
      } else {
        Fluttertoast.showToast(
            msg: data['ErrorMessage']);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text("Payment options"),
          leading: InkWell(
           onTap: () => Navigator.pop(context),
           child: Icon(Icons.arrow_back, color: Colors.white, size: 24.0),
          ),
       ),
       body: ModalProgressHUD(
         inAsyncCall: _loading,
         child: Padding(
           padding: const EdgeInsets.all(5.0),
           child: ListView(
             children: <Widget>[
               /*Padding(
                 padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
                 child: Text("Wallet Payment", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
               ),*/
               Card(
                 elevation: 4.0,
                 color: Colors.white,
                 shape: RoundedRectangleBorder(
                   side: BorderSide(color: Colors.white, width: 1),
                   borderRadius: BorderRadius.circular(10),
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, left: 12.0, right: 12.0, bottom: 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Column(
                                 mainAxisAlignment: MainAxisAlignment.start,
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                    Text("Wallet Payment", style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w500)),
                                    SizedBox(height: 4.0),
                                    Text("Available Amount: \u20B9 $walletBalance", style: TextStyle(color: Colors.grey, fontSize: 12.0)),
                                    SizedBox(height: 4.0),
                                    selectedIndex == 0 ? Text("Payable Amount: \u20B9"+(double.parse(payableAmount)-double.parse(walletBalance)).toString(), style: TextStyle(color: Colors.black, fontSize: 14.0)) : Container()
                                 ],
                               ),
                              CustomRadioButton(0)
                            ],
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Visibility(
                          visible: _walletVisibility,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                            child: InkWell(
                              onTap: (){
                                setState(() {
                                   _checkPaymentOption = "1";
                                });
                                if(int.parse(walletBalance) >= int.parse(payableAmount)){
                                   _onlyWalletPayment();
                                }
                                else{
                                  var options = {
                                    //'key': 'rzp_test_MhKrOdDQM8C8PL',
                                    'key': 'rzp_live_BFMsXWTfZmdTnn',
                                    'amount': ((int.parse(payableAmount) - int.parse(walletBalance))*100).toString(), //in the smallest currency sub-unit.
                                    'name': '7Mirchi',
                                    'description': '',
                                    'timeout': 600, // in seconds
                                    'prefill': {
                                      'contact': _mobile,
                                      'email': _email
                                    }
                                  };
                                  _razorpay.open(options);
                                }
                              },
                              child: Container(
                                height: 55.0,
                                width: double.infinity,
                                child: Card(
                                  elevation: 4.0,
                                  color: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Colors.green, width: 1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 15.0),
                                    child: Text("PAY \u20B9 "+(double.parse(payableAmount)-double.parse(walletBalance)).toString()+" BY WALLET", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                   ],
                 ),
               ),
               /*Padding(
                 padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
                 child: Text("Online Payment", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
               ),*/
               SizedBox(height: 15),
               Card(
                 elevation: 4.0,
                 color: Colors.white,
                 shape: RoundedRectangleBorder(
                   side: BorderSide(color: Colors.white, width: 1),
                   borderRadius: BorderRadius.circular(10),
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Padding(
                       padding: const EdgeInsets.only(top: 10.0, left: 12.0, right: 12.0),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Column(
                             mainAxisAlignment: MainAxisAlignment.start,
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text("Online Payment", style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w500)),
                               SizedBox(height: 4.0),
                               SizedBox(
                                   width: 290,
                                   child: Text("Choose online payment option",
                                       maxLines: 2,
                                       style: TextStyle(color: Colors.grey, fontSize: 12.0)
                                   )
                               ),
                               SizedBox(height: 4.0),
                               selectedIndex == 1 ? Text("Payable Amount: \u20B9 $payableAmount", style: TextStyle(color: Colors.black, fontSize: 14.0)) : Container()
                             ],
                           ),
                           CustomRadioButton(1)
                         ],
                       ),
                     ),
                     SizedBox(height: 5.0),
                     Visibility(
                       visible: _onlineVisibility,
                       child: Padding(
                         padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                         child: InkWell(
                           onTap: (){
                             setState(() {
                               _checkPaymentOption = "2";
                             });
                             var options = {
                               //'key': 'rzp_test_MhKrOdDQM8C8PL',
                               'key': 'rzp_live_BFMsXWTfZmdTnn',
                               'amount': ((int.parse(payableAmount)*100).toString()), //in the smallest currency sub-unit.
                               'name': '7Mirchi',
                               'description': '',
                               'timeout': 600, // in seconds
                               'prefill': {
                                 'contact': _mobile,
                                 'email': _email
                               }
                             };
                             _razorpay.open(
                                 options
                             );
                           },
                           child: Container(
                             height: 55.0,
                             width: double.infinity,
                             child: Card(
                               elevation: 4.0,
                               color: Colors.green,
                               shape: RoundedRectangleBorder(
                                 side: BorderSide(color: Colors.green, width: 1),
                                 borderRadius: BorderRadius.circular(10),
                               ),
                               child: Padding(
                                 padding: const EdgeInsets.only(top: 15.0),
                                 child: Text("PAY \u20B9 $payableAmount ONLINE", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                               ),
                             ),
                           ),
                         ),
                       ),
                     )
                   ],
                 ),
               ),
               /*Padding(
                 padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
                 child: Text("Cash On Delivery", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
               ),*/
               SizedBox(height: 15),
               Card(
                 elevation: 4.0,
                 color: Colors.white,
                 shape: RoundedRectangleBorder(
                   side: BorderSide(color: Colors.white, width: 1),
                   borderRadius: BorderRadius.circular(10),
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Padding(
                       padding: const EdgeInsets.only(top: 10.0, left: 12.0, right: 12.0),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Column(
                             mainAxisAlignment: MainAxisAlignment.start,
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text("Cash on delivery", style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w500)),
                               SizedBox(height: 4.0),
                               SizedBox(
                                   width: 290,
                                   child: Text("Pay cash at the time of delivery. We recommend you use online payments for contactless delivery",
                                       maxLines: 2,
                                       style: TextStyle(color: Colors.grey, fontSize: 12.0)
                                   )
                               ),
                               SizedBox(height: 4.0),
                               selectedIndex == 2 ? Text("Payable Amount: \u20B9 $payableAmount", style: TextStyle(color: Colors.black, fontSize: 14.0)) : Container()
                             ],
                           ),
                           CustomRadioButton(2)
                         ],
                       ),
                     ),
                     SizedBox(height: 5.0),
                     Visibility(
                       visible: _cashVisibility,
                       child: Padding(
                         padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                         child: InkWell(
                           onTap: (){
                             _cashOnDelivery();
                           },
                           child: Container(
                             height: 55.0,
                             width: double.infinity,
                             child: Card(
                               elevation: 4.0,
                               color: Colors.green,
                               shape: RoundedRectangleBorder(
                                 side: BorderSide(color: Colors.green, width: 1),
                                 borderRadius: BorderRadius.circular(10),
                               ),
                               child: Padding(
                                 padding: const EdgeInsets.only(top: 15.0),
                                 child: Text("CASH ON DELIVERY", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
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
       ),
    );
  }

  void changeIndex(int index){
    if(index == 0){
       setState(() {
          selectedIndex = index;
          _walletVisibility = true;
          _onlineVisibility = false;
          _cashVisibility = false;
       });
    }
    else if(index == 1){
      setState(() {
        selectedIndex = index;
        _walletVisibility = false;
        _onlineVisibility = true;
        _cashVisibility = false;
      });
    }
    else{
      setState(() {
        selectedIndex = index;
        _walletVisibility = false;
        _onlineVisibility = false;
        _cashVisibility = true;
      });
    }
  }

  Widget CustomRadioButton(int index) {
    if(selectedIndex == index) {
       return InkWell(
          onTap: () => changeIndex(index),
          child: Container(
             height: 24.0,
             width: 24.0,
             child: Icon(Icons.check_circle, size: 24.0, color: Colors.green),
          ),
       );
    }
    else{
       return InkWell(
         onTap: () => changeIndex(index),
         child: Container(
           height: 20.0,
           width: 20.0,
           decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(10.0),
               border: Border.all(color: Colors.grey, width: 1)
           ),
         ),
       );
    }
  }
}
