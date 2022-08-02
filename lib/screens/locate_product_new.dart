import 'package:flutter/material.dart';
import 'package:sodhis_app/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:barcode_scan/barcode_scan.dart';


class LocateProductNewPage extends StatefulWidget {
  @override
  _LocateProductNewPageState createState() => _LocateProductNewPageState();
}

class _LocateProductNewPageState extends State<LocateProductNewPage> {
  var _userId;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
    });
  }

/*
  Future scanLocateProduct() async {
    var options = ScanOptions(
      strings: {
        "cancel": 'Cancel',
        "flash_on": 'Flash on',
        "flash_off": 'Flash off',
      },
      useCamera: -1,
      android: AndroidOptions(
        useAutoFocus: true,
      ),
    );

    var result = await BarcodeScanner.scan(options: options);
    if (result.type.toString() == 'Barcode') {
      Navigator.pushNamed(
        context,
        '/locate-product',
        arguments: <String, String>{
          'barcode': result.rawContent.toString(),
        },
      );
    }
  }
*/

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Locate Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.crop_free),
            onPressed: () {
              //scanLocateProduct();
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: ProductSearch(_userId));
            },
          )
        ],
      ),
      body: Center(
        
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
                    '/locate-product',
                    arguments: <String, String>{
                      'barcode': snapshot.data['Response'][index]['barcode'].toString(),
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
