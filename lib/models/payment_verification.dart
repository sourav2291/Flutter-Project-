// models/payment_verification.dart

class PaymentVerification {
  final String name;

  final String customer;
  final String customerName;

  final String kw;
  final String place;

  // PAYMENT DETAILS
  final String amount;
  final String totalProjectCost;

  final String utrNumber;

  final String transactionImage;

  final String chequeNumber;
  final String chequeImage;

  // SALES MANAGER
  final String salesManager;
  final String managerName;

  // WORKFLOW STATUS
  final String workflowState;

  // KEEPING THESE FOR COMPATIBILITY
  // We can remove them from the UI/API after we update
  // the remaining Payment Verification files.
  final bool accountsVerified;
  final String accountsVerifiedPerson;

  PaymentVerification({
    required this.name,
    required this.customer,
    required this.customerName,
    required this.kw,
    required this.place,
    required this.amount,
    required this.totalProjectCost,
    required this.utrNumber,
    required this.transactionImage,
    required this.chequeNumber,
    required this.chequeImage,
    required this.salesManager,
    required this.managerName,
    required this.workflowState,
    required this.accountsVerified,
    required this.accountsVerifiedPerson,
  });

  factory PaymentVerification.fromJson(Map<String, dynamic> json) {
    return PaymentVerification(
      // ==========================================================
      // BASIC
      // ==========================================================
      name: json["name"]?.toString() ?? "",

      customer: json["customer"]?.toString() ?? "",

      customerName: json["customer_name"]?.toString() ?? "",

      kw: json["kw"]?.toString() ?? "",

      place: json["place"]?.toString() ?? "",

      // ==========================================================
      // PAYMENT DETAILS
      // ==========================================================
      amount: json["amount"]?.toString() ?? "0",

      totalProjectCost: json["total_project_cost"]?.toString() ?? "0",

      utrNumber: json["utr_number"]?.toString() ?? "",

      transactionImage: json["transaction_image"]?.toString() ?? "",

      chequeNumber: json["cheque_number"]?.toString() ?? "",

      chequeImage: json["cheque_image"]?.toString() ?? "",

      // ==========================================================
      // SALES MANAGER
      // ==========================================================
      salesManager: json["sales_manager"]?.toString() ?? "",

      managerName: json["manager_name"]?.toString() ?? "",

      // ==========================================================
      // WORKFLOW STATUS
      // ==========================================================
      workflowState: json["workflow_state"]?.toString() ?? "Pending",

      // ==========================================================
      // OLD ACCOUNTS VERIFICATION FIELDS
      // ==========================================================
      accountsVerified:
          json["accounts_verified"] == 1 ||
          json["accounts_verified"] == true ||
          json["accounts_verified"]?.toString() == "1",

      accountsVerifiedPerson:
          json["accounts_verified_person"]?.toString() ?? "",
    );
  }
}
