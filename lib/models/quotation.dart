// models/quotation.dart
class Quotation {
  final String name;
  final String customerName;
  final String transactionDate;
  final String validTill;
  final String status;
  final double grandTotal;
  final String company;

  final String? fileName;
  final String? fileUrl;

  Quotation({
    required this.name,
    required this.customerName,
    required this.transactionDate,
    required this.validTill,
    required this.status,
    required this.grandTotal,
    required this.company,
    this.fileName,
    this.fileUrl,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) {
    return Quotation(
      name: json["name"] ?? "",
      customerName: json["customer_name"] ?? "",
      transactionDate: json["transaction_date"] ?? "",
      validTill: json["valid_till"] ?? "",
      status: json["status"] ?? "",
      grandTotal: (json["grand_total"] ?? 0).toDouble(),
      company: json["company"] ?? "",

      // Read first attachment from attachments list
      fileName: (json["attachments"] as List?)?.isNotEmpty == true
          ? json["attachments"][0]["file_name"]
          : null,

      fileUrl: (json["attachments"] as List?)?.isNotEmpty == true
          ? json["attachments"][0]["file_url"]
          : null,
    );
  }
}
