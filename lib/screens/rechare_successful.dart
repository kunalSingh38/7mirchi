import 'dart:convert';

import 'package:flutter/material.dart';

class RechargeCompletePage extends StatefulWidget {
  final Object argument;
  const RechargeCompletePage({Key key, this.argument}) : super(key: key);
  @override
  _OrderCompletePageState createState() => _OrderCompletePageState();
}

class _OrderCompletePageState extends State<RechargeCompletePage> {
  var amount;


  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    amount = data['amount'];

  }

  Widget _orderComplete() {
    return Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 100,
              width: 100,
              margin: const EdgeInsets.only(bottom: 20),
              child: Image.asset("assets/images/wallet.png"),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 0, bottom: 80),
              child: Column(
                children: [
                  Text(
                    "Wallet Recharge Successful!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
                  ),
                  SizedBox(height:30),
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12, right: 12, bottom: 12,top: 12),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Payment Status:',style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),),
                                Text("Success",style: TextStyle(
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
                                Text('Recharge Amount',style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),),
                                Text("\u20B9 " + amount.toString(),style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),),
                              ]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height:50),
                  Container(
                    margin: new EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 30),
                    child: Align(
                      alignment: Alignment.center,
                      child: ButtonTheme(
                        minWidth: MediaQuery.of(context).size.width,
                        child: RaisedButton(
                          onPressed: () async {
                            Navigator.of(context)
                                .pushNamedAndRemoveUntil('/dashboard', (route) => false);
                          },
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 48.0),
                          shape: StadiumBorder(),
                          child: Text(
                            "CONTINUE",
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
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wallet Recharge"),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/dashboard', (route) => false);
          return true;
        },
        child: Center(
          child: _orderComplete(),
        ),
      ),
    );
  }
}
