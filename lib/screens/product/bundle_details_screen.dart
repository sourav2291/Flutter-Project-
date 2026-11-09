// screens/product/bundle_details_screen.dart

import 'package:flutter/material.dart';

import '../../models/product_bundle.dart';
import '../../repositories/product_bundle_repository.dart';
import '../../widgets/glass_card.dart';

class BundleDetailsScreen extends StatefulWidget {
  final String bundleName;

  const BundleDetailsScreen({super.key, required this.bundleName});

  @override
  State<BundleDetailsScreen> createState() => _BundleDetailsScreenState();
}

class _BundleDetailsScreenState extends State<BundleDetailsScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // EXISTING LOGIC
  // ============================================================

  final ProductBundleRepository repository = ProductBundleRepository();

  ProductBundle? bundle;

  bool isLoading = true;

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

    loadBundle();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD BUNDLE
  // ============================================================

  Future<void> loadBundle() async {
    try {
      final data = await repository.getBundle(widget.bundleName);

      if (!mounted) return;

      setState(() {
        bundle = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFF8B2E2E),
        ),
      );
    }
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

        title: Text(
          widget.bundleName,

          maxLines: 1,

          overflow: TextOverflow.ellipsis,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),

        centerTitle: true,

        actions: [
          IconButton(
            onPressed: loadBundle,

            icon: const Icon(Icons.refresh_rounded, size: 24),
          ),

          const SizedBox(width: 5),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: Stack(
        children: [
          _buildBackground(),

          SafeArea(
            top: false,

            child: isLoading
                ? _buildLoading()
                : bundle == null
                ? _buildNoBundle()
                : _buildBundleContent(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUNDLE CONTENT
  // ============================================================

  Widget _buildBundleContent() {
    final currentBundle = bundle!;

    return RefreshIndicator(
      color: const Color(0xFF7EE787),

      backgroundColor: const Color(0xFF073D3A),

      onRefresh: loadBundle,

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(16, 10, 16, 35),

        children: [
          // ======================================================
          // BUNDLE HEADER
          // ======================================================
          _buildBundleHeader(currentBundle),

          const SizedBox(height: 22),

          // ======================================================
          // SECTION TITLE
          // ======================================================
          Row(
            children: [
              Container(
                width: 39,
                height: 39,

                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954).withValues(alpha: 0.12),

                  borderRadius: BorderRadius.circular(12),

                  border: Border.all(
                    color: const Color(0xFF7EE787).withValues(alpha: 0.18),
                  ),
                ),

                child: const Icon(
                  Icons.inventory_2_rounded,

                  color: Color(0xFF7EE787),

                  size: 20,
                ),
              ),

              const SizedBox(width: 11),

              const Text(
                "Bundle Items",

                style: TextStyle(
                  color: Colors.white,

                  fontSize: 18,

                  fontWeight: FontWeight.w800,
                ),
              ),

              const Spacer(),

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

                child: Text(
                  "${currentBundle.items.length}",

                  style: const TextStyle(
                    color: Color(0xFF7EE787),

                    fontSize: 12,

                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          // ======================================================
          // ITEMS
          // ======================================================
          ...currentBundle.items.asMap().entries.map((entry) {
            return _buildItemCard(entry.value, entry.key);
          }),
        ],
      ),
    );
  }

  // ============================================================
  // BUNDLE HEADER
  // ============================================================

  Widget _buildBundleHeader(ProductBundle currentBundle) {
    return GlassCard(
      radius: 26,
      blur: 15,
      opacity: 0.13,
      tint: Colors.white,

      padding: const EdgeInsets.all(20),

      child: Column(
        children: [
          // ==================================================
          // SOLAR ICON
          // ==================================================
          Container(
            width: 82,
            height: 82,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              gradient: const LinearGradient(
                begin: Alignment.topLeft,

                end: Alignment.bottomRight,

                colors: [Color(0xFF1DB954), Color(0xFF0B5E4D)],
              ),

              border: Border.all(
                color: const Color(0xFF7EE787).withValues(alpha: 0.30),
              ),

              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1DB954).withValues(alpha: 0.24),

                  blurRadius: 24,

                  offset: const Offset(0, 8),
                ),
              ],
            ),

            child: const Icon(
              Icons.solar_power_rounded,

              color: Colors.white,

              size: 42,
            ),
          ),

          const SizedBox(height: 17),

          // ==================================================
          // BUNDLE NAME
          // ==================================================
          Text(
            currentBundle.name,

            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Colors.white,

              fontSize: 22,

              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          // ==================================================
          // PACKAGE LABEL
          // ==================================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),

            decoration: BoxDecoration(
              color: const Color(0xFFFFD166).withValues(alpha: 0.10),

              borderRadius: BorderRadius.circular(13),

              border: Border.all(
                color: const Color(0xFFFFD166).withValues(alpha: 0.18),
              ),
            ),

            child: const Row(
              mainAxisSize: MainAxisSize.min,

              children: [
                Icon(
                  Icons.wb_sunny_rounded,

                  color: Color(0xFFFFD166),

                  size: 14,
                ),

                SizedBox(width: 5),

                Text(
                  "Solar Package",

                  style: TextStyle(
                    color: Color(0xFFFFD166),

                    fontSize: 10,

                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ==================================================
          // STATS
          // ==================================================
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.inventory_2_rounded,

                  title: "Items",

                  value: "${currentBundle.items.length}",
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildStatCard(
                  icon: Icons.currency_rupee_rounded,

                  title: "Total Price",

                  value: "₹ ${currentBundle.totalPrice}",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),

      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,

            decoration: BoxDecoration(
              color: const Color(0xFF1DB954).withValues(alpha: 0.10),

              borderRadius: BorderRadius.circular(11),
            ),

            child: Icon(icon, color: const Color(0xFF7EE787), size: 19),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.40),

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

                    fontSize: 13,

                    fontWeight: FontWeight.w800,
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
  // ITEM CARD
  // ============================================================

  Widget _buildItemCard(dynamic item, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 300 + (index * 70)),

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
          blur: 13,
          opacity: 0.11,
          tint: Colors.white,

          padding: const EdgeInsets.all(15),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ================================================
              // ITEM NUMBER / ICON
              // ================================================
              Container(
                width: 53,
                height: 53,

                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954).withValues(alpha: 0.11),

                  borderRadius: BorderRadius.circular(16),

                  border: Border.all(
                    color: const Color(0xFF7EE787).withValues(alpha: 0.18),
                  ),
                ),

                child: const Icon(
                  Icons.inventory_2_rounded,

                  color: Color(0xFF7EE787),

                  size: 25,
                ),
              ),

              const SizedBox(width: 13),

              // ================================================
              // ITEM INFORMATION
              // ================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      item.itemCode,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Colors.white,

                        fontSize: 14,

                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ==========================================
                    // QUANTITY
                    // ==========================================
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),

                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          const Icon(
                            Icons.production_quantity_limits_rounded,

                            color: Color(0xFFFFD166),

                            size: 14,
                          ),

                          const SizedBox(width: 5),

                          Text(
                            "Qty : ${item.qty}",

                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),

                              fontSize: 10,

                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(width: 4),

                          Text(
                            item.uom,

                            style: const TextStyle(
                              color: Color(0xFFFFD166),

                              fontSize: 10,

                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ==========================================
                    // DESCRIPTION
                    // ==========================================
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 8),

                      Text(
                        item.description,

                        maxLines: 3,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),

                          fontSize: 10,

                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 7),

              // ================================================
              // ITEM NUMBER
              // ================================================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),

                decoration: BoxDecoration(
                  color: const Color(0xFF7EE787).withValues(alpha: 0.08),

                  borderRadius: BorderRadius.circular(9),
                ),

                child: Text(
                  "#${index + 1}",

                  style: const TextStyle(
                    color: Color(0xFF7EE787),

                    fontSize: 9,

                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          SizedBox(
            width: 32,
            height: 32,

            child: CircularProgressIndicator(
              strokeWidth: 2.5,

              color: Color(0xFF7EE787),
            ),
          ),

          SizedBox(height: 14),

          Text(
            "Loading package details...",

            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NO BUNDLE
  // ============================================================

  Widget _buildNoBundle() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),

        child: GlassCard(
          radius: 24,
          blur: 12,
          opacity: 0.10,
          tint: Colors.white,

          padding: const EdgeInsets.all(25),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Container(
                width: 75,
                height: 75,

                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954).withValues(alpha: 0.12),

                  shape: BoxShape.circle,

                  border: Border.all(
                    color: const Color(0xFF7EE787).withValues(alpha: 0.18),
                  ),
                ),

                child: const Icon(
                  Icons.solar_power_outlined,

                  color: Color(0xFF7EE787),

                  size: 36,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "No Bundle Found",

                style: TextStyle(
                  color: Colors.white,

                  fontSize: 17,

                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                "The selected solar package could not be found.",

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),

                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 18),

              ElevatedButton.icon(
                onPressed: loadBundle,

                icon: const Icon(Icons.refresh_rounded, size: 18),

                label: const Text("Try Again"),

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),

                  foregroundColor: Colors.white,

                  elevation: 0,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
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

              child: _buildGlow(size: 290, color: const Color(0xFF1DB954)),
            ),

            // ==================================================
            // GOLD GLOW
            // ==================================================
            Positioned(
              top: 150 - (value * 30),

              right: -120,

              child: _buildGlow(size: 300, color: const Color(0xFFFFD166)),
            ),

            // ==================================================
            // GREEN BOTTOM GLOW
            // ==================================================
            Positioned(
              bottom: -130 + (value * 20),

              left: 20,

              child: _buildGlow(size: 300, color: const Color(0xFF7EE787)),
            ),

            // ==================================================
            // FLOATING LEAF
            // ==================================================
            Positioned(
              top: 250 + (value * 35),

              right: 8,

              child: Transform.rotate(
                angle: -0.25 + (value * 0.15),

                child: const Icon(
                  Icons.eco_rounded,

                  size: 62,

                  color: Color(0x447EE787),
                ),
              ),
            ),

            // ==================================================
            // SECOND LEAF
            // ==================================================
            Positioned(
              bottom: 180 - (value * 25),

              left: 5,

              child: Transform.rotate(
                angle: 0.30 - (value * 0.12),

                child: const Icon(
                  Icons.eco_rounded,

                  size: 43,

                  color: Color(0x44FFD166),
                ),
              ),
            ),

            // ==================================================
            // SOLAR CIRCLE
            // ==================================================
            Positioned(
              top: 390 + (value * 20),

              right: 30,

              child: Container(
                width: 100,
                height: 100,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  border: Border.all(
                    color: const Color(0x227EE787),

                    width: 1.5,
                  ),
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
