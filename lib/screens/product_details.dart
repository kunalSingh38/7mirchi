import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:sodhis_app/services/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sodhis_app/components/general.dart';
import 'package:provider/provider.dart';
import 'package:sodhis_app/services/cart_badge.dart';
import 'package:sodhis_app/services/cart.dart';
import 'package:badges/badges.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProductDetailsPage extends StatefulWidget {
  final Object argument;
  const ProductDetailsPage({Key key, this.argument}) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  var _userId;
  var _title;
  var _productId;
  int _counter;
  Future _productDetails;
  String _addToBasketLabel = 'Add to Basket';
  int _cartQuantity = 0;
  bool _isWishlisted = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    _title = data['title'];
    _productId = data['product_id'];
    _counter = 1;

    Preference().getPreferences().then((prefs) {
      setState(() {
        _userId = prefs.getInt('user_id').toString();
        _productDetails = _futureProductDetails();
      });
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      setState(() {
        if (_cartQuantity != _counter) {
          _addToBasketLabel = 'Add to Basket';
        } else {
          _addToBasketLabel = 'Go to Basket';
        }
      });
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 1) {
        _counter--;
        setState(() {
          if (_cartQuantity != _counter) {
            _addToBasketLabel = 'Add to Basket';
          } else {
            _addToBasketLabel = 'Go to Basket';
          }
        });
      }
    });
  }

  Future _futureProductDetails() async {
    var response = await http
        .post(new Uri.https(BASE_URL, API_PATH + "/product-details"), body: {
      "user_id": _userId,
      "product_id": _productId,
    }, headers: {
      "Accept": "application/json",
      "authorization": basicAuth
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['Response'];
      if (result['cart_quantity'] > 0) {
        setState(() {
          _addToBasketLabel = 'Go to Basket';
          _cartQuantity = result['cart_quantity'];
          _counter = _cartQuantity;
        });
      }
      if (result['is_wishlisted'] == true) {
        setState(() {
          _isWishlisted = true;
        });
      }
      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Widget _networkImage(url) {
    return Image(
      image: CachedNetworkImageProvider(url),
    );
  }

  Widget _productDetailsBuilder() {
    final _cart = Provider.of<CartBadge>(context, listen: false);
    final _cartProvider = Provider.of<Cart>(context, listen: false);
    return FutureBuilder(
      future: _productDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  //margin: const EdgeInsets.only(top: 20, bottom: 20),
                  child: LimitedBox(
                    maxHeight: 300,
                    child: _networkImage(snapshot.data['product_image']),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    height: MediaQuery.of(context).size.height * 0.75,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25)),
                        color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          snapshot.data['product_name'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          snapshot.data['item_type'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          snapshot.data['description'] != null ? snapshot.data['description'] : '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "\u20B9 " + snapshot.data['discount'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                //decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text("MRP: "+snapshot.data['mrp'], style: TextStyle(decoration: TextDecoration.lineThrough,color: Colors.grey[700])),
                            SizedBox(
                              width: 15,
                            ),
                            Container(
                              height: 20,
                              color: Theme.of(context).accentColor,
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                snapshot.data['discount_percentage'].toString()+"%"+" OFF",
                                  style: TextStyle(fontSize: 15,color: Colors.white),
                                  overflow: TextOverflow.clip,
                                  softWrap: false,
                              ),
                            ),

                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: _decrementCounter,
                                  child: Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 2,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(35 / 2),
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
                                Text('$_counter'),
                                SizedBox(
                                  width: 15,
                                ),
                                GestureDetector(
                                  onTap: _incrementCounter,
                                  child: Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(35 / 2),
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
                            /*Text(
                              "\u20B9 " + snapshot.data['mrp'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                //decoration: TextDecoration.lineThrough,
                              ),
                            ),*/
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                if (_isWishlisted) {
                                  setState(() {
                                    _isWishlisted = false;
                                  });
                                  await http.post(
                                    new Uri.https(
                                        BASE_URL, API_PATH + "/remove-shoppinglist"),
                                    body: {
                                      "user_id": _userId.toString(),
                                      "product_id": snapshot.data['id'].toString(),
                                    },
                                    headers: {
                                      "Accept": "application/json",
                                      "authorization": basicAuth
                                    },
                                  );
                                } else {
                                  setState(() {
                                    _isWishlisted = true;
                                  });
                                  await http.post(
                                    new Uri.https(
                                        BASE_URL, API_PATH + "/add-shoppinglist"),
                                    body: {
                                      "user_id": _userId.toString(),
                                      "product_id": snapshot.data['id'].toString(),
                                      "quantity": _counter.toString(),
                                    },
                                    headers: {
                                      "Accept": "application/json",
                                      "authorization": basicAuth
                                    },
                                  );
                                }
                              },
                              child: Container(
                                height: 50,
                                width: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Theme.of(context).accentColor,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  _isWishlisted
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 25,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  if (_addToBasketLabel == 'Go to Basket') {
                                    Navigator.pushNamed(context, '/checkout-new');
                                  } else {
                                    setState(() {
                                      _loading = true;
                                    });
                                    var response = await http.post(
                                      new Uri.https(
                                          BASE_URL, API_PATH + "/cart-add"),
                                      body: {
                                        "user_id": _userId.toString(),
                                        "product_id": snapshot.data['id'].toString(),
                                        "quantity": _counter.toString(),
                                        "rate": snapshot.data['mrp'].toString(),
                                        "amount": snapshot.data['mrp']*_counter,
                                        "offer_price":snapshot.data['discount'].toString(),
                                      },
                                      headers: {
                                        "Accept": "application/json",
                                        "authorization": basicAuth
                                      },
                                    );
                                    if (response.statusCode == 200) {
                                      setState(() {
                                        _loading = false;
                                        _addToBasketLabel = 'Go to Basket';
                                        _cart.showCartBadge(_userId);
                                        _cartProvider.showCartItems(_userId);
                                      });
                                      var data = json.decode(response.body);
                                      var errorCode = data['ErrorCode'];
                                      var errorMessage = data['ErrorMessage'];
                                      if (errorCode == 0) {
                                        SharedPreferences prefs = await SharedPreferences.getInstance();
                                        prefs.setInt('cart_count', data['Response']['count']);
                                        Fluttertoast.showToast(msg: 'Item added successfully');
                                      } else {
                                        showAlertDialog(context,
                                            ALERT_DIALOG_TITLE, errorMessage);
                                      }
                                    }
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Theme.of(context).accentColor,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.shopping_basket,
                                        size: 25,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '$_addToBasketLabel',
                                        // snapshot.data['cart_quantity'] > 0 ? 'Go to Basket' : 'Add to Basket',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget build(BuildContext context) {
    final _counter = Provider.of<CartBadge>(context);
    return Scaffold(
      //extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Product Details',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Badge(
              animationDuration: Duration(milliseconds: 10),
              animationType: BadgeAnimationType.scale,
              badgeContent: Text(
                '${_counter.getCounter()}',
                style: TextStyle(color: Colors.white),
              ),
              child: const Icon(Icons.shopping_basket),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/checkout-new');
            },
          ),
        ],
      //  backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Center(
        child: ModalProgressHUD(
          inAsyncCall: _loading,
          child: _productDetailsBuilder(),
        ),
      ),
    );
  }
}
