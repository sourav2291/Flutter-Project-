// repositories/payment_verification_repository.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/payment_verification.dart';
import '../services/session_service.dart';

class PaymentVerificationRepository {
  // ==========================================================
  // GET SESSION
  // ==========================================================

  Future<Map<String, String>> _getSession() async {
    final session = SessionService();

    final site = await session.getSite();
    final cookie = await session.getCookie();

    if (site == null ||
        site.trim().isEmpty ||
        cookie == null ||
        cookie.trim().isEmpty) {
      throw Exception("Session expired. Please login again.");
    }

    return {"site": site.trim(), "cookie": cookie.trim()};
  }

  // ==========================================================
  // GET MY PAYMENT VERIFICATIONS
  // ==========================================================

  Future<List<PaymentVerification>> getPaymentVerifications() async {
    final session = await _getSession();

    final site = session["site"]!;
    final cookie = session["cookie"]!;

    final url = Uri.parse(
      "$site/api/method/"
      "madathilapp.madathilapp.api.get_my_payment_verifications",
    );

    print("====================================");
    print("GET MY PAYMENT VERIFICATIONS");
    print("URL    : $url");
    print("====================================");

    final response = await http.get(
      url,
      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    print("====================================");
    print("GET MY PAYMENT VERIFICATIONS RESPONSE");
    print("Status : ${response.statusCode}");
    print("Body   : ${response.body}");
    print("====================================");

    if (response.statusCode != 200) {
      throw Exception(
        "Unable to load Payment Verifications.\n"
        "Status: ${response.statusCode}\n"
        "${response.body}",
      );
    }

    final jsonData = jsonDecode(response.body);

    final data = jsonData["message"];

    if (data is! List) {
      return [];
    }

    return data
        .map((e) => PaymentVerification.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ==========================================================
  // GET CUSTOMERS
  // ==========================================================

  Future<List<Map<String, String>>> getCustomers() async {
    final session = await _getSession();

    final site = session["site"]!;
    final cookie = session["cookie"]!;

    final uri = Uri.parse("$site/api/resource/Customer").replace(
      queryParameters: {
        "fields": jsonEncode(["name", "customer_name"]),
        "limit_page_length": "500",
        "order_by": "customer_name asc",
      },
    );

    print("====================================");
    print("GET CUSTOMERS FOR PAYMENT");
    print("URL    : $uri");
    print("====================================");

    final response = await http.get(
      uri,
      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    print("====================================");
    print("GET CUSTOMERS RESPONSE");
    print("Status : ${response.statusCode}");
    print("Body   : ${response.body}");
    print("====================================");

    if (response.statusCode != 200) {
      throw Exception(
        "Unable to load Customers.\n"
        "Status: ${response.statusCode}\n"
        "${response.body}",
      );
    }

    final jsonData = jsonDecode(response.body);

    final data = jsonData["data"];

    if (data is! List) {
      return [];
    }

    return data.map<Map<String, String>>((e) {
      return {
        "name": e["name"]?.toString() ?? "",
        "customer_name": e["customer_name"]?.toString() ?? "",
      };
    }).toList();
  }

  // ==========================================================
  // GET LOGGED-IN USER
  // ==========================================================

  Future<String> getLoggedInUser() async {
    final session = await _getSession();

    final site = session["site"]!;
    final cookie = session["cookie"]!;

    final url = Uri.parse("$site/api/method/frappe.auth.get_logged_user");

    final response = await http.get(
      url,
      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    print("====================================");
    print("GET LOGGED-IN USER");
    print("Status : ${response.statusCode}");
    print("Body   : ${response.body}");
    print("====================================");

    if (response.statusCode != 200) {
      throw Exception(
        "Unable to get logged-in user.\n"
        "Status: ${response.statusCode}\n"
        "${response.body}",
      );
    }

    final jsonData = jsonDecode(response.body);

    final user = jsonData["message"]?.toString();

    if (user == null || user.isEmpty) {
      throw Exception("Logged-in user was not returned.");
    }

    return user;
  }

  // ==========================================================
  // GET CURRENT EMPLOYEE
  // ==========================================================
  //
  // Uses the custom backend API:
  //
  // /api/method/madathilapp.madathilapp.api.get_my_employee
  //
  // The backend identifies the employee from the logged-in
  // ERPNext session.
  // ==========================================================

  Future<Map<String, dynamic>> getCurrentEmployee() async {
    final session = await _getSession();

    final site = session["site"]!;
    final cookie = session["cookie"]!;

    final url = Uri.parse(
      "$site/api/method/"
      "madathilapp.madathilapp.api.get_my_employee",
    );

    print("====================================");
    print("GET MY EMPLOYEE");
    print("URL : $url");
    print("====================================");

    final response = await http.get(
      url,
      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    print("====================================");
    print("GET MY EMPLOYEE RESPONSE");
    print("Status : ${response.statusCode}");
    print("Body   : ${response.body}");
    print("====================================");

    if (response.statusCode != 200) {
      throw Exception(
        "Unable to get current employee.\n"
        "Status: ${response.statusCode}\n"
        "${response.body}",
      );
    }

    final jsonData = jsonDecode(response.body);

    final data = jsonData["message"];

    if (data is! Map) {
      throw Exception(
        "No Employee information returned for the logged-in user.",
      );
    }

    return Map<String, dynamic>.from(data);
  }

  // ==========================================================
  // CREATE PAYMENT VERIFICATION
  // ==========================================================

  Future<String> createPaymentVerification({
    required String customer,
    required String customerName,

    // NEW PAYMENT FIELDS
    required String amount,
    required String totalProjectCost,

    required String kw,
    required String place,
    required String utrNumber,
    required String transactionImage,
    required String chequeNumber,
    required String chequeImage,
    required String salesManager,
    required String managerName,

    // EXISTING FIELDS
    required bool accountsVerified,
    required String accountsVerifiedPerson,
  }) async {
    final session = await _getSession();

    final site = session["site"]!;
    final cookie = session["cookie"]!;

    final url = Uri.parse("$site/api/resource/Sales%20Payment%20Verification");

    final body = {
      "customer": customer,
      "customer_name": customerName,

      // NEW PAYMENT FIELDS
      "amount": double.tryParse(amount) ?? 0,
      "total_project_cost": double.tryParse(totalProjectCost) ?? 0,

      "kw": kw,
      "place": place,
      "utr_number": utrNumber,
      "transaction_image": transactionImage,
      "cheque_number": chequeNumber,
      "cheque_image": chequeImage,
      "sales_manager": salesManager,
      "manager_name": managerName,

      // EXISTING FIELDS
      "accounts_verified": accountsVerified ? 1 : 0,
      "accounts_verified_person": accountsVerifiedPerson,
    };

    print("====================================");
    print("CREATE PAYMENT VERIFICATION");
    print("URL    : $url");
    print("BODY   : ${jsonEncode(body)}");
    print("====================================");

    final response = await http.post(
      url,
      headers: {
        "Cookie": cookie,
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    );

    print("====================================");
    print("CREATE PAYMENT VERIFICATION RESPONSE");
    print("Status : ${response.statusCode}");
    print("Body   : ${response.body}");
    print("====================================");

    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMessage = response.body;

      try {
        final jsonData = jsonDecode(response.body);

        if (jsonData["exception"] != null) {
          errorMessage = jsonData["exception"].toString();
        } else if (jsonData["message"] != null) {
          errorMessage = jsonData["message"].toString();
        }
      } catch (_) {}

      throw Exception(
        "Unable to create Payment Verification.\n"
        "Status: ${response.statusCode}\n"
        "$errorMessage",
      );
    }

    try {
      final jsonData = jsonDecode(response.body);

      final created = jsonData["data"];

      final paymentId = created?["name"]?.toString();

      if (paymentId == null || paymentId.isEmpty) {
        throw Exception(
          "Payment Verification created, "
          "but ID was not returned.",
        );
      }

      print("====================================");
      print("PAYMENT VERIFICATION CREATED");
      print("Payment ID : $paymentId");
      print("====================================");

      return paymentId;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception("Unable to read created Payment Verification.");
    }
  }
}
