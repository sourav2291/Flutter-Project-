// screens/customer/customer_list_screen.dart

import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../../repositories/customer_repository.dart';
import '../../widgets/glass_card.dart';
import 'customer_details_screen.dart';
import 'create_customer_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // EXISTING LOGIC
  // ============================================================

  final CustomerRepository repository = CustomerRepository();

  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];

  bool loading = true;

  final TextEditingController searchController = TextEditingController();

  // ============================================================
  // ANIMATION
  // ============================================================

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    loadCustomers();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD CUSTOMERS
  // ============================================================

  Future<void> loadCustomers() async {
    setState(() {
      loading = true;
    });

    try {
      final data = await repository.getCustomers();

      if (!mounted) return;

      setState(() {
        customers = data;
        filteredCustomers = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
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

  void searchCustomer(String value) {
    setState(() {
      filteredCustomers = customers.where((customer) {
        return customer.customerName.toLowerCase().contains(
          value.toLowerCase(),
        );
      }).toList();
    });
  }

  // ============================================================
  // CREATE CUSTOMER
  // ============================================================

  Future<void> openCreateCustomer() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateCustomerScreen()),
    );

    if (result == true) {
      loadCustomers();
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Customers",
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
          // ========================================================
          // BACKGROUND
          // ========================================================
          _buildBackground(),

          // ========================================================
          // CONTENT
          // ========================================================
          SafeArea(
            top: false,
            child: loading
                ? _buildLoading()
                : Column(
                    children: [
                      // ==================================================
                      // SEARCH
                      // ==================================================
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                        child: _buildSearchField(),
                      ),

                      // ==================================================
                      // CUSTOMER COUNT
                      // ==================================================
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.people_alt_rounded,
                              color: Color(0xFF7EE787),
                              size: 19,
                            ),

                            const SizedBox(width: 8),

                            Text(
                              "${filteredCustomers.length} Customers",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.68),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const Spacer(),

                            if (searchController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  searchController.clear();

                                  searchCustomer("");
                                },
                                child: const Text(
                                  "Clear",
                                  style: TextStyle(
                                    color: Color(0xFF7EE787),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // ==================================================
                      // CUSTOMER LIST
                      // ==================================================
                      Expanded(
                        child: RefreshIndicator(
                          color: const Color(0xFF1DB954),
                          backgroundColor: const Color(0xFF103D39),
                          onRefresh: loadCustomers,
                          child: filteredCustomers.isEmpty
                              ? _buildEmpty()
                              : ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    14,
                                    6,
                                    14,
                                    100,
                                  ),
                                  itemCount: filteredCustomers.length,
                                  itemBuilder: (context, index) {
                                    final customer = filteredCustomers[index];

                                    return _buildCustomerCard(customer);
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),

      // ==========================================================
      // CREATE CUSTOMER BUTTON
      // ==========================================================
      floatingActionButton: _buildCreateButton(),
    );
  }

  // ============================================================
  // SEARCH FIELD
  // ============================================================

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: searchCustomer,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        cursorColor: const Color(0xFF7EE787),
        decoration: InputDecoration(
          hintText: "Search Customer",
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.48)),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF7EE787),
            size: 23,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    searchController.clear();

                    searchCustomer("");
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CUSTOMER CARD
  // ============================================================

  Widget _buildCustomerCard(Customer customer) {
    final String name = customer.customerName.isNotEmpty
        ? customer.customerName
        : "Unnamed Customer";

    final String firstLetter = customer.customerName.isNotEmpty
        ? customer.customerName[0].toUpperCase()
        : "?";

    final String type = customer.customerType.isNotEmpty
        ? customer.customerType
        : "-";

    // UPDATED FIELDS
    final String zone = customer.zoneName ?? "-";

    final String mobile = customer.mobileNo ?? "-";

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                builder: (_) => CustomerDetailsScreen(customer: customer),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // TOP
              // ==================================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // CUSTOMER AVATAR
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
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF7EE787).withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF1DB954,
                          ).withValues(alpha: 0.22),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        firstLetter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 13),

                  // =================================================
                  // CUSTOMER NAME
                  // =================================================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 7),

                        // CUSTOMER TYPE
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF7EE787,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(
                                0xFF7EE787,
                              ).withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            type,
                            style: const TextStyle(
                              color: Color(0xFF7EE787),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
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
                        color: Colors.white.withValues(alpha: 0.16),
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

              const SizedBox(height: 16),

              // ==================================================
              // DIVIDER
              // ==================================================
              Container(height: 1, color: Colors.white.withValues(alpha: 0.10)),

              const SizedBox(height: 14),

              // ==================================================
              // ZONE
              // ==================================================
              _buildInfoRow(
                icon: Icons.location_on_rounded,
                title: "Zone",
                value: zone,
              ),

              const SizedBox(height: 10),

              // ==================================================
              // MOBILE
              // ==================================================
              _buildInfoRow(
                icon: Icons.phone_rounded,
                title: "Mobile",
                value: mobile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF7EE787)),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.48),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value.isEmpty ? "-" : value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
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
              color: Colors.white.withValues(alpha: 0.10),
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
            "Loading Customers...",
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
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954).withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_outline_rounded,
                  size: 40,
                  color: Color(0xFF7EE787),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "No Customers Found",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                searchController.text.isEmpty
                    ? "There are no customers available."
                    : "No customer matches your search.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
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
  // CREATE CUSTOMER BUTTON
  // ============================================================

  Widget _buildCreateButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1DB954).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: openCreateCustomer,
        backgroundColor: const Color(0xFF1DB954),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: const Color(0xFF7EE787).withValues(alpha: 0.35),
          ),
        ),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text(
          "Customer",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
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
              top: 100 - (value * 30),
              right: -110,
              child: _buildGlow(size: 300, color: const Color(0xFFFFD166)),
            ),

            // ==================================================
            // CENTER GREEN GLOW
            // ==================================================
            Positioned(
              top: 420 + (value * 25),
              left: 50,
              child: _buildGlow(size: 240, color: const Color(0xFF7EE787)),
            ),

            // ==================================================
            // FLOATING LEAF
            // ==================================================
            Positioned(
              top: 170 + (value * 30),
              right: 8,
              child: Transform.rotate(
                angle: -0.25 + (value * 0.15),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 55,
                  color: Color(0x447EE787),
                ),
              ),
            ),

            // ==================================================
            // SECOND LEAF
            // ==================================================
            Positioned(
              bottom: 130 - (value * 20),
              left: 8,
              child: Transform.rotate(
                angle: 0.30 - (value * 0.12),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 38,
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
