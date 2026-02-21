import 'package:shared_preferences/shared_preferences.dart';

class MySharedPrefference {
  static SharedPreferences? _preferences;
  static const String key = 'usertype';

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future saveUserType(String type) async {
    await _preferences!.setString(key, type);
  }

  static String getUserType() {
    return _preferences!.getString(key) ?? "";
  }

  static Future clear() async {
    await _preferences!.remove(key);
  }
}