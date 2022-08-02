import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:sodhis_app/services/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:badges/badges.dart';
import 'package:provider/provider.dart';
import 'package:sodhis_app/services/cart_badge.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductsPage extends StatefulWidget {
  final Object argument;
  const ProductsPage({Key key, this.argument}) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {

  String restaurant_id;

  var _userId;
  var _title;
  var _id;
  var _type;
  Future _productList;
  Future itemFinderList;
  var errorCode;

  bool isSearching = false;
  TextEditingController controller;

  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    _id = data['id'];
    _title = data['title'];
    _type = data['type'];

    print(_id.toString());

    Preference().getPreferences().then((prefs) {
      setState(() {
        _userId = prefs.getInt('user_id').toString();
        if(_type == null) {
          itemFinderList = _itemFinderData();
        }
        else if(_type == 'category'){
          _productList = _myRestaurantData();
        }
        else{
          _productList = _myGroceryData();
        }

      });
    });
  }

  showConfirmDialog(cancel, done, title, content, userid, discount, mrp, qty, id) async{
    final _cart = Provider.of<CartBadge>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Widget cancelButton = FlatButton(
      child: Text(cancel),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget doneButton = FlatButton(
      child: Text(done),
      onPressed: () async{
        var response = await http
            .post(
          new Uri.https(BASE_URL,
              API_PATH + "/cart-add"),
          headers: {"Accept": "application/json", 'Content-Type': 'application/json'},
          body: jsonEncode({
            "user_id": userid,
            "offer_price": discount,
            "rate": mrp,
            "restaurant_id": "35",
            "quantity": qty,
            "product_id": id,
            "addon_items" : []
          }),
        );
        if (response.statusCode ==
            200) {
          _cart.showCartBadge(_userId);
          var data = json.decode(response.body);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt('cart_count', int.parse(data['Response']['count'].toString()));
        }
        Navigator.of(context).pop();
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  Future _itemFinderData() async{
   var response = await http.post(
     new Uri.https(BASE_URL, API_PATH + "/itemfinder"),
     body: {
       "user_id": _userId,
       "product_id": _id,

     },
     headers: {
       "Accept": "application/json",
       "authorization": basicAuth,
     },
   );
   print( {
     "user_id": _userId,
     "product_id": _id,

   });
   if (response.statusCode == 200) {
     var data = json.decode(response.body);
     var result = data['ItemResponse'];
     return result;
   } else {
     throw Exception('Something went wrong');
   }
 }


  Future _myGroceryData() async {
    setState(() {
      restaurant_id = "35";
    });
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/products"),
      body: {
        "user_id" : _userId,
        "restaurant_id" : "35",
        "category_id": _id,
        "type" : "",
      },
      headers: {
        "Accept": "application/json",
        "authorization": basicAuth,
      },
    );
    print({
      "user_id": _userId,
      "category_id": _id,
      "type": _type,
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['Response'];
      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }


  Future _myRestaurantData() async {
    setState(() {
      restaurant_id = "41";
    });
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/products"),
      body: {
        "user_id": _userId,
        "restaurant_id": "41",
        "category_id": _id,
        "type": "category"
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


  Widget _emptyCategories() {
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
              child: Image.asset("assets/images/empty.png"),
            ),
            Text(
              "Sorry No Products Available!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _profileBuilder() {
    final _cart = Provider.of<CartBadge>(context, listen: false);
    return FutureBuilder(
      future: _type!=null ?_productList : itemFinderList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if(snapshot.data.length!=0) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 16, right: 16, top: 16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/product-details',
                                arguments: <String, String>{
                                  'product_id':
                                  snapshot.data[index]['id'].toString(),
                                  'title': snapshot.data[index]['product_name'],
                                },
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                  right: 8, left: 8, top: 8, bottom: 8),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                                //color: Colors.blue.shade200,
                                image: DecorationImage(
                                  image: snapshot
                                      .data[index]['product_image'] != null
                                      ? CachedNetworkImageProvider(
                                      snapshot.data[index]['product_image'],)
                                      : AssetImage(
                                      'assets/images/no_image.png'),
                                    fit: BoxFit.cover
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/product-details',
                                        arguments: <String, String>{
                                          'product_id': snapshot
                                              .data[index]['id']
                                              .toString(),
                                          'title': snapshot.data[index]
                                          ['product_name'],
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          right: 8, top: 0),
                                      child: Text(
                                        snapshot.data[index]['product_name'],
                                        maxLines: 2,
                                        softWrap: true,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            _title,
                                            style: TextStyle(
                                                color: Colors.grey),
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: <Widget>[
                                              GestureDetector(
                                                onTap: () async {
                                                  int temp = int.parse(snapshot.data[index]['quantity'].toString());
                                                  if(temp > 0){
                                                    temp = temp-1;
                                                    setState(() {
                                                      snapshot.data[index]['quantity'] = temp.toString();
                                                    });
                                                    var response = await http.post(
                                                      new Uri.https(BASE_URL, API_PATH + "/cart-add"),
                                                      body: {
                                                        "user_id": _userId.toString(),
                                                        "offer_price":snapshot.data[index]['discount'].toString(),
                                                        "product_id": snapshot.data[index]['id'].toString(),
                                                        "restaurant_id": "35",
                                                        "quantity": snapshot.data[index]['quantity'].toString(),
                                                        "rate": snapshot.data[index]['mrp'].toString(),
                                                        "amount": (double.parse(snapshot.data[index]['mrp'].toString()) * double.parse(snapshot.data[index]['quantity'].toString())).toString(),
                                                      },
                                                      headers: {
                                                        "Accept":
                                                        "application/json",
                                                        "authorization": basicAuth
                                                      },
                                                    );
                                                    if (response.statusCode ==
                                                        200) {
                                                      _cart.showCartBadge(_userId);
                                                      var data = json.decode(response.body);
                                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                                      prefs.setInt('cart_count', int.parse(data['Response']['count'].toString()));
                                                      print(prefs.getInt('cart_count').toString());
                                                    }
                                                  }

                                                },
                                                child: Container(
                                                  height: 25,
                                                  width: 25,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.grey,
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        25 / 2),
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
                                              Text(snapshot.data[index]
                                              ['quantity']
                                                  .toString()),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                                   if(prefs.getInt('cart_count') == 0) {
                                                     prefs.setString('type', "grocery");
                                                     int temp = int.parse(snapshot.data[index]['quantity'].toString());
                                                     temp = temp+1;
                                                     setState(() {
                                                       snapshot.data[index]['quantity'] = temp.toString();
                                                     });
                                                     var response = await http
                                                         .post(
                                                       new Uri.https(BASE_URL,
                                                           API_PATH + "/cart-add"),
                                                       headers: {"Accept": "application/json", 'Content-Type': 'application/json'},
                                                       body: jsonEncode({
                                                         "user_id": _userId.toString(),
                                                         "offer_price": snapshot.data[index]['discount'].toString(),
                                                         "rate": snapshot.data[index]['mrp'].toString(),
                                                         "restaurant_id": "35",
                                                         "quantity": snapshot.data[index]['quantity'].toString(),
                                                         "product_id": snapshot.data[index]['id'].toString(),
                                                         "addon_items" : []
                                                       }),
                                                     );
                                                     if (response.statusCode == 200) {
                                                       _cart.showCartBadge(_userId);
                                                       var data = json.decode(response.body);
                                                       SharedPreferences prefs = await SharedPreferences.getInstance();
                                                       prefs.setInt('cart_count', int.parse(data['Response']['count'].toString()));
                                                     }
                                                   }
                                                   else{
                                                     if (prefs.getString('type') == "grocery") {
                                                       prefs.setString('type', "grocery");
                                                       int temp = int.parse(snapshot.data[index]['quantity'].toString());
                                                       temp = temp+1;
                                                       setState(() {
                                                         snapshot.data[index]['quantity'] = temp.toString();
                                                       });
                                                       var response = await http
                                                           .post(
                                                         new Uri.https(BASE_URL,
                                                             API_PATH + "/cart-add"),
                                                         headers: {"Accept": "application/json", 'Content-Type': 'application/json'},
                                                         body: jsonEncode({
                                                           "user_id": _userId.toString(),
                                                           "offer_price": snapshot.data[index]['discount'].toString(),
                                                           "rate": snapshot.data[index]['mrp'].toString(),
                                                           "restaurant_id": "35",
                                                           "quantity": snapshot.data[index]['quantity'].toString(),
                                                           "product_id": snapshot.data[index]['id'].toString(),
                                                           "addon_items" : []
                                                         }),
                                                       );
                                                       if (response.statusCode ==
                                                           200) {
                                                         _cart.showCartBadge(_userId);
                                                         var data = json.decode(response.body);
                                                         SharedPreferences prefs = await SharedPreferences.getInstance();
                                                         prefs.setInt('cart_count', int.parse(data['Response']['count'].toString()));
                                                       }

                                                     } else {
                                                       prefs.setString('type', "grocery");
                                                       showConfirmDialog('Cancel', 'Ok', 'Remove Item',
                                                           'Please remove or purchase restaurant items from cart after that you can add grocery item',
                                                           _userId.toString(),
                                                           snapshot.data[index]['discount'].toString(),
                                                           snapshot.data[index]['mrp'].toString(),
                                                           snapshot.data[index]['quantity'].toString(),
                                                           snapshot.data[index]['id'].toString());
                                                     }
                                                   }
                                                },
                                                child: Container(
                                                  height: 25,
                                                  width: 25,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        25 / 2),
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
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 7,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "\u20B9 " +
                                            snapshot.data[index]['discount']
                                                .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                          "MRP: " + snapshot.data[index]['mrp'],
                                          style: TextStyle(
                                                decoration: TextDecoration
                                                    .lineThrough,
                                              color: Colors.grey[700])),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        color: Theme
                                            .of(context)
                                            .accentColor,
                                        padding: const EdgeInsets.all(4.0),
                                        child: Center(
                                          child: Text(
                                            snapshot
                                                .data[index]['discount_percentage']
                                                .toString() + "%" + " OFF",
                                            style: TextStyle(fontSize: 11,
                                                color: Colors.white),
                                            overflow: TextOverflow.clip,
                                            softWrap: false,
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),
                                  //SizedBox(height: 4),
                                  /*   Container(
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          "\u20B9 " +
                                              snapshot.data[index]['mrp'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20),
                                      ],
                                    ),
                                  ),*/
                                ],
                              ),
                            ),
                            flex: 100,
                          )
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }
          else{
            return _emptyCategories();
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget build(BuildContext context) {
    final _counter = Provider.of<CartBadge>(context);
    return Scaffold(
      appBar: AppBar(
        title: _title!=null?Text(_title):Text(""),
        /*title: !isSearching  && _title != null ? Text(_title) : Container(
           height: 50,
           width: MediaQuery.of(context).size.width,
           child: TextField(
             controller: controller,
             autofocus: true,
             decoration: InputDecoration(
                 filled: true,
                 fillColor: Colors.white,
                 contentPadding: EdgeInsets.all(14),
                 // border: OutlineInputBorder(),
                 isDense: true,
                 isCollapsed: true,
                 hintText: 'SEARCH',
                 labelStyle: TextStyle(color: Colors.black),
                 suffixIcon: IconButton(
                   icon: Icon(Icons.clear),
                   onPressed: (){
                     FocusScope.of(context).unfocus();
                     setState(() {
                       //controller.text = "";
                       //list.clear();
                       //list.addAll(duplicateItems);
                       isSearching = !isSearching;
                     });
                   },
                 )
             ),
             onChanged: (value){

             },
           ),
        ),*/
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: ProductSearch(_userId,_id,_type),query:'');
            },
            /*icon: isSearching
                  ? SizedBox(
                    width: MediaQuery.of(context).size.width,
                  )
                  : IconButton(
                  onPressed: () {
                    setState(() {
                      isSearching = !isSearching;
                    });
                  },
                  icon: Icon(Icons.search, color: Colors.white,))*/
          ),
          IconButton(
            icon: Badge(
              animationDuration: Duration(milliseconds: 0),
              animationType: BadgeAnimationType.fade,
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
      ),
      body: Center(
        child: _profileBuilder(),
      ),
    );
  }
}

class ProductSearch extends SearchDelegate<String> {
  var _userId;
  var _categoryId;
  var _type;
  ProductSearch(this._userId,this._categoryId,this._type);

  final recentproducts = [];

  Future _productList(query) async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/product-search-category"),
      body: {
        "user_id": _userId,
        "category_id": _categoryId,
        "type": _type,
        "query": query,
      },

      headers: {
        "Accept": "application/json",
        "authorization": basicAuth,
      },
    );
    print({
      "user_id": _userId,
      "category_id": _categoryId,
      "type": _type,
      "query": query,
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print("data here "+data.toString());
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
          query = '';
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
  Widget _networkImage(url) {
    return Image(
      image: CachedNetworkImageProvider(url),
    );
  }
  @override
  Widget buildResults(BuildContext context) {
    if (query.length<3) {
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
                  Navigator.of(context).pop();
                  Navigator.pushNamed(
                    context,
                    '/product-details',
                    arguments: <String, String>{
                      'product_id': snapshot.data['Response'][index]['id'].toString(),
                      'title': snapshot.data['Response'][index]['product_name'],
                    },
                  );
                },
                leading: Container(padding: const EdgeInsets.only(top: 10, bottom: 10),child: _networkImage(snapshot.data['Response'][index]['product_image'])),
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

  @override
  Widget buildSuggestions(BuildContext context) {

    if (query.length<3) {
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
                  Navigator.of(context).pop();
                  Navigator.pushNamed(
                    context,
                    '/product-details',
                    arguments: <String, String>{
                      'product_id': snapshot.data['Response'][index]['id'].toString(),
                      'title': snapshot.data['Response'][index]['product_name'],
                    },
                  );
                },
                leading:Container( padding: const EdgeInsets.only(top: 10, bottom: 10),child: _networkImage(snapshot.data['Response'][index]['product_image'])),
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
