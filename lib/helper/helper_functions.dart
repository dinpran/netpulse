import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String userLoggedInKey = "USERLOGGEDINKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";

  static Future<bool> saveUserLoggedInKey(bool loggedinkey) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setBool(userLoggedInKey, loggedinkey);
  }

  static Future<bool> saveUserNamenKey(String nameloggedinkey) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(userNameKey, nameloggedinkey);
  }

  static Future<bool> saveUserEmailKey(String emailloggedinkey) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(userEmailKey, emailloggedinkey);
  }

  static Future<bool?> getUserLoggedInKey() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }

  static Future<String?> getUserNameKey() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userNameKey);
  }

  static Future<String?> getUserEmailKey() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userEmailKey);
  }
}
