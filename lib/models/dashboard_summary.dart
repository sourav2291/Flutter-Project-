// models/dashboard_summary.dart

class DashboardSummary {
  final int leads;
  final int customers;
  final int quotations;
  final int salesOrders;
  final int productBundles;
  final int materialRequests;

  DashboardSummary({
    required this.leads,
    required this.customers,
    required this.quotations,
    required this.salesOrders,
    required this.productBundles,
    required this.materialRequests,
  });
}
