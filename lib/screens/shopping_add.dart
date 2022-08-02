import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'package:flutter/services.dart';
import 'package:sodhis_app/components/general.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/services/shopping_list.dart';
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stepper_counter_swipe/stepper_counter_swipe.dart';
import 'package:provider/provider.dart';
import 'package:textfield_search/textfield_search.dart';
import 'dart:async';

class AddShoppingListPage extends StatefulWidget {
  @override
  _AddShoppingListPageState createState() => _AddShoppingListPageState();
}

class _AddShoppingListPageState extends State<AddShoppingListPage> {
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _userId;
  var _name;
  var _quantity = 1;
  String assetName = 'assets/images/add_shoppinglist.svg';
  bool _loading = false;

  Future _productList() async {
    String query = nameController.text;
    List _list = new List();
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/product-search"),
      body: {
        "user_id": _userId,
        "query": query,
      },
      headers: {
        "Accept": "application/json",
        "authorization": basicAuth,
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['Response'];
      for (var i = 0; i < result.length; i++) {
        _list.add(result[i]['product_name']);
      }
      return _list;
    } else {
      throw Exception('Something went wrong');
    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
    });
  }

  Widget svg() {
    return SvgPicture.asset(assetName, semanticsLabel: 'Acme Logo');
  }

  Widget _nameTextbox() {
    return Container(
      margin: new EdgeInsets.only(left: 30, right: 30, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFieldSearch(
            label: 'Item Name',
            controller: nameController,
            future: () {
              return _productList();
            }
            // cursorColor: Color(0xFF372D61),
            // textCapitalization: TextCapitalization.sentences,
            // validator: (value) {
            //   if (value.isEmpty) {
            //     return 'Please enter item name';
            //   }
            //   return null;
            // },
            // onSaved: (String value) {
            //   _name = value;
            // },
            // decoration: InputDecoration(
            //   hintText: 'Item Name',
            // ),
            ),
      ),
    );
  }

  Widget _quantityTextbox() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top:20, left: 30),
          child: Text("Quantity: "),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (_quantity >= 2) {
                _quantity--;
              }
            });
          },
          child: Container(
            margin: new EdgeInsets.only(left: 30, top: 20),
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
        Padding(
          padding: const EdgeInsets.only(top:20, left: 8, right: 8),
          child: Text(_quantity.toString()),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (_quantity >= 0) {
                _quantity++;
              }
            });
          },
          child: Container(
            margin: new EdgeInsets.only(top: 20),
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
    );
  }

  // Widget _quantityTextbox() {
  //   return Container(
  //     margin: new EdgeInsets.only(left: 30, right: 30, bottom: 10),
  //     child: Align(
  //       alignment: Alignment.centerLeft,
  //       child: TextFormField(
  //         controller: quantityController,
  //         keyboardType: TextInputType.number,
  //         cursorColor: Color(0xFF372D61),
  //         validator: (value) {
  //           if (value.isEmpty) {
  //             return 'Please enter item quantity';
  //           }
  //           return null;
  //         },
  //         onSaved: (String value) {
  //           _quantity = value;
  //         },
  //         decoration: InputDecoration(
  //           hintText: 'Quantity',
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _submitButton() {
    final _shoppingListProvider =
        Provider.of<ShoppingListProvider>(context, listen: false);
    return Container(
      margin: new EdgeInsets.only(top: 20, left: 30, right: 30),
      child: Align(
        alignment: Alignment.center,
        child: ButtonTheme(
          minWidth: MediaQuery.of(context).size.width,
          child: RaisedButton(
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                // if (_quantity < 1) {
                //   Fluttertoast.showToast(msg: 'Minimum quantity should be 1');
                // }
                if (nameController.text == '') {
                  Fluttertoast.showToast(msg: 'Item name should not be empty');
                } else {
                  _formKey.currentState.save();
                  setState(() {
                    _loading = true;
                  });
                  var response = await http.post(
                      new Uri.https(BASE_URL, API_PATH + "/add-shoppinglist"),
                      body: {
                        "user_id": _userId.toString(),
                        "product_name": nameController.text,
                        "quantity": _quantity.toString(),
                      },
                      headers: {
                        "Accept": "application/json",
                        "authorization": basicAuth
                      });
                  if (response.statusCode == 200) {
                    setState(() {
                      _loading = false;
                    });
                    nameController.clear();
                    quantityController.clear();
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    currentFocus.unfocus();
                    var data = json.decode(response.body);
                    var errorCode = data['ErrorCode'];
                    var errorMessage = data['ErrorMessage'];
                    if (errorCode == 0) {
                      Fluttertoast.showToast(msg: 'success');
                      _shoppingListProvider.showShoppingList(_userId);
                    } else {
                      showAlertDialog(
                          context, ALERT_DIALOG_TITLE, errorMessage);
                    }
                  }
                }
              }
            },
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            shape: StadiumBorder(),
            child: Text(
              "SUBMIT",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Item"),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        child: SafeArea(
          child: Container(
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Center(
                    child: svg(),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.only(
                          top: 10,
                          bottom: 30,
                        ),
                        children: <Widget>[
                          _nameTextbox(),
                          _quantityTextbox(),
                          SizedBox(height:10),
                          _submitButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
