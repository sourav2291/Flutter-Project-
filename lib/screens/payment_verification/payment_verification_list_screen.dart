// screens/payment_verification/payment_verification_list_screen.dart

import 'package:flutter/material.dart';

import '../../models/payment_verification.dart';
import '../../repositories/payment_verification_repository.dart';
import 'create_payment_verification_screen.dart';

class PaymentVerificationListScreen extends StatefulWidget {
  const PaymentVerificationListScreen({super.key});

  @override
  State<PaymentVerificationListScreen> createState() =>
      _PaymentVerificationListScreenState();
}

class _PaymentVerificationListScreenState
    extends State<PaymentVerificationListScreen>
    with SingleTickerProviderStateMixin {
  // ==========================================================
  // REPOSITORY
  // ==========================================================

  final PaymentVerificationRepository repository =
      PaymentVerificationRepository();

  // ==========================================================
  // DATA
  // ==========================================================

  List<PaymentVerification> payments = [];

  bool loading = true;

  String? errorMessage;

  // ==========================================================
  // ANIMATION
  // ==========================================================

  late AnimationController _animationController;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);

    loadPayments();
  }
  // ==========================================================
  // LOAD PAYMENT VERIFICATIONS
  // ==========================================================

  Future<void> loadPayments() async {
    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    try {
      final data = await repository.getPaymentVerifications();

      if (!mounted) return;

      setState(() {
        payments = data;
        loading = false;
      });
    } catch (e) {
      debugPrint("PAYMENT VERIFICATION LOAD ERROR: $e");

      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  // ==========================================================
  // OPEN CREATE SCREEN
  // ==========================================================

  Future<void> openCreateScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreatePaymentVerificationScreen(),
      ),
    );

    // Refresh list after successful creation.
    if (result == true) {
      await loadPayments();
    }
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061F24),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Payment Verification",
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),

        centerTitle: true,

        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: loading ? null : loadPayments,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: openCreateScreen,
        backgroundColor: const Color(0xFF1DB954),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "New Payment",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: Stack(
        children: [
          _buildAnimatedBackground(),

          SafeArea(
            top: false,
            child: RefreshIndicator(
              onRefresh: loadPayments,
              color: const Color(0xFF1DB954),
              backgroundColor: const Color(0xFF103F39),
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }
  // ==========================================================
  // BODY
  // ==========================================================

  Widget _buildBody() {
    if (loading && payments.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        children: [
          _buildLoadingCard(),
          const SizedBox(height: 12),
          _buildLoadingCard(),
          const SizedBox(height: 12),
          _buildLoadingCard(),
        ],
      );
    }

    if (errorMessage != null && payments.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 80),

          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFF8A80),
            size: 60,
          ),

          const SizedBox(height: 16),

          const Text(
            "Unable to load Payment Verifications",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),

          const SizedBox(height: 22),

          Center(
            child: ElevatedButton.icon(
              onPressed: loadPayments,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("TRY AGAIN"),
            ),
          ),
        ],
      );
    }

    if (payments.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 80),

          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1DB954).withValues(alpha: 0.12),
              border: Border.all(
                color: const Color(0xFF7EE787).withValues(alpha: 0.20),
              ),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: Color(0xFF7EE787),
              size: 45,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "No Payment Verifications",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "Create your first payment verification using the button below.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),

          const SizedBox(height: 25),

          Center(
            child: ElevatedButton.icon(
              onPressed: openCreateScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                "CREATE PAYMENT VERIFICATION",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPaymentCard(payment, index),
        );
      },
    );
  }
  // ==========================================================
  // PAYMENT CARD
  // ==========================================================

  Widget _buildPaymentCard(PaymentVerification payment, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1.0),
      duration: Duration(milliseconds: 350 + (index * 40)),
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  _showPaymentDetails(payment);
                },
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      // ==========================================
                      // TOP ROW
                      // ==========================================
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1DB954), Color(0xFF0B5E4D)],
                              ),
                            ),
                            child: const Icon(
                              Icons.payments_rounded,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  payment.customerName.isNotEmpty
                                      ? payment.customerName
                                      : payment.customer,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  payment.customer.isNotEmpty
                                      ? payment.customer
                                      : "Customer not available",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          _buildStatusBadge(payment.workflowState),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Container(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.10),
                      ),

                      const SizedBox(height: 12),

                      // ==========================================
                      // AMOUNT + TOTAL PROJECT COST
                      // ==========================================
                      Row(
                        children: [
                          Expanded(
                            child: _buildSmallDetail(
                              Icons.currency_rupee_rounded,
                              "Amount",
                              _formatCurrency(payment.amount),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _buildSmallDetail(
                              Icons.account_balance_wallet_rounded,
                              "Total Project",
                              _formatCurrency(payment.totalProjectCost),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ==========================================
                      // KW + PLACE
                      // ==========================================
                      Row(
                        children: [
                          Expanded(
                            child: _buildSmallDetail(
                              Icons.bolt_rounded,
                              "KW",
                              payment.kw,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _buildSmallDetail(
                              Icons.location_on_rounded,
                              "Place",
                              payment.place,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ==========================================
                      // UTR + MANAGER
                      // ==========================================
                      Row(
                        children: [
                          Expanded(
                            child: _buildSmallDetail(
                              Icons.confirmation_number_rounded,
                              "UTR",
                              payment.utrNumber,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _buildSmallDetail(
                              Icons.person_rounded,
                              "Manager",
                              payment.managerName.isNotEmpty
                                  ? payment.managerName
                                  : payment.salesManager,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ==========================================
                      // FILE INDICATORS
                      // ==========================================
                      Row(
                        children: [
                          if (payment.transactionImage.isNotEmpty)
                            _buildImageIndicator(
                              Icons.receipt_long_rounded,
                              "Transaction",
                            ),

                          if (payment.transactionImage.isNotEmpty &&
                              payment.chequeImage.isNotEmpty)
                            const SizedBox(width: 8),

                          if (payment.chequeImage.isNotEmpty)
                            _buildImageIndicator(Icons.image_rounded, "Cheque"),

                          const Spacer(),

                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white54,
                            size: 15,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // WORKFLOW STATUS BADGE
  // ==========================================================

  Widget _buildStatusBadge(String workflowState) {
    final status = workflowState.trim().isEmpty
        ? "Pending"
        : workflowState.trim();

    final normalized = status.toLowerCase();

    final bool approved = normalized == "approved";
    final bool rejected = normalized == "rejected";
    final bool pending = normalized == "pending";

    Color iconColor;
    Color backgroundColor;
    IconData icon;

    if (approved) {
      iconColor = const Color(0xFF7EE787);
      backgroundColor = const Color(0xFF1DB954).withValues(alpha: 0.15);
      icon = Icons.check_circle_rounded;
    } else if (rejected) {
      iconColor = const Color(0xFFFF8A80);
      backgroundColor = const Color(0xFFFF5252).withValues(alpha: 0.15);
      icon = Icons.cancel_rounded;
    } else if (pending) {
      iconColor = const Color(0xFFFFD166);
      backgroundColor = const Color(0xFFFFD166).withValues(alpha: 0.15);
      icon = Icons.pending_rounded;
    } else {
      iconColor = const Color(0xFF7EE787);
      backgroundColor = const Color(0xFF7EE787).withValues(alpha: 0.12);
      icon = Icons.info_outline_rounded;
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 105),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 15),

          const SizedBox(width: 5),

          Flexible(
            child: Text(
              status,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: iconColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FORMAT CURRENCY
  // ==========================================================

  String _formatCurrency(String value) {
    final number = double.tryParse(value.trim());

    if (number == null) {
      return value.trim().isEmpty ? "-" : value.trim();
    }

    return "₹${number.toStringAsFixed(2)}";
  }
  // ==========================================================
  // SMALL DETAIL
  // ==========================================================

  Widget _buildSmallDetail(IconData icon, String label, String value) {
    final displayValue = value.trim().isEmpty ? "-" : value.trim();

    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7EE787), size: 17),

        const SizedBox(width: 7),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                displayValue,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // IMAGE INDICATOR
  // ==========================================================

  Widget _buildImageIndicator(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF7EE787), size: 14),

          const SizedBox(width: 5),

          Text(
            text,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DETAILS BOTTOM SHEET
  // ==========================================================

  void _showPaymentDetails(PaymentVerification payment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF103D39),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF1DB954), Color(0xFF0B5E4D)],
                        ),
                      ),
                      child: const Icon(
                        Icons.payments_rounded,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Text(
                        "Payment Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // WORKFLOW STATUS
                _buildDetailStatus(payment.workflowState),

                const SizedBox(height: 16),

                _buildDetailRow(
                  "Customer",
                  payment.customerName.isNotEmpty
                      ? payment.customerName
                      : payment.customer,
                ),

                _buildDetailRow("Customer ID", payment.customer),

                _buildDetailRow("Amount", _formatCurrency(payment.amount)),

                _buildDetailRow(
                  "Total Project Cost",
                  _formatCurrency(payment.totalProjectCost),
                ),

                _buildDetailRow("KW", payment.kw),

                _buildDetailRow("Place", payment.place),

                _buildDetailRow("UTR Number", payment.utrNumber),

                _buildDetailRow("Cheque Number", payment.chequeNumber),

                _buildDetailRow("Sales Manager", payment.salesManager),

                _buildDetailRow("Manager Name", payment.managerName),

                const SizedBox(height: 12),

                if (payment.transactionImage.isNotEmpty)
                  _buildFileRow(
                    Icons.receipt_long_rounded,
                    "Transaction Image",
                  ),

                if (payment.chequeImage.isNotEmpty)
                  _buildFileRow(Icons.image_rounded, "Cheque Image"),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // DETAIL STATUS
  // ==========================================================

  Widget _buildDetailStatus(String workflowState) {
    final status = workflowState.trim().isEmpty
        ? "Pending"
        : workflowState.trim();

    final normalized = status.toLowerCase();

    final bool approved = normalized == "approved";
    final bool rejected = normalized == "rejected";

    final Color color = approved
        ? const Color(0xFF7EE787)
        : rejected
        ? const Color(0xFFFF8A80)
        : const Color(0xFFFFD166);

    final IconData icon = approved
        ? Icons.check_circle_rounded
        : rejected
        ? Icons.cancel_rounded
        : Icons.pending_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),

          const SizedBox(width: 10),

          const Text(
            "Workflow Status",
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),

          const Spacer(),

          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DETAIL ROW
  // ==========================================================

  Widget _buildDetailRow(String label, String value) {
    final displayValue = value.trim().isEmpty ? "-" : value.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              displayValue,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FILE ROW
  // ==========================================================

  Widget _buildFileRow(IconData icon, String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7EE787), size: 21),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF7EE787),
            size: 19,
          ),
        ],
      ),
    );
  }
  // ==========================================================
  // LOADING CARD
  // ==========================================================

  Widget _buildLoadingCard() {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF7EE787)),
      ),
    );
  }

  // ==========================================================
  // ANIMATED BACKGROUND
  // ==========================================================

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final value = _animationController.value;

        return Stack(
          children: [
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

            Positioned(
              top: -80 + (value * 30),
              left: -110,
              child: _buildGlow(size: 280, color: const Color(0xFF1DB954)),
            ),

            Positioned(
              top: 120 - (value * 25),
              right: -120,
              child: _buildGlow(size: 310, color: const Color(0xFFFFD166)),
            ),

            Positioned(
              bottom: 80 + (value * 30),
              left: 60,
              child: _buildGlow(size: 240, color: const Color(0xFF7EE787)),
            ),

            Positioned(
              top: 190 + (value * 25),
              right: 15,
              child: Transform.rotate(
                angle: -0.25 + (value * 0.12),
                child: const Icon(
                  Icons.payments_rounded,
                  size: 52,
                  color: Color(0x447EE787),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // GLOW
  // ==========================================================

  Widget _buildGlow({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.28),
              color.withValues(alpha: 0.08),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
