import 'package:shared_preferences/shared_preferences.dart';

class Preference {
  Future<SharedPreferences> getPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }
}
