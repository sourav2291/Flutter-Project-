// screens/customer/customer_details_screen.dart

import 'package:flutter/material.dart';

import '../../models/customer.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen>
    with SingleTickerProviderStateMixin {
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;

    final String customerName = customer.customerName.isNotEmpty
        ? customer.customerName
        : "Customer";

    final String firstLetter = customer.customerName.isNotEmpty
        ? customer.customerName[0].toUpperCase()
        : "?";

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

        title: Text(
          customerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
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
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),

              child: Column(
                children: [
                  // ==================================================
                  // CUSTOMER HEADER
                  // ==================================================
                  _buildCustomerHeader(customer, firstLetter),

                  const SizedBox(height: 18),

                  // ==================================================
                  // CUSTOMER INFORMATION
                  // ==================================================
                  _buildSectionTitle(
                    "Customer Information",
                    Icons.person_rounded,
                  ),

                  const SizedBox(height: 10),

                  _buildGlassTile(
                    title: "Customer Name",
                    value: customer.customerName,
                    icon: Icons.person_rounded,
                  ),

                  _buildGlassTile(
                    title: "Customer Type",
                    value: customer.customerType,
                    icon: Icons.business_rounded,
                  ),

                  _buildGlassTile(
                    title: "Customer Group",
                    value: customer.customerGroup ?? "",
                    icon: Icons.groups_rounded,
                  ),

                  _buildGlassTile(
                    title: "Territory",
                    value: customer.territory ?? "",
                    icon: Icons.public_rounded,
                  ),

                  _buildGlassTile(
                    title: "GSTIN",
                    value: customer.gstin ?? "",
                    icon: Icons.receipt_long_rounded,
                  ),

                  _buildGlassTile(
                    title: "Customer Owner",
                    value: customer.customerOwner ?? "",
                    icon: Icons.person_outline_rounded,
                  ),

                  const SizedBox(height: 10),

                  // ==================================================
                  // LOCATION
                  // ==================================================
                  _buildSectionTitle("Location", Icons.location_on_rounded),

                  const SizedBox(height: 10),

                  _buildGlassTile(
                    title: "Zone",
                    value: customer.zoneName ?? "",
                    icon: Icons.map_rounded,
                  ),

                  _buildGlassTile(
                    title: "Primary Address",
                    value: customer.primaryAddress ?? "",
                    icon: Icons.location_on_rounded,
                  ),

                  const SizedBox(height: 10),

                  // ==================================================
                  // CONTACT
                  // ==================================================
                  _buildSectionTitle("Contact", Icons.phone_rounded),

                  const SizedBox(height: 10),

                  _buildGlassTile(
                    title: "Mobile Number",
                    value: customer.mobileNo ?? "",
                    icon: Icons.phone_rounded,
                  ),

                  _buildGlassTile(
                    title: "Email",
                    value: customer.emailId ?? "",
                    icon: Icons.email_rounded,
                  ),

                  _buildGlassTile(
                    title: "Primary Contact",
                    value: customer.customerPrimaryContact ?? "",
                    icon: Icons.contact_phone_rounded,
                  ),

                  const SizedBox(height: 15),

                  // ==================================================
                  // FOOTER
                  // ==================================================
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
  // CUSTOMER HEADER
  // ============================================================

  Widget _buildCustomerHeader(Customer customer, String firstLetter) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        children: [
          // ==================================================
          // AVATAR
          // ==================================================
          Container(
            width: 92,
            height: 92,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1DB954), Color(0xFF0B5E4D)],
              ),

              border: Border.all(
                color: const Color(0xFF7EE787).withValues(alpha: 0.45),
                width: 2,
              ),

              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1DB954).withValues(alpha: 0.30),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),

            child: Center(
              child: Text(
                firstLetter,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ==================================================
          // NAME
          // ==================================================
          Text(
            customer.customerName.isNotEmpty
                ? customer.customerName
                : "Unnamed Customer",

            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          // ==================================================
          // CUSTOMER TYPE
          // ==================================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),

            decoration: BoxDecoration(
              color: const Color(0xFF7EE787).withValues(alpha: 0.12),

              borderRadius: BorderRadius.circular(20),

              border: Border.all(
                color: const Color(0xFF7EE787).withValues(alpha: 0.25),
              ),
            ),

            child: Text(
              customer.customerType.isNotEmpty
                  ? customer.customerType
                  : "Customer",

              style: const TextStyle(
                color: Color(0xFF7EE787),
                fontSize: 12,
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
          width: 34,
          height: 34,

          decoration: BoxDecoration(
            color: const Color(0xFF1DB954).withValues(alpha: 0.12),

            borderRadius: BorderRadius.circular(10),

            border: Border.all(
              color: const Color(0xFF7EE787).withValues(alpha: 0.15),
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
  // GLASS TILE
  // ============================================================

  Widget _buildGlassTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final bool hasValue = value.trim().isNotEmpty;

    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          // ==================================================
          // ICON
          // ==================================================
          Container(
            width: 43,
            height: 43,

            decoration: BoxDecoration(
              color: const Color(0xFF1DB954).withValues(alpha: 0.12),

              borderRadius: BorderRadius.circular(13),

              border: Border.all(
                color: const Color(0xFF7EE787).withValues(alpha: 0.16),
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
                    color: Colors.white.withValues(alpha: 0.48),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  hasValue ? value : "-",

                  maxLines: 4,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    color: hasValue
                        ? Colors.white.withValues(alpha: 0.90)
                        : Colors.white.withValues(alpha: 0.38),

                    fontSize: 14,

                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
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
              top: 130 - (value * 25),
              right: -120,

              child: _buildGlow(size: 300, color: const Color(0xFFFFD166)),
            ),

            // ==================================================
            // BOTTOM GREEN GLOW
            // ==================================================
            Positioned(
              bottom: -110 + (value * 20),
              left: 40,

              child: _buildGlow(size: 280, color: const Color(0xFF7EE787)),
            ),

            // ==================================================
            // FLOATING LEAF
            // ==================================================
            Positioned(
              top: 200 + (value * 30),
              right: 10,

              child: Transform.rotate(
                angle: -0.25 + (value * 0.15),

                child: const Icon(
                  Icons.eco_rounded,
                  size: 58,
                  color: Color(0x447EE787),
                ),
              ),
            ),

            // ==================================================
            // SECOND LEAF
            // ==================================================
            Positioned(
              bottom: 160 - (value * 20),
              left: 10,

              child: Transform.rotate(
                angle: 0.30 - (value * 0.12),

                child: const Icon(
                  Icons.eco_rounded,
                  size: 40,
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
