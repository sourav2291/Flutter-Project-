// models/transaction.dart

import 'package:flutter/foundation.dart';

class TransactionModel {
  final String name;
  final String paymentType;
  final String postingDate;
  final String partyType;
  final String party;
  final String partyName;

  // Customer address fetched from the ERPNext API.
  final String customerAddress;

  final double paidAmount;
  final double receivedAmount;
  final String paidFrom;
  final String paidTo;
  final String modeOfPayment;
  final String referenceNo;
  final String referenceDate;
  final String remarks;
  final String status;

  // ERPNext document submission status:
  // 0 = Draft, 1 = Submitted, 2 = Cancelled
  final int docstatus;

  // Custom Payment Entry status
  final String customStatusOfPayment;

  final String company;
  final String salesUser;
  final String creation;
  final String modified;

  final List<TransactionReference> references;

  TransactionModel({
    required this.name,
    required this.paymentType,
    required this.postingDate,
    required this.partyType,
    required this.party,
    required this.partyName,
    required this.customerAddress,
    required this.paidAmount,
    required this.receivedAmount,
    required this.paidFrom,
    required this.paidTo,
    required this.modeOfPayment,
    required this.referenceNo,
    required this.referenceDate,
    required this.remarks,
    required this.status,
    required this.docstatus,
    required this.customStatusOfPayment,
    required this.company,
    required this.salesUser,
    required this.creation,
    required this.modified,
    required this.references,
  });

  // Receipt is allowed only after ERPNext submission.
  bool get canDownloadReceipt => docstatus == 1;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final int parsedDocstatus = _toInt(json["docstatus"]);

    // TEMPORARY DEBUG LOG:
    // Check the raw API value and the parsed value.
    if (kDebugMode) {
      debugPrint(
        'PAYMENT ENTRY DEBUG | '
        'name=${json["name"]} | '
        'raw docstatus=${json["docstatus"]} | '
        'parsed docstatus=$parsedDocstatus | '
        'ERPNext status=${json["status"]}',
      );
    }

    return TransactionModel(
      name: json["name"]?.toString() ?? "",
      paymentType: json["payment_type"]?.toString() ?? "",
      postingDate: json["posting_date"]?.toString() ?? "",
      partyType: json["party_type"]?.toString() ?? "",
      party: json["party"]?.toString() ?? "",
      partyName: json["party_name"]?.toString() ?? "",

      // Read the address returned by the ERPNext API.
      customerAddress: json["customer_address"]?.toString() ?? "",

      paidAmount: _toDouble(json["paid_amount"]),
      receivedAmount: _toDouble(json["received_amount"]),
      paidFrom: json["paid_from"]?.toString() ?? "",
      paidTo: json["paid_to"]?.toString() ?? "",
      modeOfPayment: json["mode_of_payment"]?.toString() ?? "",
      referenceNo: json["reference_no"]?.toString() ?? "",
      referenceDate: json["reference_date"]?.toString() ?? "",
      remarks: json["remarks"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "",

      // Use the parsed ERPNext submission status.
      docstatus: parsedDocstatus,

      // Read custom_status_of_payment from ERPNext.
      customStatusOfPayment: json["custom_status_of_payment"]?.toString() ?? "",

      company: json["company"]?.toString() ?? "",
      salesUser: json["custom_sales_user"]?.toString() ?? "",
      creation: json["creation"]?.toString() ?? "",
      modified: json["modified"]?.toString() ?? "",

      references: (json["references"] as List? ?? [])
          .map(
            (e) => TransactionReference.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

class TransactionReference {
  final String referenceDoctype;
  final String referenceName;
  final double totalAmount;
  final double outstandingAmount;
  final double allocatedAmount;

  TransactionReference({
    required this.referenceDoctype,
    required this.referenceName,
    required this.totalAmount,
    required this.outstandingAmount,
    required this.allocatedAmount,
  });

  factory TransactionReference.fromJson(Map<String, dynamic> json) {
    return TransactionReference(
      referenceDoctype: json["reference_doctype"]?.toString() ?? "",
      referenceName: json["reference_name"]?.toString() ?? "",
      totalAmount: _toDouble(json["total_amount"]),
      outstandingAmount: _toDouble(json["outstanding_amount"]),
      allocatedAmount: _toDouble(json["allocated_amount"]),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
