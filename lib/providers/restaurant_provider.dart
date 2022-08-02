import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
class RestaurantProvider with ChangeNotifier{
    String totalamount = "0";

    void getamout(){
         totalamount = (int.parse(totalamount)+ 100).toString();
         notifyListeners();
    }

}