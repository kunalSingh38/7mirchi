import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sodhis_app/constants.dart';
import 'package:sodhis_app/utilities/basic_auth.dart';

class ApplyCouponScreen extends StatefulWidget {
  final Object argument;
  const ApplyCouponScreen({Key key, this.argument}) : super(key: key);

  @override
  _ApplyCouponScreenState createState() => _ApplyCouponScreenState();
}

class _ApplyCouponScreenState extends State<ApplyCouponScreen> {

  String _userid;
  String _payableamount;
  String _restaurantid;

  String couponcode;

  final TextEditingController couponcodeController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    var encodedJson = json.encode(widget.argument);
    var data = json.decode(encodedJson);
    _userid = data['userid'];
    _payableamount = data['payable_amount'];
    _restaurantid = data['restaurant_id'];

    print(_userid.toString());
    print(_payableamount.toString());
    print(_restaurantid.toString());

   /* if(int.parse(walletBalance) >= int.parse(payableAmount)){
      setState(() {
        selectedIndex = 0;
        _walletVisibility = true;
      });
    }
    else{
      setState(() {
        selectedIndex = 1;
        _onlineVisibility = true;
      });
    }*/

  }

  Future _applycouponcode(String couponcode, String userid, String totalprice, String restaurantid) async{
    var response = await http.post(
      new Uri.https(BASE_URL, API_PATH + "/coupon-apply"),
      body: {
        "coupon_code": couponcode,
        "total": totalprice,
        "user_id": userid,
        "restaurant_id" : restaurantid,
      },
      headers: {
        "Accept": "application/json",
        "authorization": basicAuth,
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var result = data['CouponResponse'];
      if(data['ErrorMessage'].toString() == "success"){
        setState(() {
          _loading = false;
        });
        if(data['CouponResponse'].containsKey('msg')){
          if(data['CouponResponse']['msg'].toString() == "You have already used this coupon"){
            Fluttertoast.showToast(msg: data['CouponResponse']['msg'].toString());
          }
        }
        else{
          print(data['CouponResponse']);
          couponcode = "";
          Navigator.pushReplacementNamed(context, '/checkout-new');
        }
      }
    } else {
      throw Exception('Something went wrong');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: Text("Apply Coupon", style: TextStyle(color: Colors.white)),
         leading: InkWell(
               onTap: () => Navigator.pop(context),
               child: Icon(Icons.arrow_back, color: Colors.white, size: 24.0),
            ),
       ),
       body: ModalProgressHUD(
         inAsyncCall: _loading,
         child: Card(
           elevation: 4.0,
           color: Colors.white,
           shape: RoundedRectangleBorder(
             side: BorderSide(color: Colors.white, width: 1),
             borderRadius: BorderRadius.circular(10),
           ),
           child: Padding(
             padding: const EdgeInsets.only(top: 40.0, left: 15.0, right: 15.0, bottom: 40.0),
             child: Container(
               height: 50,
               width: double.infinity,
               decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(16.0),
                   border: Border.all(color: Colors.grey.shade300, width: 1)
               ),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Padding(
                     padding: const EdgeInsets.only(left: 8.0),
                     child: Container(
                       height: 45,
                       width: MediaQuery.of(context).size.width * 0.65,
                       alignment: Alignment.center,
                       child: TextField(
                         decoration: new InputDecoration.collapsed(
                             hintText: 'Enter Coupon Code'
                         ),
                         controller: couponcodeController,
                         onChanged: (value){
                            couponcode = value.toString();
                         },
                       ),
                     ),
                   ),
                   GestureDetector(
                     onTap: (){
                       if(couponcode.toString() == "" || couponcode.toString() == "null"){
                         Fluttertoast.showToast(msg: "Please enter coupon code");
                       }
                       else{
                         _applycouponcode(couponcodeController.text.toString(), _userid, _payableamount, _restaurantid);
                       }

                     },
                     child: Container(
                       height: 45,
                       width: MediaQuery.of(context).size.width * 0.20,
                       alignment: Alignment.center,
                       child: Text("APPLY", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                     ),
                   )
                 ],
               ),
             ),
           ),
         ),
       ),
    );
  }


}
