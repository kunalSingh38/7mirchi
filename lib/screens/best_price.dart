import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sodhis_app/components/general.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';

class BestPricePage extends StatefulWidget {
  final Object argument;
  const BestPricePage({Key key, this.argument}) : super(key: key);
  @override
  _BestPricePageState createState() => _BestPricePageState();
}

class _BestPricePageState extends State<BestPricePage> {
  var _userId;
  var _productName;
  var _productImage;
  var _productDesc;
  var _brand;
  var _mrp;
  var _bestPrice;
  var _barcode;
  bool _loaded = false;
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    _barcode = data['barcode'];
    getUser();
  }

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
    });
    bestPrice();
  }

  bestPrice() async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/best-price"),
      body: {
        "user_id": _userId,
        "barcode": _barcode,
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
        setState(() {
          _loaded = true;
            _productName = data['Response']['item_name'];
            _productImage = data['Response']['image'];
            _productDesc = data['Response']['short_description'];
            _brand = data['Response']['brand'];
            _mrp = data['Response']['item_price'];
            _bestPrice = data['Response']['discount_price'];
        });
      
      }
      else if (errorCode == -101) {
        showAlertWithBackDialog(context, ALERT_DIALOG_TITLE, 'Sorry this product is not available.');
      }
      else {
        showAlertWithBackDialog(context, ALERT_DIALOG_TITLE, errorMessage);
      }
    }
  }

  Widget _productContainer() {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
              child: Center(
                child: Image.network("$_productImage"),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.only(top: 30),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
              ),
              child: ListView(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(top: 20, left: 30),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("$_productName",
                        style: TextStyle(
                          fontSize: 22.0,
                          color: Color(0xFF372D61),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.only(top: 10, left: 30, right: 30),
                    child: RichText(
                      text: TextSpan(
                        text: "Brand: ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '$_brand',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.only(top: 10, left: 30, right: 30),
                    child: RichText(
                      text: TextSpan(
                        text: "MRP: ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '$_mrp',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.only(top: 10, left: 30, right: 30),
                    child: RichText(
                      text: TextSpan(
                        text: "Best Price: ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '$_bestPrice',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.only(top: 10, left: 30, right: 30),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "$_productDesc",
                        //style: TextStyle(fontSize: 14.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color(0xFF372D61),
        ),
        //title: Text('Tata Salt', style: TextStyle(color: Colors.purple),),
        backgroundColor: _loaded ? Colors.white: Colors.grey[50],
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: _loaded ? _productContainer() : Text('Loading...'),
        ),
      ),
    );
  }
}
