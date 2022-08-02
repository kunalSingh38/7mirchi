import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:marquee_widget/marquee_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sodhis_app/components/ThemeColor.dart';
import 'package:sodhis_app/constants.dart';
import 'package:sodhis_app/screens/webview.dart';
import 'package:sodhis_app/utilities/basic_auth.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({Key key}) : super(key: key);

  @override
  _GroceryScreenState createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin{

  var _userId;
  var deliveryType = "";
  var errorCode;
  var product_error;
  String _name;
  String _shortName = '';
  String _mobile_number;
  String _email_address;
  String _address;
  Future _mydashboardBanner;
  Future<dynamic> _myproductCategories;
  Future<dynamic> _myStore;
  var _storeId;
  bool isToggle = false;
  AnimationController _animationController;
  String pickUp = "takeaway";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _getUser();
    //_getCurrentLocation();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      pickUp = "takeaway";
      prefs.setString('delivery_type', pickUp);
      print(pickUp);
      print(_userId);
      _name = prefs.getString('name');
      _shortName = _name[0];
      _storeId = prefs.getInt('store_id').toString();
      _mobile_number = prefs.getString('mobile_number');
      _email_address = prefs.getString('email_address');
      _address = prefs.getString('address');
      _mydashboardBanner = _dashboardBanners();
      //_myproductCategories = _productCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Column(
          children: <Widget>[
            SizedBox(
              height: 1,
            ),
            /*Center(
              child: AnimatedToggle(
                values: ['Take Away', 'Home Delivery'],
                textColor: lightMode.textColor,
                backgroundColor: lightMode.toggleBackgroundColor,
                buttonColor: lightMode.toggleButtonColor,
                borderColor: lightMode.borderColor,
                shadows: lightMode.shadow,
                onToggleCallback: (index) async {
                  isToggle = !isToggle;
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  if (isToggle) {
                    pickUp = "home_delivery";
                    prefs.setString('delivery_type', pickUp);
                    //  Navigator.of(context).pop();
                    Navigator.pushNamed(
                      context,
                      '/addnewaddress',
                    );
                  } else {
                    pickUp = "takeaway";
                    prefs.setString('delivery_type', pickUp);
                  }
                  print(pickUp);
                  setState(() {});
                },
              ),
            ),*/

            Expanded(
              child: ListView(
                  children: <Widget>[ Container(
                    color: Color(0xFFeeeeee),
                    alignment: Alignment.topCenter,
                    child: _dashboardBannersBuilder(),
                  ),
                  ]
              ),
            ),
          ],
        ),
        drawer: Drawer(
            child: ListView(children: <Widget>[
              Column(
                children: <Widget>[
                  new UserAccountsDrawerHeader(
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        "$_shortName".toUpperCase(),
                        style: TextStyle(fontSize: 40.0),
                      ),
                    ),
                    // onDetailsPressed: () {

                    // },
                    accountName: new Text("$_name".toUpperCase()),
                    accountEmail: new Text("$_email_address"),
                  ),
                  ListTile(
                      leading: new Icon(Icons.location_on),
                      title: Text(_address != null ? _address : ""),
                      trailing:
                      _gpsButton() /*GestureDetector(
                onTap:  _getCurrentLocation(),
                  child: new Icon(Icons.my_location,color: Colors.red,)),*/
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: new Icon(Icons.location_city),
                    title: Text('Add New Address'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(
                        context,
                        '/addnewaddress',
                      );
                    },
                  ),
                  ListTile(
                    leading: new Icon(Icons.store),
                    title: Text('About Us'),
                    onTap: _openWebview,
                  ),

                  ListTile(
                    leading: new Icon(Icons.person),
                    title: Text('My Profile'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(
                        context,
                        '/my-profile',
                      );
                    },
                  ),
                  ListTile(
                    leading: new Icon(Icons.card_giftcard),
                    title: Text('My Orders'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(
                        context,
                        '/my-orders',
                      );
                    },
                  ),
                  ListTile(
                    leading: new Icon(Icons.feedback),
                    title: Text('Feedback'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(
                        context,
                        '/feedback',
                      );
                    },
                  ),
                  //Divider(height: 1),
                  ListTile(
                    leading: new Icon(Icons.lock_open),
                    title: Text('Change PIN'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(
                        context,
                        '/change-pin',
                      );
                    },
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: new Icon(Icons.exit_to_app),
                    title: Text('Logout'),
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences
                          .getInstance();
                      //prefs.remove('logged_in');
                      prefs.clear();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),
            ])),);
  }

  void _openWebview() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) =>
            MyWebView(
              title: "About Us",
              url: "https://7mirchi.com/about",
            ),
      ),
    );
  }

  ThemeColor lightMode = ThemeColor(
    /* gradient: [
      const Color(0xDDFF0080),
      const Color(0xDDFF8C00),
    ],*/
    backgroundColor: const Color(0xFFFFFFFF),
    textColor: const Color(0xFF000000),
    toggleButtonColor: const Color(0xFFFFFFFF),
    toggleBackgroundColor: const Color(0xDDFF8C00),
    borderColor: const Color(0xDDFF8C00),
    shadow: const [
      BoxShadow(
        color: const Color(0xFFd8d7da),
        spreadRadius: 5,
        blurRadius: 10,
        offset: Offset(0, 5),
      ),
    ],
  );

  Widget _dashboardBannersBuilder() {
    final orientation = MediaQuery
        .of(context)
        .orientation;
    return FutureBuilder(
      future: _mydashboardBanner,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(children: <Widget>[
            Container(
              padding: EdgeInsets.all(5),
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0)),
              ),
              child: CarouselSlider.builder(
                  options: CarouselOptions(
                    height: 160,
                    initialPage: 1,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 3),
                    autoPlayAnimationDuration: Duration(milliseconds: 1000),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                  ),
                  itemCount: snapshot
                      .data['SliderResponse'][0]['slider_options'].length,
                  itemBuilder: (BuildContext context, int itemIndex) {
                    return GestureDetector(
                      onTap: () {
                        if (snapshot
                            .data['SliderResponse'][0]['slider_options'][itemIndex]['category_id'] !=
                            null) {
                          Navigator.pushNamed(
                            context,
                            '/products',
                            arguments: <String, String>{
                              'id': snapshot
                                  .data['SliderResponse'][0]['slider_options'][itemIndex]['category_id']
                                  .toString(),
                              'title': snapshot
                                  .data['SliderResponse'][0]['slider_options'][itemIndex]['category_name'],
                              'type': 'subcategory',
                            },
                          );
                        }
                      },
                      child: Container(
                          child: Image.network(
                              snapshot
                                  .data['SliderResponse'][0]['slider_options'][itemIndex]['soimage'],
                              fit: BoxFit.fill,
                              width: 1000.0)),
                    );
                  }),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              height: 30,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0)),
                  color: Color(0xFFff726f)),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  "Shop by Category",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            ListView.builder(
              primary: false,
              shrinkWrap: true,
              itemCount: snapshot.data['CategoryResponse'].length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      GestureDetector(
                        onTap: () {
                          print(
                              snapshot.data['CategoryResponse'][index]['id']);
                          Navigator.pushNamed(
                            context,
                            '/products',
                            arguments: <String, String>{
                              'id': snapshot.data['CategoryResponse'][index]
                              ['id']
                                  .toString(),
                              'title': snapshot.data['CategoryResponse']
                              [index]['name'],
                              'type': 'category',
                            },
                          );
                        },
                        child: Text(
                          snapshot.data['CategoryResponse'][index]['name'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontSize: 16,
                              decoration: TextDecoration.underline),
                        ),
                      ),

                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            for(var i in snapshot.data['CategoryResponse']
                            [index]['subcategories'])
                              makeItem(
                                  id: i['id'].toString(),
                                  image: i['image'],
                                  title: i['name']),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(
              height: 8,
            ),
            ListView.builder(
              primary: false,
              shrinkWrap: true,
              itemCount: snapshot.data['SliderResponse'].length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        snapshot.data['OfferResponse'][index]['bckimage'],
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: ListView(
                      shrinkWrap: true,
                      primary: false,
                      children: <Widget>[
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(
                                left: 0, right: 0, top: 10, bottom: 0),
                            padding: EdgeInsets.all(5),
                            alignment: Alignment(0.0, -1.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                snapshot.data['OfferResponse'][index]
                                ['title'],
                                style: TextStyle(
                                    fontFamily: 'AirbnbCerealBold',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          child: Builder(
                            builder: (context) {
                              if (snapshot
                                  .data['OfferResponse'][index]['oimg4'] ==
                                  null)
                                return Container(
                                    margin: EdgeInsets.only(left: 10,
                                        right: 10,
                                        top: 10,
                                        bottom: 10),
                                    child: GridView.count(
                                      crossAxisCount: 3,
                                      primary: false,
                                      shrinkWrap: true,
                                      crossAxisSpacing: 20.0,
                                      mainAxisSpacing: 20.0,
                                      children: <Widget>[
                                        snapshot
                                            .data['OfferResponse'][index]['oimg1'] !=
                                            null
                                            ?
                                        GestureDetector(
                                            onTap: () async {
                                              if (snapshot
                                                  .data['OfferResponse'][index]['oimg1']['offer_options'][0]['category_id'] !=
                                                  null) {
                                                _onTileClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg1']['offer_options'][0]['category_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]['oimg1']['offer_options'][0]['category_name']);
                                              }
                                              else if (snapshot
                                                  .data['OfferResponse'][index]['oimg1']['offer_options'][0]['category_id'] ==
                                                  null) {
                                                _onOffersClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg1']['offer_options'][0]['product_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]
                                                    ['title']);
                                                /* var res = await http.post(new Uri.https(BASE_URL,API_PATH + "/itemfinder"),
                                                  body: {
                                                    "user_id": _userId.toString(),
                                                    "product_id": snapshot.data['OfferResponse'][index]['oimg1']['offer_options'][0]['"product_id"']
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
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/products',
                                                      arguments: <String, String>{
                                                        'id': data['ErrorCode'] ,
                                                        'title': title,
                                                        'type': 'category',
                                                      },
                                                    );
                                                  }
                                                }
*/

                                              }
                                            },
                                            child: _networkImage(snapshot
                                                .data['OfferResponse'][index]['oimg1']['img_url']))
                                            : Container(),
                                        snapshot
                                            .data['OfferResponse'][index]['oimg2'] !=
                                            null
                                            ?
                                        GestureDetector(
                                            onTap: () {
                                              if (snapshot
                                                  .data['OfferResponse'][index]['oimg2']['offer_options'][0]['category_id'] !=
                                                  null) {
                                                _onTileClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg2']['offer_options'][0]['category_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]['oimg2']['offer_options'][0]['category_name']);
                                              }
                                              else if (snapshot
                                                  .data['OfferResponse'][index]['oimg2']['offer_options'][0]['category_id'] ==
                                                  null) {
                                                _onOffersClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg2']['offer_options'][0]['product_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]
                                                    ['title']);
                                              }
                                            },
                                            child: _networkImage(snapshot
                                                .data['OfferResponse'][index]['oimg2']['img_url']))
                                            : Container(),
                                        snapshot
                                            .data['OfferResponse'][index]['oimg3'] !=
                                            null
                                            ?
                                        GestureDetector(
                                            onTap: () {
                                              if (snapshot
                                                  .data['OfferResponse'][index]['oimg3']['offer_options'][0]['category_id'] !=
                                                  null) {
                                                _onTileClicked(
                                                    snapshot
                                                        .data['OfferResponse'][index]['oimg3']['offer_options'][0]['category_id']
                                                        .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]['oimg2']['offer_options'][0]['category_name']);
                                              }
                                              else if (snapshot
                                                  .data['OfferResponse'][index]['oimg3']['offer_options'][0]['category_id'] ==
                                                  null) {
                                                _onOffersClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg3']['offer_options'][0]['product_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]
                                                    ['title']);
                                              }
                                            },
                                            child: _networkImage(snapshot
                                                .data['OfferResponse'][index]['oimg3']['img_url']))
                                            : Container(),
                                      ],
                                    )
                                );
                              else if (snapshot
                                  .data['OfferResponse'][index]['oimg7'] ==
                                  null)
                                return Container(
                                    margin: EdgeInsets.only(left: 10,
                                        right: 10,
                                        top: 10,
                                        bottom: 10),
                                    child: GridView.count(
                                      crossAxisCount: 3,
                                      shrinkWrap: true,
                                      primary: false,
                                      crossAxisSpacing: 20.0,
                                      mainAxisSpacing: 20.0,
                                      children: <Widget>[
                                        snapshot
                                            .data['OfferResponse'][index]['oimg1'] !=
                                            null
                                            ?
                                        GestureDetector(
                                            onTap: () async {
                                              if (snapshot
                                                  .data['OfferResponse'][index]['oimg1']['offer_options'][0]['category_id'] !=
                                                  null) {
                                                _onTileClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg1']['offer_options'][0]['category_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]['oimg1']['offer_options'][0]['category_name']);
                                              }
                                              else if (snapshot
                                                  .data['OfferResponse'][index]['oimg1']['offer_options'][0]['category_id'] ==
                                                  null) {
                                                _onOffersClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg1']['offer_options'][0]['product_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]
                                                    ['title']);
                                              }
                                            },
                                            child: _networkImage(snapshot
                                                .data['OfferResponse'][index]['oimg1']['img_url']))
                                            : Container(),
                                        snapshot
                                            .data['OfferResponse'][index]['oimg2'] !=
                                            null
                                            ?
                                        GestureDetector(
                                            onTap: () {
                                              if (snapshot
                                                  .data['OfferResponse'][index]['oimg2']['offer_options'][0]['category_id'] !=
                                                  null) {
                                                _onTileClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg2']['offer_options'][0]['category_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]['oimg2']['offer_options'][0]['category_name']);
                                              }
                                              else if (snapshot
                                                  .data['OfferResponse'][index]['oimg2']['offer_options'][0]['category_id'] ==
                                                  null) {
                                                _onOffersClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg2']['offer_options'][0]['product_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]
                                                    ['title']);
                                              }
                                            },
                                            child: _networkImage(snapshot
                                                .data['OfferResponse'][index]['oimg2']['img_url']))
                                            : Container(),
                                        snapshot
                                            .data['OfferResponse'][index]['oimg3'] !=
                                            null
                                            ?
                                        GestureDetector(
                                            onTap: () {
                                              if (snapshot
                                                  .data['OfferResponse'][index]['oimg3']['offer_options'][0]['category_id'] !=
                                                  null) {
                                                _onTileClicked(
                                                    snapshot
                                                        .data['OfferResponse'][index]['oimg3']['offer_options'][0]['category_id']
                                                        .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]['oimg2']['offer_options'][0]['category_name']);
                                              }
                                              else if (snapshot
                                                  .data['OfferResponse'][index]['oimg3']['offer_options'][0]['category_id'] ==
                                                  null) {
                                                _onOffersClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg3']['offer_options'][0]['product_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]
                                                    ['title']);
                                              }
                                            },
                                            child: _networkImage(snapshot
                                                .data['OfferResponse'][index]['oimg3']['img_url']))
                                            : Container(),
                                        snapshot
                                            .data['OfferResponse'][index]['oimg4'] !=
                                            null
                                            ?
                                        GestureDetector(
                                            onTap: () {
                                              if (snapshot
                                                  .data['OfferResponse'][index]['oimg4']['offer_options'][0]['category_id'] !=
                                                  null) {
                                                _onTileClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg4']['offer_options'][0]['category_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]['oimg4']['offer_options'][0]['category_name']);
                                              }
                                              else if (snapshot
                                                  .data['OfferResponse'][index]['oimg4']['offer_options'][0]['category_id'] ==
                                                  null) {
                                                _onOffersClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg4']['offer_options'][0]['product_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]
                                                    ['title']);
                                              }
                                            },
                                            child: _networkImage(snapshot
                                                .data['OfferResponse'][index]['oimg4']['img_url']))
                                            : Container(),
                                        snapshot
                                            .data['OfferResponse'][index]['oimg5'] !=
                                            null
                                            ?
                                        GestureDetector(
                                            onTap: () {
                                              if (snapshot
                                                  .data['OfferResponse'][index]['oimg5']['offer_options'][0]['category_id'] !=
                                                  null) {
                                                _onTileClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg5']['offer_options'][0]['category_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]['oimg5']['offer_options'][0]['category_name']);
                                              }
                                              else if (snapshot
                                                  .data['OfferResponse'][index]['oimg5']['offer_options'][0]['category_id'] ==
                                                  null) {
                                                _onOffersClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg5']['offer_options'][0]['product_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]
                                                    ['title']);
                                              }
                                            },
                                            child: _networkImage(snapshot
                                                .data['OfferResponse'][index]['oimg5']['img_url']))
                                            : Container(),
                                        snapshot
                                            .data['OfferResponse'][index]['oimg6'] !=
                                            null
                                            ?
                                        GestureDetector(
                                            onTap: () {
                                              if (snapshot
                                                  .data['OfferResponse'][index]['oimg6']['offer_options'][0]['category_id'] !=
                                                  null) {
                                                _onTileClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg6']['offer_options'][0]['category_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]['oimg6']['offer_options'][0]['category_name']);
                                              }
                                              else if (snapshot
                                                  .data['OfferResponse'][index]['oimg6']['offer_options'][0]['category_id'] ==
                                                  null) {
                                                _onOffersClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg6']['offer_options'][0]['product_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]
                                                    ['title']);
                                              }
                                            },
                                            child: _networkImage(snapshot
                                                .data['OfferResponse'][index]['oimg6']['img_url']))
                                            : Container(),
                                      ],
                                    )

                                );
                              else
                                return Container(
                                    margin: EdgeInsets.only(left: 10,
                                        right: 10,
                                        top: 10,
                                        bottom: 10),
                                    child: GridView.count(
                                      crossAxisCount: 3,
                                      shrinkWrap: true,
                                      primary: false,
                                      crossAxisSpacing: 20.0,
                                      mainAxisSpacing: 20.0,
                                      children: <Widget>[
                                        snapshot
                                            .data['OfferResponse'][index]['oimg1'] !=
                                            null
                                            ?
                                        GestureDetector(
                                            onTap: () {
                                              if (snapshot
                                                  .data['OfferResponse'][index]['oimg1']['offer_options'][0]['category_id'] !=
                                                  null) {
                                                _onTileClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg1']['offer_options'][0]['category_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]['oimg1']['offer_options'][0]['category_name']);
                                              }
                                              else if (snapshot
                                                  .data['OfferResponse'][index]['oimg1']['offer_options'][0]['category_id'] ==
                                                  null) {
                                                _onOffersClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg1']['offer_options'][0]['product_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]
                                                    ['title']);
                                              }
                                            },
                                            child: _networkImage(snapshot
                                                .data['OfferResponse'][index]['oimg1']['img_url']))
                                            : Container(),
                                        snapshot
                                            .data['OfferResponse'][index]['oimg2'] !=
                                            null
                                            ?
                                        GestureDetector(
                                            onTap: () {
                                              if (snapshot
                                                  .data['OfferResponse'][index]['oimg2']['offer_options'][0]['category_id'] !=
                                                  null) {
                                                _onTileClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg2']['offer_options'][0]['category_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]['oimg2']['offer_options'][0]['category_name']);
                                              }
                                              else if (snapshot
                                                  .data['OfferResponse'][index]['oimg2']['offer_options'][0]['category_id'] ==
                                                  null) {
                                                _onOffersClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg2']['offer_options'][0]['product_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]
                                                    ['title']);
                                              }
                                            },
                                            child: _networkImage(snapshot
                                                .data['OfferResponse'][index]['oimg2']['img_url']))
                                            : Container(),
                                        snapshot
                                            .data['OfferResponse'][index]['oimg3'] !=
                                            null
                                            ?
                                        GestureDetector(
                                            onTap: () {
                                              if (snapshot
                                                  .data['OfferResponse'][index]['oimg3']['offer_options'][0]['category_id'] !=
                                                  null) {
                                                _onTileClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg3']['offer_options'][0]['category_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]['oimg3']['offer_options'][0]['category_name']);
                                              }
                                              else if (snapshot
                                                  .data['OfferResponse'][index]['oimg3']['offer_options'][0]['category_id'] ==
                                                  null) {
                                                _onOffersClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg3']['offer_options'][0]['product_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]
                                                    ['title']);
                                              }
                                            },
                                            child: _networkImage(snapshot
                                                .data['OfferResponse'][index]['oimg3']['img_url']))
                                            : Container(),
                                        snapshot
                                            .data['OfferResponse'][index]['oimg4'] !=
                                            null
                                            ?
                                        GestureDetector(
                                            onTap: () {
                                              if (snapshot
                                                  .data['OfferResponse'][index]['oimg4']['offer_options'][0]['category_id'] !=
                                                  null) {
                                                _onTileClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg4']['offer_options'][0]['category_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]['oimg4']['offer_options'][0]['category_name']);
                                              }
                                              else if (snapshot
                                                  .data['OfferResponse'][index]['oimg4']['offer_options'][0]['category_id'] ==
                                                  null) {
                                                _onOffersClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg4']['offer_options'][0]['product_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]
                                                    ['title']);
                                              }
                                            },
                                            child: _networkImage(snapshot
                                                .data['OfferResponse'][index]['oimg4']['img_url']))
                                            : Container(),
                                        snapshot
                                            .data['OfferResponse'][index]['oimg5'] !=
                                            null
                                            ?
                                        GestureDetector(
                                            onTap: () {
                                              if (snapshot
                                                  .data['OfferResponse'][index]['oimg5']['offer_options'][0]['category_id'] !=
                                                  null) {
                                                _onTileClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg5']['offer_options'][0]['category_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]['oimg5']['offer_options'][0]['category_name']);
                                              }
                                              else if (snapshot
                                                  .data['OfferResponse'][index]['oimg5']['offer_options'][0]['category_id'] ==
                                                  null) {
                                                _onOffersClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg5']['offer_options'][0]['product_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]
                                                    ['title']);
                                              }
                                            },
                                            child: _networkImage(snapshot
                                                .data['OfferResponse'][index]['oimg5']['img_url']))
                                            : Container(),
                                        snapshot
                                            .data['OfferResponse'][index]['oimg6'] !=
                                            null
                                            ?
                                        GestureDetector(
                                            onTap: () {
                                              if (snapshot
                                                  .data['OfferResponse'][index]['oimg6']['offer_options'][0]['category_id'] !=
                                                  null) {
                                                _onTileClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg6']['offer_options'][0]['category_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]['oimg6']['offer_options'][0]['category_name']);
                                              }
                                              else if (snapshot
                                                  .data['OfferResponse'][index]['oimg6']['offer_options'][0]['category_id'] ==
                                                  null) {
                                                _onOffersClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg6']['offer_options'][0]['product_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]
                                                    ['title']);
                                              }
                                            },
                                            child: _networkImage(snapshot
                                                .data['OfferResponse'][index]['oimg6']['img_url']))
                                            : Container(),

                                        snapshot
                                            .data['OfferResponse'][index]['oimg7'] !=
                                            null
                                            ?
                                        GestureDetector(
                                            onTap: () {
                                              if (snapshot
                                                  .data['OfferResponse'][index]['oimg7']['offer_options'][0]['category_id'] !=
                                                  null) {
                                                _onTileClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg7']['offer_options'][0]['category_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]['oimg7']['offer_options'][0]['category_name']);
                                              }
                                              else if (snapshot
                                                  .data['OfferResponse'][index]['oimg7']['offer_options'][0]['category_id'] ==
                                                  null) {
                                                _onOffersClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg7']['offer_options'][0]['product_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]
                                                    ['title']);
                                              }
                                            },
                                            child: _networkImage(snapshot
                                                .data['OfferResponse'][index]['oimg7']['img_url']))
                                            : Container(),
                                        snapshot
                                            .data['OfferResponse'][index]['oimg8'] !=
                                            null
                                            ?
                                        GestureDetector(
                                            onTap: () {
                                              if (snapshot
                                                  .data['OfferResponse'][index]['oimg8']['offer_options'][0]['category_id'] !=
                                                  null) {
                                                _onTileClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg8']['offer_options'][0]['category_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]['oimg8']['offer_options'][0]['category_name']);
                                              }
                                              else if (snapshot
                                                  .data['OfferResponse'][index]['oimg8']['offer_options'][0]['category_id'] ==
                                                  null) {
                                                _onOffersClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg8']['offer_options'][0]['product_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]
                                                    ['title']);
                                              }
                                            },
                                            child: _networkImage(snapshot
                                                .data['OfferResponse'][index]['oimg8']['img_url']))
                                            : Container(),
                                        snapshot
                                            .data['OfferResponse'][index]['oimg9'] !=
                                            null
                                            ?
                                        GestureDetector(
                                            onTap: () {
                                              if (snapshot
                                                  .data['OfferResponse'][index]['oimg9']['offer_options'][0]['category_id'] !=
                                                  null) {
                                                _onTileClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg9']['offer_options'][0]['category_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]['oimg9']['offer_options'][0]['category_name']);
                                              }
                                              else if (snapshot
                                                  .data['OfferResponse'][index]['oimg9']['offer_options'][0]['category_id'] ==
                                                  null) {
                                                _onOffersClicked(snapshot
                                                    .data['OfferResponse'][index]['oimg9']['offer_options'][0]['product_id']
                                                    .toString(),
                                                    snapshot
                                                        .data['OfferResponse'][index]
                                                    ['title']);
                                              }
                                            },
                                            child: _networkImage(snapshot
                                                .data['OfferResponse'][index]['oimg9']['img_url']))
                                            : Container(),
                                      ],
                                    )

                                );
                            },
                          ),
                        ),

                      ]
                  ),
                );
              },
            ),

            SizedBox(
              height: 8,
            ),
            Container(
              padding: EdgeInsets.all(5),
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0)),
              ),
              child: CarouselSlider.builder(
                  options: CarouselOptions(
                    height: 160,
                    initialPage: 1,
                    viewportFraction: 1.0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 3),
                    autoPlayAnimationDuration: Duration(milliseconds: 1000),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                  ),
                  itemCount: snapshot.data['SliderResponse'][1]['slider_options'].length,
                  itemBuilder: (BuildContext context, int itemIndex) {
                    return GestureDetector(
                      onTap: () {
                        if (snapshot
                            .data['SliderResponse'][1]['slider_options'][itemIndex]['category_id'] !=
                            null) {
                          Navigator.pushNamed(
                            context,
                            '/products',
                            arguments: <String, String>{
                              'id': snapshot
                                  .data['SliderResponse'][1]['slider_options'][itemIndex]['category_id']
                                  .toString(),
                              'title': snapshot
                                  .data['SliderResponse'][1]['slider_options'][itemIndex]['category_name'],
                              'type': 'subcategory',
                            },
                          );
                        }
                      },
                      child: Container(
                          child: Image.network(
                              snapshot
                                  .data['SliderResponse'][1]['slider_options'][itemIndex]['soimage'],
                              fit: BoxFit.fill,
                              width: 1000.0)),
                    );
                  }),
            ),
          ]);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Container(child: CircularProgressIndicator()));
        }else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void _onOffersClicked(id, title) {
    Navigator.pushNamed(
      context,
      '/products',
      arguments: <String, String>{
        'id': id.toString(),
        'title': title,
        'type': null,
      },
    );
  }

  void _onTileClicked(id, title) {
    Navigator.pushNamed(
      context,
      '/products',
      arguments: <String, String>{
        'id': id.toString(),
        'title': title,
        'type': 'subcategory',
      },
    );
  }

  Future _dashboardBanners() async {
    var response = await http.post(
        new Uri.https(BASE_URL, API_PATH + "/sliderfinder"),
        body: {"user_id": _userId, "store_id" : "35"},
        headers: {"Accept": "application/json", "authorization": basicAuth});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['Response'];
      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Widget _networkImage(url) {
    return Stack(
        children: <Widget>[ ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image(
            fit: BoxFit.fitHeight,
            image: CachedNetworkImageProvider(url),
          ),
        ), Positioned(
          top: 68.0,
          left: 10.0,
          right: 10.0,
          child: Card(
            elevation: 8.0,
            color: Color(0xFFc62714),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "shop",
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,
                ),
              ),
            ),

          ),
        ),

        ]
    );
  }

  Widget _gpsButton() {
    return Container(
      margin: new EdgeInsets.only(right: 15),
      child: IconButton(
        icon: Icon(
          Icons.gps_fixed,
        ),
        //iconSize: 50,
        color: Colors.green,
        splashColor: Colors.purple,
        onPressed: () {
          //_getCurrentLocation();
        },
      ),
    );
  }

  /*_getCurrentLocation() async {
    Position position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    setState(() {
      _address =
          place.name +
              ', ' +
              place.subLocality +
              ', ' +
              place.locality +
              ' - ' +
              place.postalCode;
    });
    //_myStore = _storeFuture(position.latitude, position.longitude);
  }*/

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
        child: Column(
            children: <Widget>[ Container(
              height: 90,
              margin: EdgeInsets.only(right: 15, bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(20.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(4, 4), // changes position of shadow
                  ),
                ],
                //image: CachedNetworkImageProvider(image),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(image),
                  fit: BoxFit.cover,
                ),
              ),
              //image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover)),
              child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(20.0)),
                      gradient: LinearGradient(begin: Alignment.bottomRight, colors: [
                        Colors.black.withOpacity(.8),
                        Colors.black.withOpacity(.2),
                      ])),
                  child: Container()/*Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),*/
              ),
            ),
              SizedBox(height: 5),
              Container(
                margin: EdgeInsets.only(right: 20),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Marquee(
                    textDirection : TextDirection.ltr,
                    child: Text(
                      title,
                      maxLines: 2,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                ),
              ),

            ]
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
