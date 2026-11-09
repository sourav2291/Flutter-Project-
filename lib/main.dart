// main.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'services/session_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ERPNext Mobile',
      home: const StartupScreen(),
    );
  }
}

// ============================================================
// STARTUP SCREEN
// ============================================================

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();

    _checkSession();
  }

  // ============================================================
  // CHECK SAVED SESSION
  // ============================================================

  Future<void> _checkSession() async {
    final session = SessionService();

    try {
      // --------------------------------------------------------
      // GET SAVED SITE
      // --------------------------------------------------------

      final site = await session.getSite();

      // --------------------------------------------------------
      // GET SAVED COOKIE
      // --------------------------------------------------------

      final cookie = await session.getCookie();

      print("==========================================");
      print("STARTUP SESSION CHECK");
      print("Saved Site   : $site");
      print("Cookie Found : ${cookie != null && cookie.trim().isNotEmpty}");
      print("==========================================");

      // --------------------------------------------------------
      // NO SAVED SESSION
      // --------------------------------------------------------

      if (site == null ||
          site.trim().isEmpty ||
          cookie == null ||
          cookie.trim().isEmpty) {
        _goToLogin();
        return;
      }

      // --------------------------------------------------------
      // VERIFY SESSION WITH ERPNext
      // --------------------------------------------------------

      final url = Uri.parse(
        '${site.trim()}/api/method/frappe.auth.get_logged_user',
      );

      print("Checking ERPNext session...");
      print("URL: $url");

      final response = await http.get(
        url,
        headers: {"Cookie": cookie, "Accept": "application/json"},
      );

      print("Startup Session Status: ${response.statusCode}");
      print("Startup Session Body: ${response.body}");

      // --------------------------------------------------------
      // VALID SESSION
      // --------------------------------------------------------

      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);

          final loggedInUser = jsonData["message"]?.toString().trim() ?? "";

          print("Logged In User: $loggedInUser");

          if (loggedInUser.isNotEmpty && loggedInUser != "Guest") {
            // Save/refresh username if available
            await session.saveUserName(loggedInUser);

            _goToDashboard();
            return;
          }
        } catch (e) {
          print("Session response parsing error: $e");
        }
      }

      // --------------------------------------------------------
      // INVALID / EXPIRED SESSION
      // --------------------------------------------------------

      print("Saved session is invalid or expired.");

      await session.logout();

      _goToLogin();
    } catch (e) {
      print("Startup session check failed: $e");

      // --------------------------------------------------------
      // IMPORTANT:
      // If checking the session itself fails because of network
      // problems, do NOT immediately delete the saved session.
      // --------------------------------------------------------

      final site = await session.getSite();
      final cookie = await session.getCookie();

      if (site != null &&
          site.trim().isNotEmpty &&
          cookie != null &&
          cookie.trim().isNotEmpty) {
        print("Saved session exists. Opening Dashboard.");
        _goToDashboard();
      } else {
        _goToLogin();
      }
    }
  }

  // ============================================================
  // GO TO LOGIN
  // ============================================================

  void _goToLogin() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // ============================================================
  // GO TO DASHBOARD
  // ============================================================

  void _goToDashboard() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  // ============================================================
  // STARTUP UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF041A1F),
      body: Center(child: CircularProgressIndicator(color: Color(0xFF7EE787))),
    );
  }
}
