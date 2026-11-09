// screens/sales_order/sales_order_list_screen.dart

import 'package:flutter/material.dart';

import '../../models/sales_order.dart';
import '../../repositories/sales_order_repository.dart';
import '../../widgets/glass_card.dart';
import 'sales_order_detail_screen.dart';

class SalesOrderListScreen extends StatefulWidget {
  const SalesOrderListScreen({super.key});

  @override
  State<SalesOrderListScreen> createState() => _SalesOrderListScreenState();
}

class _SalesOrderListScreenState extends State<SalesOrderListScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // EXISTING LOGIC
  // ============================================================

  final SalesOrderRepository repository = SalesOrderRepository();

  List<SalesOrder> salesOrders = [];

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

    loadSalesOrders();
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD SALES ORDERS
  // ============================================================

  Future<void> loadSalesOrders() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final data = await repository.getMySalesOrders();

      if (!mounted) return;

      setState(() {
        salesOrders = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

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

  List<SalesOrder> get filteredSalesOrders {
    final value = searchController.text.trim().toLowerCase();

    if (value.isEmpty) {
      return salesOrders;
    }

    return salesOrders.where((order) {
      return order.name.toLowerCase().contains(value) ||
          order.customer.toLowerCase().contains(value) ||
          order.status.toLowerCase().contains(value);
    }).toList();
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
          "Sales Orders",

          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),

        centerTitle: true,

        actions: [
          IconButton(
            onPressed: loadSalesOrders,

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

                          onRefresh: loadSalesOrders,

                          child: _buildSalesOrderList(),
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
          // ICON
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
              Icons.shopping_cart_rounded,

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
                  "My Sales Orders",

                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 18,

                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "${salesOrders.length} order${salesOrders.length == 1 ? '' : 's'}",

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
              "${salesOrders.length}",

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

        onChanged: (_) {
          setState(() {});
        },

        style: const TextStyle(color: Colors.white, fontSize: 14),

        decoration: InputDecoration(
          hintText: "Search Sales Order...",

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

                    setState(() {});
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
  // SALES ORDER LIST
  // ============================================================

  Widget _buildSalesOrderList() {
    final orders = filteredSalesOrders;

    if (orders.isEmpty) {
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

      itemCount: orders.length,

      itemBuilder: (context, index) {
        final order = orders[index];

        return _buildSalesOrderCard(order, index);
      },
    );
  }

  // ============================================================
  // SALES ORDER CARD
  // ============================================================

  Widget _buildSalesOrderCard(SalesOrder order, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),

      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 300 + (index * 70)),

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
                // ===============================================
                // EXISTING NAVIGATION
                // ===============================================

                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) => SalesOrderDetailScreen(salesOrder: order),
                  ),
                );
              },

              child: Column(
                children: [
                  Row(
                    children: [
                      // ==========================================
                      // ORDER ICON
                      // ==========================================
                      Container(
                        width: 60,
                        height: 60,

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
                          Icons.shopping_cart_rounded,

                          color: Color(0xFF7EE787),

                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // ==========================================
                      // CUSTOMER / ORDER
                      // ==========================================
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              order.customer,

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
                                  Icons.receipt_long_rounded,

                                  size: 13,

                                  color: Color(0xFF7EE787),
                                ),

                                const SizedBox(width: 5),

                                Expanded(
                                  child: Text(
                                    order.name,

                                    maxLines: 1,

                                    overflow: TextOverflow.ellipsis,

                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.48,
                                      ),

                                      fontSize: 10,

                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 7),

                      // ==========================================
                      // ARROW
                      // ==========================================
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

                  const SizedBox(height: 13),

                  // ================================================
                  // BOTTOM INFORMATION
                  // ================================================
                  Row(
                    children: [
                      // ==========================================
                      // STATUS
                      // ==========================================
                      _buildInfoChip(
                        icon: Icons.info_outline_rounded,

                        label: order.status,

                        color: _getStatusColor(order.status),
                      ),

                      const SizedBox(width: 8),

                      // ==========================================
                      // TOTAL
                      // ==========================================
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,

                          children: [
                            const Icon(
                              Icons.currency_rupee_rounded,

                              color: Color(0xFFFFD166),

                              size: 17,
                            ),

                            const SizedBox(width: 2),

                            Flexible(
                              child: Text(
                                order.grandTotal.toStringAsFixed(2),

                                maxLines: 1,

                                overflow: TextOverflow.ellipsis,

                                style: const TextStyle(
                                  color: Color(0xFFFFD166),

                                  fontSize: 16,

                                  fontWeight: FontWeight.w800,
                                ),
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
        ),
      ),
    );
  }

  // ============================================================
  // INFO CHIP
  // ============================================================

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),

      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),

        borderRadius: BorderRadius.circular(11),

        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(icon, color: color, size: 14),

          const SizedBox(width: 5),

          Flexible(
            child: Text(
              label,

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                color: color,

                fontSize: 9,

                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
                Icons.shopping_cart_outlined,

                color: Color(0xFF7EE787),

                size: 37,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              searchController.text.isNotEmpty
                  ? "No Matching Orders"
                  : "No Sales Orders Found",

              textAlign: TextAlign.center,

              style: const TextStyle(
                color: Colors.white,

                fontSize: 16,

                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              searchController.text.isNotEmpty
                  ? "Try searching with a different customer or order number."
                  : "Your sales orders will appear here.",

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),

                fontSize: 11,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: loadSalesOrders,

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
            "Loading sales orders...",

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
            // GOLD GLOW
            // ==================================================
            Positioned(
              top: 140 - (value * 30),

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
            // CIRCLE
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
