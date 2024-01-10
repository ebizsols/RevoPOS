import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static SharedPreferences? data;

  static Future init() async {
    data = await SharedPreferences.getInstance();
  }
}