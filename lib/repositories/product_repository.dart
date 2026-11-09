// repositories/product_repository.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../services/session_service.dart';

class ProductRepository {
  Future<List<ProductBundle>> getBundles() async {
    final session = SessionService();

    final site = await session.getSite();
    final cookie = await session.getCookie();

    if (site == null || cookie == null) {
      throw Exception("Session not found. Please login again.");
    }

    final url = Uri.parse(
      '$site/api/resource/Product%20Bundle'
      '?fields=["name","custom_product_total_price"]'
      '&limit_page_length=100',
    );

    final response = await http.get(
      url,
      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      List<dynamic> data = jsonData["data"];

      return data.map((bundle) => ProductBundle.fromJson(bundle)).toList();
    } else {
      throw Exception("Failed to load Product Bundles");
    }
  }
}
