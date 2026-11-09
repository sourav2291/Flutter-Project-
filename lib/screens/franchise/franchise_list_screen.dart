// screens/franchise/franchise_list_screen.dart

import 'package:flutter/material.dart';

import '../../models/franchise.dart';
import '../../repositories/franchise_repository.dart';
import '../../widgets/glass_card.dart';
import 'create_franchise_screen.dart';

class FranchiseListScreen extends StatefulWidget {
  const FranchiseListScreen({super.key});

  @override
  State<FranchiseListScreen> createState() => _FranchiseListScreenState();
}

class _FranchiseListScreenState extends State<FranchiseListScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // EXISTING LOGIC
  // ============================================================

  final FranchiseRepository repository = FranchiseRepository();

  List<Franchise> franchiseList = [];
  List<Franchise> filteredList = [];

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

    loadFranchises();
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD FRANCHISES
  // ============================================================

  Future<void> loadFranchises() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final data = await repository.getFranchises();

      if (!mounted) return;

      setState(() {
        franchiseList = data;
        filteredList = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF8B2E2E),
          content: Text(e.toString()),
        ),
      );
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void searchFranchise(String value) {
    final searchValue = value.trim().toLowerCase();

    setState(() {
      if (searchValue.isEmpty) {
        filteredList = franchiseList;
      } else {
        filteredList = franchiseList.where((item) {
          return item.franchiseName.toLowerCase().contains(searchValue);
        }).toList();
      }
    });
  }

  // ============================================================
  // CREATE FRANCHISE
  // ============================================================

  Future<void> openCreateFranchise() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateFranchiseScreen()),
    );

    // Refresh list after returning
    loadFranchises();
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
          "Franchise List",

          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),

        centerTitle: true,

        actions: [
          IconButton(
            tooltip: "New Franchise",

            icon: const Icon(Icons.add_business_rounded, size: 25),

            onPressed: openCreateFranchise,
          ),

          const SizedBox(width: 5),
        ],
      ),

      // ==========================================================
      // FLOATING BUTTON
      // ==========================================================
      floatingActionButton: _buildFloatingButton(),

      // ==========================================================
      // BODY
      // ==========================================================
      body: Stack(
        children: [
          // Background
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
                          color: const Color(0xFF1DB954),

                          backgroundColor: const Color(0xFF073D3A),

                          onRefresh: loadFranchises,

                          child: _buildFranchiseList(),
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
            width: 57,
            height: 57,

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
              Icons.storefront_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "My Franchises",

                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 18,

                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "${franchiseList.length} franchise application${franchiseList.length == 1 ? '' : 's'}",

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
              "${franchiseList.length}",

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

        onChanged: searchFranchise,

        style: const TextStyle(color: Colors.white, fontSize: 14),

        decoration: InputDecoration(
          hintText: "Search Franchise...",

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

                    searchFranchise("");
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
            "Loading franchises...",

            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FRANCHISE LIST
  // ============================================================

  Widget _buildFranchiseList() {
    if (filteredList.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.30),

          _buildEmptyState(),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),

      itemCount: filteredList.length,

      itemBuilder: (context, index) {
        final franchise = filteredList[index];

        return _buildFranchiseCard(franchise, index);
      },
    );
  }

  // ============================================================
  // FRANCHISE CARD
  // ============================================================

  Widget _buildFranchiseCard(Franchise franchise, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

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
          radius: 22,
          blur: 13,
          opacity: 0.11,
          tint: Colors.white,

          padding: const EdgeInsets.all(15),

          child: Material(
            color: Colors.transparent,

            child: InkWell(
              borderRadius: BorderRadius.circular(22),

              onTap: () {
                // =================================================
                // KEEPING YOUR EXISTING FLOW
                // =================================================
                //
                // Next we can create:
                // FranchiseDetailsScreen
                //
                // For now, this remains unchanged.
              },

              child: Row(
                children: [
                  // ================================================
                  // FRANCHISE ICON
                  // ================================================
                  Container(
                    width: 57,
                    height: 57,

                    decoration: BoxDecoration(
                      color: const Color(0xFF1DB954).withValues(alpha: 0.12),

                      borderRadius: BorderRadius.circular(17),

                      border: Border.all(
                        color: const Color(0xFF7EE787).withValues(alpha: 0.20),
                      ),
                    ),

                    child: const Icon(
                      Icons.storefront_rounded,

                      color: Color(0xFF7EE787),

                      size: 27,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // ================================================
                  // FRANCHISE INFORMATION
                  // ================================================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          franchise.franchiseName,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: Colors.white,

                            fontSize: 15,

                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,

                              decoration: const BoxDecoration(
                                color: Color(0xFF7EE787),

                                shape: BoxShape.circle,
                              ),
                            ),

                            const SizedBox(width: 6),

                            Text(
                              "Franchise Application",

                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.50),

                                fontSize: 10,

                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ================================================
                  // ARROW
                  // ================================================
                  Container(
                    width: 35,
                    height: 35,

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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: GlassCard(
          radius: 24,
          blur: 12,
          opacity: 0.09,
          tint: Colors.white,

          padding: const EdgeInsets.all(25),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Container(
                width: 72,
                height: 72,

                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954).withValues(alpha: 0.12),

                  shape: BoxShape.circle,

                  border: Border.all(
                    color: const Color(0xFF7EE787).withValues(alpha: 0.18),
                  ),
                ),

                child: const Icon(
                  Icons.storefront_outlined,

                  color: Color(0xFF7EE787),

                  size: 34,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "No Franchises Found",

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white,

                  fontSize: 16,

                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                "Create your first franchise application",

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),

                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 18),

              ElevatedButton.icon(
                onPressed: openCreateFranchise,

                icon: const Icon(Icons.add_rounded, size: 18),

                label: const Text("Create Franchise"),

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),

                  foregroundColor: Colors.white,

                  elevation: 0,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
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
  // FLOATING BUTTON
  // ============================================================

  Widget _buildFloatingButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1DB954).withValues(alpha: 0.30),

            blurRadius: 20,

            offset: const Offset(0, 7),
          ),
        ],
      ),

      child: FloatingActionButton.extended(
        onPressed: openCreateFranchise,

        backgroundColor: const Color(0xFF1DB954),

        foregroundColor: Colors.white,

        elevation: 0,

        icon: const Icon(Icons.add_business_rounded),

        label: const Text(
          "New Franchise",

          style: TextStyle(fontWeight: FontWeight.w700),
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

              child: _buildGlow(size: 290, color: const Color(0xFF1DB954)),
            ),

            // ==================================================
            // GOLD GLOW
            // ==================================================
            Positioned(
              top: 170 - (value * 30),

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
              top: 260 + (value * 35),

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
