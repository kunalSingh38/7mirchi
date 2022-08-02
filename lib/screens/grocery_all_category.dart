import 'dart:convert';
import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sodhis_app/constants.dart';
import 'package:sodhis_app/providers/itemcount_provider.dart';
import 'package:sodhis_app/services/cart_badge.dart';
import 'package:sodhis_app/utilities/basic_auth.dart';
import 'package:sodhis_app/utill/custom_themes.dart';
import 'package:sodhis_app/utill/dimensions.dart';

class GroceryAllCategory extends StatefulWidget {
  final Object argument;
  const GroceryAllCategory({Key key, this.argument}) : super(key: key);

  @override
  _GroceryAllCategoryState createState() => _GroceryAllCategoryState();
}

class _GroceryAllCategoryState extends State<GroceryAllCategory> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String categoryname;
  String categoryid;
  String _userId;

  List categorylist = [];
  List itemlist = [];

  Future _productList;
  Future itemFinderList;
  Future<dynamic> _myproductCategories;
  Future<dynamic> _myproductSubCategories;

  Future<dynamic> _myCategoriesProducts;

  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);

    _userId = data['userid'];
    categoryname = data['categoryname'];
    categoryid = data['categoryid'];


    _myCategoriesProducts = _mycategoriesproducts(categoryid);

    _myproductSubCategories = _grocerySubCategory(_userId, categoryid);

    _myproductCategories = _groceryCategory();

  }

  void cartaction(String id, String mrp, String discount, String qty, List items, String addtocart) async {
    //final _cart = Provider.of<CartBadge>(context, listen: false);
    //final _itemCheck = Provider.of<ItemCountProvider>(context, listen: false);
    print(jsonEncode({
      "user_id": _userId.toString(),
      "offer_price": discount.toString(),
      "rate": mrp.toString(),
      "restaurant_id": "35",
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
        "restaurant_id": "35",
        "quantity": qty.toString(),
        "product_id": id.toString(),
        "addon_items": items.length == 0 ? [] : items
      }),
    );
    if (response.statusCode == 200) {
      //_cart.showCartBadge(_userId);
      var data = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('cart_count', int.parse(data['Response']['count'].toString()));
      if(data['ErrorCode'].toString() == "0"){
        if(addtocart.toString() == "1"){
          //_itemCheck.getItemData(_userId, "35");
          _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("Item Added Successfully", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
        }
        else if(qty.toString() == "0"){
          //_itemCheck.getItemData(_userId, "35");
          _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("Item Removed Successfully", style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
        }
        else{}
      }
    } else {
      print(response.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final _counter = Provider.of<CartBadge>(context);
    _counter.showCartBadge(_userId);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Stack(
         children: [
           Column(
             children: [
               Container(
                   height: 100,
                   decoration: BoxDecoration(
                     color: Colors.white,
                     border: Border(
                       bottom: BorderSide(width: 1.5, color: Colors.grey[400]),
                     ),
                   ),
                   alignment: Alignment.center,
                   child: Padding(
                     padding: EdgeInsets.only(left: 10, top: 30, right: 10),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.start,
                       children: [
                         IconButton(
                           onPressed: (){
                             Navigator.pop(context);
                           }, icon: Icon(Icons.arrow_back, size: 24, color: Colors.black),
                         ),
                         SizedBox(width: 10),
                         Expanded(
                           child: GestureDetector(
                             onTap: (){
                               //showCategoriesSheet();
                             },
                             child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children : [
                                   Text(categoryname.toString().toUpperCase(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                                   SizedBox(height: 0.0),
                                   /*Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text("see all categories", style: TextStyle(color: Colors.green, fontSize: 16)),
                                      SizedBox(width: 0.0),
                                      Icon(Icons.keyboard_arrow_down, color: Colors.green, size: 20)
                                    ],
                                  )*/
                                 ]
                             ),
                           ),
                         ),
                         Padding(
                           padding: EdgeInsets.only(right: 5),
                           child: IconButton(
                             icon: Badge(
                               animationDuration: Duration(milliseconds: 10),
                               animationType: BadgeAnimationType.scale,
                               badgeContent: Text(
                                 '${_counter.getCounter()}',
                                 style: TextStyle(color: Colors.white),
                               ),
                               child: const Icon(Icons.shopping_basket, color: Colors.grey, size: 28),
                             ),
                             onPressed: () {
                               Navigator.pushNamed(context, '/checkout-new');
                               // Navigator.pushNamed(context, '/cart');
                             },
                           ),
                         )
                       ],
                     ),
                   )
               ),
               Expanded(child: Row (
                   children: [
                     Container(
                       width: 85,
                       margin: EdgeInsets.only(top: 1),
                       height: double.infinity,
                       decoration: BoxDecoration(
                         color: Colors.grey[100],
                         boxShadow: [BoxShadow(color: Colors.white, spreadRadius: 1, blurRadius: 1)],
                       ),
                       child: FutureBuilder(
                           future: _myproductSubCategories,
                           builder: (context, snapshot){
                             if(snapshot.hasData){
                               return ListView.builder(
                                 physics: BouncingScrollPhysics(),
                                 itemCount: snapshot.data['CategoryResponse'].length,
                                 padding: EdgeInsets.all(0),
                                 itemBuilder: (context, index) {
                                   return InkWell(
                                     onTap: () async{
                                       SharedPreferences prefs = await SharedPreferences.getInstance();
                                       prefs.setString('subcategoryid', snapshot.data['CategoryResponse'][index]['id'].toString());
                                       _grocerySubCategoryItem(snapshot.data['CategoryResponse'][index]['id'].toString());
                                       print(snapshot.data['CategoryResponse'][index].toString());
                                       List temp = snapshot.data['CategoryResponse'];
                                       temp.forEach((element) {
                                         setState(() {
                                           element['isSelected'] = false;
                                         });
                                       });
                                       setState(() {
                                         snapshot.data['CategoryResponse'][index]['isSelected'] = true;
                                       });
                                     },
                                     child: CategoryItem(
                                       title: snapshot.data['CategoryResponse'][index]['name'].toString(),
                                       image : snapshot.data['CategoryResponse'][index]['image'].toString(),
                                       id : snapshot.data['CategoryResponse'][index]['id'].toString(),
                                       isSelected: snapshot.data['CategoryResponse'][index]['isSelected'],
                                     ),
                                   );

                                 },
                               );
                             }
                             else{
                               return Container();
                             }
                           }
                       ),
                     ),
                     itemlist.isEmpty ? _emptyCategories(context) : Expanded(
                       child: GridView.builder(
                         itemCount: itemlist.length,
                         padding: EdgeInsets.zero,
                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.87),
                         itemBuilder: (BuildContext context, int index) {
                           return Card(
                               elevation: 5.0,
                               color: Colors.white,
                               child: Column(
                                 children: [
                                   SizedBox(height: 10.0),
                                   Container(
                                       height: 80,
                                       width: 80,
                                       child: Image(image: CachedNetworkImageProvider(itemlist[index]["product_image"]), fit: BoxFit.cover)
                                   ),
                                   Padding(
                                     padding: EdgeInsets.only(left: 5.0, top: 8.0, right: 5.0),
                                     child: Align(
                                         alignment: Alignment.topLeft,
                                         child: Text(itemlist[index]['product_name'], maxLines: 2, style: const TextStyle(color: Colors.black, fontSize: 14.0))
                                     ),
                                   ),
                                   SizedBox(height: 2.0),
                                   Padding(
                                       padding: EdgeInsets.only(left: 7.0, top: 5.0, right: 7.0),
                                       child: Row(
                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                         children: [
                                           itemlist[index]['product_uom'].toString() == "null" ||  itemlist[index]['product_uom'].toString() == "" ? Text("") : Text(itemlist[index]['product_uom'].toString(), style: TextStyle(color: Colors.grey, fontSize: 14.0)),
                                           Container(
                                             width: 80,
                                             color: Theme.of(context).accentColor,
                                             padding: const EdgeInsets.all(4.0),
                                             child: Center(
                                               child: Text(
                                                 itemlist[index]['discount_percentage'].toString() + "%" + " OFF",
                                                 style: TextStyle(fontSize: 11,
                                                     color: Colors.white),
                                                 overflow: TextOverflow.clip,
                                                 softWrap: false,
                                               ),
                                             ),
                                           ),
                                         ],
                                       )
                                   ),
                                   Padding(
                                     padding: EdgeInsets.only(left: 7.0, top: 15.0, right: 5.0),
                                     child: Row(
                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                         children: <Widget>[
                                           Column(
                                             children: [
                                               Text("\u20B9 ${itemlist[index]['discount'].toString()}", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                               Text("\u20B9 ${itemlist[index]['mrp'].toString()}", style: TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontWeight: FontWeight.bold))
                                             ],
                                           ),
                                           itemlist[index]['quantity'].toString() == "0" ? GestureDetector(
                                             onTap: () async{
                                               SharedPreferences prefs = await SharedPreferences.getInstance();
                                               if (prefs.getInt('cart_count') == 0) {
                                                 prefs.setString('type', "grocery");
                                                 setState(() {
                                                   itemlist[index]['quantity'] = 1;
                                                 });
                                                 cartaction(itemlist[index]['id'].toString(), itemlist[index]['mrp'].toString(),
                                                     itemlist[index]['discount'].toString(), "1", [], "1");
                                               }
                                               else{
                                                 if(prefs.getString('type') == "restaurant"){
                                                   showConfirmDialog(
                                                       'Cancel',
                                                       'Ok',
                                                       'Remove Item',
                                                       'Please remove or purchase restaurant items from cart after that you can add grocery item',
                                                       index,
                                                       itemlist[index]['id'].toString(),
                                                       itemlist[index]['mrp'].toString(),
                                                       itemlist[index]['discount'].toString(),
                                                       (int.parse(itemlist[index]['quantity'].toString()) + 1).toString(),
                                                       []);
                                                 }
                                                 else{
                                                   prefs.setString('type', "grocery");
                                                   setState(() {
                                                     itemlist[index]['quantity'] = 1;
                                                   });
                                                   cartaction(itemlist[index]['id'].toString(), itemlist[index]['mrp'].toString(),
                                                       itemlist[index]['discount'].toString(), "1", [], "1");
                                                 }
                                               }

                                             },
                                             child: Container(
                                               height: 35,
                                               width: 85,
                                               decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(4.0),
                                                   border: Border.all(width: 1, color: Colors.green)
                                               ),
                                               child: Card(
                                                 elevation: 0.0,
                                                 child: Padding(
                                                   padding: const EdgeInsets.only(top: 3.0),
                                                   child: Text("add",
                                                       textAlign: TextAlign.center,
                                                       style: TextStyle(
                                                           color: Colors.green,
                                                           fontWeight: FontWeight.w400,
                                                           fontSize: 16)),
                                                 ),
                                               ),
                                             ),
                                           ) :
                                           Container(
                                             height: 35,
                                             width: 85,
                                             child: Row(
                                               children: [
                                                 GestureDetector(
                                                   onTap: (){
                                                     setState(() {
                                                       itemlist[index]['quantity'] = int.parse(itemlist[index]['quantity'].toString()) - 1;
                                                     });
                                                     cartaction(itemlist[index]['id'].toString(), itemlist[index]['mrp'].toString(),
                                                         itemlist[index]['discount'].toString(), itemlist[index]['quantity'].toString(), [], "0");
                                                   },
                                                   child: Container(
                                                     height: 25,
                                                     width: 25,
                                                     decoration: BoxDecoration(
                                                       border: Border.all(
                                                         color: Colors.green,
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
                                                         color: Colors.green,
                                                       ),
                                                     ),
                                                   ),
                                                 ),
                                                 SizedBox(
                                                   width: 12,
                                                 ),
                                                 Text(itemlist[index]['quantity'].toString(), style: TextStyle(color: Colors.green, fontSize: 16)),
                                                 SizedBox(
                                                   width: 12,
                                                 ),
                                                 GestureDetector(
                                                   onTap: (){
                                                     setState(() {
                                                       itemlist[index]['quantity'] = int.parse(itemlist[index]['quantity'].toString()) + 1;
                                                     });
                                                     cartaction(itemlist[index]['id'].toString(), itemlist[index]['mrp'].toString(),
                                                         itemlist[index]['discount'].toString(), itemlist[index]['quantity'].toString(), [], "0");
                                                   },
                                                   child: Container(
                                                     height: 25,
                                                     width: 25,
                                                     decoration: BoxDecoration(
                                                       border: Border.all(
                                                         color: Colors.green,
                                                         width: 2,
                                                       ),
                                                       borderRadius:
                                                       BorderRadius.circular(
                                                           25 / 2),
                                                     ),
                                                     child: Center(
                                                       child: Icon(
                                                         Icons.add,
                                                         size: 20,
                                                         color: Colors.green,
                                                       ),
                                                     ),
                                                   ),
                                                 ),
                                               ],
                                             ),
                                           )
                                         ]
                                     ),
                                   ),
                                 ],
                               )
                           );

                         },
                       ),
                     ),
                   ]
               )),
             ],
           ),
           Positioned(
               left: 0,
               right: 0,
               bottom: 0,
               child: showItemWidget()
           )
         ],
      ),
    );

  }

  Widget showItemWidget() {
    final mydata = Provider.of<ItemCountProvider>(context);
    //mydata.getItemData(_userId, "41");
    if (mydata.counter != 0) {
      return Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/checkout-new');
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

  Widget _cartWithoutBadge() {
    return IconButton(
      icon: const Icon(Icons.shopping_basket),
      onPressed: () {
        Navigator.pushNamed(context, '/checkout-new');
      },
    );
  }

  Future _grocerySubCategory(String userId, String categoryid) async{
    print("subcategory calling");
    var response = await http.post(
        new Uri.https(BASE_URL, API_PATH + "/grocery-subcategory-list"),
        body: {
          "user_id": userId,
          "store_id" : "35",
          "category_id" : categoryid
        },
        headers: {"Accept": "application/json", "authorization": basicAuth});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print("mysub data");
      print(data);
      List result = data['CategoryResponse'];
      result.forEach((element) {
        if(result.indexOf(element)==0){
          element['isSelected'] = false;
          //_grocerySubCategoryItem(element['id'].toString());
        }else{
          element['isSelected'] = false;
        }

      });
      return data;
    } else {
      print(response.body);
      print("mysub exception");
      print("Exception");
      throw Exception('Something went wrong');
    }
  }

  Future _grocerySubCategoryItem(String subcategoryid) async{
    print("subcategory item calling");
    itemlist.clear();
    var response = await http.post(
        new Uri.https(BASE_URL, API_PATH + "/products"),
        body: {
          "user_id" : _userId,
          "restaurant_id" : "35",
          "category_id": subcategoryid,
          "type" : ""
        },
        headers: {"Accept": "application/json", "authorization": basicAuth});
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['Response'];
      if(data.isEmpty){
        setState(() {
           itemlist = [];
        });
      }
      else{
        setState(() {
          itemlist.addAll(data);
        });
      }
    } else {
      print("Error");
      throw Exception('Something went wrong');
    }
  }

  showConfirmDialog(cancel, done, title, content, index, productid, productprice,
      discount, qty, addextraitem) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
        cartaction(productid, productprice, discount, qty, addextraitem, "0");
        Navigator.of(context).pop();
        prefs.setString('type', "grocery");
        setState(() {
          itemlist[index]['quantity'] = int.parse(itemlist[index]['quantity'].toString()) + 1;
        });
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

  showCategoriesSheet(){
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
            height: 450,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0))),
            child: FutureBuilder(
                future: _myproductCategories,
                builder: (context, snapshot){
                   if(snapshot.hasData){
                     return Padding(
                         padding: EdgeInsets.all(10),
                         child: Container(
                             height: 450,
                             padding: EdgeInsets.all(5.0),
                             child: GridView.builder(
                               itemCount: snapshot.data['CategoryResponse'].length,
                               padding: EdgeInsets.zero,
                               primary: false,
                               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                 crossAxisCount: 3,
                                 crossAxisSpacing: 2.0,
                                 mainAxisSpacing: 2.0,
                               ),
                               itemBuilder: (BuildContext context, int index){
                                 return GestureDetector(
                                   onTap: (){
                                     Navigator.pushReplacementNamed(
                                       context,
                                       '/grocery-item',
                                       arguments: <String, String>{
                                         'userid' : _userId,
                                         'categoryname' : snapshot.data['CategoryResponse'][index]['name'].toString(),
                                         'categoryid' : snapshot.data['CategoryResponse'][index]['id'].toString()
                                       },
                                     );
                                   },
                                   child: Column(
                                     children: [
                                       Container(
                                         height: 90,
                                         width: 120,
                                         child: Card(
                                           elevation : 2.0,
                                           shape: RoundedRectangleBorder(
                                             side: BorderSide(color: Colors.grey, width: 0.5),
                                             borderRadius: BorderRadius.circular(5),
                                           ),
                                           child: Image.network(snapshot.data['CategoryResponse'][index]['image'], fit: BoxFit.fill),
                                         ),
                                       ),
                                       SizedBox(height: 4.0),
                                       Text(snapshot.data['CategoryResponse'][index]['name'], textAlign: TextAlign.center)
                                     ],
                                   ),
                                 );
                               },
                             )
                         )
                     );
                   }
                   else{
                     return Container();
                   }
                }
            )
        )
    );
  }

  Future _groceryCategory() async {
    try {
      var response = await http.post(new Uri.https(BASE_URL, API_PATH + "/grocery-category-list"),
          body: {"user_id": _userId, "store_id" : "35"},
          headers: {"Accept": "application/json", "authorization": basicAuth});
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data;
      }
    } on Exception catch(e) {
      print(e.toString());
    } catch(e) {
      print(e.toString());
    }
  }

   Future _mycategoriesproducts(categoryid) async {
     try {
       var response = await http.post(new Uri.https(BASE_URL, API_PATH + "/products"),
           body: {
              "user_id": _userId,
              "category_id" : categoryid,
              "restaurant_id" : "35",
              "type" :"category"
           },
           headers: {"Accept": "application/json", "authorization": basicAuth});
       if (response.statusCode == 200) {
         print(response.body);
         var data = json.decode(response.body)['Response'];
         if(data.isEmpty){
           setState(() {
             itemlist = [];
           });
         }
         else{
           setState(() {
             itemlist.addAll(data);
           });
         }
         //return data;
       }
     } on Exception catch(e) {
       print(e.toString());
     } catch(e) {
       print(e.toString());
     }
  }
}



Widget _emptyCategories(context) {
  return Padding(
    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.14),
    child: Center(
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
    ),
  );
}


class CategoryItem extends StatelessWidget {
  final String title;
  final String image;
  final String id;
  final bool isSelected;
  CategoryItem({@required this.title, @required this.image, @required this.id, @required this.isSelected});

  Widget build(BuildContext context) {

    return Container(
      width: 100,
      height: 100,
      margin: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL, horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Container(
            margin: EdgeInsets.only(right: 8, left: 8, top: 0, bottom: 8),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.grey,
              image: DecorationImage(
                  image: image != null
                      ? CachedNetworkImageProvider(
                      image)
                      : AssetImage(
                      'assets/images/no_image.png'),
                  fit: BoxFit.cover
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: titilliumSemiBold.copyWith(
                fontSize: 14,
                color: isSelected ? Colors.black : Colors.grey[800],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w400
            )),
          ),
        ]),
      ),
    );
  }


}
