// screens/quotation/quotation_list_screen.dart

import 'package:flutter/material.dart';

import '../../models/quotation.dart';
import '../../repositories/quotation_repository.dart';
import '../../widgets/glass_card.dart';
import 'quotation_detail_screen.dart';

class QuotationListScreen extends StatefulWidget {
  const QuotationListScreen({super.key});

  @override
  State<QuotationListScreen> createState() => _QuotationListScreenState();
}

class _QuotationListScreenState extends State<QuotationListScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // EXISTING LOGIC
  // ============================================================

  final QuotationRepository repository = QuotationRepository();

  List<Quotation> quotations = [];

  bool isLoading = true;

  // ============================================================
  // ANIMATION
  // ============================================================

  late AnimationController _animationController;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    loadQuotations();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD QUOTATIONS
  // ============================================================

  Future<void> loadQuotations() async {
    try {
      quotations = await repository.getMyQuotations();
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFF8B2E2E),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041A1F),

      // ==========================================================
      // APP BAR
      // ==========================================================
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
          "My Quotations",
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
            onPressed: isLoading
                ? null
                : () {
                    setState(() {
                      isLoading = true;
                    });

                    loadQuotations();
                  },
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: Stack(
        children: [
          // Animated background
          _buildBackground(),

          SafeArea(
            top: false,
            child: isLoading
                ? _buildLoading()
                : quotations.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
                    color: const Color(0xFF1DB954),

                    backgroundColor: const Color(0xFF103D39),

                    onRefresh: loadQuotations,

                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),

                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 30),

                      itemCount: quotations.length,

                      itemBuilder: (context, index) {
                        final quotation = quotations[index];

                        return _buildQuotationCard(quotation);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUOTATION CARD
  // ============================================================

  Widget _buildQuotationCard(Quotation quotation) {
    final String customerName = quotation.customerName.isNotEmpty
        ? quotation.customerName
        : "Customer";

    // final String firstLetter = customerName.isNotEmpty
    //     ? customerName[0].toUpperCase()
    //     : "?";

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),

      child: GlassCard(
        radius: 22,
        blur: 13,
        opacity: 0.13,
        tint: Colors.white,

        padding: const EdgeInsets.all(16),

        child: InkWell(
          borderRadius: BorderRadius.circular(18),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuotationDetailScreen(quotation: quotation),
              ),
            );
          },

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // TOP ROW
              // ==================================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // =================================================
                  // ICON
                  // =================================================
                  Container(
                    width: 57,
                    height: 57,

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,

                        end: Alignment.bottomRight,

                        colors: [Color(0xFF1DB954), Color(0xFF0B5E4D)],
                      ),

                      borderRadius: BorderRadius.circular(17),

                      border: Border.all(
                        color: const Color(0xFF7EE787).withValues(alpha: 0.35),
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF1DB954,
                          ).withValues(alpha: 0.20),

                          blurRadius: 16,

                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),

                    child: const Icon(
                      Icons.description_rounded,

                      color: Colors.white,

                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 13),

                  // =================================================
                  // CUSTOMER + QUOTATION
                  // =================================================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          customerName,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: Colors.white,

                            fontSize: 17,

                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          quotation.name,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.52),

                            fontSize: 12,

                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // =================================================
                  // ARROW
                  // =================================================
                  Container(
                    width: 34,
                    height: 34,

                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),

                      shape: BoxShape.circle,

                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),

                    child: Icon(
                      Icons.arrow_forward_ios_rounded,

                      size: 14,

                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // ==================================================
              // DIVIDER
              // ==================================================
              Container(height: 1, color: Colors.white.withValues(alpha: 0.10)),

              const SizedBox(height: 14),

              // ==================================================
              // STATUS + ATTACHMENT
              // ==================================================
              Row(
                children: [
                  _buildStatusChip(quotation.status),

                  const Spacer(),

                  if (quotation.fileName != null &&
                      quotation.fileName!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD166).withValues(alpha: 0.10),

                        borderRadius: BorderRadius.circular(20),

                        border: Border.all(
                          color: const Color(
                            0xFFFFD166,
                          ).withValues(alpha: 0.20),
                        ),
                      ),

                      child: const Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Icon(
                            Icons.attach_file_rounded,

                            size: 14,

                            color: Color(0xFFFFD166),
                          ),

                          SizedBox(width: 4),

                          Text(
                            "Attachment",

                            style: TextStyle(
                              color: Color(0xFFFFD166),

                              fontSize: 10,

                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // ==================================================
              // TOTAL
              // ==================================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        "Grand Total",

                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),

                          fontSize: 10,

                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        "₹ ${quotation.grandTotal.toStringAsFixed(2)}",

                        style: const TextStyle(
                          color: Colors.white,

                          fontSize: 18,

                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // =================================================
                  // VIEW
                  // =================================================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFF1DB954).withValues(alpha: 0.10),

                      borderRadius: BorderRadius.circular(12),

                      border: Border.all(
                        color: const Color(0xFF7EE787).withValues(alpha: 0.18),
                      ),
                    ),

                    child: const Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Icon(
                          Icons.visibility_rounded,

                          size: 15,

                          color: Color(0xFF7EE787),
                        ),

                        SizedBox(width: 5),

                        Text(
                          "View",

                          style: TextStyle(
                            color: Color(0xFF7EE787),

                            fontSize: 11,

                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
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
  // STATUS CHIP
  // ============================================================

  Widget _buildStatusChip(String status) {
    Color textColor;

    if (status.toLowerCase() == "draft") {
      textColor = const Color(0xFFFFD166);
    } else if (status.toLowerCase() == "open") {
      textColor = const Color(0xFF7EE787);
    } else if (status.toLowerCase() == "submitted") {
      textColor = const Color(0xFF64B5F6);
    } else if (status.toLowerCase() == "cancelled") {
      textColor = const Color(0xFFFF8A80);
    } else {
      textColor = const Color(0xFF7EE787);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),

      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.10),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: textColor.withValues(alpha: 0.22)),
      ),

      child: Text(
        status.isEmpty ? "-" : status,

        style: TextStyle(
          color: textColor,

          fontSize: 10,

          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Container(
            width: 70,
            height: 70,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.09),

              shape: BoxShape.circle,

              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),

            child: const Padding(
              padding: EdgeInsets.all(20),

              child: CircularProgressIndicator(
                strokeWidth: 2.5,

                color: Color(0xFF7EE787),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Text(
            "Loading Quotations...",

            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),

              fontSize: 13,

              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: GlassCard(
          radius: 25,
          blur: 15,
          opacity: 0.12,
          tint: Colors.white,

          padding: const EdgeInsets.all(28),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Container(
                width: 78,
                height: 78,

                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954).withValues(alpha: 0.12),

                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.description_outlined,

                  size: 40,

                  color: Color(0xFF7EE787),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "No Quotations Found",

                style: TextStyle(
                  color: Colors.white,

                  fontSize: 19,

                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                "Your quotations will appear here.",

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.52),

                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BACKGROUND
  // ============================================================

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _animationController,

      builder: (context, child) {
        final value = _animationController.value;

        return Stack(
          children: [
            // ==================================================
            // MAIN GRADIENT
            // ==================================================
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

            // ==================================================
            // GREEN GLOW
            // ==================================================
            Positioned(
              top: -100 + (value * 35),

              left: -110,

              child: _buildGlow(size: 280, color: const Color(0xFF1DB954)),
            ),

            // ==================================================
            // GOLD GLOW
            // ==================================================
            Positioned(
              top: 120 - (value * 30),

              right: -110,

              child: _buildGlow(size: 300, color: const Color(0xFFFFD166)),
            ),

            // ==================================================
            // BOTTOM GREEN GLOW
            // ==================================================
            Positioned(
              bottom: -100 + (value * 20),

              left: 40,

              child: _buildGlow(size: 280, color: const Color(0xFF7EE787)),
            ),

            // ==================================================
            // FLOATING LEAF
            // ==================================================
            Positioned(
              top: 180 + (value * 30),

              right: 8,

              child: Transform.rotate(
                angle: -0.25 + (value * 0.15),

                child: Icon(
                  Icons.eco_rounded,

                  size: 58,

                  color: const Color(0x447EE787),
                ),
              ),
            ),

            // ==================================================
            // SECOND LEAF
            // ==================================================
            Positioned(
              bottom: 140 - (value * 20),

              left: 8,

              child: Transform.rotate(
                angle: 0.30 - (value * 0.12),

                child: Icon(
                  Icons.eco_rounded,

                  size: 40,

                  color: const Color(0x44FFD166),
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
