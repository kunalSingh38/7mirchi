import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:cached_network_image/cached_network_image.dart';

class ShelfOffersPage extends StatefulWidget {
  final Object argument;
  const ShelfOffersPage({Key key, this.argument}) : super(key: key);
  @override
  _ShelfOffersPageState createState() => _ShelfOffersPageState();
}

class _ShelfOffersPageState extends State<ShelfOffersPage> {
  var _userId;
  var _shelfId;
  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    _shelfId = data['shelf_id'];
    _getUser();
  }

  Widget _shelfOffers() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.network(
            "https://vinylbannersprinting.co.uk/wp-content/uploads/2016/04/sb25-RA-demo.png"),
      ),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.grey[400],
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
    );
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
    });
  }

  Future<Null> refreshList() async {
    await Future.delayed(
      Duration(milliseconds: 500),
    );
    setState(() {});
    return null;
  }

  Future _shoppingLists() async {
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/shelf-offers"),
      body: {
        "user_id": _userId,
        "shelf_id": _shelfId,
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

  Widget _shoppingListBuilder() {
    return FutureBuilder(
      future: _shoppingLists(),
      builder: (context, snapshot) {
        print(snapshot.data);
        if (snapshot.connectionState == ConnectionState.done) {
          return ListView.separated(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(snapshot.data[index]['offer_image']),
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.grey[400],
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              );
              // return Column(
              //   children: <Widget>[
              //     ListTile(
              //       title: Text(snapshot.data[index]['product_name']),
              //       subtitle: Text('Quantity: ' +
              //           snapshot.data[index]['quantity'].toString()),
              //       leading: Image(
              //         //image: NetworkImage(snapshot.data[index]['product_image']),
              //         image: CachedNetworkImageProvider(
              //             snapshot.data[index]['product_image']),
              //       ),
              //       //trailing: Icon(Icons.delete),
              //     ),
              //   ],
              // );
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shelf Offers'),
      ),
      body: RefreshIndicator(
        child: Center(
          child: _shoppingListBuilder(),
        ),
        onRefresh: refreshList,
      ),
      // body: Center(
      //   child: Column(
      //     children: <Widget>[
      //       _shelfOffers(),
      //     ],
      //   ),
      // ),
    );
  }
}
