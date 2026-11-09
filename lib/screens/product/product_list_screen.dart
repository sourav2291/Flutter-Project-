// screens/product/product_list_screen.dart

import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../repositories/product_repository.dart';
import '../../widgets/glass_card.dart';
import 'bundle_details_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // EXISTING LOGIC
  // ============================================================

  final ProductRepository repository = ProductRepository();

  List<ProductBundle> bundles = [];
  List<ProductBundle> filteredBundles = [];

  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

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

    loadBundles();
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD PRODUCTS
  // ============================================================

  Future<void> loadBundles() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final data = await repository.getBundles();

      if (!mounted) return;

      setState(() {
        bundles = data;
        filteredBundles = data;
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
  // SEARCH
  // ============================================================

  void searchBundle(String value) {
    final searchValue = value.trim().toLowerCase();

    setState(() {
      if (searchValue.isEmpty) {
        filteredBundles = bundles;
      } else {
        filteredBundles = bundles.where((bundle) {
          return bundle.name.toLowerCase().contains(searchValue);
        }).toList();
      }
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
          "Solar Packages",

          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),

        centerTitle: true,

        actions: [
          IconButton(
            onPressed: loadBundles,

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
          // Animated background
          _buildBackground(),

          SafeArea(
            top: false,

            child: Column(
              children: [
                const SizedBox(height: 8),

                // ==================================================
                // HEADER
                // ==================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  child: _buildHeader(),
                ),

                const SizedBox(height: 15),

                // ==================================================
                // SEARCH
                // ==================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  child: _buildSearchBox(),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // LIST
                // ==================================================
                Expanded(
                  child: isLoading
                      ? _buildLoading()
                      : RefreshIndicator(
                          color: const Color(0xFF7EE787),

                          backgroundColor: const Color(0xFF073D3A),

                          onRefresh: loadBundles,

                          child: _buildProductList(),
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
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return GlassCard(
      radius: 23,
      blur: 14,
      opacity: 0.12,
      tint: Colors.white,

      padding: const EdgeInsets.all(17),

      child: Row(
        children: [
          // ==================================================
          // SOLAR ICON
          // ==================================================
          Container(
            width: 58,
            height: 58,

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
                  color: const Color(0xFF1DB954).withValues(alpha: 0.22),

                  blurRadius: 18,

                  offset: const Offset(0, 6),
                ),
              ],
            ),

            child: const Icon(
              Icons.solar_power_rounded,

              color: Colors.white,

              size: 29,
            ),
          ),

          const SizedBox(width: 14),

          // ==================================================
          // TITLE
          // ==================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "Solar Packages",

                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 18,

                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "${bundles.length} package${bundles.length == 1 ? '' : 's'} available",

                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.48),

                    fontSize: 11,

                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // COUNT
          // ==================================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

            decoration: BoxDecoration(
              color: const Color(0xFF1DB954).withValues(alpha: 0.12),

              borderRadius: BorderRadius.circular(15),

              border: Border.all(
                color: const Color(0xFF7EE787).withValues(alpha: 0.20),
              ),
            ),

            child: Text(
              "${bundles.length}",

              style: const TextStyle(
                color: Color(0xFF7EE787),

                fontSize: 15,

                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH BOX
  // ============================================================

  Widget _buildSearchBox() {
    return GlassCard(
      radius: 19,
      blur: 12,
      opacity: 0.10,
      tint: Colors.white,

      padding: EdgeInsets.zero,

      child: TextField(
        controller: searchController,

        onChanged: searchBundle,

        style: const TextStyle(color: Colors.white, fontSize: 14),

        decoration: InputDecoration(
          hintText: "Search Solar Package...",

          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.42),

            fontSize: 13,
          ),

          prefixIcon: const Icon(
            Icons.search_rounded,

            color: Color(0xFF7EE787),

            size: 23,
          ),

          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54),

                  onPressed: () {
                    searchController.clear();

                    searchBundle("");
                  },
                )
              : null,

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 17,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT LIST
  // ============================================================

  Widget _buildProductList() {
    if (filteredBundles.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.28),

          _buildEmptyState(),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),

      itemCount: filteredBundles.length,

      itemBuilder: (context, index) {
        final bundle = filteredBundles[index];

        return _buildProductCard(bundle, index);
      },
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget _buildProductCard(ProductBundle bundle, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),

      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 350 + (index * 70)),

        tween: Tween(begin: 0, end: 1),

        curve: Curves.easeOutCubic,

        builder: (context, value, child) {
          return Opacity(
            opacity: value,

            child: Transform.translate(
              offset: Offset(0, 18 * (1 - value)),

              child: child,
            ),
          );
        },

        child: GlassCard(
          radius: 23,
          blur: 14,
          opacity: 0.12,
          tint: Colors.white,

          padding: const EdgeInsets.all(16),

          child: Material(
            color: Colors.transparent,

            child: InkWell(
              borderRadius: BorderRadius.circular(23),

              onTap: () {
                // =================================================
                // EXISTING NAVIGATION
                // =================================================

                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        BundleDetailsScreen(bundleName: bundle.name),
                  ),
                );
              },

              child: Column(
                children: [
                  Row(
                    children: [
                      // ============================================
                      // SOLAR ICON
                      // ============================================
                      Container(
                        width: 61,
                        height: 61,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),

                          gradient: LinearGradient(
                            begin: Alignment.topLeft,

                            end: Alignment.bottomRight,

                            colors: [
                              const Color(0xFF1DB954).withValues(alpha: 0.16),

                              const Color(0xFF7EE787).withValues(alpha: 0.07),
                            ],
                          ),

                          border: Border.all(
                            color: const Color(
                              0xFF7EE787,
                            ).withValues(alpha: 0.20),
                          ),
                        ),

                        child: const Icon(
                          Icons.solar_power_rounded,

                          color: Color(0xFF7EE787),

                          size: 31,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // ============================================
                      // NAME
                      // ============================================
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              bundle.name,

                              maxLines: 2,

                              overflow: TextOverflow.ellipsis,

                              style: const TextStyle(
                                color: Colors.white,

                                fontSize: 16,

                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Row(
                              children: [
                                const Icon(
                                  Icons.wb_sunny_rounded,

                                  size: 13,

                                  color: Color(0xFFFFD166),
                                ),

                                const SizedBox(width: 5),

                                Text(
                                  "Solar Package",

                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.48),

                                    fontSize: 10,

                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ============================================
                      // ARROW
                      // ============================================
                      Container(
                        width: 36,
                        height: 36,

                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),

                          shape: BoxShape.circle,

                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),

                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,

                          color: Colors.white60,

                          size: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // ================================================
                  // DIVIDER
                  // ================================================
                  Container(
                    height: 1,

                    color: Colors.white.withValues(alpha: 0.08),
                  ),

                  const SizedBox(height: 14),

                  // ================================================
                  // PRICE
                  // ================================================
                  Row(
                    children: [
                      Container(
                        width: 37,
                        height: 37,

                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFFD166,
                          ).withValues(alpha: 0.10),

                          borderRadius: BorderRadius.circular(11),
                        ),

                        child: const Icon(
                          Icons.currency_rupee_rounded,

                          color: Color(0xFFFFD166),

                          size: 20,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Package Price",

                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.42),

                              fontSize: 9,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            "₹ ${bundle.totalPrice}",

                            style: const TextStyle(
                              color: Color(0xFFFFD166),

                              fontSize: 17,

                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // VIEW DETAILS
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 8,
                        ),

                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF1DB954,
                          ).withValues(alpha: 0.10),

                          borderRadius: BorderRadius.circular(12),

                          border: Border.all(
                            color: const Color(
                              0xFF7EE787,
                            ).withValues(alpha: 0.18),
                          ),
                        ),

                        child: const Text(
                          "View Details",

                          style: TextStyle(
                            color: Color(0xFF7EE787),

                            fontSize: 10,

                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Padding(
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
              width: 76,
              height: 76,

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

                size: 37,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "No Solar Packages Found",

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.white,

                fontSize: 16,

                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              "No packages are available at the moment.",

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),

                fontSize: 11,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: loadBundles,

              icon: const Icon(Icons.refresh_rounded, size: 18),

              label: const Text("Refresh"),

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
            "Loading solar packages...",

            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
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
            // GOLD SUN GLOW
            // ==================================================
            Positioned(
              top: 120 - (value * 30),

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
              top: 270 + (value * 35),

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
              bottom: 190 - (value * 25),

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
              top: 360 + (value * 20),

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
