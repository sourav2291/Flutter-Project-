// repositories/lead_repository.dart

// repositories/lead_repository.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/lead.dart';

import '../services/session_service.dart';
import '../services/upload_service.dart';

class LeadRepository {
  /// ==========================

  /// GET MY LEADS

  /// ==========================

  Future<List<Lead>> getLeads() async {
    final session = SessionService();

    final site = await session.getSite();

    final cookie = await session.getCookie();

    if (site == null || cookie == null) {
      throw Exception("Session not found. Please login again.");
    }

    final url = Uri.parse(
      "$site/api/method/madathilapp.madathilapp.api.get_my_leads",
    );

    final response = await http.get(
      url,

      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    print("========== GET MY LEADS ==========");

    print("Status : ${response.statusCode}");

    print(response.body);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final message = jsonData["message"];

      if (message is Map && message["success"] == true) {
        final List<dynamic> data = message["data"] ?? [];

        return data
            .map((e) => Lead.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      if (message is Map) {
        throw Exception(
          message["message"]?.toString() ?? "Failed to load Leads",
        );
      }

      throw Exception("Failed to load Leads");
    }

    throw Exception("Failed to load Leads. Status: ${response.statusCode}");
  }

  /// ==========================

  /// GET LEAD SOURCES

  /// ==========================

  Future<List<String>> getLeadSources() async {
    final session = SessionService();

    final site = await session.getSite();

    final cookie = await session.getCookie();

    if (site == null || cookie == null) {
      throw Exception("Session not found.");
    }

    final url = Uri.parse('$site/api/resource/Lead Source?fields=["name"]');

    final response = await http.get(
      url,

      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final List data = jsonData["data"] ?? [];

      return data.map<String>((e) => e["name"].toString()).toList();
    }

    throw Exception("Unable to load Lead Sources");
  }

  /// ==========================

  /// GET STATES

  /// ==========================

  Future<List<String>> getStates() async {
    final session = SessionService();

    final site = await session.getSite();

    final cookie = await session.getCookie();

    if (site == null || cookie == null) {
      throw Exception("Session not found.");
    }

    final url = Uri.parse("$site/api/resource/State").replace(
      queryParameters: {
        "fields": jsonEncode(["name"]),

        "limit_page_length": "100",
      },
    );

    final response = await http.get(
      url,

      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    print("========== GET STATES ==========");

    print("URL    : $url");

    print("Status : ${response.statusCode}");

    print(response.body);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final List<dynamic> data = jsonData["data"] ?? [];

      return data
          .map<String>((e) => e["name"]?.toString().trim() ?? "")
          .where((state) => state.isNotEmpty)
          .toList();
    }

    throw Exception("Unable to load States. Status: ${response.statusCode}");
  }

  /// ==========================

  /// VALIDATE ADDRESS STATE

  /// ==========================

  Future<String?> validateAddressState(
    Map<String, dynamic>? addressData,
  ) async {
    if (addressData == null) {
      return null;
    }

    String state = addressData["state"]?.toString().trim() ?? "";

    if (state.isEmpty) {
      return "Please select State.";
    }

    final states = await getStates();

    if (states.isEmpty) {
      return "Unable to load State options from ERPNext.";
    }

    final normalizedState = state.toLowerCase().trim();

    String? matchedState;

    /// First check exact ERPNext State names.

    for (final erpState in states) {
      if (erpState.toLowerCase().trim() == normalizedState) {
        matchedState = erpState;

        break;
      }
    }

    /// Support the display values used in the mobile app.

    if (matchedState == null) {
      if (normalizedState == "kerala") {
        for (final erpState in states) {
          if (erpState.toLowerCase().trim() == "kerala") {
            matchedState = erpState;

            break;
          }
        }
      } else if (normalizedState == "tamil" ||
          normalizedState == "tamil nadu") {
        for (final erpState in states) {
          if (erpState.toLowerCase().trim() == "tamil nadu") {
            matchedState = erpState;

            break;
          }
        }
      } else if (normalizedState == "karnataka" ||
          normalizedState == "karanataka") {
        for (final erpState in states) {
          if (erpState.toLowerCase().trim() == "karnataka") {
            matchedState = erpState;

            break;
          }
        }
      }
    }

    if (matchedState == null) {
      return "Please select a valid State from available options.";
    }

    /// Replace the value with the exact ERPNext State name.

    addressData["state"] = matchedState;

    return null;
  }

  /// ==========================

  /// VALIDATE ADDRESS PINCODE

  /// ==========================

  String? validateAddressPincode(Map<String, dynamic>? addressData) {
    if (addressData == null) {
      return null;
    }

    final state = addressData["state"]?.toString().trim() ?? "";

    final pincode = addressData["pincode"]?.toString().trim() ?? "";

    // Pincode is optional in the current Address screen.

    if (pincode.isEmpty) {
      return null;
    }

    // Indian pincode must contain exactly 6 digits.

    if (!RegExp(r"^\d{6}$").hasMatch(pincode)) {
      return "Please enter a valid 6-digit Pincode.";
    }

    // ERPNext India Compliance checks the initial three digits

    // against the selected State.

    final prefix = int.tryParse(pincode.substring(0, 3));

    if (prefix == null) {
      return "Please enter a valid Pincode.";
    }

    if (state.toLowerCase() == "kerala") {
      // Kerala postal prefixes: 670-695

      if (prefix < 670 || prefix > 695) {
        return "Pincode $pincode is not valid for Kerala.";
      }
    } else if (state.toLowerCase() == "tamil nadu") {
      // Tamil Nadu postal prefixes: 600-643

      if (prefix < 600 || prefix > 643) {
        return "Pincode $pincode is not valid for Tamil Nadu.";
      }
    } else if (state.toLowerCase() == "karnataka") {
      // Karnataka postal prefixes: 560-591

      if (prefix < 560 || prefix > 591) {
        return "Pincode $pincode is not valid for Karnataka.";
      }
    }

    return null;
  }

  /// ==========================

  /// CREATE LEAD

  /// ==========================

  Future<String?> createLead({
    required String firstName,

    required String lastName,

    required String mobileNo,

    required String email,

    required String franchiseName,

    required String leadSource,

    Map<String, dynamic>? addressData,
  }) async {
    final session = SessionService();

    final site = await session.getSite();

    final cookie = await session.getCookie();

    if (site == null || cookie == null) {
      throw Exception("Session not found.");
    }

    // ============================================================

    // VALIDATE ADDRESS STATE BEFORE CREATING LEAD

    // ============================================================

    if (addressData != null) {
      final addressStateError = await validateAddressState(addressData);

      if (addressStateError != null) {
        throw Exception(addressStateError);
      }
    }

    // ============================================================

    // VALIDATE ADDRESS PINCODE BEFORE CREATING LEAD

    // ============================================================

    final addressPincodeError = validateAddressPincode(addressData);

    if (addressPincodeError != null) {
      throw Exception(addressPincodeError);
    }

    // ============================================================

    // CREATE LEAD

    // ============================================================

    final leadUrl = Uri.parse("$site/api/resource/Lead");

    final leadBody = {
      "first_name": firstName,

      "last_name": lastName,

      "mobile_no": mobileNo,

      "email_id": email,

      "custom_franchise_name": franchiseName,

      "source": leadSource,
    };

    final leadResponse = await http.post(
      leadUrl,

      headers: {
        "Cookie": cookie,

        "Content-Type": "application/json",

        "Accept": "application/json",
      },

      body: jsonEncode(leadBody),
    );

    print("========== CREATE LEAD ==========");

    print("Status : ${leadResponse.statusCode}");

    print(leadResponse.body);

    if (leadResponse.statusCode != 200 && leadResponse.statusCode != 201) {
      return null;
    }

    final leadJson = jsonDecode(leadResponse.body);

    final leadName = leadJson["data"]?["name"];

    if (leadName == null) {
      return null;
    }

    // ============================================================

    // CREATE ADDRESS FOR LEAD

    // ============================================================

    if (addressData != null) {
      final addressUrl = Uri.parse("$site/api/resource/Address");

      final addressBody = {
        "address_title": addressData["address_title"] ?? "",

        "address_type": addressData["address_type"] ?? "Billing",

        "address_line1": addressData["address_line1"] ?? "",

        "address_line2": addressData["address_line2"] ?? "",

        "city": addressData["city"] ?? "",

        // This is now the exact ERPNext State value.
        "state": addressData["state"] ?? "",

        "country": addressData["country"] ?? "India",

        "pincode": addressData["pincode"] ?? "",

        "phone": addressData["phone"] ?? "",

        "is_primary_address": addressData["is_primary_address"] ?? 0,

        "is_shipping_address": addressData["is_shipping_address"] ?? 0,

        "links": [
          {"link_doctype": "Lead", "link_name": leadName},
        ],
      };

      print("========== ADDRESS BODY ==========");

      print(jsonEncode(addressBody));

      final addressResponse = await http.post(
        addressUrl,

        headers: {
          "Cookie": cookie,

          "Content-Type": "application/json",

          "Accept": "application/json",
        },

        body: jsonEncode(addressBody),
      );

      print("========== CREATE LEAD ADDRESS ==========");

      print("Status : ${addressResponse.statusCode}");

      print(addressResponse.body);

      if (addressResponse.statusCode != 200 &&
          addressResponse.statusCode != 201) {
        throw Exception(
          "Lead created successfully, but address could not be created.\n"
          "Status: ${addressResponse.statusCode}\n"
          "${addressResponse.body}",
        );
      }
    }

    return leadName.toString();
  }

  /// ==========================

  /// ==========================
  /// UPLOAD KSEB BILL
  /// ==========================

  Future<String?> uploadKsebBill({
    required String leadName,
    required File file,
  }) async {
    final originalName = file.path.split(Platform.pathSeparator).last;
    final fileName = originalName.startsWith("KSEB_BILL_")
        ? originalName
        : "KSEB_BILL_$originalName";

    final uploadService = UploadService();

    return await uploadService.uploadFile(
      file,
      attachedToDoctype: "Lead",
      attachedToName: leadName,
      fileName: fileName,
    );
  }

  /// ==========================
  /// GET KSEB BILLS
  /// ==========================

  Future<List<Map<String, dynamic>>> getKsebBills(String leadName) async {
    final session = SessionService();

    final site = await session.getSite();
    final cookie = await session.getCookie();

    if (site == null || cookie == null) {
      throw Exception("Session not found. Please login again.");
    }

    final url = Uri.parse("$site/api/resource/File").replace(
      queryParameters: {
        "fields": jsonEncode([
          "name",
          "file_name",
          "file_url",
          "is_private",
          "attached_to_doctype",
          "attached_to_name",
          "creation",
        ]),
        "filters": jsonEncode([
          ["attached_to_doctype", "=", "Lead"],
          ["attached_to_name", "=", leadName],
          ["file_name", "like", "KSEB_BILL_%"],
        ]),
        "order_by": "creation desc",
        "limit_page_length": "0",
      },
    );

    final response = await http.get(
      url,
      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    print("========== GET KSEB BILLS ==========");
    print("Status : ${response.statusCode}");
    print(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        "Unable to load KSEB Bills. Status: ${response.statusCode}",
      );
    }

    final jsonData = jsonDecode(response.body);
    final List<dynamic> data = jsonData["data"] ?? [];

    return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  /// ADD LEAD FOLLOW-UP

  /// ==========================

  Future<bool> addLeadFollowUp({
    required String leadName,

    required String status,

    required String feedback,

    required String dateAndTime,
  }) async {
    final session = SessionService();

    final site = await session.getSite();

    final cookie = await session.getCookie();

    if (site == null || cookie == null) {
      throw Exception("Session not found. Please login again.");
    }

    final url = Uri.parse(
      "$site/api/method/madathilapp.madathilapp.api.add_lead_follow_up",
    );

    final body = {
      "lead_name": leadName,

      "status": status,

      "feedback": feedback,

      "date_and_time": dateAndTime,
    };

    final response = await http.post(
      url,

      headers: {
        "Cookie": cookie,

        "Content-Type": "application/json",

        "Accept": "application/json",
      },

      body: jsonEncode(body),
    );

    print("========== ADD LEAD FOLLOW-UP ==========");

    print("Status : ${response.statusCode}");

    print(response.body);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final message = jsonData["message"];

      if (message is Map && message["success"] == true) {
        return true;
      }

      if (message is Map) {
        throw Exception(
          message["message"]?.toString() ?? "Failed to add lead follow-up",
        );
      }

      throw Exception("Failed to add lead follow-up");
    }

    throw Exception(
      "Failed to add lead follow-up. "
      "Status: ${response.statusCode}",
    );
  }

  /// ==========================

  /// GET QUOTATION MANAGER

  /// ==========================

  Future<Map<String, String>> getQuotationManager() async {
    final session = SessionService();

    final site = await session.getSite();

    final cookie = await session.getCookie();

    if (site == null || cookie == null) {
      throw Exception("Session not found.");
    }

    final url = Uri.parse(
      "$site/api/method/madathilapp.madathilapp.api.get_quotation_manager",
    );

    final response = await http.get(
      url,

      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    print("========== GET QUOTATION MANAGER ==========");

    print("Status : ${response.statusCode}");

    print(response.body);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return {
        "email": jsonData["message"]["parent"].toString(),

        "name": jsonData["message"]["full_name"].toString(),
      };
    }

    throw Exception("Unable to fetch Quotation Manager");
  }

  /// ============================================================
  /// CREATE ADDRESS FOR EXISTING LEAD
  /// ============================================================

  Future<bool> createAddressForLead({
    required String leadName,
    required Map<String, dynamic> addressData,
  }) async {
    final session = SessionService();

    final site = await session.getSite();
    final cookie = await session.getCookie();

    if (site == null || cookie == null) {
      throw Exception("Session not found. Please login again.");
    }

    // Validate the selected State.
    final stateError = await validateAddressState(addressData);
    if (stateError != null) {
      throw Exception(stateError);
    }

    // Validate the Pincode.
    final pincodeError = validateAddressPincode(addressData);
    if (pincodeError != null) {
      throw Exception(pincodeError);
    }

    final url = Uri.parse("$site/api/resource/Address");

    final body = {
      "address_title": addressData["address_title"] ?? "",
      "address_type": addressData["address_type"] ?? "Billing",
      "address_line1": addressData["address_line1"] ?? "",
      "address_line2": addressData["address_line2"] ?? "",
      "city": addressData["city"] ?? "",
      "state": addressData["state"] ?? "",
      "country": addressData["country"] ?? "India",
      "pincode": addressData["pincode"] ?? "",
      "phone": addressData["phone"] ?? "",
      "is_primary_address": addressData["is_primary_address"] ?? 0,
      "is_shipping_address": addressData["is_shipping_address"] ?? 0,
      "links": [
        {"link_doctype": "Lead", "link_name": leadName},
      ],
    };

    print("========== CREATE ADDRESS FOR EXISTING LEAD ==========");
    print("Lead: $leadName");
    print("Address body: ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: {
        "Cookie": cookie,
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    );

    print("Status: ${response.statusCode}");
    print(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    throw Exception(
      "Failed to create Lead address. "
      "Status: ${response.statusCode}\n${response.body}",
    );
  }

  /// ==========================

  /// ASSIGN LEAD

  /// ==========================

  Future<bool> assignLead({
    required String leadName,

    required String allocatedTo,
  }) async {
    final session = SessionService();

    final site = await session.getSite();

    final cookie = await session.getCookie();

    if (site == null || cookie == null) {
      throw Exception("Session not found.");
    }

    final url = Uri.parse("$site/api/resource/ToDo");

    final body = {
      "allocated_to": allocatedTo,

      "reference_type": "Lead",

      "reference_name": leadName,

      "description": "Lead Assigned from Mobile App",
    };

    final response = await http.post(
      url,

      headers: {
        "Cookie": cookie,

        "Content-Type": "application/json",

        "Accept": "application/json",
      },

      body: jsonEncode(body),
    );

    print("========== ASSIGN LEAD ==========");

    print("Status : ${response.statusCode}");

    print(response.body);

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
