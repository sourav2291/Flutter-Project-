// services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'session_service.dart';

class AuthService {
  Future<bool> login({
    required String site,
    required String username,
    required String password,
  }) async {
    try {
      print("========== LOGIN START ==========");
      print("Site: $site");
      print("Username: $username");

      final url = Uri.parse("$site/api/method/login");
      print("URL: $url");

      final response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {"usr": username, "pwd": password},
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final cookie = response.headers["set-cookie"];

        final json = jsonDecode(response.body);
        final fullName = json["full_name"] ?? username;

        final session = SessionService();

        await session.saveSite(site);
        await session.saveUserName(fullName);

        if (cookie != null) {
          await session.saveCookie(cookie);
          print("Session Cookie Saved");
        } else {
          print("No session cookie received");
        }

        print("Login Successful");
        return true;
      }

      print("Login Failed");
      return false;
    } catch (e) {
      print("Login Error: $e");
      return false;
    }
  }
}
