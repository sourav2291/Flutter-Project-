// repositories/product_bundle_repository.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_bundle.dart';
import '../services/session_service.dart';

class ProductBundleRepository {
  Future<ProductBundle> getBundle(String bundleName) async {
    final session = SessionService();

    final cookie = await session.getCookie();
    final site = await session.getSite();

    final url = Uri.parse("$site/api/resource/Product Bundle/$bundleName");

    final response = await http.get(
      url,
      headers: {"Cookie": cookie ?? "", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return ProductBundle.fromJson(json["data"]);
    }

    throw Exception("Unable to load bundle");
  }
}
