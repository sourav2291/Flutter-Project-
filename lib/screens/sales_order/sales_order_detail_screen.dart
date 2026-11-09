// screens/sales_order/sales_order_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/sales_order.dart';
import '../../repositories/transaction_repository.dart';
import '../../services/download_service.dart';
import '../../services/session_service.dart';
import '../../widgets/glass_card.dart';
import '../quotation/pdf_viewer_screen.dart';
import '../transaction/transaction_list_screen.dart';
import '../payment/payment_entry_screen.dart';

class SalesOrderDetailScreen extends StatefulWidget {
  final SalesOrder salesOrder;

  const SalesOrderDetailScreen({super.key, required this.salesOrder});

  @override
  State<SalesOrderDetailScreen> createState() => _SalesOrderDetailScreenState();
}

class _SalesOrderDetailScreenState extends State<SalesOrderDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  SalesOrder get salesOrder => widget.salesOrder;

  // Payment summary state
  double amountReceived = 0.0;
  bool isPaymentLoading = true;
  String? paymentError;

  // Load submitted payments created by the logged-in sales person
  // and allocated directly against this Sales Order.
  Future<void> _loadPaymentSummary() async {
    if (mounted) {
      setState(() {
        isPaymentLoading = true;
        paymentError = null;
      });
    }

    try {
      final transactions = await TransactionRepository().getMyPaymentEntries();

      double totalReceived = 0.0;

      for (final payment in transactions) {
        // Only submitted Payment Entries count as received payments.
        if (payment.docstatus != 1) continue;

        for (final reference in payment.references) {
          if (reference.referenceDoctype == "Sales Order" &&
              reference.referenceName == salesOrder.name) {
            totalReceived += reference.allocatedAmount;
          }
        }
      }

      if (!mounted) return;

      setState(() {
        amountReceived = totalReceived;
        isPaymentLoading = false;
        paymentError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isPaymentLoading = false;
        paymentError = e.toString();
      });

      debugPrint("Payment Summary Error: $e");
    }
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _loadPaymentSummary();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // VIEW SALES ORDER
  // ============================================================

  Future<void> _viewSalesOrder(BuildContext context) async {
    if (salesOrder.fileUrl == null || salesOrder.fileUrl!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No Attachment Found")));
      return;
    }

    final session = SessionService();
    final site = await session.getSite();

    if (site == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Site URL not found")));
      return;
    }

    final pdfUrl = "$site${salesOrder.fileUrl!}";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
          url: pdfUrl,
          title: salesOrder.fileName ?? salesOrder.name,
        ),
      ),
    );
  }

  // ============================================================
  // DOWNLOAD SALES ORDER
  // ============================================================

  Future<void> _downloadSalesOrder(BuildContext context) async {
    if (salesOrder.fileUrl == null || salesOrder.fileUrl!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No Attachment Found")));
      return;
    }

    final session = SessionService();
    final site = await session.getSite();

    if (site == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Site URL not found")));
      return;
    }

    await DownloadService.downloadFile(
      context: context,
      url: "$site${salesOrder.fileUrl!}",
      fileName: salesOrder.fileName ?? "${salesOrder.name}.pdf",
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041A1F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 27),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Sales Order Details",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderHeader(),
                  const SizedBox(height: 16),

                  // PAYMENT SUMMARY
                  _buildSectionTitle(
                    "Payment Summary",
                    Icons.account_balance_wallet_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentSummary(),
                  const SizedBox(height: 22),

                  // BASIC INFORMATION
                  _buildSectionTitle(
                    "Order Information",
                    Icons.receipt_long_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildInformationCard(),
                  const SizedBox(height: 22),

                  // COMMISSION DETAILS
                  if (salesOrder.commissionDetails.isNotEmpty) ...[
                    _buildSectionTitle(
                      "Commission Details",
                      Icons.workspace_premium_rounded,
                    ),
                    const SizedBox(height: 10),
                    _buildCommissionDetailsCard(),
                    const SizedBox(height: 22),
                  ],

                  // ITEMS
                  _buildSectionTitle("Items", Icons.inventory_2_rounded),
                  const SizedBox(height: 10),
                  if (salesOrder.items.isEmpty)
                    _buildNoItems()
                  else
                    ...salesOrder.items.asMap().entries.map(
                      (entry) => _buildItemCard(entry.value, entry.key),
                    ),

                  const SizedBox(height: 22),

                  // ATTACHMENT
                  _buildAttachmentSection(),
                  const SizedBox(height: 20),

                  // BUTTONS
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ORDER HEADER
  // ============================================================

  Widget _buildOrderHeader() {
    return GlassCard(
      radius: 25,
      blur: 15,
      opacity: 0.13,
      tint: Colors.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1DB954), Color(0xFF0B5E4D)],
                  ),
                  border: Border.all(
                    color: const Color(0xFF7EE787).withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1DB954).withValues(alpha: 0.25),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_cart_rounded,
                  color: Colors.white,
                  size: 31,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sales Order",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      salesOrder.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    _buildStatusChip(salesOrder.status),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.10)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildHeaderStat(
                  Icons.person_rounded,
                  "Customer",
                  salesOrder.customer,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHeaderStat(
                  Icons.currency_rupee_rounded,
                  "Grand Total",
                  "₹ ${salesOrder.grandTotal.toStringAsFixed(2)}",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER STAT
  // ============================================================

  Widget _buildHeaderStat(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7EE787), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.42),
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF1DB954).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: const Color(0xFF7EE787).withValues(alpha: 0.15),
            ),
          ),
          child: Icon(icon, color: const Color(0xFF7EE787), size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAYMENT SUMMARY
  // ============================================================

  Widget _buildPaymentSummary() {
    final double projectCost = salesOrder.grandTotal;

    final double balanceAmount = (projectCost - amountReceived)
        .clamp(0.0, double.infinity)
        .toDouble();

    return GlassCard(
      radius: 22,
      blur: 13,
      opacity: 0.10,
      tint: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPaymentLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: CircularProgressIndicator(color: Color(0xFF7EE787)),
              ),
            )
          else if (paymentError != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoTile(
                  "Project Cost",
                  "₹ ${projectCost.toStringAsFixed(2)}",
                  Icons.account_balance_wallet_rounded,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Unable to load payment details.",
                  style: TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _loadPaymentSummary,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Color(0xFF7EE787),
                  ),
                  label: const Text(
                    "Retry",
                    style: TextStyle(color: Color(0xFF7EE787)),
                  ),
                ),
              ],
            )
          else ...[
            _buildInfoTile(
              "Project Cost",
              "₹ ${projectCost.toStringAsFixed(2)}",
              Icons.account_balance_wallet_rounded,
            ),
            _buildInfoTile(
              "Amount Received",
              "₹ ${amountReceived.toStringAsFixed(2)}",
              Icons.payments_rounded,
            ),
            _buildInfoTile(
              "Balance Amount",
              "₹ ${balanceAmount.toStringAsFixed(2)}",
              Icons.pending_actions_rounded,
              isLast: true,
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _buildInformationCard() {
    return GlassCard(
      radius: 22,
      blur: 13,
      opacity: 0.10,
      tint: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoTile("Customer", salesOrder.customer, Icons.person_rounded),
          _buildInfoTile(
            "Transaction Date",
            DateFormat("dd-MM-yyyy").format(salesOrder.transactionDate),
            Icons.calendar_month_rounded,
          ),
          _buildInfoTile(
            "Delivery Date",
            salesOrder.deliveryDate == null
                ? "-"
                : DateFormat("dd-MM-yyyy").format(salesOrder.deliveryDate!),
            Icons.local_shipping_rounded,
          ),
          _buildInfoTile("Company", salesOrder.company, Icons.business_rounded),
          _buildInfoTile(
            "Franchise Name",
            salesOrder.franchiseName,
            Icons.store_rounded,
          ),
          _buildInfoTile(
            "Franchise Commission",
            "₹ ${salesOrder.franchiseCommission.toStringAsFixed(2)}",
            Icons.account_balance_wallet_rounded,
          ),
          _buildInfoTile(
            "Sales User",
            salesOrder.salesUser,
            Icons.account_circle_rounded,
          ),
          _buildInfoTile(
            "Executive Name",
            salesOrder.executiveName,
            Icons.person_outline_rounded,
          ),
          _buildInfoTile(
            "Closing Executive",
            salesOrder.closingExecutive,
            Icons.person_pin_circle_outlined,
          ),
          _buildInfoTile(
            "Status",
            salesOrder.status,
            Icons.verified_rounded,
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATION TILE
  // ============================================================

  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Icon(icon, color: const Color(0xFF7EE787), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.43),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value.isEmpty ? "-" : value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
      ],
    );
  }
  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMMISSION DETAILS CARD
  // ============================================================

  Widget _buildCommissionDetailsCard() {
    return GlassCard(
      radius: 22,
      blur: 13,
      opacity: 0.10,
      tint: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: salesOrder.commissionDetails.asMap().entries.map((entry) {
          final index = entry.key;
          final detail = entry.value;

          return _buildCommissionDetailTile(
            user: detail.user,
            points: detail.points,
            isLast: index == salesOrder.commissionDetails.length - 1,
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // COMMISSION DETAIL TILE
  // ============================================================

  Widget _buildCommissionDetailTile({
    required String user,
    required String points,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF7EE787),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "User",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.43),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.isEmpty ? "-" : user,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF7EE787).withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "Points",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.43),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      points.isEmpty ? "0" : points,
                      style: const TextStyle(
                        color: Color(0xFF7EE787),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
      ],
    );
  }

  // ============================================================
  // ITEM CARD
  // ============================================================

  Widget _buildItemCard(dynamic item, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 350 + (index * 80)),
        tween: Tween(begin: 0, end: 1),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 15 * (1 - value)),
              child: child,
            ),
          );
        },
        child: GlassCard(
          radius: 21,
          blur: 12,
          opacity: 0.10,
          tint: Colors.white,
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1DB954).withValues(alpha: 0.16),
                          const Color(0xFF7EE787).withValues(alpha: 0.07),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFF7EE787).withValues(alpha: 0.16),
                      ),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: Color(0xFF7EE787),
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.itemCode,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.42),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // DESCRIPTION
              Text(
                "Description",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.42),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                item.description.isEmpty ? "-" : item.description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.07)),
              const SizedBox(height: 13),
              Row(
                children: [
                  _buildMiniInfo("Qty", "${item.qty}"),
                  _buildMiniInfo("UOM", item.uom),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildMiniInfo("Rate", "₹ ${item.rate.toStringAsFixed(2)}"),
                  _buildMiniInfo(
                    "Amount",
                    "₹ ${item.amount.toStringAsFixed(2)}",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NO ITEMS
  // ============================================================

  Widget _buildNoItems() {
    return GlassCard(
      radius: 20,
      blur: 12,
      opacity: 0.09,
      tint: Colors.white,
      padding: const EdgeInsets.all(25),
      child: const Center(
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF7EE787),
              size: 40,
            ),
            SizedBox(height: 10),
            Text(
              "No Items Found",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ATTACHMENT SECTION
  // ============================================================

  Widget _buildAttachmentSection() {
    final hasAttachment =
        salesOrder.fileUrl != null && salesOrder.fileUrl!.isNotEmpty;

    return GlassCard(
      radius: 22,
      blur: 13,
      opacity: 0.11,
      tint: Colors.white,
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Color(0xFFFF6B6B),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Attachment",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.insert_drive_file_rounded,
                  color: Color(0xFFFF6B6B),
                  size: 20,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    salesOrder.fileName ?? "No Attachment",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hasAttachment ? Colors.white : Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (hasAttachment)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF7EE787),
                    size: 18,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // ACTION BUTTONS
  // ============================================================

  Widget _buildActionButtons() {
    final hasAttachment =
        salesOrder.fileUrl != null && salesOrder.fileUrl!.isNotEmpty;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: hasAttachment ? () => _viewSalesOrder(context) : null,
            icon: const Icon(Icons.visibility_rounded),
            label: const Text(
              "View Attachement",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DB954),
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.06),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white30,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: hasAttachment
                ? () => _downloadSalesOrder(context)
                : null,
            icon: const Icon(Icons.download_rounded),
            label: const Text(
              "Download Attachement",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7EE787),
              disabledForegroundColor: Colors.white30,
              side: BorderSide(
                color: const Color(0xFF7EE787).withValues(alpha: 0.35),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TransactionListScreen(salesOrderName: salesOrder.name),
                ),
              );
            },
            icon: const Icon(Icons.receipt_long_rounded),
            label: const Text(
              "Transaction",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7EE787),
              side: BorderSide(
                color: const Color(0xFF7EE787).withValues(alpha: 0.35),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentEntryScreen(salesOrder: salesOrder),
                ),
              );

              // Refresh payment summary when returning from Payment Entry.
              if (mounted) {
                await _loadPaymentSummary();
              }
            },
            icon: const Icon(Icons.payment_rounded),
            label: const Text(
              "Payment Entry",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7EE787),
              side: BorderSide(
                color: const Color(0xFF7EE787).withValues(alpha: 0.35),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MINI INFO
  // ============================================================

  Widget _buildMiniInfo(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.40),
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ANIMATED BACKGROUND
  // ============================================================

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final value = _animationController.value;

        return Stack(
          children: [
            // MAIN GRADIENT
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF041A1F),
                    Color(0xFF073D3A),
                    Color(0xFF0B5E4D),
                    Color(0xFF102F2D),
                  ],
                ),
              ),
            ),

            // GREEN GLOW
            Positioned(
              top: -110 + (value * 35),
              left: -120,
              child: _buildGlow(size: 300, color: const Color(0xFF1DB954)),
            ),

            // GOLD GLOW
            Positioned(
              top: 170 - (value * 30),
              right: -130,
              child: _buildGlow(size: 300, color: const Color(0xFFFFD166)),
            ),

            // BOTTOM GLOW
            Positioned(
              bottom: -150 + (value * 20),
              left: -40,
              child: _buildGlow(size: 320, color: const Color(0xFF7EE787)),
            ),

            // FLOATING LEAF
            Positioned(
              top: 300 + (value * 35),
              right: 5,
              child: Transform.rotate(
                angle: -0.25 + (value * 0.15),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 68,
                  color: Color(0x447EE787),
                ),
              ),
            ),

            // SECOND LEAF
            Positioned(
              bottom: 200 - (value * 25),
              left: -5,
              child: Transform.rotate(
                angle: 0.30 - (value * 0.12),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 48,
                  color: Color(0x44FFD166),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // GLOW
  // ============================================================

  Widget _buildGlow({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.25),
              color.withValues(alpha: 0.07),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "submitted":
      case "completed":
      case "completed order":
        return const Color(0xFF7EE787);

      case "cancelled":
      case "closed":
        return const Color(0xFFFF6B6B);

      case "on hold":
      case "hold":
        return const Color(0xFFFFD166);

      default:
        return const Color(0xFF64B5F6);
    }
  }
}
