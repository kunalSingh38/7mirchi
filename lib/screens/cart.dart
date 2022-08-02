import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shortuuid/shortuuid.dart';
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
import 'package:sodhis_app/components/general.dart';

import 'checkoutview.dart';

class CartPage extends StatefulWidget {

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>  with SingleTickerProviderStateMixin{
  var _userId,takeaway_address;
  var _branchId;
  var _warehouseId;
  var _stockItem;
  var _deliveryType;
  var _dateDropdownVal = 'Today';
  var _timeDropdownVal = '';
  var _placeOrderBtnParent = 'Place Order';
  var _placeOrderBtn = 'Place Order';
  Future _myCartList;
  final nameController = TextEditingController();
  final instructionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var errorCode;
  var response;
  var data;
  AnimationController _animationController;
  List dataModel= new List();
  Map<String, dynamic> value=new Map();

  bool isPress1 = false;
  bool isPress2 = false;
  String _paymentMode = "";
  String _name;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _getUser();
  }

  void dispose() {
    nameController.dispose();
    instructionController.dispose();
    super.dispose();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      takeaway_address = prefs.getString('takeAwayAddress').toString();
      _branchId = prefs.getInt('branch_id').toString();
      _warehouseId = prefs.getInt('warehouse_id').toString();
      _stockItem = prefs.getString('cart');
      _myCartList = _cartLists();
      _name = prefs.getString('name');
      _deliveryType = prefs.getString('delivery_type');
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

  Widget _stockLabel(content,color){
    if(color == 'red'){
      return Text(content, style: TextStyle(color: Colors.red));
    }
    else{
      return Text(content, style: TextStyle(color: Colors.green));
    }
  }

  Widget _outofstockText(response) {
    return Column(
      children: <Widget>[
        for(var i = 0; i < response.length; i++)
        ListTile(
          title: Text(response[i]['item_name']),
          leading: null,
          trailing: _stockLabel(response[i]['status'], response[i]['status'] == 'Out of Stock' ? "red" : "green"),
        ),
      ],
    );
  }

  Widget _outofstockDialog(BuildContext context, response) {
    return new AlertDialog(
      title: const Text('Cart contains out of stock items..'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _outofstockText(response),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Okay, Got it!'),
        ),
      ],
    );
  }

  Future _instructionDialogHD(BuildContext context) async {
    String _additionalInstruction = '';
    return showDialog(
      context: context,
      barrierDismissible: false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Additional Instruction'),
          content: new Row(
            children: [
              new Expanded(
                  child: new TextField(
                autofocus: false,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: new InputDecoration(
                    //hintText: 'eg. Add spoon'
                ),
                onChanged: (value) {
                  _additionalInstruction = value;
                },
              ))
            ],
          ),
          actions: [
            FlatButton(
              child: Text('SKIP'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context,'/checkout',
                  arguments: <String, String>{
                    'additional_instruction': "",
                  },
                );
              },
            ),
            FlatButton(
              child: Text('SUBMIT'),
              onPressed: () {
                Navigator.of(context).pop(_additionalInstruction);
                Navigator.pushNamed(context,'/checkout',
                  arguments: <String, String>{
                    'additional_instruction': _additionalInstruction,
                  },
                );
              },
            ),
          ],
        );
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

