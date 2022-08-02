import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderCompletePage extends StatefulWidget {
  @override
  _OrderCompletePageState createState() => _OrderCompletePageState();
}

class _OrderCompletePageState extends State<OrderCompletePage> {
  Widget _orderComplete() {
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
              child: Image.asset("assets/images/logo.png"),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 0, bottom: 80),
              child: Column(
                children: [
                  Text(
                    "Thank You!!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green),
                  ),
                  SizedBox(height:10),
                  Text(
                    "Your order has been placed successfully. It will be delivered on time.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF372D61)),
                  ),
                  SizedBox(height:5),
                  Text(
                    "Sit back and relax. To check the order information, Go to 'My Orders' page.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.grey),
                  ),
              SizedBox(height:50),
              Container(
                margin: new EdgeInsets.only(top: 20, left: 50, right: 50, bottom: 30),
                child: Align(
                  alignment: Alignment.center,
                  child: ButtonTheme(
                    minWidth: MediaQuery.of(context).size.width,
                    child: RaisedButton(
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setString('type', "");
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil('/dashboard', (route) => false);
                      },
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 24.0),
                      shape: StadiumBorder(),
                      child: Text(
                        "Back to Home",
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
        title: Text("Order Complete"),
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/dashboard', (route) => false);
          },
          child: Icon(
            Icons.clear,  // add custom icons also
          ),
        ),
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
