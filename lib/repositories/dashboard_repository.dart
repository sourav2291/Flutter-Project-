// repositories/dashboard_repository.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/dashboard_summary.dart';
import '../services/session_service.dart';

class DashboardRepository {
  // ==========================================================
  // COMMON SESSION DETAILS
  // ==========================================================

  Future<Map<String, String>> _getSessionDetails() async {
    final session = SessionService();

    final site = await session.getSite();
    final cookie = await session.getCookie();

    if (site == null ||
        site.trim().isEmpty ||
        cookie == null ||
        cookie.trim().isEmpty) {
      throw Exception('Session expired. Please log in again.');
    }

    return {'site': site.replaceAll(RegExp(r'/$'), ''), 'cookie': cookie};
  }

  // ==========================================================
  // PARSE COUNT RESPONSE
  // ==========================================================

  int _parseCountResponse(http.Response response, String description) {
    print('====================================');
    print(description);
    print('Status: ${response.statusCode}');
    print('Body  : ${response.body}');
    print('====================================');

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to fetch $description.\n'
        'Status: ${response.statusCode}\n'
        '${response.body}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid response received from $description.');
    }

    if (decoded['exc'] != null) {
      throw Exception('$description API error: ${decoded['exc']}');
    }

    final message = decoded['message'];

    if (message == null) {
      throw Exception('$description API returned no count.');
    }

    final count = int.tryParse(message.toString());

    if (count == null) {
      throw Exception('Invalid count returned by $description: $message');
    }

    return count;
  }

  // ==========================================================
  // GET COUNT FOR CURRENT USER
  // ==========================================================

  Future<int> getMyCount(String doctype, String field, String user) async {
    final details = await _getSessionDetails();

    final site = details['site']!;
    final cookie = details['cookie']!;

    final filters = jsonEncode([
      [doctype, field, '=', user],
    ]);

    final url = Uri.parse(
      '$site/api/method/frappe.client.get_count',
    ).replace(queryParameters: {'doctype': doctype, 'filters': filters});

    print('====================================');
    print('GET MY COUNT');
    print('Doctype: $doctype');
    print('Field  : $field');
    print('User   : $user');
    print('URL    : $url');
    print('====================================');

    final response = await http.get(
      url,
      headers: {'Cookie': cookie, 'Accept': 'application/json'},
    );

    return _parseCountResponse(response, '$doctype count');
  }

  // ==========================================================
  // GET GLOBAL COUNT
  // Used for shared records such as Product Bundle.
  // ==========================================================

  Future<int> getCount(String doctype) async {
    final details = await _getSessionDetails();

    final site = details['site']!;
    final cookie = details['cookie']!;

    final url = Uri.parse(
      '$site/api/method/frappe.client.get_count',
    ).replace(queryParameters: {'doctype': doctype});

    print('====================================');
    print('GET GLOBAL COUNT');
    print('Doctype: $doctype');
    print('URL    : $url');
    print('====================================');

    final response = await http.get(
      url,
      headers: {'Cookie': cookie, 'Accept': 'application/json'},
    );

    return _parseCountResponse(response, '$doctype global count');
  }

  // ==========================================================
  // GET SALES ORDERS COUNT
  // ==========================================================

  Future<int> getMySalesOrdersCount() async {
    final details = await _getSessionDetails();

    final site = details['site']!;
    final cookie = details['cookie']!;

    final url = Uri.parse(
      '$site/api/method/'
      'madathilapp.madathilapp.api.get_my_sales_orders_count',
    );

    print('====================================');
    print('GET MY SALES ORDERS COUNT');
    print('URL: $url');
    print('====================================');

    final response = await http.get(
      url,
      headers: {'Cookie': cookie, 'Accept': 'application/json'},
    );

    final count = _parseCountResponse(response, 'Sales Orders count');

    print('Sales Orders Count: $count');

    return count;
  }

  // ==========================================================
  // GET MATERIAL REQUESTS COUNT FOR CURRENT USER
  // Uses the existing backend API.
  // ==========================================================

  Future<int> getMyMaterialRequestsCount() async {
    final details = await _getSessionDetails();

    final site = details['site']!;
    final cookie = details['cookie']!;

    final url = Uri.parse(
      '$site/api/method/'
      'madathilapp.madathilapp.api.get_my_material_requests',
    );

    print('====================================');
    print('GET MY MATERIAL REQUESTS COUNT');
    print('URL: $url');
    print('====================================');

    final response = await http.get(
      url,
      headers: {'Cookie': cookie, 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to fetch Material Requests count.\n'
        'Status: ${response.statusCode}\n'
        '${response.body}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid response received from Material Requests API.');
    }

    if (decoded['exc'] != null) {
      throw Exception('Material Requests API error: ${decoded['exc']}');
    }

    final message = decoded['message'];

    if (message is! List) {
      throw Exception('Material Requests API did not return a list.');
    }

    final count = message.length;

    print('Material Requests Count: $count');

    return count;
  }

  // ==========================================================
  // LOAD DASHBOARD
  // Fetch all counts concurrently.
  // ==========================================================

  Future<DashboardSummary> loadDashboard() async {
    final session = SessionService();

    final user = await session.getUserName();

    if (user == null || user.trim().isEmpty) {
      throw Exception('Logged-in user not found.');
    }

    print('====================================');
    print('LOADING DASHBOARD');
    print('Logged-in user: $user');
    print('====================================');

    try {
      // Fetch all dashboard counts concurrently.
      final results = await Future.wait<int>([
        getMyCount('Lead', 'owner', user),
        getMyCount('Customer', 'custom_customer_owner', user),
        getMyCount('Quotation', 'custom_sales_person', user),
        getCount('Product Bundle'),
        getMySalesOrdersCount(),
        getMyMaterialRequestsCount(),
      ]);

      final leads = results[0];
      final customers = results[1];
      final quotations = results[2];
      final productBundles = results[3];
      final salesOrders = results[4];
      final materialRequests = results[5];

      print('====================================');
      print('DASHBOARD COUNTS');
      print('User              : $user');
      print('Leads             : $leads');
      print('Customers         : $customers');
      print('Quotations        : $quotations');
      print('Products          : $productBundles');
      print('Sales Orders      : $salesOrders');
      print('Material Requests : $materialRequests');
      print('====================================');

      return DashboardSummary(
        leads: leads,
        customers: customers,
        quotations: quotations,
        salesOrders: salesOrders,
        productBundles: productBundles,
        materialRequests: materialRequests,
      );
    } catch (e, stackTrace) {
      print('====================================');
      print('DASHBOARD LOADING FAILED');
      print('User : $user');
      print('Error: $e');
      print(stackTrace);
      print('====================================');

      rethrow;
    }
  }
}
