// repositories/transaction_repository.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/transaction.dart';
import '../services/session_service.dart';

class TransactionRepository {
  Future<List<TransactionModel>> getMyPaymentEntries() async {
    final session = SessionService();

    final site = await session.getSite();
    final cookie = await session.getCookie();

    if (site == null || cookie == null) {
      throw Exception("Please login again.");
    }

    final response = await http.get(
      Uri.parse(
        "$site/api/method/madathilapp.madathilapp.api.get_my_payment_entries",
      ),
      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    if (kDebugMode) {
      debugPrint("========== PAYMENT ENTRY API ==========");
      debugPrint("Status: ${response.statusCode}");
      debugPrint("Body: ${response.body}");
    }

    if (response.statusCode != 200) {
      throw Exception("Unable to fetch Payment Entries\n${response.body}");
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception("Unexpected Payment Entry API response.");
    }

    final dynamic message = decoded["message"];

    if (message is! List) {
      throw Exception("Payment Entry API did not return a list in 'message'.");
    }

    final List<TransactionModel> transactions = [];

    for (final item in message) {
      if (item is! Map) continue;

      final Map<String, dynamic> json = Map<String, dynamic>.from(item);

      if (kDebugMode && json["name"]?.toString() == "ACC-PAY-2026-00021") {
        debugPrint(
          "TARGET API ITEM: ${jsonEncode({"name": json["name"], "docstatus": json["docstatus"], "status": json["status"], "custom_status_of_payment": json["custom_status_of_payment"]})}",
        );
      }

      final transaction = TransactionModel.fromJson(json);

      if (kDebugMode && transaction.name == "ACC-PAY-2026-00021") {
        debugPrint(
          "TARGET MODEL: "
          "name=${transaction.name}, "
          "docstatus=${transaction.docstatus}, "
          "status=${transaction.status}, "
          "canDownloadReceipt=${transaction.canDownloadReceipt}",
        );
      }

      transactions.add(transaction);
    }

    return transactions;
  }
}
