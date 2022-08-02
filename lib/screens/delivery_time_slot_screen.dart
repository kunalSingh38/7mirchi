import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:sodhis_app/Animation/animations.dart';

class DeliveryTimeSlotScreen extends StatefulWidget {
  final Object argument;
  const DeliveryTimeSlotScreen({Key key, this.argument}) : super(key: key);

  @override
  _DeliveryTimeSlotScreenState createState() => _DeliveryTimeSlotScreenState();
}

class _DeliveryTimeSlotScreenState extends State<DeliveryTimeSlotScreen> {

  bool _option1Visibility = true;
  bool _option2Visibility = false;
  bool _option1 = false;
  bool _option2 = false;
  int selectedIndex = 0;
  String deliveryday = "Tomorrow";

  List selecttiming = [];

  String todayinittime;

  bool checktoday = false;

  // List of items in our dropdown menu
  //var tomorrowtiming = [];
  //var todaytiming = [];

  String userid;
  String subtotal;
  String walletblnc;
  String couponcode;
  String totalpay;
  String instruction;
  String discount;
  String address;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);

    setState(() {
      userid = data['userid'].toString();
      subtotal = data['subtotal'].toString();
      walletblnc = data['wallet_balance'].toString();
      couponcode = data['coupon_code'].toString();
      totalpay = data['payable_amount'].toString();
      discount = data['total_discount'].toString();
      instruction = data['instructions'].toString();
      address = data['address'].toString();
    });

    todattimeslot();
    tomorrowtimeslot();

    setState(() {
      todayinittime = selecttiming[0]['time'].toString();
    });
  }

  void todattimeslot(){
    var startTime = TimeOfDay(hour: DateTime.now().hour.toInt()+1, minute: 0);
    int k = DateTime.now().hour.toInt()+1;
    while(k < 22) {
      var time = DateFormat("hh:mm a").format(DateTime(startTime.hour, startTime.minute).add(Duration(hours: k)));
      var time1 = DateFormat("hh:mm a").format(DateTime(startTime.hour, startTime.minute).add(Duration(hours: k + 1)));
      setState(() {
        selecttiming.add({"today": true,"time" : time + "-" + time1, "selected" : false});
        deliveryday = "Today";
        checktoday = true;
      });
      k = k + 1;
    }

  }

  void tomorrowtimeslot(){
    var startTime = TimeOfDay(hour: 7, minute: 0);
    int k = 7;
    while (k < 22) {
      var time = DateFormat("hh:mm a").format(DateTime(startTime.hour, startTime.minute).add(Duration(hours: k)));
      var time1 = DateFormat("hh:mm a").format(DateTime(startTime.hour, startTime.minute).add(Duration(hours: k + 1)));
      setState(() {
        selecttiming.add({"today": false,"time" : time + "-" + time1, "selected" : false});
      });
      k = k + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: Text("Delivery Option", style: TextStyle(color: Colors.white)),
         centerTitle: true,
         backgroundColor: Colors.red,
       ),
       backgroundColor: Colors.white,
       body: ListView(
         padding: EdgeInsets.zero,
         children: [
            Column(
              children: [
                 Card(
                   color: Colors.white,
                   child: Padding(
                       padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Row(
                              children: [
                                 Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
                                 SizedBox(width: 2),
                                 Expanded(
                                     child: Text("Deliver to:")
                                 ),
                                 /*GestureDetector(
                                   onTap: (){},
                                   child: Container(
                                      height: 25,
                                      width: 80,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6.0),
                                        border: Border.all(color: Colors.green, width: 1)
                                      ),
                                     child: Text("Change", style: TextStyle(color: Colors.green)),
                                   ),
                                 )*/
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                 Text("Home", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                                 SizedBox(width: 5),
                                 Text("(Default)", style: TextStyle(color: Colors.black, fontSize: 12))
                              ],
                            ),
                            SizedBox(height: 2),
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.65,
                                child: address == "" || address == null ? Text("") : Text(address, style: TextStyle(color: Colors.black, fontSize: 12)))
                         ],
                       ),
                   ),
                 ),
                 SizedBox(height: 15),
                 /*Card(
                   elevation: 4.0,
                   color: Colors.grey[300],
                   child: Padding(
                     padding: EdgeInsets.symmetric(vertical: 17, horizontal: 12),
                     child: Column(
                       children: [
                         Row(
                           children: [
                             CustomRadioButton(0),
                             SizedBox(width: 7),
                             Expanded(child: Text("Default Delivery Option", style: TextStyle(color: Colors.black, fontSize: 16))),
                             SvgPicture.asset('assets/images/bike.svg'),
                             SizedBox(width: 3),
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 //Text("1 Shipment", style: TextStyle(color: Colors.black)),
                                 Row(
                                   children: [
                                     Text("Delivery charges:"),
                                     Text("FREE", style: TextStyle(color: Colors.green))
                                   ],
                                 )
                               ],
                             )
                           ],
                         ),
                         SizedBox(height: 20),
                         Container(
                           height: 55,
                           decoration: BoxDecoration(
                               color: Colors.green,
                               borderRadius: BorderRadius.circular(8.0)
                           ),
                           alignment: Alignment.center,
                           child: Text("PROCEED TO PAY", style: TextStyle(color: Colors.white, fontSize: 16)),
                         )
                       ],
                     ),
                   ),
                 ),*/
                 Card(
                  elevation: 4.0,
                  color: Colors.grey[50],
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 17, horizontal: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            //CustomRadioButton(1),
                            //SizedBox(width: 7),
                            Expanded(child: Text("Delivery option", style: TextStyle(color: Colors.black, fontSize: 16))),
                            SvgPicture.asset('assets/images/bike.svg'),
                            SizedBox(width: 3),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Text("2 Shipment", style: TextStyle(color: Colors.black)),
                                Row(
                                  children: [
                                    Text("Delivery charges:"),
                                    Text("FREE", style: TextStyle(color: Colors.green))
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(thickness: 2, color: Colors.white),
                        SizedBox(height: 5),
                        InkWell(
                          onTap: (){
                            _timeslotDialogBox();
                          },
                          child: Container(
                             height: 40,
                             width: double.infinity,
                             decoration: BoxDecoration(
                               color: Colors.white,
                               border: Border.all(width: 1, color: Colors.grey.shade700),
                               borderRadius: BorderRadius.circular(4.0)
                             ),
                             child: Padding(
                               padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                               child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                     Text("$deliveryday  $todayinittime", style: TextStyle(color: Colors.black, fontSize: 16)),
                                     Icon(Icons.keyboard_arrow_down, size: 24, color: Colors.black)
                                  ],
                               ),
                             ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Row(
                            children: [
                              Text("Delivery charges:"),
                              Text("FREE", style: TextStyle(color: Colors.green))
                            ],
                          ),
                        ),
                        /*SizedBox(height: 20),*/
                        /*Divider(height: 1, color: Colors.white, thickness: 2),*/
                        /*SizedBox(height: 20),*/
                        /*Container(
                          height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 1, color: Colors.grey.shade700),
                              borderRadius: BorderRadius.circular(4.0)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                            child: DropdownButton(
                              value: tomorrowinittime,
                              icon: const Icon(Icons.keyboard_arrow_down, size: 30, color: Colors.black),
                              onChanged: (value){
                                 setState(() {
                                    tomorrowinittime = value;
                                 });
                              },
                              isExpanded: true,
                              underline: SizedBox(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18
                              ),
                              items: tomorrowtiming.map((items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items),
                                );
                              }).toList(),
                            ),
                          ),
                        ),*/
                        /*SizedBox(height: 10),*/
                        /*Align(
                          alignment: Alignment.topLeft,
                          child: Row(
                            children: [
                              Text("Delivery charges:"),
                              Text("FREE", style: TextStyle(color: Colors.green))
                            ],
                          ),
                        ),*/
                        SizedBox(height: 20),
                        InkWell(
                          onTap: (){
                            if(deliveryday == "Today"){
                              final DateTime now = DateTime.now();
                              final DateFormat formatter = DateFormat('yyyy-MM-dd');
                              final String formatteddate = formatter.format(now);
                              Navigator.pushNamed(
                                context,
                                '/payment_options',
                                arguments: <String, String>{
                                  'userid': userid,
                                  'subtotal': subtotal,
                                  'wallet_balance': walletblnc,
                                  'coupon_code': couponcode,
                                  'payable_amount': totalpay,
                                  'total_discount': discount,
                                  'instructions': instruction,
                                  'time' : todayinittime.toString(),
                                  "date" : formatteddate
                                },
                              );
                            }
                            else{
                              final DateTime now = DateTime.now();
                              var newDate = new DateTime(now.year, now.month, now.day+1);
                              final DateFormat formatter = DateFormat('yyyy-MM-dd');
                              final String formatteddate = formatter.format(newDate);
                              Navigator.pushNamed(
                                context,
                                '/payment_options',
                                arguments: <String, String>{
                                  'userid': userid,
                                  'subtotal': subtotal,
                                  'wallet_balance': walletblnc,
                                  'coupon_code': couponcode,
                                  'payable_amount': totalpay,
                                  'total_discount': discount,
                                  'instructions': instruction,
                                  'time' : todayinittime.toString(),
                                  "date" : formatteddate
                                },
                              );
                            }

                          },
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8.0)
                            ),
                            alignment: Alignment.center,
                            child: Text("PROCEED TO PAY", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            )
         ],
       ),
    );
  }

  void changeIndex(int index){
    if(index == 0){
      setState(() {
        selectedIndex = index;
        _option1 = true;
        _option1Visibility = true;
        _option2 = false;
        _option2Visibility = false;
      });
    }
    else{
      setState(() {
        selectedIndex = index;
        _option1 = false;
        _option1Visibility = false;
        _option2 = true;
        _option2Visibility = true;
      });
    }
  }

  Widget CustomRadioButton(int index) {
    if(selectedIndex == index) {
      return InkWell(
        onTap: () => changeIndex(index),
        child: Container(
          height: 24.0,
          width: 24.0,
          child: Icon(Icons.check_circle, size: 24.0, color: Colors.green),
        ),
      );
    }
    else{
      return InkWell(
        onTap: () => changeIndex(index),
        child: Container(
          height: 20.0,
          width: 20.0,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.grey, width: 1)
          ),
        ),
      );
    }
  }

  _timeslotDialogBox() {
    return showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierDismissible: true,
      transitionDuration: Duration(milliseconds: 300),
      transitionBuilder: (context, _animation, _secondaryAnimation, _child) {
        return Animations.fromLeft(_animation, _secondaryAnimation, _child);
      },
      pageBuilder: (_animation, _secondaryAnimation, _child) {
        return _timelistDialog(context);
      },
    );
  }

  Widget _timelistDialog(context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildChild(context),
    );
  }

  _buildChild(BuildContext context) => Container(
    height: MediaQuery.of(context).size.height * 0.60,
    decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(10))),
    child: Stack(
       children: [
         Positioned(
             right: 10,
             child: Container(
               height: 20,
               color: Colors.red,
             )
         ),
         SingleChildScrollView(
           child: Column(
             children: [
               checktoday ? Container(
                 height: MediaQuery.of(context).size.height * 0.05,
                 width: double.infinity,
                 decoration: BoxDecoration(
                     color: Colors.grey.shade400,
                     borderRadius: BorderRadius.only(
                       topRight: Radius.circular(10.0),
                       topLeft: Radius.circular(10.0),
                     )
                 ),
                 alignment: Alignment.centerLeft,
                 child: Padding(
                   padding: EdgeInsets.only(left: 15),
                   child: Text("Today", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)),
                 ),
               ) : SizedBox(),
               Column(
                 children: selecttiming.map((e) {
                   if(e['today'] == true){
                     return _catlist(e);
                   }else {
                     return SizedBox();
                   }
                 }).toList(),

               ),
               Container(
                 height: MediaQuery.of(context).size.height * 0.05,
                 width: double.infinity,
                 color: Colors.grey.shade400,
                 alignment: Alignment.centerLeft,
                 child: Padding(
                   padding: EdgeInsets.only(left: 15),
                   child: Text("Tomorrow", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)),

                 ),
               ),
               Column(
                 children: selecttiming.map((e) {
                   if(e['today'] == false){
                     return _catlist(e);
                   }else {
                     return SizedBox();
                   }
                 }).toList(),
               ),
             ],
           ),
         )
       ],
    ),
  );

  Widget _catlist(Map e) {

    return GestureDetector(
      onTap: () {
        selecttiming.forEach((element) {
           setState(() {
              element['selected'] = false;
           });

        });
        setState(() {
          e['selected'] = true;
          todayinittime= e['time'].toString();
          if(e['today']){
            setState(() {
               deliveryday = "Today";
            });
          }
          else{
            setState(() {
              deliveryday = "Tomorrow";
            });
          }
        });
        Navigator.pop(context);
      },
      child: Container(
        height: 45.0,
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            children: [
              e['selected'] ? Icon(Icons.watch_later_outlined, size: 18.0, color: Colors.redAccent) : Icon(Icons.watch_later_outlined, size: 18.0, color: Colors.black),
              SizedBox(width: 10.0),
              Expanded(child:e['selected'] ? Text(e['time'].toString(), style: TextStyle(color: Colors.redAccent, fontSize: 14.0)) : Text(e['time'].toString(), style: TextStyle(color: Colors.black, fontSize: 14.0))),
              e['selected'] ? Icon(Icons.check, size: 18.0, color: Colors.green) : Container()
            ],
          ),
        ),
      ),
    );
  }
}
