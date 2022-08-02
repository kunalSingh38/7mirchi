import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sodhis_app/Animation/FadeAnimation.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:badges/badges.dart';
import 'package:provider/provider.dart';
import 'package:sodhis_app/services/cart_badge.dart';

class Shop2Page extends StatefulWidget {
  @override
  _Shop2PageState createState() => _Shop2PageState();
}

class _Shop2PageState extends State<Shop2Page> {
  var _userId;
  var _storeId;
  Future<dynamic> _myproductCategories;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void dispose() {
    super.dispose();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      _storeId = prefs.getInt('store_id').toString();
      _myproductCategories = _productCategories();
    });
  }

  Future _productCategories() async {
    var response = await http.post(
        new Uri.https(BASE_URL, API_PATH + "/product-categories"),
        body: {
          "user_id": _userId,
          "store_id": _storeId,
        },
        headers: {
          "Accept": "application/json",
          "authorization": basicAuth
        });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['Response'];
      return result;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Widget _productCategoriesBuilder() {
    return FutureBuilder(
      future: _myproductCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FadeAnimation(1, 
                        GestureDetector(
                          onTap: () {
                            print(snapshot.data[index]['id']);
                            Navigator.pushNamed(
                              context,
                              '/products',
                              arguments: <String, String>{
                                'id': snapshot.data[index]['id'].toString(),
                                'title': snapshot.data[index]['name'],
                                'type': 'category',
                              },
                            );
                          },
                          child: Text(snapshot.data[index]['name'],
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800], fontSize: 18, decoration: TextDecoration.underline),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      FadeAnimation(1.4, Container(
                        height: 140,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            for (var i in snapshot.data[index]['subcategories'])
                            makeItem(id: i['id'].toString(), image: i['image'], title: i['name']),
                          ],
                        ),
                      )),
                      SizedBox(height: 20,),
                    ],
                  ),
              );
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget build(BuildContext context) {
    final _counter = Provider.of<CartBadge>(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Shop Categories'),
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
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              //height: 300,
              margin: EdgeInsets.only(bottom:30),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.jpg'),
                  fit: BoxFit.cover
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(.8),
                      Colors.black.withOpacity(.2),
                    ]
                  )
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FadeAnimation(1, Text("What would you like to buy?", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),)),
                    SizedBox(height: 30,),
                    FadeAnimation(1.3, Container(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      margin: EdgeInsets.symmetric(horizontal: 40),
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white,
                      ),
                      child: TextField(
                        readOnly: true,
                        onTap: (){
                          showSearch(context: context, delegate: ProductSearch(_userId));
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: Colors.grey,),
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                          hintText: "Search for grocery, fruits..."
                        ),
                      ),
                    )),
                    SizedBox(height: 30,)
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: _productCategoriesBuilder(),
          ),
        ],
      ),
    );
  }

  Widget makeItem({id, image, title}) {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/products',
            arguments: <String, String>{
              'id': id,
              'title': title,
              'type': 'subcategory',
            },
          );
        },
        child: Container(
          margin: EdgeInsets.only(right: 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              //image: CachedNetworkImageProvider(image),
              image: DecorationImage(
                image: CachedNetworkImageProvider(image),
                fit: BoxFit.cover,
              ),
          ),
              //image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover)),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(begin: Alignment.bottomRight, colors: [
                  Colors.black.withOpacity(.8),
                  Colors.black.withOpacity(.2),
                ])),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

}


class ProductSearch extends SearchDelegate<String> {
  var _userId;
  ProductSearch(this._userId);

  final recentproducts = [];

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
        child: Text(""),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
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
                  Navigator.pushNamed(
                    context,
                    '/product-details',
                    arguments: <String, String>{
                      'product_id': snapshot.data['Response'][index]['id'].toString(),
                      'title': snapshot.data['Response'][index]['product_name'],
                    },
                  );
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
