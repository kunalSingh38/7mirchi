import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_wrapper.dart';
import 'package:responsive_framework/utils/scroll_behavior.dart';
import 'package:sodhis_app/providers/itemcount_provider.dart';
import 'package:sodhis_app/screens/apply_coupon_screen.dart';
import 'package:sodhis_app/screens/delivery_time_slot_screen.dart';
import 'package:sodhis_app/screens/grocery_all_category.dart';
import 'package:sodhis_app/screens/grocery_new_screen.dart';
import 'package:sodhis_app/screens/grocery_screen.dart';
import 'package:sodhis_app/screens/intro.dart';

import 'package:sodhis_app/screens/login.dart';
import 'package:sodhis_app/screens/forgot_pin.dart';
import 'package:sodhis_app/screens/multislider_home.dart';
import 'package:sodhis_app/screens/payment_options_screen.dart';
import 'package:sodhis_app/screens/rechare_successful.dart';
import 'package:sodhis_app/screens/signup.dart';
import 'package:sodhis_app/screens/otp_signup.dart';
import 'package:sodhis_app/screens/otp_forgotpin.dart';
import 'package:sodhis_app/screens/create_pin.dart';
import 'package:sodhis_app/screens/reset_pin.dart';
import 'package:sodhis_app/screens/dashboard.dart';
import 'package:sodhis_app/screens/feedback.dart';
import 'package:sodhis_app/screens/notifications.dart';
import 'package:sodhis_app/screens/change_pin.dart';
import 'package:sodhis_app/screens/my_profile.dart';
import 'package:sodhis_app/screens/addnewaddress.dart';
import 'package:sodhis_app/screens/edit_profile.dart';
import 'package:sodhis_app/screens/products.dart';
import 'package:sodhis_app/screens/order_history.dart';
import 'package:sodhis_app/screens/product_details.dart';
import 'package:sodhis_app/screens/cart.dart';
import 'package:sodhis_app/screens/checkout.dart';
import 'package:sodhis_app/screens/checkout_new.dart';
import 'package:sodhis_app/screens/billing_history.dart';
import 'package:sodhis_app/screens/recharge_history.dart';
import 'package:sodhis_app/screens/add_address.dart';
import 'package:sodhis_app/screens/add_address_home.dart';
import 'package:sodhis_app/screens/change_address.dart';
import 'package:sodhis_app/screens/order_complete.dart';
import 'package:sodhis_app/screens/order_failed.dart';
import 'package:sodhis_app/screens/my_orders.dart';
import 'package:sodhis_app/screens/order_details.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sodhis_app/screens/wallet.dart';
import 'services/cart_badge.dart';
import 'services/cart.dart';
import 'services/shopping_list.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loggedIn = false;
  var _isLoggedOne;

  void initState() {
    super.initState();
    _checkLoggedIn();
  }

  MaterialColor createMaterialColor(Color color) {
    //commit now
    List strengths = <double>[.05];
    Map swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }

  _checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _isLoggedIn = prefs.getBool('logged_in');
    _isLoggedOne = prefs.getBool('logged_one');
    if (_isLoggedIn == true) {
      setState(() {
        _loggedIn = _isLoggedIn;
      });
    }
    else{
      setState(() {
        _loggedIn = false;


      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartBadge>(
          create: (BuildContext context) {
            return CartBadge();
          },
        ),
        ChangeNotifierProvider<Cart>(
          create: (BuildContext context) {
            return Cart();
          },
        ),
        ChangeNotifierProvider<ShoppingListProvider>(
          create: (BuildContext context) {
            return ShoppingListProvider();
          },
        ),
        ChangeNotifierProvider<ItemCountProvider>(
          create: (BuildContext context) {
            return ItemCountProvider();
          },
        ),
      ],
      child: MaterialApp(
        title: '7Mirchi',
        theme: ThemeData(
          primarySwatch: createMaterialColor(Color(0xFFc62714)),
        ),
        builder: (context, widget) => ResponsiveWrapper.builder(
            BouncingScrollWrapper.builder(context, widget),
            maxWidth: 800,
            minWidth: 450,
            defaultScale: true,
            breakpoints: [
              ResponsiveBreakpoint.resize(450, name: MOBILE),
              // ResponsiveBreakpoint.autoScale(450, name: TABLET),
              // ResponsiveBreakpoint.resize(450, name: DESKTOP),
            ],
        background: Container(color: Color(0xFFF5F5F5))),
        debugShowCheckedModeBanner: false,
        // routes: {
        //   '/login': (context) => LoginPage(),
        //   '/signup': (context) => SignupPage(),
        // },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return PageTransition(
                child: LoginPage(),
                type: null,
                settings: settings,
              );
              break;
            case '/signup':
              return PageTransition(
                child: SignupPage(),
                type: null,
                settings: settings,
              );
              break;
            case '/otp-signup':
              var obj = settings.arguments;
              return PageTransition(
                child: OtpSignup(argument: obj),
                type: null,
                settings: settings,
              );
              break;
            case '/otp-forgotpin':
              var obj = settings.arguments;
              return PageTransition(
                child: OtpForgotpin(argument: obj),
                type: null,
                settings: settings,
              );
              break;
            case '/create-pin':
              var obj = settings.arguments;
              return PageTransition(
                child: CreatePin(arg: obj),
                type: null,
                settings: settings,
              );
              break;
            case '/reset-pin':
              var obj = settings.arguments;
              return PageTransition(
                child: ResetPin(arg: obj),
                type: null,
                settings: settings,
              );
              break;
            case '/forgot-pin':
              return PageTransition(
                child: ForgotPinPage(),
                type: null,
                settings: settings,
              );
              break;
            case '/dashboard':
              return PageTransition(
                child: DashboardPage(),
                type: null,
                settings: settings,
              );
              break;
            case '/feedback':
              return PageTransition(
                child: FeedbackPage(),
                type: null,
                settings: settings,
              );
              break;
            /*case '/scan':
              return PageTransition(
                child: ScanPage(),
                type: PageTransitionType.rightToLeftWithFade,
                settings: settings,
              );
              break;
            case '/store':
              return PageTransition(
                child: StorePage(),
                type: PageTransitionType.rightToLeftWithFade,
                settings: settings,
              );
              break;
            case '/best-price':
              var obj = settings.arguments;
              return PageTransition(
                child: BestPricePage(argument: obj),
                type: PageTransitionType.rightToLeftWithFade,
                settings: settings,
              );
              break;*/
          /*  case '/shelf-offers':
              var obj = settings.arguments;
              return PageTransition(
                child: ShelfOffersPage(argument: obj),
                type: PageTransitionType.rightToLeftWithFade,
                settings: settings,
              );
              break;*/
          /*  case '/locate-product':
              var obj = settings.arguments;
              return PageTransition(
                child: LocateProductPage(argument: obj),
                type: PageTransitionType.rightToLeftWithFade,
                settings: settings,
              );
              break;*/
          /*  case '/locate-product-new':
              return PageTransition(
                child: LocateProductNewPage(),
                type: PageTransitionType.rightToLeftWithFade,
                settings: settings,
              );
              break;*/
           /* case '/shopping-list':
              return PageTransition(
                child: ShoppingListPage(),
                type: PageTransitionType.rightToLeftWithFade,
                settings: settings,
              );
              break;*/
            case '/delivery-timeslot':
              var obj = settings.arguments;
              return PageTransition(
                child: DeliveryTimeSlotScreen(argument: obj),
                type: null,
                settings: settings,
              );
              break;
            case '/notifications':
              return PageTransition(
                child: NotificationsPage(),
                type: null,
                settings: settings,
              );
              break;
            case '/change-pin':
              return PageTransition(
                child: ChangePinPage(),
                type: null,
                settings: settings,
              );
              break;
            case '/addnewaddress':
              return PageTransition(
                child: AddNewAddressPage(),
                type: null,
                settings: settings,
              );
              break;
            case '/my-profile':
              return PageTransition(
                child: MyProfilePage(),
                type: null,
                settings: settings,
              );
              break;
            case '/edit-profile':
              return PageTransition(
                child: EditProfilePage(),
                type: null,
                settings: settings,
              );
              break;
            case '/products':
              var obj = settings.arguments;
              return PageTransition(
                child: ProductsPage(argument: obj),
                type: null,
                settings: settings,
              );
              break;
            case '/product-details':
              var obj = settings.arguments;
              return PageTransition(
                child: ProductDetailsPage(argument: obj),
                type: null,
                settings: settings,
              );
              break;
            case '/cart':
              return PageTransition(
                child: CartPage(),
                type: null,
                settings: settings,
              );
              break;

            case '/checkout-new':
              return PageTransition(
                child: CheckOutNewPage(),
                type: null,
                settings: settings,
              );
              break;
            case '/checkout':
              var obj = settings.arguments;
              return PageTransition(
                child: CheckoutPage(argument: obj),
                type: null,
                settings: settings,
              );
              break;
            case '/add-address':
              var obj = settings.arguments;
              return PageTransition(
                child: AddAddressPage(argument: obj),
                type: null,
                settings: settings,
              );
              break;
            case '/add-address-home':
              return PageTransition(
                child: AddAddressHomePage(),
                type: null,
                settings: settings,
              );
              break;
            case '/change-address':
              return PageTransition(
                child: ChangeAddressPage(),
                type: null,
                settings: settings,
              );
              break;
            case '/order-complete':
              return PageTransition(
                child: OrderCompletePage(),
                type: null,
                settings: settings,
              );
              break;
            case '/order-failed':
              return PageTransition(
                child: OrderFailedPage(),
                type: null,
                settings: settings,
              );
              break;
            case '/multislider-home':
              return PageTransition(
                child: HomePageMultislider(),
                type: null,
                settings: settings,
              );
              break;
            case '/my-orders':
              return PageTransition(
                child: MyOrdersPage(),
                type: null,
                settings: settings,
              );
              break;
            case '/order-details':
              var obj = settings.arguments;
              return PageTransition(
                child: OrderDetailsPage(argument: obj),
                type: null,
                settings: settings,
              );
              break;
            case '/order-history':
              var obj = settings.arguments;
              return PageTransition(
                child: OrderHistoryPage(argument: obj),
                type: null,
                settings: settings,
              );
              break;
            case '/payment_options':
              var obj = settings.arguments;
              return PageTransition(
                child: PaymentOptionsScreen(argument: obj),
                type: PageTransitionType.rightToLeftWithFade,
                settings: settings,
              );
              break;
            case '/apply_coupon':
              var obj = settings.arguments;
              return PageTransition(
                child: ApplyCouponScreen(argument: obj),
                type: PageTransitionType.rightToLeftWithFade,
                settings: settings,
              );
              break;
            case '/grocery':
              return PageTransition(
                child: GroceryNewScreen(),
                type: PageTransitionType.rightToLeftWithFade,
                settings: settings,
              );
              break;
           case '/grocery-item':
              var obj = settings.arguments;
              return PageTransition(
                child: GroceryAllCategory(argument: obj),
                type: null,
                settings: settings,
              );
              break;
            case '/wallet':
              return PageTransition(
                child: MyWallet(),
                type: null,
                settings: settings,
              );
              break;
            case '/recharge-history':
              return PageTransition(
                child: RechargeHistoryPage(),
                type: null,
                settings: settings,
              );
              break;
            case '/billing-history':
              return PageTransition(
                child: BillingHistoryPage(),
                type: null,
                settings: settings,
              );
              break;
            case '/recharge-successful':
              var obj = settings.arguments;
              return PageTransition(
                child: RechargeCompletePage(argument: obj),
                type:null,
                settings: settings,
              );
              break;
            default:
              return null;
          }
        },
        home: Scaffold(
           body:  homeOrLog(),
        ),
      ),
    );
  }
  Widget homeOrLog(){
    if(this._loggedIn){
      return DashboardPage();
    }
    else{
      return IntroScreen();
    }

  }
}
