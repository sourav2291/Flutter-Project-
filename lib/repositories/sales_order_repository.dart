// repositories/sales_order_repository.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sales_order.dart';
import '../services/session_service.dart';

class SalesOrderRepository {
  Future<List<SalesOrder>> getMySalesOrders() async {
    final session = SessionService();

    final site = await session.getSite();
    final cookie = await session.getCookie();

    if (site == null || cookie == null) {
      throw Exception("Please login again.");
    }

    final response = await http.get(
      Uri.parse(
        "$site/api/method/madathilapp.madathilapp.api.get_my_sales_orders",
      ),
      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Unable to fetch Sales Orders\n${response.body}");
    }

    final data = jsonDecode(response.body);

    print("========== SALES ORDER API ==========");
    print(data);

    final List list = data["message"]["sales_orders"];

    return list.map((e) => SalesOrder.fromJson(e)).toList();
  }
}
