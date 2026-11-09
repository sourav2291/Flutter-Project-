// repositories/quotation_repository.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/quotation.dart';
import '../services/session_service.dart';

class QuotationRepository {
  Future<List<Quotation>> getMyQuotations() async {
    final session = SessionService();

    final site = await session.getSite();
    final cookie = await session.getCookie();

    if (site == null || cookie == null) {
      throw Exception("Session not found.");
    }

    final url = Uri.parse(
      "$site/api/method/madathilapp.madathilapp.api.get_my_quotations",
    );

    final response = await http.get(
      url,
      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    print("========== MY QUOTATIONS ==========");
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final List data = jsonData["message"];

      return data.map((e) => Quotation.fromJson(e)).toList();
    }

    throw Exception("Unable to load Quotations");
  }
}
