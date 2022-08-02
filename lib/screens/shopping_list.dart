import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ShoppingListPage extends StatefulWidget {
  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  var _userId;
  Future _myShoppingList;

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

  Widget _shelfContainer(_shelf) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.all(
          Radius.circular(6),
        ),
      ),
      child: Text(
        "Shelf No: $_shelf",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _shoppingListBuilder() {
    return FutureBuilder(
      future: _myShoppingList,
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
                    trailing: snapshot.data[index]['shelf_number'] != null
                        ? _shelfContainer(snapshot.data[index]['shelf_number'])
                        : null,
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop From My List'),
      ),
      body: RefreshIndicator(
        child: Center(
          child: _shoppingListBuilder(),
        ),
        onRefresh: refreshList,
      ),
    );
  }
}
