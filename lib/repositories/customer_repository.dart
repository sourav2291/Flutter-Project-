// repositories/customer_repository.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/customer.dart';
import '../services/session_service.dart';

class CustomerRepository {
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
  // GET MY CUSTOMERS
  // ==========================================================

  Future<List<Customer>> getCustomers() async {
    final session = await _getSession();

    final site = session["site"]!;
    final cookie = session["cookie"]!;

    final url = Uri.parse(
      "$site/api/method/madathilapp.madathilapp.api.get_my_customers",
    );

    print("====================================");
    print("GET MY CUSTOMERS");
    print("URL    : $url");
    print("====================================");

    final response = await http.get(
      url,
      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    print("====================================");
    print("GET MY CUSTOMERS RESPONSE");
    print("Status : ${response.statusCode}");
    print("Body   : ${response.body}");
    print("====================================");

    if (response.statusCode != 200) {
      throw Exception(
        "Unable to load customers.\n"
        "Status: ${response.statusCode}\n"
        "${response.body}",
      );
    }

    final jsonData = jsonDecode(response.body);

    final message = jsonData["message"];

    // ==========================================================
    // SUCCESS RESPONSE
    // ==========================================================

    if (message is Map && message["success"] == true) {
      final data = message["data"];

      if (data is! List) {
        return [];
      }

      return data
          .map((e) => Customer.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    // ==========================================================
    // API ERROR RESPONSE
    // ==========================================================

    if (message is Map) {
      throw Exception(
        message["message"]?.toString() ?? "Unable to load customers.",
      );
    }

    throw Exception("Unable to load customers.");
  }

  // ==========================================================
  // GET CUSTOMER GROUPS
  // ==========================================================

  Future<List<String>> getCustomerGroups() async {
    final session = await _getSession();

    final site = session["site"]!;
    final cookie = session["cookie"]!;

    final uri = Uri.parse("$site/api/resource/Customer%20Group").replace(
      queryParameters: {
        "fields": jsonEncode(["name"]),
        "filters": jsonEncode([
          ["is_group", "=", 0],
        ]),
        "limit_page_length": "500",
      },
    );

    print("====================================");
    print("GET CUSTOMER GROUPS");
    print("URL    : $uri");
    print("====================================");

    final response = await http.get(
      uri,
      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    print("====================================");
    print("GET CUSTOMER GROUPS RESPONSE");
    print("Status : ${response.statusCode}");
    print("Body   : ${response.body}");
    print("====================================");

    if (response.statusCode != 200) {
      throw Exception(
        "Unable to load Customer Groups.\n"
        "Status: ${response.statusCode}\n"
        "${response.body}",
      );
    }

    final jsonData = jsonDecode(response.body);

    final data = jsonData["data"];

    if (data is! List) {
      return [];
    }

    return data
        .map((e) => e["name"].toString())
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }

  // ==========================================================
  // GET TERRITORIES
  // ==========================================================

  Future<List<String>> getTerritories() async {
    final session = await _getSession();

    final site = session["site"]!;
    final cookie = session["cookie"]!;

    final uri = Uri.parse("$site/api/resource/Territory").replace(
      queryParameters: {
        "fields": jsonEncode(["name"]),
        "filters": jsonEncode([
          ["is_group", "=", 0],
        ]),
        "limit_page_length": "500",
      },
    );

    print("====================================");
    print("GET TERRITORIES");
    print("URL    : $uri");
    print("====================================");

    final response = await http.get(
      uri,
      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    print("====================================");
    print("GET TERRITORIES RESPONSE");
    print("Status : ${response.statusCode}");
    print("Body   : ${response.body}");
    print("====================================");

    if (response.statusCode != 200) {
      throw Exception(
        "Unable to load Territories.\n"
        "Status: ${response.statusCode}\n"
        "${response.body}",
      );
    }

    final jsonData = jsonDecode(response.body);

    final data = jsonData["data"];

    if (data is! List) {
      return [];
    }

    return data
        .map((e) => e["name"].toString())
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }

  // ==========================================================
  // GET STATES
  // ==========================================================

  Future<List<String>> getStates() async {
    final session = await _getSession();

    final site = session["site"]!;
    final cookie = session["cookie"]!;

    final uri = Uri.parse("$site/api/resource/State").replace(
      queryParameters: {
        "fields": jsonEncode(["name"]),
        "limit_page_length": "500",
        "order_by": "name asc",
      },
    );

    print("====================================");
    print("GET STATES");
    print("URL    : $uri");
    print("====================================");

    final response = await http.get(
      uri,
      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    print("====================================");
    print("GET STATES RESPONSE");
    print("Status : ${response.statusCode}");
    print("Body   : ${response.body}");
    print("====================================");

    if (response.statusCode != 200) {
      throw Exception(
        "Unable to load States.\n"
        "Status: ${response.statusCode}\n"
        "${response.body}",
      );
    }

    final jsonData = jsonDecode(response.body);

    final data = jsonData["data"];

    if (data is! List) {
      return [];
    }

    return data
        .map((e) => e["name"].toString())
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }

  // ==========================================================
  // CREATE CUSTOMER
  // ==========================================================

  Future<String> createCustomer({
    required String customerName,
    required String customerType,
    required String customerGroup,
    required String territory,
    required String mobileNo,
    required String whatsappNumber,
    required String customerLocation,
  }) async {
    final session = await _getSession();

    final site = session["site"]!;
    final cookie = session["cookie"]!;

    final url = Uri.parse("$site/api/resource/Customer");

    final body = {
      "customer_name": customerName,
      "customer_type": customerType,
      "customer_group": customerGroup,
      "territory": territory,
      "mobile_no": mobileNo,
      "custom_whatsapp_number": whatsappNumber,
      "custom_customer_location": customerLocation,
    };

    print("====================================");
    print("CREATE CUSTOMER");
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
    print("CREATE CUSTOMER RESPONSE");
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
        "Unable to create customer.\n"
        "Status: ${response.statusCode}\n"
        "$errorMessage",
      );
    }

    try {
      final jsonData = jsonDecode(response.body);

      final createdCustomer = jsonData["data"];

      final customerId = createdCustomer?["name"]?.toString();

      if (customerId == null || customerId.isEmpty) {
        throw Exception(
          "Customer created, but Customer ID "
          "was not returned.",
        );
      }

      print("====================================");
      print("CUSTOMER CREATED SUCCESSFULLY");
      print("Customer ID : $customerId");
      print("====================================");

      return customerId;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception("Unable to read created Customer.");
    }
  }

  // ==========================================================
  // CREATE ADDRESS
  // ==========================================================

  Future<String> createAddress({
    required String customerName,
    required String addressLine1,
    String addressLine2 = "",
    String city = "",
    required String state,
    required String country,
    String pincode = "",
  }) async {
    final session = await _getSession();

    final site = session["site"]!;
    final cookie = session["cookie"]!;

    final url = Uri.parse("$site/api/resource/Address");

    final body = {
      "address_title": customerName,
      "address_type": "Billing",
      "address_line1": addressLine1,
      "address_line2": addressLine2,
      "city": city,
      "state": state,
      "country": country,
      "pincode": pincode,
      "is_primary_address": 1,
      "links": [
        {"link_doctype": "Customer", "link_name": customerName},
      ],
    };

    print("====================================");
    print("CREATE ADDRESS");
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
    print("CREATE ADDRESS RESPONSE");
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
        "Unable to create address.\n"
        "Status: ${response.statusCode}\n"
        "$errorMessage",
      );
    }

    try {
      final jsonData = jsonDecode(response.body);

      final createdAddress = jsonData["data"];

      final addressId = createdAddress?["name"]?.toString();

      if (addressId == null || addressId.isEmpty) {
        throw Exception(
          "Address created, but Address ID "
          "was not returned.",
        );
      }

      print("====================================");
      print("ADDRESS CREATED SUCCESSFULLY");
      print("Address ID : $addressId");
      print("Customer ID: $customerName");
      print("====================================");

      return addressId;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception("Unable to read created Address.");
    }
  }
}
