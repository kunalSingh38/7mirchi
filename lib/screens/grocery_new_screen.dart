import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sodhis_app/constants.dart';
import 'package:sodhis_app/utilities/basic_auth.dart';

class GroceryNewScreen extends StatefulWidget {
  const GroceryNewScreen({Key key}) : super(key: key);

  @override
  _GroceryNewScreenState createState() => _GroceryNewScreenState();
}

class _GroceryNewScreenState extends State<GroceryNewScreen> {

  var _userId;
  Future _mydashboardBanner;
  Future<dynamic> _myproductCategories;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUser();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id').toString();

      //_mobile_number = prefs.getString('mobile_number');
      //_email_address = prefs.getString('email_address');
      //_address = prefs.getString('address');
      _mydashboardBanner = _dashboardBanners();
      _myproductCategories = _groceryCategory();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder(
            future: _mydashboardBanner,
            builder: (context, snapshot){
              if(snapshot.hasData){
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      child: Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: TextField(
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.search_outlined),
                                  border: InputBorder.none,
                                  hintText: "Search for atta, dal, coke and more"
                              ),
                            ),
                          )
                      ),
                    ),
                    FutureBuilder(
                        future: _myproductCategories,
                        builder: (context, snapshot){
                           if(snapshot.hasData){
                              return Padding(
                                  padding: EdgeInsets.all(10),
                                  child: snapshot.data['CategoryResponse'].length > 4 ? Container(
                                      height: 300,
                                      padding: EdgeInsets.all(5.0),
                                      child: GridView.builder(
                                        itemCount: snapshot.data['CategoryResponse'].length,
                                        padding: EdgeInsets.zero,
                                        primary: false,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4,
                                            crossAxisSpacing: 2.0,
                                            mainAxisSpacing: 2.0,
                                            childAspectRatio: 0.70
                                        ),
                                        itemBuilder: (BuildContext context, int index){
                                          return GestureDetector(
                                             onTap: (){
                                               Navigator.pushNamed(
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
                                  ) : Container(
                                      height: 150,
                                      padding: EdgeInsets.all(5.0),
                                      child: GridView.builder(
                                        itemCount: snapshot.data['CategoryResponse'].length,
                                        padding: EdgeInsets.zero,
                                        primary: false,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4,
                                            crossAxisSpacing: 2.0,
                                            mainAxisSpacing: 2.0,
                                            childAspectRatio: 0.70
                                        ),
                                        itemBuilder: (BuildContext context, int index){
                                          return GestureDetector(
                                             onTap: (){
                                               Navigator.pushNamed(
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
                                                       child: Image(image: CachedNetworkImageProvider(snapshot.data['CategoryResponse'][index]['image']), fit: BoxFit.cover)
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
                    ),
                    /*Padding(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Container(
                        height: 50,
                        child: Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("See more categories", style: TextStyle(color: Colors.black, fontSize: 18)),
                                SizedBox(width: 5.0),
                                Icon(Icons.apps_outlined, color: Colors.black, size: 24)
                              ],
                            )
                        ),
                      ),
                    ),*/
                    /*Padding(
                     padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                     child: Container(
                       height: 120,
                       child: Card(
                           elevation: 4.0,
                           color: Colors.green.shade50,
                           shape: RoundedRectangleBorder(
                             side: BorderSide(color: Colors.green.shade50, width: 1),
                             borderRadius: BorderRadius.circular(10),
                           ),
                           child: Padding(
                             padding: const EdgeInsets.all(18.0),
                             child: Column(
                               mainAxisAlignment: MainAxisAlignment.start,
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text("flat \u20B9 75 off your first order!", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                                 SizedBox(height: 5.0),
                                 Text("Order above \u20B9 300", style: TextStyle(color: Colors.grey, fontSize: 18)),
                                 SizedBox(height: 5.0),
                                 Row(
                                   children: [
                                     Text("Use Code:", style: TextStyle(color: Colors.grey.shade700, fontSize: 18)),
                                     SizedBox(width: 5.0),
                                     Text("BLINK75", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500))
                                   ],
                                 )
                               ],
                             ),
                           )
                       ),
                     ),
                   ),*/
                    Padding(
                      padding: EdgeInsets.all(18),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(snapshot.data['SliderResponse'][0]['slider_name'].toString(),
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)
                          )
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: CarouselSlider.builder(
                        itemCount: snapshot.data['SliderResponse'][0]['slider_options'].length,
                        itemBuilder: (BuildContext context, int itemIndex){
                          return Container(
                            margin: EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              image: DecorationImage(
                                image: NetworkImage(snapshot.data['SliderResponse'][0]['slider_options'][itemIndex]['soimage']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                        options: CarouselOptions(
                          height: 180.0,
                          enlargeCenterPage: true,
                          autoPlay: true,
                          aspectRatio: 16 / 9,
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enableInfiniteScroll: true,
                          autoPlayAnimationDuration: Duration(milliseconds: 400),
                          viewportFraction: 0.9,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(18),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(snapshot.data['SliderResponse'][1]['slider_name'].toString(),
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)
                          )
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: CarouselSlider.builder(
                        itemCount: snapshot.data['SliderResponse'][1]['slider_options'].length,
                        itemBuilder: (BuildContext context, int itemIndex){
                          return Container(
                            margin: EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              image: DecorationImage(
                                image: NetworkImage(snapshot.data['SliderResponse'][1]['slider_options'][itemIndex]['soimage']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                        options: CarouselOptions(
                          height: 180.0,
                          enlargeCenterPage: true,
                          autoPlay: true,
                          aspectRatio: 16 / 9,
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enableInfiniteScroll: true,
                          autoPlayAnimationDuration: Duration(milliseconds: 400),
                          viewportFraction: 0.9,
                        ),
                      ),
                    ),
                  ],
                );
              }
              else{
                return Center(
                  child: Container(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.red),
                  ),
                );
              }
            }
        ),
      ),
    );
  }

  Future _dashboardBanners() async {
    var response = await http.post(
        new Uri.https(BASE_URL, API_PATH + "/sliderfinder"),
        body: {"user_id": _userId, "store_id" : "35"},
        headers: {"Accept": "application/json", "authorization": basicAuth});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }

  Future _groceryCategory() async {
    var response = await http.post(
        new Uri.https(BASE_URL, API_PATH + "/grocery-category-list"),
        body: {"user_id": _userId, "store_id" : "35"},
        headers: {"Accept": "application/json", "authorization": basicAuth});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Something went wrong');
    }
  }
}
