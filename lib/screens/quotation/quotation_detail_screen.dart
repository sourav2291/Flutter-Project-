// screens/quotation/quotation_detail_screen.dart

import 'package:flutter/material.dart';

import '../../models/quotation.dart';
import '../../services/download_service.dart';
import '../../services/session_service.dart';
import '../../widgets/glass_card.dart';
import 'pdf_viewer_screen.dart';

class QuotationDetailScreen extends StatefulWidget {
  final Quotation quotation;

  const QuotationDetailScreen({super.key, required this.quotation});

  @override
  State<QuotationDetailScreen> createState() => _QuotationDetailScreenState();
}

class _QuotationDetailScreenState extends State<QuotationDetailScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // ANIMATION
  // ============================================================

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

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
  // VIEW QUOTATION
  // ============================================================

  Future<void> _viewQuotation(BuildContext context) async {
    if (widget.quotation.fileUrl == null || widget.quotation.fileUrl!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No attachment found")));

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

    final String pdfUrl = "$site${widget.quotation.fileUrl!}";

    print("========== VIEW PDF ==========");
    print(pdfUrl);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
          url: pdfUrl,
          title: widget.quotation.fileName ?? widget.quotation.name,
        ),
      ),
    );
  }

  // ============================================================
  // DOWNLOAD QUOTATION
  // ============================================================

  Future<void> _downloadQuotation(BuildContext context) async {
    if (widget.quotation.fileUrl == null || widget.quotation.fileUrl!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No attachment found")));

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

    final String downloadUrl = "$site${widget.quotation.fileUrl!}";

    print("========== DOWNLOAD PDF ==========");
    print(downloadUrl);

    await DownloadService.downloadFile(
      context: context,
      url: downloadUrl,
      fileName: widget.quotation.fileName ?? "${widget.quotation.name}.pdf",
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final quotation = widget.quotation;

    final String customerName = quotation.customerName.isNotEmpty
        ? quotation.customerName
        : "Customer";

    final String firstLetter = customerName.isNotEmpty
        ? customerName[0].toUpperCase()
        : "?";

    final bool hasAttachment =
        quotation.fileUrl != null && quotation.fileUrl!.isNotEmpty;

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
          "Quotation Details",
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),

        centerTitle: true,
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: Stack(
        children: [
          _buildBackground(),

          SafeArea(
            top: false,

            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 35),

              child: Column(
                children: [
                  // ==================================================
                  // QUOTATION HEADER
                  // ==================================================
                  _buildQuotationHeader(customerName, firstLetter, quotation),

                  const SizedBox(height: 18),

                  // ==================================================
                  // QUOTATION INFORMATION
                  // ==================================================
                  _buildSectionTitle(
                    "Quotation Information",
                    Icons.description_rounded,
                  ),

                  const SizedBox(height: 10),

                  _buildInfoTile(
                    title: "Quotation Number",
                    value: quotation.name,
                    icon: Icons.numbers_rounded,
                  ),

                  _buildInfoTile(
                    title: "Customer",
                    value: quotation.customerName,
                    icon: Icons.person_rounded,
                  ),

                  _buildInfoTile(
                    title: "Status",
                    value: quotation.status,
                    icon: Icons.flag_rounded,
                    status: true,
                  ),

                  _buildInfoTile(
                    title: "Grand Total",
                    value: "₹ ${quotation.grandTotal.toStringAsFixed(2)}",
                    icon: Icons.currency_rupee_rounded,
                    highlight: true,
                  ),

                  _buildInfoTile(
                    title: "Company",
                    value: quotation.company,
                    icon: Icons.business_rounded,
                  ),

                  const SizedBox(height: 10),

                  // ==================================================
                  // ATTACHMENT
                  // ==================================================
                  _buildSectionTitle("Attachment", Icons.attach_file_rounded),

                  const SizedBox(height: 10),

                  _buildAttachmentCard(quotation, hasAttachment),

                  const SizedBox(height: 20),

                  // ==================================================
                  // ACTION BUTTONS
                  // ==================================================
                  _buildActionButton(
                    icon: Icons.picture_as_pdf_rounded,
                    title: "View Quotation",
                    subtitle: hasAttachment
                        ? "Open quotation PDF"
                        : "No attachment available",
                    enabled: hasAttachment,
                    onTap: hasAttachment ? () => _viewQuotation(context) : null,
                  ),

                  const SizedBox(height: 12),

                  _buildActionButton(
                    icon: Icons.download_rounded,
                    title: "Download Quotation",
                    subtitle: hasAttachment
                        ? "Save quotation PDF"
                        : "No attachment available",
                    enabled: hasAttachment,
                    onTap: hasAttachment
                        ? () => _downloadQuotation(context)
                        : null,
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "Madathil Solar ERP",

                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUOTATION HEADER
  // ============================================================

  Widget _buildQuotationHeader(
    String customerName,
    String firstLetter,
    Quotation quotation,
  ) {
    return GlassCard(
      radius: 25,
      blur: 15,
      opacity: 0.13,
      tint: Colors.white,

      padding: const EdgeInsets.all(20),

      child: Column(
        children: [
          // ==================================================
          // ICON
          // ==================================================
          Container(
            width: 88,
            height: 88,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1DB954), Color(0xFF0B5E4D)],
              ),

              border: Border.all(
                color: const Color(0xFF7EE787).withValues(alpha: 0.35),
                width: 2,
              ),

              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1DB954).withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),

            child: const Icon(
              Icons.description_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),

          const SizedBox(height: 14),

          // ==================================================
          // CUSTOMER
          // ==================================================
          Text(
            customerName,

            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          // ==================================================
          // QUOTATION NUMBER
          // ==================================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),

            decoration: BoxDecoration(
              color: const Color(0xFF7EE787).withValues(alpha: 0.10),

              borderRadius: BorderRadius.circular(20),

              border: Border.all(
                color: const Color(0xFF7EE787).withValues(alpha: 0.20),
              ),
            ),

            child: Text(
              quotation.name,

              style: const TextStyle(
                color: Color(0xFF7EE787),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
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
          width: 35,
          height: 35,

          decoration: BoxDecoration(
            color: const Color(0xFF1DB954).withValues(alpha: 0.12),

            borderRadius: BorderRadius.circular(11),

            border: Border.all(
              color: const Color(0xFF7EE787).withValues(alpha: 0.16),
            ),
          ),

          child: Icon(icon, size: 18, color: const Color(0xFF7EE787)),
        ),

        const SizedBox(width: 10),

        Text(
          title,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INFORMATION TILE
  // ============================================================

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
    bool highlight = false,
    bool status = false,
  }) {
    final bool hasValue = value.trim().isNotEmpty;

    Color valueColor = Colors.white;

    if (status) {
      final statusLower = value.toLowerCase();

      if (statusLower == "draft") {
        valueColor = const Color(0xFFFFD166);
      } else if (statusLower == "open") {
        valueColor = const Color(0xFF7EE787);
      } else if (statusLower == "submitted") {
        valueColor = const Color(0xFF64B5F6);
      } else if (statusLower == "cancelled") {
        valueColor = const Color(0xFFFF8A80);
      }
    }

    if (highlight) {
      valueColor = const Color(0xFF7EE787);
    }

    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        children: [
          // ==================================================
          // ICON
          // ==================================================
          Container(
            width: 43,
            height: 43,

            decoration: BoxDecoration(
              color: const Color(0xFF1DB954).withValues(alpha: 0.11),

              borderRadius: BorderRadius.circular(13),

              border: Border.all(
                color: const Color(0xFF7EE787).withValues(alpha: 0.15),
              ),
            ),

            child: Icon(icon, size: 21, color: const Color(0xFF7EE787)),
          ),

          const SizedBox(width: 13),

          // ==================================================
          // TEXT
          // ==================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  hasValue ? value : "-",

                  maxLines: 3,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    color: valueColor,
                    fontSize: highlight ? 17 : 14,
                    fontWeight: highlight || status
                        ? FontWeight.w800
                        : FontWeight.w600,
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
  // ATTACHMENT CARD
  // ============================================================

  Widget _buildAttachmentCard(Quotation quotation, bool hasAttachment) {
    return GlassCard(
      radius: 18,
      blur: 12,
      opacity: 0.09,
      tint: Colors.white,

      padding: const EdgeInsets.all(15),

      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: hasAttachment
                  ? const Color(0xFFFFD166).withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.06),

              borderRadius: BorderRadius.circular(14),

              border: Border.all(
                color: hasAttachment
                    ? const Color(0xFFFFD166).withValues(alpha: 0.20)
                    : Colors.white.withValues(alpha: 0.10),
              ),
            ),

            child: Icon(
              hasAttachment
                  ? Icons.picture_as_pdf_rounded
                  : Icons.insert_drive_file_outlined,

              color: hasAttachment ? const Color(0xFFFFD166) : Colors.white38,

              size: 24,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  hasAttachment ? "Quotation PDF" : "No Attachment",

                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.50),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  hasAttachment
                      ? quotation.fileName ?? "Quotation PDF"
                      : "No attachment available",

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    color: hasAttachment ? Colors.white : Colors.white38,

                    fontSize: 14,

                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          if (hasAttachment)
            Container(
              width: 32,
              height: 32,

              decoration: BoxDecoration(
                color: const Color(0xFF7EE787).withValues(alpha: 0.10),

                shape: BoxShape.circle,

                border: Border.all(
                  color: const Color(0xFF7EE787).withValues(alpha: 0.18),
                ),
              ),

              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF7EE787),
                size: 17,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 68,

      child: GlassCard(
        radius: 20,
        blur: 12,
        opacity: enabled ? 0.12 : 0.06,
        tint: Colors.white,

        padding: EdgeInsets.zero,

        child: Material(
          color: Colors.transparent,

          child: InkWell(
            borderRadius: BorderRadius.circular(20),

            onTap: onTap,

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,

                    decoration: BoxDecoration(
                      color: enabled
                          ? const Color(0xFF1DB954).withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.05),

                      borderRadius: BorderRadius.circular(13),

                      border: Border.all(
                        color: enabled
                            ? const Color(0xFF7EE787).withValues(alpha: 0.18)
                            : Colors.white.withValues(alpha: 0.08),
                      ),
                    ),

                    child: Icon(
                      icon,

                      color: enabled ? const Color(0xFF7EE787) : Colors.white24,

                      size: 21,
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          title,

                          style: TextStyle(
                            color: enabled ? Colors.white : Colors.white38,

                            fontSize: 14,

                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          subtitle,

                          style: TextStyle(
                            color: enabled
                                ? Colors.white.withValues(alpha: 0.45)
                                : Colors.white24,

                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios_rounded,

                    color: enabled ? Colors.white70 : Colors.white24,

                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ANIMATED BACKGROUND
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
