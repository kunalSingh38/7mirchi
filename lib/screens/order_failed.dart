import 'package:flutter/material.dart';

class OrderFailedPage extends StatefulWidget {
  @override
  _OrderFailedPageState createState() => _OrderFailedPageState();
}

class _OrderFailedPageState extends State<OrderFailedPage> {
  Widget _orderFailed() {
    return Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 120,
              width: 120,
              margin: const EdgeInsets.only(bottom: 20),
              child: Image.asset("assets/images/failed.png"),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 0, bottom: 80),
              child: Column(
                children: [
                  Text(
                    "Uh Ho!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red),
                  ),
                  SizedBox(height:10),
                  Text(
                    "Your order has been failed.",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF372D61)),
                  ),
                  SizedBox(height:0),
                  Text(
                    "Kindly try placing your order again.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
        title: Text("Order Failed"),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/dashboard', (route) => false);
          return true;
        },
        child: Center(
          child: _orderFailed(),
        ),
      ),
    );
  }
}
