import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shortuuid/shortuuid.dart';
import 'package:sodhis_app/components/general.dart';
import 'package:sodhis_app/services/cart.dart';
import 'package:sodhis_app/utilities/basic_auth.dart';

import '../constants.dart';
import 'checkoutview.dart';

class ShopPage extends StatefulWidget {
  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  var _userId;
  var _deliveryType;
  var _dateDropdownVal = 'Today';
  String _name;
  var _timeDropdownVal = '';
  final nameController = TextEditingController();
  final instructionController = TextEditingController();
  var _placeOrderBtnParent = 'Place Order';
  var _placeOrderBtn = 'Place Order';
  final _formKey = GlobalKey<FormState>();
  String _paymentMode = 'Cash On Delivery';
  String isPress1 = "false";
  String isPress2 = "false";

  @override
  void initState() {
    super.initState();
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
      _name = prefs.getString('name');
    });
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
    var response = await http.post(
      "http://ssm.techstreet.in/Service1.svc/GetItemStock",
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
          builder: (BuildContext context) =>
              _outofstockDialog(context, data['Response']),
        );
      }
    }
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

  Widget _outofstockText(response) {
    return Column(
      children: <Widget>[
        for (var i = 0; i < response.length; i++)
          ListTile(
            title: Text(response[i]['item_name']),
            leading: null,
            trailing: _stockLabel(response[i]['status'],
                response[i]['status'] == 'Out of Stock' ? "red" : "green"),
          ),
      ],
    );
  }

  Widget _stockLabel(content, color) {
    if (color == 'red') {
      return Text(content, style: TextStyle(color: Colors.red));
    } else {
      return Text(content, style: TextStyle(color: Colors.green));
    }
  }

  Future _instructionDialogHD(BuildContext context) async {
    String _additionalInstruction = '';
    return showDialog(
      context: context,
      barrierDismissible: false,
      // dialog is dismissible with a tap on the barrier
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
                Navigator.pushNamed(
                  context,
                  '/checkout',
                  arguments: <String, String>{
                    'additional_instruction': _additionalInstruction == null
                        ? "_additionalInstruction"
                        : _additionalInstruction,
                  },
                );
              },
            ),
            FlatButton(
              child: Text('SUBMIT'),
              onPressed: () {
                Navigator.of(context).pop(_additionalInstruction);
                Navigator.pushNamed(
                  context,
                  '/checkout',
                  arguments: <String, String>{
                    'additional_instruction': _additionalInstruction == null
                        ? "_additionalInstruction"
                        : _additionalInstruction,
                  },
                );
              },
            ),
          ],
        );
      },
    );
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

  void _placeOrder(
      _cartProvider, setModalState, date, time /*, name*/, instruction) async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/place-order"),
      body: {
        "user_id": _userId.toString(),
        "date": date.toString(),
        "time": time.toString(),
        "name": _name.toString(),
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
    /* SharedPreferences prefs = await SharedPreferences.getInstance();
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
            "name": "",
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
    }*/
  }

  void _showPaymentModeDialog(context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Payment Mode'),
          content: new Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    title: new Text('Cash On Delivery'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _paymentMode = 'Cash On Delivery';
                      });
                    }),
                new ListTile(
                  title: new Text('Online Payment'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _paymentMode = 'Online Payment';
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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

  Widget build(BuildContext context) {
    final _cartProvider = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Delivery Type'),
      ),
      //backgroundColor: Colors.grey[100],
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('delivery_type', 'home_delivery');
                  // Navigator.pushNamed(context,'/cart');
                  if (prefs.getString('delivery_type') == 'home_delivery') {
                    //_homeDelivery();
                    Navigator.of(context).pop();
                    Navigator.pushNamed(
                      context,
                      '/checkout',
                      arguments: <String, String>{
                        'additional_instruction': "",
                      },
                    );
                  } else {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(builder: (BuildContext context,
                            StateSetter
                                setModalState /*You can rename this!*/) {
                          return Form(
                            key: _formKey,
                            child: Container(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        "Pickup Details",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 10),
                                      DropdownButton<String>(
                                        isExpanded: true,
                                        underline: Container(
                                          height: 1,
                                        ),
                                        items: [
                                          DropdownMenuItem<String>(
                                            child: Text('Today'),
                                            value: 'Today',
                                          ),
                                          DropdownMenuItem<String>(
                                            child: Text('Tomorrow'),
                                            value: 'Tomorrow',
                                          ),
                                        ],
                                        value: _dateDropdownVal,
                                        onChanged: (String value) {
                                          setModalState(() {
                                            _timeDropdownVal = '';
                                            _dateDropdownVal = value;
                                          });
                                        },
                                      ),
                                      SizedBox(height: 10),
                                      DropdownButton<String>(
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
                                              i <
                                                  timeSlot(_dateDropdownVal)
                                                      .length;
                                              i++)
                                            DropdownMenuItem<String>(
                                              child: Text(timeSlot(
                                                  _dateDropdownVal)[i]),
                                              value:
                                                  timeSlot(_dateDropdownVal)[i],
                                            ),
                                        ],
                                        value: _timeDropdownVal,
                                        onChanged: (String value) {
                                          setModalState(() {
                                            _timeDropdownVal = value;
                                          });
                                        },
                                      ),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        controller: nameController,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please enter customer name';
                                          }
                                          return null;
                                        },
                                        onSaved: (String value) {
                                          nameController.text = value;
                                        },
                                        decoration: new InputDecoration(
                                          labelText: "Customer Name",
                                          contentPadding:
                                              EdgeInsets.only(left: 8.0),
                                          fillColor: Colors.white,
                                          border: new OutlineInputBorder(
                                            borderSide: new BorderSide(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        controller: instructionController,
                                        onSaved: (String value) {
                                          instructionController.text = value;
                                        },
                                        decoration: new InputDecoration(
                                          labelText: "Additional Instruction",
                                          contentPadding:
                                              EdgeInsets.only(left: 8.0),
                                          fillColor: Colors.white,
                                          border: new OutlineInputBorder(
                                            borderSide: new BorderSide(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        child: RaisedButton(
                                          onPressed: () {
                                            if (_formKey.currentState
                                                .validate()) {
                                              _formKey.currentState.save();
                                              if (_timeDropdownVal != '') {
                                                setModalState(() {
                                                  _placeOrderBtn =
                                                      'Please wait...';
                                                });
                                                // Navigator.pushReplacementNamed(context, '/order-complete');
                                                if (_paymentMode ==
                                                    'Cash On Delivery') {
                                                  _placeOrder(
                                                      _cartProvider,
                                                      setModalState,
                                                      _dateDropdownVal,
                                                      _timeDropdownVal /*,nameController.text*/,
                                                      instructionController
                                                          .text);
                                                } else {
                                                  var merchantTxnId =
                                                      ShortUuid.shortv4();
                                                  print("how" + merchantTxnId);
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          MyWebView(
                                                        title: "Make Payment",
                                                        url: "https://qrestro.com/sodhis/proceed-to-pay?restaurant_id=" +
                                                            "35" +
                                                            "&user_id=" +
                                                            _userId.toString() +
                                                            "&merchantTxnId=" +
                                                            merchantTxnId +
                                                            "&channel=ANDROID&instruction=" +
                                                            instructionController
                                                                .text,
                                                        userId: _userId,
                                                        merchantTxnId:
                                                            merchantTxnId,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                          textColor: Colors.white,
                                          color: Colors.grey[700],
                                          child: new Text(
                                            _placeOrderBtn,
                                          ),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          );
                        });
                      },
                    );
                  }
                },
                child: Container(
                  height: 240,
                  margin: const EdgeInsets.only(top: 30, left: 30, right: 30),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.grey[400],
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                        child: Image(
                          width: 200,
                          height: 200,
                          image: AssetImage('assets/images/delivery.jpg'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          "Home Delivery",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('delivery_type', 'takeaway');
                  //  Navigator.pushNamed(context,'/cart');
                  if (prefs.getString('delivery_type') == 'home_delivery') {
                    // _homeDelivery();
                    Navigator.of(context).pop();
                    Navigator.pushNamed(
                      context,
                      '/checkout',
                      arguments: <String, String>{
                        'additional_instruction': "",
                      },
                    );
                  }
                  else {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(builder: (BuildContext context,
                            StateSetter
                                setModalState /*You can rename this!*/) {
                          return Form(
                            key: _formKey,
                            child: Container(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              //  color: Color(0xFFf2f2f2),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(30, 15, 30, 15),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        "Pickup Details",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 5),
                                      DropdownButton<String>(
                                        isExpanded: true,
                                        underline: Container(
                                          height: 1,
                                        ),
                                        items: [
                                          DropdownMenuItem<String>(
                                            child: Text('Today'),
                                            value: 'Today',
                                          ),
                                          DropdownMenuItem<String>(
                                            child: Text('Tomorrow'),
                                            value: 'Tomorrow',
                                          ),
                                        ],
                                        value: _dateDropdownVal,
                                        onChanged: (String value) {
                                          setModalState(() {
                                            _timeDropdownVal = '';
                                            _dateDropdownVal = value;
                                          });
                                        },
                                      ),
                                      SizedBox(height: 0),
                                      DropdownButton<String>(
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
                                              i <
                                                  timeSlot(_dateDropdownVal)
                                                      .length;
                                              i++)
                                            DropdownMenuItem<String>(
                                              child: Text(timeSlot(
                                                  _dateDropdownVal)[i]),
                                              value:
                                                  timeSlot(_dateDropdownVal)[i],
                                            ),
                                        ],
                                        value: _timeDropdownVal,
                                        onChanged: (String value) {
                                          setModalState(() {
                                            _timeDropdownVal = value;
                                          });
                                        },
                                      ),
                                      SizedBox(height: 5),
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
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      16, 8, 0, 0),
                                              child: Container(
                                                alignment: Alignment.bottomLeft,
                                                child: Text(
                                                  'Payment Options',
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ),
                                            new Container(
                                              child: new Wrap(
                                                children: <Widget>[
                                                  GestureDetector(
                                                    onTap: () {
                                                      // Navigator.pop(context);
                                                      setState(() {
                                                        isPress1 = "true";
                                                        isPress2 = "false";
                                                        _paymentMode =
                                                            'Cash On Delivery';
                                                      });
                                                    },
                                                     child: Theme(
                                                       data: ThemeData(
                                                         highlightColor: isPress1 ==
                                                             "true"
                                                             ? Colors.grey
                                                             : Colors
                                                             .transparent,
                                                       ),
                                                      child: new ListTile(
                                                        leading: Icon(
                                                          MdiIcons.cash,
                                                          color:
                                                              Theme.of(context)
                                                                  .accentColor,
                                                        ),
                                                        title: new Text(
                                                          'Cash On Delivery',
                                                          style: TextStyle(
                                                              fontSize: 14.0,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        trailing: Icon(
                                                          Icons.arrow_right,
                                                          color:
                                                              Theme.of(context)
                                                                  .accentColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(8, 0, 8, 0),
                                                    child: Divider(
                                                      height: 5,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      // Navigator.pop(context);
                                                      setState(() {
                                                        isPress2 = "true";
                                                        isPress1 = "false";
                                                        _paymentMode =
                                                            'Cash On Delivery';
                                                      });
                                                    },
                                                    child: Theme(
                                                      data: ThemeData(
                                                        highlightColor: isPress2 ==
                                                            "true"
                                                            ? Colors.grey
                                                            : Colors
                                                            .transparent,
                                                      ),
                                                      child: new ListTile(
                                                        leading: Icon(
                                                          Icons.credit_card,
                                                          color:
                                                              Theme.of(context)
                                                                  .accentColor,
                                                        ),
                                                        title: new Text(
                                                          'Online Payment',
                                                          style: TextStyle(
                                                              fontSize: 14.0,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        trailing: Icon(
                                                          Icons.arrow_right,
                                                          color:
                                                              Theme.of(context)
                                                                  .accentColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ]),
                                        ),
                                      ),

                                      /*  TextFormField(
                                          controller: nameController,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Please enter customer name';
                                            }
                                            return null;
                                          },
                                          onSaved: (String value) {
                                            nameController.text = value;
                                          },
                                          decoration: new InputDecoration(labelText: "Customer Name",
                                            contentPadding: EdgeInsets.only(left: 8.0),
                                            fillColor: Colors.white,
                                            border: new OutlineInputBorder(borderSide:new BorderSide(),),
                                          ),
                                        ),*/
                                      SizedBox(height: 8),
                                      TextFormField(
                                        controller: instructionController,
                                        onSaved: (String value) {
                                          instructionController.text = value;
                                        },
                                        decoration: new InputDecoration(
                                          labelText: "Additional Instruction",
                                          contentPadding:
                                              EdgeInsets.only(left: 8.0),
                                          fillColor: Colors.white,
                                          border: new OutlineInputBorder(
                                            borderSide: new BorderSide(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      SizedBox(
                                        width: double.infinity,
                                        child: RaisedButton(
                                          onPressed: () {
                                            if (_formKey.currentState
                                                .validate()) {
                                              _formKey.currentState.save();
                                              if (_timeDropdownVal != '') {
                                                setModalState(() {
                                                  _placeOrderBtn =
                                                      'Please wait...';
                                                });
                                                //  Navigator.pushReplacementNamed(context, '/order-complete');
                                                if (_paymentMode ==
                                                    'Cash On Delivery') {
                                                  _placeOrder(
                                                      _cartProvider,
                                                      setModalState,
                                                      _dateDropdownVal,
                                                      _timeDropdownVal /*,nameController.text*/,
                                                      instructionController
                                                          .text);
                                                } else {
                                                  var merchantTxnId =
                                                      ShortUuid.shortv4();
                                                  print("how" + merchantTxnId);
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          MyWebView(
                                                        title: "Make Payment",
                                                        url: "https://qrestro.com/sodhis/proceed-to-pay?restaurant_id=" +
                                                            "35" +
                                                            "&user_id=" +
                                                            _userId.toString() +
                                                            "&merchantTxnId=" +
                                                            merchantTxnId +
                                                            "&channel=ANDROID&instruction=" +
                                                            instructionController
                                                                .text,
                                                        userId: _userId,
                                                        merchantTxnId:
                                                            merchantTxnId,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                          textColor: Colors.white,
                                          color: Colors.grey[700],
                                          child: new Text(
                                            _placeOrderBtn,
                                          ),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          );
                        });
                      },
                    );
                  }
                },
                child: Container(
                  height: 225,
                  margin: const EdgeInsets.only(top: 30, left: 30, right: 30),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.grey[400],
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                        child: Image(
                          width: 200,
                          image: AssetImage('assets/images/takeaway.jpg'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          "Pick Up",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
