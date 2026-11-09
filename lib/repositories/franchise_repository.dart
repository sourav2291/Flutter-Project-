// repositories/franchise_repository.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/franchise.dart';
import '../services/session_service.dart';

class FranchiseRepository {
  // ==============================
  // GET FRANCHISE LIST
  // ==============================
  Future<List<Franchise>> getFranchises() async {
    final session = SessionService();

    final site = await session.getSite();
    final cookie = await session.getCookie();

    if (site == null || cookie == null) {
      throw Exception("Session not found. Please login again.");
    }

    final url = Uri.parse(
      '$site/api/resource/Franchise%20Application%20Form'
      '?fields=["name","franchise_name"]'
      '&limit_page_length=100',
    );

    final response = await http.get(
      url,
      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final List data = jsonData["data"];

      return data.map((e) => Franchise.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load Franchise List");
    }
  }

  // ==============================
  // CREATE FRANCHISE APPLICATION
  // ==============================
  Future<bool> createFranchiseApplication({
    required String franchiseName,
    required String applicantName,
    required String phoneNumber,
    required String email,
    required String aadhaarNumber,
    required String panNumber,
    required String officeAddress,
    required String bankName,
    required String bankAccountNumber,
    required String ifsc,
    required String branch,
    required String panchayath,
    required String municipality,

    // Attachments
    required String aadhaarCard,
    required String panCard,
    required String bankAccountAttachment,
  }) async {
    final session = SessionService();

    final site = await session.getSite();
    final cookie = await session.getCookie();

    if (site == null || cookie == null) {
      throw Exception("Session expired. Please login again.");
    }

    final url = Uri.parse("$site/api/resource/Franchise%20Application%20Form");

    final body = {
      "franchise_name": franchiseName,
      "applicant_name": applicantName,
      "phone_number": phoneNumber,
      "email": email,
      "aadhaar_number": aadhaarNumber,
      "pan_number": panNumber,
      "office_address": officeAddress,
      "bank_name": bankName,
      "bank_account_number": bankAccountNumber,
      "ifsc": ifsc,
      "branch": branch,
      "panchayath": panchayath,
      "muncipality": municipality,

      // Attachments
      "aadhaar_card": aadhaarCard,
      "pan_card": panCard,
      "bank_account_details": bankAccountAttachment,
    };

    print("================================");
    print("CREATE FRANCHISE");
    print(jsonEncode(body));
    print("================================");

    final response = await http.post(
      url,
      headers: {
        "Cookie": cookie,
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    print("================================");
    print("Status : ${response.statusCode}");
    print("Body   : ${response.body}");
    print("================================");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    return false;
  }
}
