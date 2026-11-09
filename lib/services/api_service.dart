// services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://solar.m.frappe.cloud";

  // ============================================================
  // EXISTING LOGIN
  // ============================================================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/method/login"),
        body: {"usr": email, "pwd": password},
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "cookie": response.headers["set-cookie"],
          "data": jsonDecode(response.body),
        };
      } else {
        return {"success": false, "message": "Invalid username or password"};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // ============================================================
  // PAYMENT ENTRY - GET MODE OF PAYMENTS
  // ============================================================

  static Future<Map<String, dynamic>> getModeOfPayments({
    required String cookie,
  }) async {
    try {
      final fields = Uri.encodeComponent(jsonEncode(["name"]));

      final filters = Uri.encodeComponent(
        jsonEncode([
          ["enabled", "=", 1],
        ]),
      );

      final url =
          "$baseUrl/api/resource/Mode%20of%20Payment"
          "?fields=$fields"
          "&filters=$filters"
          "&order_by=name%20asc"
          "&limit_page_length=100";

      final response = await http.get(
        Uri.parse(url),
        headers: {"Cookie": cookie, "Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {"success": true, "data": data["data"] ?? []};
      }

      return {"success": false, "message": _extractError(response)};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // ============================================================
  // PAYMENT ENTRY - CREATE
  // ============================================================

  static Future<Map<String, dynamic>> createPaymentEntry({
    required String cookie,
    required String salesOrder,
    required String customer,
    required String company,
    required String salesUser,
    required String modeOfPayment,
    required double paidAmount,
    required String referenceNo,
    required String referenceDate,
    String? attachmentUrl,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        "sales_order": salesOrder,
        "customer": customer,
        "company": company,
        "sales_user": salesUser,
        "mode_of_payment": modeOfPayment,
        "paid_amount": paidAmount,
        "reference_no": referenceNo,
        "reference_date": referenceDate,
        "attachment_url": attachmentUrl,
      };

      final response = await http.post(
        Uri.parse(
          "$baseUrl/api/method/"
          "madathilapp.madathilapp.api.create_mobile_payment_entry",
        ),
        headers: {
          "Cookie": cookie,
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {"success": true, "data": data["message"]};
      }

      return {"success": false, "message": _extractError(response)};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // ============================================================
  // PAYMENT ENTRY - UPLOAD ATTACHMENT
  // ============================================================

  static Future<Map<String, dynamic>> uploadPaymentAttachment({
    required String cookie,
    required String filePath,
  }) async {
    try {
      final request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/api/method/upload_file"),
      );

      request.headers["Cookie"] = cookie;
      request.fields["is_private"] = "0";

      request.files.add(await http.MultipartFile.fromPath("file", filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          "success": true,
          "file_url": data["message"]?["file_url"],
          "data": data["message"],
        };
      }

      return {"success": false, "message": _extractError(response)};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // ============================================================
  // MATERIAL REQUEST - READ ONLY
  // ============================================================

  static Future<Map<String, dynamic>> getMyMaterialRequests({
    required String cookie,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/method/"
          "madathilapp.madathilapp.api.get_my_material_requests",
        ),
        headers: {"Cookie": cookie, "Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = responseData["message"];

        if (data is List) {
          return {"success": true, "data": data};
        }

        return {
          "success": false,
          "message": "Unexpected response from the server.",
        };
      }

      return {"success": false, "message": _extractError(response)};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // ============================================================
  // SITE MATERIAL TRACKING - VEHICLE TRACKING
  // ============================================================

  static Future<Map<String, dynamic>> getSiteMaterialTracking({
    required String cookie,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl/api/method/"
          "madathilapp.madathilapp.api.get_site_material_tracking",
        ),
        headers: {"Cookie": cookie, "Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = responseData["message"];

        if (data is List) {
          return {"success": true, "data": data};
        }

        return {
          "success": false,
          "message": "Unexpected response from Site Material Tracking API.",
        };
      }

      return {"success": false, "message": _extractError(response)};
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // ============================================================
  // ERROR HANDLER
  // ============================================================

  static String _extractError(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (data["message"] != null) {
        if (data["message"] is String) {
          return data["message"];
        }

        return jsonEncode(data["message"]);
      }

      if (data["_server_messages"] != null) {
        return data["_server_messages"].toString();
      }

      return "Request failed (${response.statusCode})";
    } catch (_) {
      return "Request failed (${response.statusCode}): ${response.body}";
    }
  }
}
