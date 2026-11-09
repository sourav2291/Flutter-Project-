// models/sales_order.dart

// models/sales_order.dart

class SalesOrder {
  final String name;
  final String customer;
  final DateTime transactionDate;
  final DateTime? deliveryDate;
  final String status;
  final double grandTotal;

  // PAYMENT SUMMARY
  final double amountReceived;
  final double outstandingAmount;

  final String company;
  final String salesUser;

  // SALES ORDER USER FIELDS
  final String executiveName;
  final String closingExecutive;

  // FRANCHISE DETAILS
  final String franchiseName;
  final double franchiseCommission;

  // APPLICANT COMMISSION DETAILS
  final List<SalesOrderCommissionDetail> commissionDetails;

  final List<SalesOrderItem> items;

  final String? fileName;
  final String? fileUrl;

  SalesOrder({
    required this.name,
    required this.customer,
    required this.transactionDate,
    this.deliveryDate,
    required this.status,
    required this.grandTotal,

    // PAYMENT SUMMARY
    this.amountReceived = 0.0,
    this.outstandingAmount = 0.0,

    required this.company,
    required this.salesUser,
    required this.executiveName,
    required this.closingExecutive,
    required this.franchiseName,
    required this.franchiseCommission,
    required this.commissionDetails,
    required this.items,
    this.fileName,
    this.fileUrl,
  });

  factory SalesOrder.fromJson(Map<String, dynamic> json) {
    return SalesOrder(
      // ----------------------------------------------------------
      // BASIC SALES ORDER DETAILS
      // ----------------------------------------------------------
      name: json["name"]?.toString() ?? "",

      customer: json["customer"]?.toString() ?? "",

      transactionDate:
          DateTime.tryParse(json["transaction_date"]?.toString() ?? "") ??
          DateTime(2000),

      deliveryDate:
          json["delivery_date"] != null &&
              json["delivery_date"].toString().isNotEmpty
          ? DateTime.tryParse(json["delivery_date"].toString())
          : null,

      status: json["status"]?.toString() ?? "",

      grandTotal: _toDouble(json["grand_total"]),

      // ----------------------------------------------------------
      // PAYMENT SUMMARY
      // These values must be returned by the backend API.
      // ----------------------------------------------------------
      amountReceived: _toDouble(json["amount_received"]),

      outstandingAmount: _toDouble(json["outstanding_amount"]),

      // ----------------------------------------------------------
      // COMPANY AND SALES USER
      // ----------------------------------------------------------
      company: json["company"]?.toString() ?? "",

      salesUser: json["custom_sales_user"]?.toString() ?? "",

      // ----------------------------------------------------------
      // SALES ORDER USER FIELDS
      // ----------------------------------------------------------
      executiveName: json["custom_executive_name"]?.toString() ?? "",

      closingExecutive: json["custom_closing_executive"]?.toString() ?? "",

      // ----------------------------------------------------------
      // FRANCHISE DETAILS
      // ----------------------------------------------------------
      franchiseName: json["custom_franchise_name"]?.toString() ?? "",

      franchiseCommission: _toDouble(json["custom_franchise_commission"]),

      // ----------------------------------------------------------
      // APPLICANT COMMISSION DETAILS
      // ----------------------------------------------------------
      commissionDetails: (json["commission_details"] as List? ?? [])
          .whereType<Map>()
          .map(
            (e) => SalesOrderCommissionDetail.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),

      // ----------------------------------------------------------
      // SALES ORDER ITEMS
      // ----------------------------------------------------------
      items: (json["items"] as List? ?? [])
          .whereType<Map>()
          .map((e) => SalesOrderItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),

      // ----------------------------------------------------------
      // ATTACHMENT
      // ----------------------------------------------------------
      fileName: (json["attachments"] as List?)?.isNotEmpty == true
          ? json["attachments"][0]["file_name"]?.toString()
          : null,

      fileUrl: (json["attachments"] as List?)?.isNotEmpty == true
          ? json["attachments"][0]["file_url"]?.toString()
          : null,
    );
  }

  // ============================================================
  // SAFE DOUBLE CONVERSION
  // ============================================================

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }
}

// ============================================================
// APPLICANT COMMISSION DETAIL
// ============================================================

class SalesOrderCommissionDetail {
  final String points;
  final String user;

  SalesOrderCommissionDetail({required this.points, required this.user});

  factory SalesOrderCommissionDetail.fromJson(Map<String, dynamic> json) {
    return SalesOrderCommissionDetail(
      points: json["points"]?.toString() ?? "",
      user: json["user"]?.toString() ?? "",
    );
  }
}

// ============================================================
// SALES ORDER ITEM
// ============================================================

class SalesOrderItem {
  final String itemCode;
  final String itemName;
  final String description;
  final double qty;
  final String uom;
  final double rate;
  final double amount;

  SalesOrderItem({
    required this.itemCode,
    required this.itemName,
    required this.description,
    required this.qty,
    required this.uom,
    required this.rate,
    required this.amount,
  });

  factory SalesOrderItem.fromJson(Map<String, dynamic> json) {
    return SalesOrderItem(
      itemCode: json["item_code"]?.toString() ?? "",

      itemName: json["item_name"]?.toString() ?? "",

      description: json["description"]?.toString() ?? "",

      qty: _toDouble(json["qty"]),

      uom: json["uom"]?.toString() ?? "",

      rate: _toDouble(json["rate"]),

      amount: _toDouble(json["amount"]),
    );
  }

  // ============================================================
  // SAFE DOUBLE CONVERSION
  // ============================================================

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }
}
