// services/session_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  Future<void> saveCookie(String cookie) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("cookie", cookie);
  }

  Future<void> saveSite(String site) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("site", site);
  }

  Future<String?> getCookie() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("cookie");
  }

  Future<String?> getSite() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("site");
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user_name", name);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_name");
  }
}
