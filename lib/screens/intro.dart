import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sodhis_app/screens/login.dart';

class IntroScreen extends StatefulWidget {
  IntroScreen({Key key}) : super(key: key);

  @override
  IntroScreenState createState() => new IntroScreenState();
}

// ------------------ Default config ------------------
class IntroScreenState extends State<IntroScreen> {
 List<Slide> slides = new List();

 @override
 void initState() {
   super.initState();

   slides.add(
     new Slide(
       title: "Best Supermarket",
       description: "Best Shopping Experience in Delhi NCR. Easy reach, Helpful staff, Quality Pruducts and Best Prices. 7mirchi is the Best Super Mart !!!",
       pathImage: "assets/images/intro_1.png",
       backgroundColor: Color(0xfff08521),
     ),
   );
   slides.add(
     new Slide(
       title: "Easy Shopping",
       description: "With Most Exhaustive Collection of your Daily Needs 7mirchi is One Stop Shop for every family's demands. When you have 7mirchi : Why go anywhere else !!!",
       pathImage: "assets/images/intro_2.png",
       backgroundColor: Color(0xff392C61),
     ),
   );
   slides.add(
     new Slide(
       title: "Save Money",
       description:"Save Money on every product. Shop more to Save More. 7mirchi ... Why Pay More !!!",
       pathImage: "assets/images/intro_3.png",
       backgroundColor: Color(0xffef5350),
     ),
   );
 }

 void onDonePress() {
   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
 }

 void onSkipPress() {
   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
 }

 @override
 Widget build(BuildContext context) {
   return new IntroSlider(
     slides: this.slides,
     onDonePress: this.onDonePress,
     onSkipPress: this.onSkipPress,
   );
 }
}