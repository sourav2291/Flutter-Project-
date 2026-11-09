// screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';
import '../services/session_service.dart';

import '../widgets/app_drawer.dart';
import '../widgets/glass_card.dart';

import 'lead/lead_list_screen.dart';
import 'lead/create_lead_screen.dart';

import 'customer/customer_list_screen.dart';
import 'customer/create_customer_screen.dart';

import 'quotation/quotation_list_screen.dart';

import 'sales_order/sales_order_list_screen.dart';

import 'product/product_list_screen.dart';

import 'franchise/franchise_list_screen.dart';
// import 'payment_verification/payment_verification_list_screen.dart';

import 'material_request/material_request_list_screen.dart';

import 'leave/leave_application_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // EXISTING DATA / LOGIC
  // ============================================================

  String userName = "";

  DashboardSummary? summary;

  final DashboardRepository dashboardRepository = DashboardRepository();

  bool isDashboardLoading = true;

  late AnimationController _animationController;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);

    loadUser();
    loadDashboard();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // EXISTING LOGIC
  // ============================================================

  Future<void> loadDashboard() async {
    try {
      final data = await dashboardRepository.loadDashboard();

      if (!mounted) return;

      setState(() {
        summary = data;
        isDashboardLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isDashboardLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> loadUser() async {
    final name = await SessionService().getUserName();

    if (!mounted) return;

    setState(() {
      userName = name ?? "";
    });
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    }

    if (hour < 17) {
      return "Good Afternoon";
    }

    return "Good Evening";
  }

  String getCurrentDate() {
    return DateFormat("EEEE, dd MMM yyyy").format(DateTime.now());
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061F24),

      drawer: const AppDrawer(),

      body: BackdropGroup(
        child: Stack(
          children: [
            // ====================================================
            // BACKGROUND
            // ====================================================
            _buildAnimatedBackground(),

            // ====================================================
            // CONTENT
            // ====================================================
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: loadDashboard,

                      color: const Color(0xFF1DB954),

                      backgroundColor: const Color(0xFF103F39),

                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),

                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 35),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // ==================================================
                            // WELCOME
                            // ==================================================
                            _buildWelcomeCard(),

                            const SizedBox(height: 28),

                            // ==================================================
                            // SUMMARY TITLE
                            // ==================================================
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    "Sales Overview",
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                                _buildViewAllButton(),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ==================================================
                            // SUMMARY
                            // ==================================================
                            _buildSummaryGrid(),

                            const SizedBox(height: 30),

                            // ==================================================
                            // QUICK ACTIONS
                            // ==================================================
                            Row(
                              children: [
                                const Text(
                                  "Quick Actions",
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(width: 7),

                                const Text(
                                  "✦",
                                  style: TextStyle(
                                    color: Color(0xFFFFD166),
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            _buildQuickActions(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      height: 70,

      padding: const EdgeInsets.symmetric(horizontal: 4),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),

        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),

      child: Row(
        children: [
          // MENU
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  size: 28,
                  color: Colors.white,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),

          const SizedBox(width: 2),

          // LOGO
          Container(
            width: 42,
            height: 42,

            padding: const EdgeInsets.all(7),

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),

              shape: BoxShape.circle,

              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7EE787).withValues(alpha: 0.20),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Image.asset("assets/Madathilogo.png", fit: BoxFit.contain),
          ),

          const SizedBox(width: 10),

          // TITLE
          const Expanded(
            child: Text(
              "Madathil Solar ERP",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),

          // NOTIFICATION
          IconButton(
            onPressed: () {},

            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 28,
              color: Colors.white,
            ),
          ),
        ],
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
            // ==================================================
            // MAIN BACKGROUND
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
              top: 40 + (value * 35),

              left: -100,

              child: _buildGlow(size: 280, color: const Color(0xFF1DB954)),
            ),

            // ==================================================
            // GOLD SOLAR GLOW
            // ==================================================
            Positioned(
              top: 40 - (value * 25),

              right: -110,

              child: _buildGlow(size: 330, color: const Color(0xFFFFD166)),
            ),

            // ==================================================
            // LIGHT GREEN GLOW
            // ==================================================
            Positioned(
              top: 390 + (value * 20),

              left: 80,

              child: _buildGlow(size: 240, color: const Color(0xFF7EE787)),
            ),

            // ==================================================
            // BOTTOM GREEN GLOW
            // ==================================================
            Positioned(
              bottom: -80 + (value * 25),

              right: -60,

              child: _buildGlow(size: 280, color: const Color(0xFF26B864)),
            ),

            // ==================================================
            // FLOATING LEAF 1
            // ==================================================
            Positioned(
              top: 170 + (value * 35),

              right: 12,

              child: Transform.rotate(
                angle: -0.25 + (value * 0.15),

                child: Icon(
                  Icons.eco_rounded,
                  size: 52,
                  color: const Color(0x557EE787),
                ),
              ),
            ),

            // ==================================================
            // FLOATING LEAF 2
            // ==================================================
            Positioned(
              top: 450 - (value * 25),

              left: 8,

              child: Transform.rotate(
                angle: 0.35 - (value * 0.12),

                child: Icon(
                  Icons.eco_rounded,
                  size: 38,
                  color: const Color(0x44FFD166),
                ),
              ),
            ),

            // ==================================================
            // FLOATING LEAF 3
            // ==================================================
            Positioned(
              bottom: 160 + (value * 30),

              right: 25,

              child: Transform.rotate(
                angle: 0.15 + (value * 0.10),

                child: Icon(
                  Icons.eco_rounded,
                  size: 32,
                  color: const Color(0x447EE787),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGlow({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.30),
              color.withValues(alpha: 0.10),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // WELCOME CARD
  // ============================================================

  Widget _buildWelcomeCard() {
    return GlassCard(
      radius: 28,
      blur: 18,
      opacity: 0.20,
      tint: const Color(0xFF1DB954),

      padding: const EdgeInsets.all(22),

      child: Stack(
        children: [
          // ==================================================
          // DECORATIVE GLOW
          // ==================================================
          Positioned(
            top: -65,
            right: -65,

            child: Container(
              width: 180,
              height: 180,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          // ==================================================
          // SOLAR GOLD CIRCLE
          // ==================================================
          Positioned(
            bottom: -45,
            left: 100,

            child: Container(
              width: 110,
              height: 110,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: const Color(0xFFFFD166).withValues(alpha: 0.10),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          "${getGreeting()} ",

                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.80),

                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 7),

                        Text(
                          userName.isEmpty ? "Welcome" : userName,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: Colors.white,

                            fontSize: 27,

                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 7),

                        Text(
                          getCurrentDate(),

                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),

                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  _buildFloatingLogo(),
                ],
              ),

              const SizedBox(height: 24),

              Container(height: 1, color: Colors.white.withValues(alpha: 0.18)),

              const SizedBox(height: 18),

              Row(
                children: [
                  _buildSolarDecoration(Icons.wb_sunny_rounded),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      "Powering Your Solar Business",

                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),

                        fontSize: 13,

                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FLOATING LOGO
  // ============================================================

  Widget _buildFloatingLogo() {
    return AnimatedBuilder(
      animation: _animationController,

      builder: (context, child) {
        final offset = (_animationController.value * 8) - 4;

        return Transform.translate(
          offset: Offset(0, offset),

          child: Container(
            width: 70,
            height: 70,

            padding: const EdgeInsets.all(11),

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),

              shape: BoxShape.circle,

              border: Border.all(
                color: Colors.white.withValues(alpha: 0.55),

                width: 1,
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),

                  blurRadius: 20,

                  offset: const Offset(0, 8),
                ),
              ],
            ),

            child: Image.asset("assets/Madathilogo.png", fit: BoxFit.contain),
          ),
        );
      },
    );
  }

  // ============================================================
  // SOLAR ICON
  // ============================================================

  Widget _buildSolarDecoration(IconData icon) {
    return Container(
      width: 40,
      height: 40,

      decoration: BoxDecoration(
        color: const Color(0xFFFFD166).withValues(alpha: 0.18),

        shape: BoxShape.circle,

        border: Border.all(
          color: const Color(0xFFFFD166).withValues(alpha: 0.20),
        ),
      ),

      child: Icon(icon, color: const Color(0xFFFFD166), size: 21),
    );
  }

  // ============================================================
  // VIEW ALL BUTTON
  // ============================================================

  Widget _buildViewAllButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Text(
            "View All",

            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.80),

              fontSize: 12,

              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(width: 4),

          Icon(
            Icons.chevron_right_rounded,

            color: Colors.white.withValues(alpha: 0.75),

            size: 18,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY GRID
  // ============================================================

  Widget _buildSummaryGrid() {
    return GridView.count(
      crossAxisCount: 2,

      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      crossAxisSpacing: 12,

      mainAxisSpacing: 12,

      childAspectRatio: 0.92,

      children: [
        _buildSummaryCard(
          title: "Leads",

          count: summary?.leads.toString() ?? "...",

          icon: Icons.people_alt_rounded,

          iconColor: const Color(0xFF1687E8),

          iconBackground: const Color(0xFFE4F2FF),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LeadListScreen()),
            );
          },
        ),

        _buildSummaryCard(
          title: "Customers",

          count: summary?.customers.toString() ?? "...",

          icon: Icons.person_rounded,

          iconColor: const Color(0xFF43A047),

          iconBackground: const Color(0xFFE7F5E9),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomerListScreen()),
            );
          },
        ),

        _buildSummaryCard(
          title: "Quotation",

          count: summary?.quotations.toString() ?? "...",

          icon: Icons.description_rounded,

          iconColor: const Color(0xFFFF9800),

          iconBackground: const Color(0xFFFFF0DB),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuotationListScreen()),
            );
          },
        ),

        _buildSummaryCard(
          title: "Sales Orders",

          count: summary?.salesOrders.toString() ?? "...",

          icon: Icons.shopping_cart_rounded,

          iconColor: const Color(0xFF9B6BFF),

          iconBackground: const Color(0xFFEDE7FA),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SalesOrderListScreen()),
            );
          },
        ),

        _buildSummaryCard(
          title: "Material Requests",

          count: summary?.materialRequests.toString() ?? "...",

          icon: Icons.local_shipping_rounded,

          iconColor: const Color(0xFF68D391),

          iconBackground: const Color(0xFFE0F4E8),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MaterialRequestListScreen(),
              ),
            );
          },
        ),

        _buildSummaryCard(
          title: "Products",

          count: summary?.productBundles.toString() ?? "...",

          icon: Icons.inventory_2_rounded,

          iconColor: const Color(0xFF00C2A8),

          iconBackground: const Color(0xFFE0F4F1),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductListScreen()),
            );
          },
        ),

        _buildSummaryCard(
          title: "Franchise",

          count: "0",

          icon: Icons.storefront_rounded,

          iconColor: const Color(0xFFFFB36B),

          iconBackground: const Color(0xFFF0EAE7),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FranchiseListScreen()),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard({
    required String title,
    required String count,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1.0),

      duration: const Duration(milliseconds: 500),

      curve: Curves.easeOut,

      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,

          child: GlassCard(
            radius: 22,

            blur: 14,

            opacity: 0.14,

            tint: Colors.white,

            padding: const EdgeInsets.all(15),

            child: InkWell(
              borderRadius: BorderRadius.circular(22),

              onTap: onTap,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,

                        decoration: BoxDecoration(
                          color: iconBackground.withValues(alpha: 0.80),

                          borderRadius: BorderRadius.circular(15),
                        ),

                        child: Icon(icon, color: iconColor, size: 27),
                      ),

                      const Spacer(),

                      Container(
                        width: 28,
                        height: 28,

                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),

                          shape: BoxShape.circle,

                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),

                        child: Icon(
                          Icons.arrow_forward_ios_rounded,

                          size: 12,

                          color: Colors.white.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Text(
                    count,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 30,

                      fontWeight: FontWeight.w800,

                      color: Colors.white,

                      height: 1.0,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    title,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: 14,

                      color: Colors.white.withValues(alpha: 0.78),

                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions() {
    return Column(
      children: [
        _buildQuickAction(
          icon: Icons.add_rounded,
          title: "Create Lead",
          subtitle: "Add a new potential lead",
          color: const Color(0xFFB48CFF),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateLeadScreen()),
            );
          },
        ),

        // ============================================================
        // MY LEADS - NEW
        // ============================================================
        _buildQuickAction(
          icon: Icons.people_alt_rounded,
          title: "My Leads",
          subtitle: "View and manage your leads",
          color: const Color(0xFF54D6C1),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LeadListScreen()),
            );
          },
        ),

        _buildQuickAction(
          icon: Icons.person_add_alt_1_rounded,
          title: "Create Customer",
          subtitle: "Add a new customer",
          color: const Color(0xFF68D391),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateCustomerScreen()),
            );
          },
        ),

        // ============================================================
        // MY CUSTOMERS
        // ============================================================
        _buildQuickAction(
          icon: Icons.people_alt_rounded,
          title: "My Customers",
          subtitle: "View and manage your customers",
          color: const Color(0xFF54D6C1),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomerListScreen()),
            );
          },
        ),

        _buildQuickAction(
          icon: Icons.description_rounded,
          title: "My Quotations",
          subtitle: "View and manage quotations",
          color: const Color(0xFFFFC15A),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuotationListScreen()),
            );
          },
        ),

        _buildQuickAction(
          icon: Icons.shopping_cart_checkout_rounded,
          title: "My Sales Orders",
          subtitle: "View and manage sales orders",
          color: const Color(0xFFB48CFF),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SalesOrderListScreen()),
            );
          },
        ),

        // ============================================================
        // ============================================================
        // MATERIAL REQUEST
        // ============================================================
        _buildQuickAction(
          icon: Icons.local_shipping_rounded,
          title: "Material Request",
          subtitle: "Create and manage material requests",
          color: const Color(0xFF68D391),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MaterialRequestListScreen(),
              ),
            );
          },
        ),

        _buildQuickAction(
          icon: Icons.storefront_rounded,
          title: "Franchise List",
          subtitle: "View franchise information",
          color: const Color(0xFFFFB36B),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FranchiseListScreen()),
            );
          },
        ),

        _buildQuickAction(
          icon: Icons.inventory_2_rounded,
          title: "Products",
          subtitle: "View all products",
          color: const Color(0xFF54D6C1),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductListScreen()),
            );
          },
        ),

        // ============================================================
        // LEAVE APPLICATION
        // ============================================================
        _buildQuickAction(
          icon: Icons.event_available_rounded,
          title: "Leave Application",
          subtitle: "Apply for and manage your leaves",
          color: const Color(0xFF68D391),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LeaveApplicationListScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // QUICK ACTION CARD
  // ============================================================

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: GlassCard(
        radius: 18,

        blur: 10,

        opacity: 0.12,

        tint: Colors.white,

        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),

        child: InkWell(
          borderRadius: BorderRadius.circular(18),

          onTap: onTap,

          child: Row(
            children: [
              // ==================================================
              // ICON
              // ==================================================
              Container(
                width: 48,
                height: 48,

                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),

                  shape: BoxShape.circle,

                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),

                child: Icon(icon, color: color, size: 24),
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

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 16,

                        fontWeight: FontWeight.w700,

                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 12,

                        color: Colors.white.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // ARROW
              // ==================================================
              Icon(
                Icons.arrow_forward_ios_rounded,

                size: 17,

                color: Colors.white.withValues(alpha: 0.75),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
