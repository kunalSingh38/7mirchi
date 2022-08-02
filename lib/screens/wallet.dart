import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sodhis_app/screens/dashboard.dart';
import 'package:sodhis_app/screens/multislider_home.dart';
import 'package:sodhis_app/services/shared_preferences.dart';
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../constants.dart';

class MyWallet extends StatefulWidget {
  @override
  _MyWalletState createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWallet> {
  Razorpay _razorpay;
  var value1=1000;
  var value2=2000;
  var value3=3000;
  var value4=4000;
  bool v1=false;
  bool v2=false;
  bool v3=false;
  bool v4=false;
  Future _walletBalance;
  var _name,_userId, mobile_no, email_add;
  final moneyController = TextEditingController(text: "1000");
  TextStyle textStyle = TextStyle(
      fontSize: 15,
      color: Colors.black87,
      fontWeight: FontWeight.normal);


  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    Preference().getPreferences().then((prefs) {
      setState(() {
        _userId = prefs.getInt('user_id').toString();
        _name = prefs.getString('name');
        email_add = prefs.getString('email_address');
        mobile_no = prefs.getString('mobile_number');
      });
    });



  }

  Future walletBalance() async {
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
      print(data);
      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final ProgressDialog pr = ProgressDialog(context, isDismissible: false);
    pr.style(
      message: 'Please wait...',
    );
    print("Success: " + response.orderId.toString());
    print("Success: " + response.paymentId.toString());
    print("Success: " + response.signature.toString());

     var responses = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/walletrecharge"),
      body: {
        "user_id": _userId.toString(),
        "credit_type": "C",
        "transaction_id": response.paymentId.toString(),
        "amount":moneyController.text,
        "mode_type":"Online"
      },
      headers: {
        "Accept": "application/json",
        "authorization": basicAuth,
      },
    );
     print(json.encode({
       "user_id": _userId.toString(),
       "credit_type": "C",
       "transaction_id": response.paymentId.toString(),
       "amount":moneyController.text,
       "mode_type":"Online"
     }));
    if (responses.statusCode == 200) {
      await pr.hide();
      var data = json.decode(responses.body);
      var errorCode = data['ErrorCode'];
      if (errorCode == 0) {
        Navigator.pushNamed(
          context,
          '/recharge-successful',
          arguments: <String, String>{
            'amount': moneyController.text.toString()
          },
        );
      /*  Navigator.of(context)
            .pushNamedAndRemoveUntil('/recharge-wallet', (route) => false);*/
      } else {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/dashboard', (route) => false);
      }
    } else {
      await pr.hide();
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/dashboard', (route) => false);
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

  /*Future<String> generateOrderId(String key, String secret, int amount) async {
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
  }*/

  void openCheckout( num amount) async {
    var options = {
      'key': 'rzp_live_BFMsXWTfZmdTnn',
      'amount': amount,
      'name': "7mirchi",
      //  'order_id': orderId.toString(),
      'description': "Payment for ",
      'prefill': {'contact': mobile_no, 'email': email_add},
      "method": {
        "netbanking": true,
        "card": true,
        "wallet": false,
        "upi": false
      },
      'external': {
        'wallets': ['paytm']
      },
      'redirect': true
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }


  @override
  void dispose() {
    moneyController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  Widget _walletUi(){
    return FutureBuilder(
      future: walletBalance(),
      builder: (context, snapshot) {
        if (snapshot.hasData)
        {
          var errorCode = snapshot.data['ErrorCode'];
          var response = snapshot.data['Response'];
          if (errorCode == 0) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10,bottom: 20),
                    child: Container(
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 12, right: 12, bottom: 12,top: 12),
                            child: Column(

                                children: [
                                  Text('Wallet Balance',style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),),
                                  snapshot.data['Response']!=null? Text("\u20B9 " + snapshot.data['Response']['total_balance'].toString(),style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),):Text("\u20B9 " + "0",style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),),
                                ]),
                          ),
                         /* Container(
                              height: 30,
                              child: VerticalDivider(color: Colors.grey, width: 1)),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 12, right: 12, bottom: 12,top: 12),
                            child: Column(

                                children: [
                                  Text('Reserved Balance',style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),),
                                  Text("\u20B9 " + "0",style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),),
                                ]),
                          ),*/
                        ],
                      ),
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
                            'Add Money',
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
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: moneyController,
                            style: TextStyle(fontFamily: 'Gotham'),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              prefix: Text('\u20B9 ') ,
                              contentPadding: EdgeInsets.only(bottom: 8.0),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).accentColor,),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).accentColor,),
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).accentColor,),
                              ),
                            ),
                            onSaved: (value){
                              moneyController.text = value;
                            },
                            onChanged: (String value) {
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10,right: 10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 5,right: 5,top: 10,bottom: 10),
                                  child:
                                  Material(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          v1 =! v1;
                                          if(v1){
                                            moneyController.text=value1.toString();
                                            v2=false;
                                            v3=false;
                                            v4=false;
                                          }
                                        });


                                      },
                                      child: Container(
                                        alignment: Alignment(0.0, 0.0),
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(width: 1, color: Colors.black87),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(20.0),
                                          ),
                                        ),
                                        child: Text(
                                          '+'+value1.toString(),
                                          style: textStyle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 5,right: 5,top: 10,bottom: 10),
                                  child:
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          v2 =! v2;
                                          if(v2){
                                            moneyController.text=value2.toString();
                                            v1=false;
                                            v3=false;
                                            v4=false;
                                          }
                                        });


                                      },
                                      child: Container(
                                        alignment: Alignment(0.0, 0.0),
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(width: 1, color: Colors.black87),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(20.0),
                                          ),
                                        ),
                                        child: Text(
                                          '+'+value2.toString(),
                                          style: textStyle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 5,right: 5,top: 10,bottom: 10),
                                  child:

                                  Material(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          v3 =! v3;
                                          if(v3){
                                            moneyController.text=value3.toString();
                                            v1=false;
                                            v2=false;
                                            v4=false;
                                          }
                                        });


                                      },
                                      child: Container(
                                        alignment: Alignment(0.0, 0.0),
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(width: 1, color: Colors.black87),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(20.0),
                                          ),
                                        ),
                                        child: Text(
                                          '+'+value3.toString(),
                                          style: textStyle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 5,right: 5,top: 10,bottom: 10),
                                  child:

                                  Material(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          v4 =! v4;
                                          if(v4){
                                            moneyController.text=value4.toString();
                                            v1=false;
                                            v2=false;
                                            v3=false;
                                          }
                                        });


                                      },
                                      child: Container(
                                        alignment: Alignment(0.0, 0.0),
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(width: 1, color: Colors.black87),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(20.0),
                                          ),
                                        ),
                                        child: Text(
                                          '+'+value4.toString(),
                                          style: textStyle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 200,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: RaisedButton(
                                onPressed: () {
                                  openCheckout(num.parse(moneyController.text)*100);
                                },
                                color: Color(0xFFc62714),
                                elevation: 10,
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Add Money",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Gotham',
                                      fontSize: 15.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: (){
                            Navigator.pushNamed(context, '/recharge-history');
                          },
                          child: Card(
                            child: Image.asset(
                              'assets/images/history.jpg',
                              width: 90,
                              height: 90,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: (){
                            Navigator.pushNamed(context, '/billing-history');
                          },
                          child: Card(
                            child: Image.asset(
                              'assets/images/bill.jpg',
                              width: 90,
                              height: 90,
                            ),
                          ),
                        ),
                        /*SizedBox(
                          width: 10,
                        ),

                        Card(
                          child: Image.asset(
                            'assets/images/reserve.jpg',
                            width: 90,
                            height: 90,
                          ),
                        ),*/
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.only(top: 15, left: 12, right: 12),
                          child: Text(
                            'Wallet Summary',
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
                                Text('Last Recharge Amount',style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),),
                                snapshot.data['Response']!=null?
                                Text("\u20B9 " +  snapshot.data['Response']['last_recharge'].toString(),style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),): Text("\u20B9 " + "0",style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),),
                              ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12, right: 12, bottom: 12),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Balance After Last Recharge',style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),),
                                snapshot.data['Response']!=null? Text("\u20B9 " + snapshot.data['Response']['total_balance'].toString(),style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),):Text("\u20B9 " + "0",style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),),
                              ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12, right: 12, bottom: 12),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Bill Since Last Recharge',style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),),
                                snapshot.data['Response']['bill_last_recharge']!=null?
                                Text("\u20B9 " +  snapshot.data['Response']['bill_last_recharge'].toString(),style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),):Text("\u20B9 " + "0",style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),),
                              ]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        }
        else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Container(child: CircularProgressIndicator()));
        }
        else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );


  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            backgroundColor: Colors.grey[200],
            appBar: AppBar(
              title: Text("My Wallet"),
            ),
            body: Container(
                padding: EdgeInsets.all(15),
                child: _walletUi())),
        onWillPop: () async{
          return Navigator.pushNamed(
            context,
            '/dashboard',
          );
        }
    );
  }
}
