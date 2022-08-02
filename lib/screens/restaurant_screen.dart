import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sodhis_app/Animation/animations.dart';
import 'package:sodhis_app/components/ThemeColor.dart';
import 'package:sodhis_app/constants.dart';
import 'package:http/http.dart' as http;
import 'package:sodhis_app/models/extraitemdata.dart';
import 'package:sodhis_app/models/restuarantitemslistdata.dart';
import 'package:sodhis_app/providers/itemcount_provider.dart';
import 'package:sodhis_app/providers/restaurant_provider.dart';
import 'package:sodhis_app/screens/webview.dart';
import 'package:sodhis_app/services/cart_badge.dart';
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({Key key}) : super(key: key);

  @override
  _RestaurantScreenState createState() => _RestaurantScreenState();
}

PersistentBottomSheetController controller;

class _RestaurantScreenState extends State<RestaurantScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final itemController = ItemScrollController();

  var _userId;
  var deliveryType = "";
  var errorCode;
  var product_error;
  String _name;
  String _shortName = '';
  String _email_address;

  bool isToggle = false;
  String pickUp = "takeaway";

  List<Response> restlist = [];
  List<ExtraItemResponse> extraitem = [];

  bool loader = false;
  List<bool> isChecked;

  bool showviewcart = false;

  List addextraitem = [];

  final scrollDirection = Axis.vertical;
  AutoScrollController controller;

  String bottomaddontotalprice = "";

  double finalPrice = 0;

  double totalprice = 0.0;

  @override
  void initState() {
    super.initState();
    print(BASE_URL + API_PATH + "/restaurant-category");
    _getUser();
    //_getCurrentLocation();

    _getRestaurantData();
  }

  Future scrollItem(int index) async {
    itemController.scrollTo(index: index, duration: Duration(seconds: 1));
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();
      pickUp = "takeaway";
      prefs.setString('delivery_type', pickUp);
      //print(pickUp);
      //print(_userId);
      _name = prefs.getString('name');
      _shortName = _name[0];
      //_storeId = prefs.getInt('store_id').toString();
      //_mobile_number = prefs.getString('mobile_number');
      _email_address = prefs.getString('email_address');
      //_address = prefs.getString('address');
    });
  }

  Future<void> refreshList() async {
    await Future.delayed(Duration(milliseconds: 500));
    _getRestaurantData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: loader == false
            ? RefreshIndicator(
                onRefresh: refreshList,
                child: Stack(
                  children: [
                    Column(
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 1.0, bottom: 15.0),
                          child: Container(
                              height: MediaQuery.of(context).size.height * 0.73,
                              width: double.infinity,
                              child: ScrollablePositionedList.separated(
                                itemCount: restlist.length,
                                itemScrollController: itemController,
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        Divider(),
                                itemBuilder: (context, i) {
                                  return ExpansionTile(
                                    initiallyExpanded: true,
                                    title: new Text(restlist[i].name,
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold)),
                                    children: <Widget>[
                                      new Column(
                                        children: _buildExpandableContent(
                                            restlist[i]),
                                      ),
                                    ],
                                  );
                                },
                              )),
                        )
                      ],
                    ),
                    Positioned(
                        bottom: 100,
                        right: 20,
                        child: GestureDetector(
                          onTap: () {
                            _categoryDialogBox();
                          },
                          child: Container(
                              height: 65,
                              width: 65,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(32.5)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.payment,
                                      color: Colors.white, size: 18),
                                  SizedBox(height: 2.0),
                                  Text("Menu",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              )),
                        )),
                     showviewcart ?  showItemWidget() : SizedBox()
                  ],
                ),
              )
            : Center(
                child: Container(
                  height: 24.0,
                  width: 24.0,
                  child: CircularProgressIndicator(color: Colors.red),
                ),
              ),
        drawer: new Drawer(
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
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    //prefs.remove('logged_in');
                    prefs.clear();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          ]),
        ));
  }

  void _openWebview() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => MyWebView(
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

  Future<List<Response>> _getRestaurantData() async {
    restlist.clear();
    setState(() {
      loader = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(BASE_URL + API_PATH + "/restaurant-category");
    var response = await http.post(
      Uri.https(BASE_URL, API_PATH + "/restaurant-category"),
      body: {
        "user_id": prefs.getInt('user_id').toString(),
        "restaurant_id": "41"
      },
      headers: {"Accept": "application/json", "authorization": basicAuth},
    );
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body)['Response'];
      List<Response> _list = list.map((m) => Response.fromJson(m)).toList();
      if (mounted) {
        setState(() {
          restlist.addAll(_list);
          loader = false;
        });
      }
    } else {
      throw Exception('Something went wrong');
    }
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
              'type': 'category',
            },
          );
        },
        child: Column(children: <Widget>[
          Container(
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
                    gradient:
                        LinearGradient(begin: Alignment.bottomRight, colors: [
                      Colors.black.withOpacity(.8),
                      Colors.black.withOpacity(.2),
                    ])),
                child: Container()),
          ),
          SizedBox(height: 5),
          Container(
            margin: EdgeInsets.only(right: 20),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Marquee(
                textDirection: TextDirection.ltr,
                child: Text(
                  title,
                  maxLines: 2,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  Widget _product(
      context,
      int i,
      List<Items> data,
      String productid,
      String productimage,
      String productname,
      String productprice,
      String shortdesc,
      String longdesc,
      String discountper,
      String qty,
      String discount,
      bool selected,
      String addon,
      String itemtype) {
    return GestureDetector(
      onTap: () {
        /*_productdetails(context, i, data, productid, productimage, productname,
            productprice, discount, qty, longdesc, addon);*/
      },
      child: Column(
        children: [
          Container(
            height: 170,
            width: double.infinity,
            child: Padding(
              padding:
              EdgeInsets.only(left: 12.0, top: 4.0, bottom: 4.0, right: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.0),
                      itemtype == "veg"
                          ? Container(
                        height: 14.0,
                        width: 14.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border:
                            Border.all(color: Colors.green, width: 1.0)),
                        child: Icon(
                          Icons.circle,
                          color: Colors.green,
                          size: 8.0,
                        ),
                      )
                          : Container(
                        height: 14.0,
                        width: 14.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border:
                            Border.all(color: Colors.red, width: 1.0)),
                        child: Icon(
                          Icons.warning_outlined,
                          color: Colors.red,
                          size: 8.0,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(productname,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10.0),
                      discount == "0.00"
                          ? Text("\u20B9 " + productprice,
                          style: TextStyle(color: Colors.black, fontSize: 16.0))
                          : Text("\u20B9 " + discount,
                          style:
                          TextStyle(color: Colors.black, fontSize: 16.0)),
                      SizedBox(height: 5.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          discount == "0.00"
                              ? Text("")
                              : Text("\u20B9 " + productprice,
                              style: TextStyle(
                                  color: Colors.red,
                                  decoration: TextDecoration.lineThrough)),
                          SizedBox(width: 80),
                          discount == "0.00"
                              ? Text("")
                              : Text(discountper + "% Off",
                              style: TextStyle(
                                color: Colors.green,
                              )),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                              width: 200,
                              height: 40,
                              child: ([
                                "",
                                null,
                                "null"
                              ].contains(data[i].shortDescription.toString()))
                                  ? Container(color: Colors.transparent)
                                  : AutoSizeText(
                                data[i].shortDescription.toString(),
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16.0),
                              )),
                        ],
                      )
                    ],
                  ),
                  Container(
                    height: 140,
                    child: Stack(
                      children: [
                        Container(
                          height: 120,
                          width: 140,
                          child: Card(
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: Image.network(
                              productimage,
                              fit: BoxFit.fill,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            elevation: 5,
                            margin: EdgeInsets.all(10),
                          ),
                        ),
                        Positioned(
                            bottom: 5,
                            left: 15,
                            right: 15,
                            //child: SizedBox(),
                            child: data[i].quantity.toString() == "0"
                                ? addItem(i, data, productid, productprice,
                                discount, qty, addon)
                                : addminusItem(i, data, productid, productprice,
                                discount, qty))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Divider(
             thickness: 10,
             color: Colors.grey,
             height: 10,
          )
        ] ,
      ),
    );
  }

  void _productdetails(
      context,
      int i,
      List<Items> data,
      String id,
      String productimage,
      String productname,
      String productprice,
      String discount,
      String qty,
      String longdesc,
      String addon) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0))),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0))),
                        width: double.infinity,
                        child: Card(
                          child: Image.network(
                            productimage,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 14.0,
                            width: 14.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.green, width: 1.0)),
                            child: Icon(
                              Icons.circle,
                              color: Colors.green,
                              size: 8.0,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 220,
                                height: 45,
                                child: AutoSizeText(
                                  productname,
                                  style: TextStyle(
                                      fontSize: 28,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                ),
                              ),
                              Container(
                                width: 110,
                                height: 45,
                                child: data[i].quantity.toString() == "0"
                                    ? addItem(i, data, id, productprice,
                                        discount, qty, addon)
                                    : addminusItem(i, data, id, productprice,
                                        discount, qty),
                              )
                            ],
                          ),
                          SizedBox(height: 10),
                          Text("\u20B9 " + productprice,
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey)),
                          SizedBox(height: 10),
                          Text(
                            '',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                            maxLines: 2,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            }));
  }

  Widget _categoryDialog(context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildChild(context),
    );
  }

  _buildChild(BuildContext context) => Container(
        height: 250,
        decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            Container(
                child:
                Scrollbar(
                  thickness: 2,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                primary: false,
                controller: controller,
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(),
                itemCount: restlist.length,
                itemBuilder: (BuildContext context, int index) {
                  return _catlist(context, index, restlist[index].name,
                      restlist[index].items.length.toString());
                },
              ),
            ))
          ],
        ),
      );

  Widget _catlist(context, int index, String catname, String items) {
    return GestureDetector(
      onTap: () {
        scrollItem(index);
        Navigator.pop(context);
      },
      child: Container(
        height: 40.0,
        width: double.infinity,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.star, size: 12.0, color: Colors.blue),
            ),
            SizedBox(width: 0.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(catname,
                    style: TextStyle(color: Colors.black, fontSize: 18.0)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(items,
                  style: TextStyle(color: Colors.black, fontSize: 18.0)),
            ),
          ],
        ),
      ),
    );
  }

  _buildExpandableContent(Response data) {
    List<Widget> columnContent = [];

    for (int index = 0; index < data.items.length; index++) {
      columnContent.add(_product(
          context,
          index,
          data.items,
          data.items[index].id.toString(),
          data.items[index].productImage,
          data.items[index].productName,
          data.items[index].mrp,
          data.items[index].shortDescription,
          data.items[index].longDescription,
          data.items[index].discountPercentage,
          data.items[index].quantity.toString(),
          data.items[index].discount,
          data.items[index].selected,
          data.items[index].addonStatus.toString(),
          data.items[index].itemType.toString()));
    }

    return columnContent;
  }

  Widget addItem(int i, List<Items> data, String productid, String productprice,
      String discount, String qty, String addon) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return GestureDetector(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              if (addon == "1") {
                 _getExtraData(productid).then((value){
                  setState(() {
                    myextraitemlist.addAll(value);
                  });
                  addextraitem.clear();
                  discount == "0.00"
                      ? extraItem(context, productprice, productid, discount,
                      (int.parse(qty) + 1).toString(), addextraitem)
                      : extraItem(context, discount, productid, discount,
                      (int.parse(qty) + 1).toString(), addextraitem);
                });
                return;
              } else {
                print(prefs.getInt('cart_count').toString());
                if(prefs.getInt('cart_count') == 0) {
                  prefs.setString('type', "restaurant");
                  addextraitem.clear();
                  cartaction(productid, productprice, discount, (int.parse(qty) + 1).toString(), addextraitem, "0");
                  setState(() {
                    data[i].quantity = int.parse(qty) + 1;
                  });
                } else {
                  if (prefs.getString('type') == "restaurant") {
                    prefs.setString('type', "restaurant");
                    addextraitem.clear();
                    cartaction(productid, productprice, discount,
                        (int.parse(qty) + 1).toString(), addextraitem, "0");
                    setState(() {
                      data[i].quantity = int.parse(qty) + 1;
                    });
                  } else {
                    prefs.setString('type', "restaurant");
                    showConfirmDialog(
                        'Cancel',
                        'Ok',
                        'Remove Item',
                        'Please remove or purchase grocery items from cart after that you can add restaurant item',
                        productid,
                        productprice,
                        discount,
                        (int.parse(qty) + 1).toString(),
                        addextraitem,
                        "0");
                  }
                }
              }
            },
            child: addon == "1"
                ? Container(
                    height: 45,
                    width: 70,
                    child: Card(
                      elevation: 4.0,
                      child: Stack(
                        children: [
                          Padding(
                              padding:
                                  const EdgeInsets.only(left: 30.0, top: 10.0),
                              child: Text("ADD",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16))),
                          Positioned(
                              top: 2,
                              right: 3,
                              child:
                                  Icon(Icons.add, color: Colors.red, size: 12))
                        ],
                      ),
                    ),
                  )
                : Container(
                    height: 45,
                    width: 70,
                    child: Card(
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text("ADD",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
                    ),
                  )
        );
      },
    );
  }

  Widget addminusItem(int i, List<Items> data, String productid,
      String productprice, String discount, String qty) {
    return Container(
      height: 45,
      width: 70,
      child: Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.only(left: 5.0, right: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    addextraitem.clear();
                    setState(() {
                      data[i].quantity = int.parse(qty) - 1;
                    });
                    cartaction(productid, productprice, discount,
                        (int.parse(qty) - 1).toString(), addextraitem, "0");
                  },
                  child: Icon(Icons.remove, color: Colors.grey),
                ),
                Text(data[i].quantity.toString(),
                    style: TextStyle(color: Colors.black, fontSize: 14.0)),
                GestureDetector(
                  onTap: () {
                    addextraitem.clear();
                    setState(() {
                      data[i].quantity = int.parse(qty) + 1;
                    });
                    cartaction(productid, productprice, discount,
                        (int.parse(qty) + 1).toString(), addextraitem, "0");
                  },
                  child: Icon(Icons.add, color: Colors.red),
                ),
              ],
            ),
          )),
    );
  }

  void cartaction(String id, String mrp, String discount, String qty,
      List items, String sheetcheck) async {
    final _cart = Provider.of<CartBadge>(context, listen: false);
    final _itemCheck = Provider.of<ItemCountProvider>(context, listen: false);
    print(jsonEncode({
      "user_id": _userId.toString(),
      "offer_price": discount.toString(),
      "rate": mrp.toString(),
      "restaurant_id": "41",
      "quantity": qty.toString(),
      "product_id": id.toString(),
      "addon_items": items.length == 0 ? [] : items
    }));
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/cart-add"),
      headers: {
        "Accept": "application/json",
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "user_id": _userId.toString(),
        "offer_price": discount.toString(),
        "rate": mrp.toString(),
        "restaurant_id": "41",
        "quantity": qty.toString(),
        "product_id": id.toString(),
        "addon_items": items.length == 0 ? [] : items
      }),
    );
    if (response.statusCode == 200) {
      _cart.showCartBadge(_userId);
      var data = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('cart_count', int.parse(data['Response']['count'].toString()));
      if (sheetcheck == "1") {
        Navigator.pop(context);
        _getRestaurantData();
        _itemCheck.getItemData(_userId, "41");
        //updateItem(_itemCheck.getCounter().toString(), _itemCheck.getTotalPrice().toString());
      } else {
        _itemCheck.getItemData(_userId, "41");
        print("Total Count"+_itemCheck.getCounter().toString());
        print("Total Price"+_itemCheck.getTotalPrice().toString());
        //updateItem(_itemCheck.getCounter().toString(), _itemCheck.getTotalPrice().toString());
      }
    } else {
      print(response.toString());
    }
  }

  showConfirmDialog(cancel, done, title, content, productid, productprice,
      discount, qty, addextraitem, sheetcheck) {
    //final _cart = Provider.of<CartBadge>(context, listen: false);
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
        cartaction(
            productid, productprice, discount, qty, addextraitem, sheetcheck);
        Navigator.of(context).pop();
        _getRestaurantData();
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

  extraItem(context, String itemprice, String id, String discount, String quantity, List addextraitem) {
    setState(() {
       finalPrice = 0;
    });
    addextraitem.clear();
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => StatefulBuilder(
            builder: (BuildContext context, StateSetter extrasetState) =>
                Container(
                    height: 600,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25.0),
                            topRight: Radius.circular(25.0))),
                    child: Stack(
                      children: [
                        Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              children: myextraitemlist.map((e) {

                                List tempList = e['data'];
                                return Column(children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(left: 8, top: 10),
                                      child: Text(e['group_name'],
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                  SizedBox(height: 2.0),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: e['addon_limit'].toString() == "0"
                                          ? Container()
                                          : Text(
                                              e['title_name']
                                                  .toString()
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12.0)),
                                    ),
                                  ),
                                  SizedBox(height: 5.0),
                                  Column(
                                    children: tempList
                                        .map((ee) => Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Container(
                                                height: 40,
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 12.0,
                                                      width: 12.0,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.green,
                                                              width: 1.0)),
                                                      child: Icon(
                                                        Icons.circle,
                                                        color: Colors.green,
                                                        size: 6.0,
                                                      ),
                                                    ),
                                                    SizedBox(width: 6.0),
                                                    Text(ee['addon_name']),
                                                    SizedBox(width: 10.0),
                                                    Expanded(child: ee['addon_price'].toString() == "0.00" ? Text("") : Text("\u20B9" + ee['addon_price'])),
                                                    Checkbox(
                                                      activeColor: Colors.green,
                                                      value: ee['selected'],
                                                      onChanged: (val) {
                                                        if (int.parse(e['addon_limit'].toString()) == 0) {
                                                          if (ee['selected'] == true) {
                                                            extrasetState(() {
                                                              ee['selected'] = false;
                                                            });
                                                            for (int i = 0; i < addextraitem.length; i++) {
                                                              if (addextraitem[i]['id'].toString() == ee['id'].toString()) {
                                                                addextraitem.removeAt(i);
                                                              }
                                                            }
                                                            extrasetState(() {
                                                              totalprice = 0;
                                                            });
                                                            tempList.forEach(
                                                                (element) {
                                                              if (element['selected'] == true) {
                                                                totalprice = totalprice + double.parse(element['addon_price'].toString());
                                                              }
                                                            });
                                                          } else {
                                                            extrasetState(() {
                                                              totalprice = 0;
                                                              ee['selected'] = true;
                                                            });
                                                            addextraitem.add({
                                                              "id": ee['id'].toString(),
                                                              "price": ee['addon_price'].toString(),
                                                              "status": 1
                                                            });
                                                            tempList.forEach(
                                                                (element) {
                                                              if (element[
                                                                      'selected'] ==
                                                                  true) {
                                                                totalprice = totalprice +
                                                                    double.parse(
                                                                        element['addon_price']
                                                                            .toString());
                                                              }
                                                            });
                                                          }
                                                        } else {
                                                          if (ee['selected'] ==
                                                              true) {
                                                            extrasetState(() {
                                                              ee['selected'] =
                                                                  false;
                                                              totalprice = 0;
                                                            });
                                                            for (int i = 0;
                                                                i <
                                                                    addextraitem
                                                                        .length;
                                                                i++) {
                                                              if (addextraitem[
                                                                              i]
                                                                          ['id']
                                                                      .toString() ==
                                                                  ee['id']
                                                                      .toString()) {
                                                                addextraitem
                                                                    .removeAt(
                                                                        i);
                                                              }
                                                            }
                                                            tempList.forEach(
                                                                (element) {
                                                              if (element[
                                                                      'selected'] ==
                                                                  true) {
                                                                totalprice = totalprice +
                                                                    double.parse(
                                                                        element['addon_price']
                                                                            .toString());
                                                              }
                                                            });
                                                          } else {
                                                            int total = 0;
                                                            tempList.forEach(
                                                                (element) {
                                                              if (element[
                                                                      'selected'] ==
                                                                  true) {
                                                                total++;
                                                                //totalprice = totalprice+double.parse(element['addon_price'].toString());

                                                              }
                                                            });
                                                            if (total <
                                                                int.parse(e[
                                                                        'addon_limit']
                                                                    .toString())) {
                                                              extrasetState(() {
                                                                totalprice = 0;
                                                                ee['selected'] =
                                                                    true;
                                                              });
                                                              addextraitem.add({
                                                                "id": ee['id']
                                                                    .toString(),
                                                                "price": ee[
                                                                        'addon_price']
                                                                    .toString(),
                                                                "status": 1
                                                              });
                                                              tempList.forEach(
                                                                  (element) {
                                                                if (element[
                                                                        'selected'] ==
                                                                    true) {
                                                                  totalprice = totalprice +
                                                                      double.parse(
                                                                          element['addon_price']
                                                                              .toString());
                                                                }
                                                              });
                                                            } else {
                                                              Fluttertoast.showToast(
                                                                  msg: e['title_name']
                                                                          .toString() +
                                                                      " items\nUnselect selected items");
                                                            }
                                                          }
                                                        }
                                                        print("my print");
                                                        double temp1 = 0;
                                                        for(int i=0; i<addextraitem.length; i++){
                                                           if(addextraitem[i]['status'].toString() == "1"){
                                                              temp1 = temp1+double.parse(addextraitem[i]['price'].toString());
                                                              print(addextraitem[i]);
                                                           }
                                                        }
                                                        print(temp1);
                                                        extrasetState(() {
                                                           finalPrice = temp1;
                                                        });

                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  )
                                ]);
                              }).toList(),
                            )),
                        Positioned(
                            bottom: 10.0,
                            left: 10.0,
                            right: 10.0,
                            child: GestureDetector(
                              onTap: () async{
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                if(prefs.getString('type') == "restaurant") {
                                  prefs.setString('type', "restaurant");
                                  cartaction(id, itemprice, discount, quantity,
                                      addextraitem, "1");
                                }
                                else{
                                  prefs.setString('type', "restaurant");
                                  showConfirmDialog(
                                      'Cancel',
                                      'Ok',
                                      'Remove Item',
                                      'Please remove or purchase grocery items from cart after that you can add restaurant item',
                                      id,
                                      itemprice,
                                      discount,
                                      quantity,
                                      addextraitem,
                                      "1");
                                }

                              },
                              child: Container(
                                height: 45,
                                width: 100,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0))),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          "Item Price : " +
                                              (double.parse(itemprice.toString())+finalPrice).toString(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500)),
                                      Text("ADD ITEM",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500))
                                    ],
                                  ),
                                ),
                              ),
                            ))
                      ],
                    ))
        )
    );
  }

  List myextraitemlist = [];

  Future<List> _getExtraData(String id) async {
    print("Extra data method");
    extraitem.clear();
    setState(() {
      myextraitemlist.clear();
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = await http.post(
      Uri.https(BASE_URL, API_PATH + "/products-addon"),
      body: {
        "user_id": prefs.getInt('user_id').toString(),
        "restaurant_id": "41",
        "item_id": id.toString()
      },
      headers: {"Accept": "application/json", "authorization": basicAuth},
    );

    List group_ids = [];
    List data = json.decode(response.body)['Response'];
    data.forEach((element) {
      group_ids.add(element['group_id'].toString());
    });

    List mylist = [];

    Map newMap = groupBy(
        json.decode(response.body)['Response'], (obj) => obj['group_id']);
    group_ids.toSet().toList().forEach((element) {
      Map mymap = {};
      mymap['group_id'] = element.toString();
      List t = newMap[int.parse(element.toString())];
      t.forEach((eleme) {
        eleme['selected'] = false;
      });

      mymap['data'] = t;
      mymap['title_name'] =
          newMap[int.parse(element.toString())][0]['title_name'];
      mymap['group_name'] =
          newMap[int.parse(element.toString())][0]['group_name'];
      mymap['addon_limit'] =
          newMap[int.parse(element.toString())][0]['addon_limit'];
      mymap['count'] = 1;
      mylist.add(mymap);
    });
    print(mylist);

    return mylist;
    //List<ExtraItemResponse> _list = list.map((m) => ExtraItemResponse.fromJson(m)).toList();
    //print(_list);
    /*if (response.statusCode == 200) {
      Iterable list = json.decode(response.body)['Response'];
      List<ExtraItemResponse> _list = list.map((m) => ExtraItemResponse.fromJson(m)).toList();
      setState((){
        extraitem.addAll(_list);
        isChecked = List.filled(_list.length, false);
      });
      return _list;
    } else {
      throw Exception('Something went wrong');
    }*/
  }

  _categoryDialogBox() {
    return showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierDismissible: true,
      transitionDuration: Duration(milliseconds: 300),
      transitionBuilder: (context, _animation, _secondaryAnimation, _child) {
        return Animations.grow(_animation, _secondaryAnimation, _child);
      },
      pageBuilder: (_animation, _secondaryAnimation, _child) {
        return _categoryDialog(context);
      },
    );
  }

  Future<Null> updatedPrice(StateSetter itempricesetState, String totalprice,
      String itemprice) async {
    itempricesetState(() {
      bottomaddontotalprice = totalprice;
      print(bottomaddontotalprice);
    });
  }

  Widget showItemWidget() {
    final mydata = Provider.of<ItemCountProvider>(context);
    mydata.getItemData(_userId, "41");
    if (mydata.counter != 0) {
      return Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/checkout-new').then((value){
                  mydata.getItemData(_userId, "41");
                  if(mydata.counter==0){
                    setState(() {
                      showviewcart = false;
                    });
                  }
                  else{
                    setState(() {
                      showviewcart = true;
                    });
                  }
                });
              },
              child: Container(
                height: 55,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(0.0)),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: mydata.counter == 0 || mydata.counter == 1
                          ? Text("${mydata.counter.toString()} Item",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 14.0))
                          : Text("${mydata.counter.toString()} Items",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 14.0)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 5.0, top: 15.0, bottom: 15.0, right: 5.0),
                      child: VerticalDivider(
                        color: Colors.white,
                        thickness: 2,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                          padding: EdgeInsets.only(
                              left: 5.0, top: 15.0, bottom: 15.0, right: 5.0),
                          child: Text("\u20B9 ${mydata.totalprice.toString()}",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 14.0))),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: Text("View Cart",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500)),
                    )
                  ],
                ),
              )));
    } else {
      return Container();
    }
  }
}