  void _homeDelivery() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var item = prefs.getString('item');
    var body = json.encode({
      "branch_id": "8",
      "warehouse_id": "2",
      "item": json.decode(item),
    });
    print(body);
    var response = await http.post("http://ssm.techstreet.in/Service1.svc/GetItemStock",
      body: body,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var errorCode = data['ErrorCode'];
      if (errorCode == 0) {
        _instructionDialogHD(context);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) => _outofstockDialog(context,data['Response']),
        );
      }
    }
  }
  showAlertDialog(BuildContext context, title, content) {
    // Set up the Button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        okButton,
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
 /* void _placeOrder(_cartProvider, setModalState, date, time, name, instruction) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var item = prefs.getString('item');
    var body = json.encode({
      "branch_id": "8",
      "warehouse_id": "2",
      "item": json.decode(item),
    });
    print(body);
    var response = await http.post("http://ssm.techstreet.in/Service1.svc/GetItemStock",
      body: body,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var errorCode = data['ErrorCode'];
      if (errorCode == 0) {
        var response = await http.post(
          new Uri.https(BASE_URL, API_PATH + "/place-order"),
          body: {
            "user_id": _userId.toString(),
            "date": date.toString(),
            "time": time.toString(),
            "name": name.toString(),
            "instruction": instruction.toString(),
          },
          headers: {"Accept": "application/json", "authorization": basicAuth},
        );
        if (response.statusCode == 200) {
          Navigator.pop(context);
          setModalState(() {
            _placeOrderBtn = 'Place Order';
          });
          var data = json.decode(response.body);
          var errorCode = data['ErrorCode'];
          var errorMessage = data['ErrorMessage'];
          if (errorCode == 0) {
            _cartProvider.showCartItems(_userId);
            Navigator.pushReplacementNamed(context, '/order-complete');
          } else {
            showAlertDialog(context, ALERT_DIALOG_TITLE, errorMessage);
          }
        }
      } else {
        Navigator.pop(context);
        setModalState(() {
          _placeOrderBtn = 'Place Order';
        });
        showDialog(
          context: context,
          builder: (BuildContext context) => _outofstockDialog(context,data['Response']),
        );
      }
    }
  }
*/



  Iterable<TimeOfDay> getTimes(TimeOfDay startTime, TimeOfDay endTime, Duration step) sync* {
    var hour = startTime.hour;
    var minute = startTime.minute;
    do {
      yield TimeOfDay(hour: hour, minute: minute);
      minute += step.inMinutes;
      while (minute >= 60) {
        minute -= 60;
        hour++;
      }
    } while (hour < endTime.hour || (hour == endTime.hour && minute <= endTime.minute));
  }
  
  timeSlot(date){
    var currDt = DateTime.now();
    var hourSlot = 10;
    var minuteSlot = 0;
    if(date == 'Today'){
      hourSlot = currDt.hour+1;
      var minute = currDt.minute;
      minuteSlot = 0;
      if(minute > 30){
        hourSlot = currDt.hour+2;
      }
      else{
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

  Future<Null> refreshList() async {
    await Future.delayed(
      Duration(milliseconds: 500),
    );
    setState(() {
      _myCartList = _cartLists();
    });
    //setState(() {});
    return null;
  }

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
      value=json.decode(response.body);
      var result = data['Response'];
      if(data['ErrorCode']==0) {
        setState(() {
          dataModel = result["items"];
        });
      }

      //return result;

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
  Widget _cartListBuilder() {
   // final _counter = Provider.of<CartBadge>(context);
    final _cartProvider = Provider.of<Cart>(context);
    return FutureBuilder(
      future: _cartProvider.getCartList(_userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
           errorCode = snapshot.data['ErrorCode'];
           response = snapshot.data['Response'];
          if (errorCode == 0) {
            return Container(
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                      child: ListView.builder(
                        itemCount: response['items'].length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                    left: 16, right: 16, top: 16),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
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
                                              'product_id': response['items']
                                                      [index]['id']
                                                  .toString(),
                                              'title': response['items'][index]
                                                  ['product_name'],
                                            },
                                          );
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              right: 8,
                                              left: 8,
                                              top: 8,
                                              bottom: 8),
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(14)),
                                            //color: Colors.blue.shade200,
                                            image: DecorationImage(
                                              image: CachedNetworkImageProvider(
                                                  response['items'][index]
                                                      ['product_image']),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/product-details',
                                                    arguments: <String, String>{
                                                      'product_id':
                                                          response['items']
                                                                  [index]['id']
                                                              .toString(),
                                                      'title': response['items']
                                                              [index]
                                                          ['product_name'],
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      right: 8, top: 0),
                                                  child: Text(
                                                    response['items'][index]
                                                        ['product_name'],
                                                    maxLines: 2,
                                                    softWrap: true,
                                                    style:
                                                        TextStyle(fontSize: 16),
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
                                                      child: Text(
                                                        "\u20B9 " +
                                                            "${response['items'][index]['amount']}",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Row(
                                                        children: <Widget>[
                                                          GestureDetector(
                                                            onTap: () async {
                                                              _cartLists();
                                                              setState(() {
                                                                if (response['items'][index]['quantity'] >=1) {
                                                                  response['items'][index]['quantity']--;
                                                                }
                                                              });
                                                              var _amount = response['items'][index]['rate'] * response['items'][index]['quantity'];
                                                              if(response['items'][index]['quantity'] == 0){
                                                                _amount = 0;
                                                              }
                                                              var res = await http.post(new Uri.https(BASE_URL,API_PATH + "/cart-add"),
                                                                body: {
                                                                  "user_id": _userId.toString(),
                                                                  "product_id": response['items'][index]['id'].toString(),
                                                                  "quantity": response['items'][index]['quantity'].toString(),
                                                                  "rate": response['items'][index]['rate'].toString(),
                                                                  "amount": _amount.toString(),
                                                                  "offer_price":response['items'][index]['offer_price'].toString()
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
                                                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                  prefs.setInt('cart_count', data['Response']['count']);
                                                                }
                                                              }
                                                            },
                                                            child: Container(
                                                              height: 25,
                                                              width: 25,
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 2,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            25 /
                                                                                2),
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
                                                          Text(response['items'][index]['quantity'].toString()),
                                                          SizedBox(
                                                            width: 15,
                                                          ),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              _cartLists();
                                                              setState(() {
                                                                response['items'][index]['quantity']++;
                                                              });
                                                              var res = await http.post(new Uri.https(BASE_URL,API_PATH + "/cart-add"),
                                                                body: {
                                                                  "user_id": _userId.toString(),
                                                                  "product_id": response['items'][index]['id'].toString(),
                                                                  "quantity": response['items'][index]['quantity'].toString(),
                                                                  "rate": response['items'][index]['rate'].toString(),
                                                                  "amount": response['items'][index]['rate'] * response['items'][index]['quantity'],
                                                                  "offer_price":response['items'][index]['offer_price'].toString()
                                                                },
                                                                headers: {
                                                                  "Accept": "application/json",
                                                                  "authorization": basicAuth
                                                                },
                                                              );
                                                              if (res.statusCode == 200) {
                                                                var data = json.decode(res.body);
                                                                if (data['ErrorCode'] == 0) {
                                                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                                                  prefs.setInt('cart_count', data['Response']['count']);
                                                                }
                                                              }
                                                            },
                                                            child: Container(
                                                              height: 25,
                                                              width: 25,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            25 /
                                                                                2),
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .grey,
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
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        flex: 100,
                                      )
                                    ],
                                  ),
                                  secondaryActions: <Widget>[
                                    IconSlideAction(
                                      caption: 'Delete',
                                      color: Colors.red,
                                      icon: Icons.delete,
                                      onTap: () {
                                        showConfirmDialog(
                                            response['items'][index]['cart_id'],
                                            'Cancel',
                                            'Remove',
                                            'Remove Item',
                                            'Are you sure want to remove this item?');
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: Center(
                              child: Container(
                                color: Colors.white,
                                height: 60,
                                width: MediaQuery.of(context).size.width *0.50,
                               // padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'Total Price',
                                      style: TextStyle(
                                          color: Theme.of(context).accentColor, fontSize: 12),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      response['total_price'] != null
                                          ? "\u20B9 " +
                                              response['total_price'].toString()
                                          : 0.toString(),
                                      style: TextStyle(
                                          color: Theme.of(context).accentColor, fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(

                            child: Center(
                              child: InkWell(
                                onTap: (){
                                  //   Navigator.pushNamed(context,'/shop');
                                  // if (_deliveryType == 'home_delivery') {
                                  // _homeDelivery();
                                  Navigator.of(context).pop();
                                  Navigator.pushNamed(context,'/checkout',
                                    arguments: <String, String>{
                                      'additional_instruction': "",
                                    },
                                  );
                                },
                                child: Container(
                                  height: 60,
                                  color:Theme.of(context).accentColor,
                                  width: MediaQuery.of(context).size.width *0.50,
                                 // padding: EdgeInsets.only(left: 10,right: 10,top: 15,bottom: 15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        _placeOrderBtnParent,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                  ),

                ],
              ),
            );
          } else {
            return _emptyCart();
          }
        } else {
          return Container(
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
               Container(

                    child: ListView.builder(
                      itemCount: dataModel==null ? 0 :  dataModel.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                  left: 16, right: 16, top: 16),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                              child: Slidable(
                                actionPane: SlidableDrawerActionPane(),
                                child: Row(
                                  children: <Widget>[
                                    GestureDetector(

                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: 8,
                                            left: 8,
                                            top: 8,
                                            bottom: 8),
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(14)),
                                          //color: Colors.blue.shade200,
                                          image: DecorationImage(
                                            image: CachedNetworkImageProvider(
                                                dataModel[index]
                                                ['product_image']),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  '/product-details',
                                                  arguments: <String, String>{
                                                    'product_id':
                                                    response['items']
                                                    [index]['id']
                                                        .toString(),
                                                    'title': response['items']
                                                    [index]
                                                    ['product_name'],
                                                  },
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    right: 8, top: 0),
                                                child: Text(
                                                  dataModel[index]
                                                  ['product_name'],
                                                  maxLines: 2,
                                                  softWrap: true,
                                                  style:
                                                  TextStyle(fontSize: 16),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 6),
                                            Padding(
                                              padding:
                                              const EdgeInsets.all(0.0),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text(
                                                      "\u20B9 " +
                                                          "${dataModel[index]['amount']}",
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight
                                                              .bold),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Row(
                                                      children: <Widget>[
                                                        GestureDetector(
                                                          child: Container(
                                                            height: 25,
                                                            width: 25,
                                                            decoration:
                                                            BoxDecoration(
                                                              border:
                                                              Border.all(
                                                                color: Colors
                                                                    .grey,
                                                                width: 2,
                                                              ),
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  25 /
                                                                      2),
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
                                                        Text(dataModel[index]['quantity'].toString()),
                                                        SizedBox(
                                                          width: 15,
                                                        ),
                                                        GestureDetector(

                                                          child: Container(
                                                            height: 25,
                                                            width: 25,
                                                            decoration:
                                                            BoxDecoration(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  25 /
                                                                      2),
                                                              border:
                                                              Border.all(
                                                                color: Colors
                                                                    .grey,
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
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      flex: 100,
                                    )
                                  ],
                                ),
                                secondaryActions: <Widget>[
                                  IconSlideAction(
                                    caption: 'Delete',
                                    color: Colors.red,
                                    icon: Icons.delete,

                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                Container(
                  width: MediaQuery.of(context).size.width,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Expanded(

                        child: Center(
                          child: Container(
                            height: 60,
                            color: Colors.white,
                            width: MediaQuery.of(context).size.width *0.50,
                            //padding: EdgeInsets.only(left: 20,right: 10,top: 10,bottom: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Total Price',
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor, fontSize: 12),
                                ),
                                SizedBox(height: 5),
                                Text(
                                 "",
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor, fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(

                        child: Center(
                          child: InkWell(
                            onTap: (){

                            },
                            child: Container(
                              height: 60,
                              color:Theme.of(context).accentColor,
                              width: MediaQuery.of(context).size.width *0.50,
                              //padding: EdgeInsets.only(left: 20,right: 10,top: 10,bottom: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    _placeOrderBtnParent,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),

                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),

              ],
            ),
          );

        /* return Center(child: Container(
             child: CircularProgressIndicator()));*/
        }

      },
    );
  }


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Shopping Basket'),
      ),
      body: RefreshIndicator(
        child: Container(
          child: _cartListBuilder(),
        ),
        onRefresh: refreshList,
      ),
    );
  }
}
