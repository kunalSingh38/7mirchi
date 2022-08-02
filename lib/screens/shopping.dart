import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stepper_counter_swipe/stepper_counter_swipe.dart';
import 'package:provider/provider.dart';
import 'package:sodhis_app/services/shopping_list.dart';


class ShoppingPage extends StatefulWidget {
  @override
  _ShoppingPageState createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  var _userId;
  Future _myShoppingList;
  bool start = true;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      _myShoppingList = _shoppingLists();
    });
  }

  void deleteItem(listId) async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/delete-shoppinglist"),
      body: {
        "user_id": _userId.toString(),
        "list_id": listId.toString(),
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
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Item deleted successfully"),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: errorMessage);
      }
      setState(() {
        _myShoppingList = _shoppingLists();
      });
    } else {
      throw Exception('Something went wrong');
    }
  }

  Future<Null> refreshList() async {
    await Future.delayed(
      Duration(milliseconds: 500),
    );
    setState(() {
      _myShoppingList = _shoppingLists();
    });
    //setState(() {});
    return null;
  }

  Future _shoppingLists() async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/shopping-list"),
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
      var result = data['Response'];
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

  Widget _shoppingListBuilder() {
    final _shoppingListProvider = Provider.of<ShoppingListProvider>(context);
    return FutureBuilder(
      future: _shoppingListProvider.startCheck() ? _myShoppingList : _shoppingListProvider.getShoppingList(_userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ListView.separated(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  ListTile(
                    title: Text(snapshot.data[index]['product_name']),
                    subtitle: Text('Quantity: ' +
                        snapshot.data[index]['quantity'].toString()),
                    leading: snapshot.data[index]['product_image'] != null
                        ? _networkImage(snapshot.data[index]['product_image'])
                        : null,
                    trailing: InkWell(
                      onTap: () {
                        deleteItem(snapshot.data[index]['id']);
                      },
                      child: Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              );
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget build(BuildContext context) {
    final _shoppingListProvider = Provider.of<ShoppingListProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping List'),
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.search),
        //     onPressed: () {
        //       showSearch(context: context, delegate: ProductSearch(_userId,_shoppingListProvider));
        //     },
        //   )
        // ],
      ),
      body: RefreshIndicator(
        child: Center(
          child: _shoppingListBuilder(),
        ),
        onRefresh: refreshList,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "fab-addlist",
        onPressed: () {
          Navigator.pushNamed(context, '/add-shoppinglist');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ProductSearch extends SearchDelegate<String> {
  var _userId;
  var _shoppingListProvider;
  ProductSearch(this._userId,this._shoppingListProvider);

  var _id;
  var _productName;
  var _productImage;
  var _productDesc;
  var _brand;
  var _mrp;
  var _bestPrice;
  var _quantity;

  // final products = [
  //   "Tata Salt",
  //   "Amul Butter",
  //   "Pampers Diaper",
  //   "Fortune Oil",
  //   "Oreo Biscuit",
  //   "Tata tea Gold",
  //   "Pears Soap",
  //   "Dettol Sanitizer"
  // ];

  final recentproducts = [];

  Widget _networkImage(url) {
    return Image(
      image: CachedNetworkImageProvider(url),
    );
  }

  Widget _quantityTextbox() {
    return Container(
      margin: new EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 10),
      height: 100,
      child: StepperSwipe(
        initialValue: _quantity,
        speedTransitionLimitCount: 3, //Trigger count for fast counting
        onChanged: (int value) async {
          var response = await http.post(
            new Uri.https(BASE_URL, API_PATH + "/add-shoppinglist"),
            body: {
              "user_id": _userId.toString(),
              "product_id": _id.toString(),
              "quantity": value.toString(),
            },
            headers: {"Accept": "application/json", "authorization": basicAuth},
          );
          if (response.statusCode == 200) {
            var data = json.decode(response.body);
            var errorCode = data['ErrorCode'];
            if (errorCode == 0) {
              _shoppingListProvider.showShoppingList(_userId);
            }
          }
        },
        firstIncrementDuration:
            Duration(milliseconds: 250), //Unit time before fast counting
        secondIncrementDuration:
            Duration(milliseconds: 100), //Unit time during fast counting
        direction: Axis.horizontal,
        dragButtonColor: Color(0xFF6C61F6),
        withNaturalNumbers: true,
        iconsColor: null,
      ),
    );
  }

  Widget _productContainer() {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.only(top: 30),
              child: Center(
                // child: Image.network("$_productImage"),
                child: _networkImage("$_productImage"),
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
                      child: Text(
                        "$_productName",
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
                  // Container(
                  //   padding:
                  //       const EdgeInsets.only(top: 10, left: 30, right: 30),
                  //   child: Align(
                  //     alignment: Alignment.centerLeft,
                  //     child: Text(
                  //       "$_productDesc",
                  //       //style: TextStyle(fontSize: 14.0),
                  //     ),
                  //   ),
                  // ),
                  _quantityTextbox(),
                  Container(
                    margin:
                        new EdgeInsets.only(left: 30, right: 30, bottom: 10),
                    child: Center(
                      child: Text(
                        "Swipe to increment or decrement quantity",
                        style: TextStyle(fontStyle: FontStyle.italic),
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

  Future _productList(query) async {
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
      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Container(
        //child: Text(_productName),
        child: _productContainer(),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // final suggestionlist = query.isEmpty
    //     ? recentproducts
    //     : products
    //         .where((p) => p.toLowerCase().contains(query.toLowerCase()))
    //         .toList();
    // return ListView.builder(
    //   itemBuilder: (context, index) => ListTile(
    //     onTap: (){
    //       showResults(context);
    //     },
    //     leading: Icon(Icons.fastfood),
    //     title: Text(
    //       suggestionlist[index],
    //       style:
    //           TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
    //     ),
    //   ),
    //   itemCount: suggestionlist.length,
    // );

    // final suggestionlist = query.isEmpty
    //     ? recentproducts
    //     : products
    //         .where((p) => p.toLowerCase().contains(query.toLowerCase()))
    //         .toList();

    if (query.length < 3) {
      return ListView.builder(
        itemBuilder: (context, index) => ListTile(
          onTap: () {
            showResults(context);
          },
          leading: Icon(Icons.fastfood),
          title: Text(
            recentproducts[index],
            style:
                TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
        ),
        itemCount: recentproducts.length,
      );
    } else {
      return FutureBuilder(
        future: _productList(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemBuilder: (context, index) => ListTile(
                onTap: () {
                  _id = snapshot.data['Response'][index]['id'];
                  _productName =
                      snapshot.data['Response'][index]['product_name'];
                  _productImage =
                      snapshot.data['Response'][index]['product_image'];
                  _productDesc =
                      snapshot.data['Response'][index]['description'];
                  _brand = snapshot.data['Response'][index]['brand'];
                  _mrp = snapshot.data['Response'][index]['mrp'];
                  _bestPrice = snapshot.data['Response'][index]['offer_price'];
                  _quantity = snapshot.data['Response'][index]['quantity'];
                  showResults(context);
                },
                leading: Icon(Icons.fastfood),
                title: Text(
                  snapshot.data['ErrorCode'] == 0
                      ? snapshot.data['Response'][index]['product_name']
                      : recentproducts,
                  style: TextStyle(
                      color: Colors.grey[600], fontWeight: FontWeight.bold),
                ),
              ),
              itemCount: snapshot.data['ErrorCode'] == 0
                  ? snapshot.data['Response'].length
                  : recentproducts.length,
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    }
  }
}
