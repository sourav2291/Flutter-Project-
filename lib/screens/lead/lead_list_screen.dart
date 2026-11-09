// screens/lead/lead_list_screen.dart

import 'package:flutter/material.dart';

import '../../models/lead.dart';
import '../../repositories/lead_repository.dart';
import '../../widgets/glass_card.dart';

import 'lead_details_screen.dart';

class LeadListScreen extends StatefulWidget {
  const LeadListScreen({super.key});

  @override
  State<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // EXISTING LOGIC
  // ============================================================

  late Future<List<Lead>> futureLeads;

  // ============================================================
  // BACKGROUND ANIMATION
  // ============================================================

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    futureLeads = LeadRepository().getLeads();

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
    return Scaffold(
      backgroundColor: const Color(0xFF061F24),

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
          "My Leads",
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: Stack(
        children: [
          // ======================================================
          // ANIMATED BACKGROUND
          // ======================================================
          _buildBackground(),

          // ======================================================
          // CONTENT
          // ======================================================
          SafeArea(
            top: false,
            child: FutureBuilder<List<Lead>>(
              future: futureLeads,

              builder: (context, snapshot) {
                // ==================================================
                // LOADING
                // ==================================================

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoading();
                }

                // ==================================================
                // ERROR
                // ==================================================

                if (snapshot.hasError) {
                  return _buildError(snapshot.error.toString());
                }

                final leads = snapshot.data ?? [];

                // ==================================================
                // EMPTY
                // ==================================================

                if (leads.isEmpty) {
                  return _buildEmpty();
                }

                // ==================================================
                // LEAD LIST
                // ==================================================

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 30),

                  itemCount: leads.length,

                  itemBuilder: (context, index) {
                    final lead = leads[index];

                    return _buildLeadCard(lead, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LEAD CARD
  // ============================================================

  Widget _buildLeadCard(Lead lead, int index) {
    final String leadName = lead.leadName.isNotEmpty
        ? lead.leadName
        : "Unnamed Lead";

    final String firstLetter = lead.leadName.isNotEmpty
        ? lead.leadName[0].toUpperCase()
        : "?";

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: GlassCard(
        radius: 22,
        blur: 13,
        opacity: 0.13,
        tint: Colors.white,

        padding: const EdgeInsets.all(16),

        child: InkWell(
          borderRadius: BorderRadius.circular(22),

          // ======================================================
          // OPEN LEAD DETAILS
          // ======================================================
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LeadDetailsScreen(lead: lead)),
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
                  // ==================================================
                  // AVATAR
                  // ==================================================
                  Container(
                    width: 56,
                    height: 56,

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

                  // ==================================================
                  // NAME + STATUS
                  // ==================================================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          leadName,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: Colors.white,

                            fontSize: 18,

                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 8),

                        _buildStatusChip(lead.currentStatus),
                      ],
                    ),
                  ),

                  // ==================================================
                  // ARROW
                  // ==================================================
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

                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,

                      size: 14,

                      color: Color(0xB8FFFFFF),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 17),

              // ==================================================
              // DIVIDER
              // ==================================================
              Container(height: 1, color: Colors.white.withValues(alpha: 0.10)),

              const SizedBox(height: 14),

              // ==================================================
              // MOBILE
              // ==================================================
              _buildInfoRow(
                icon: Icons.phone_rounded,

                title: "Mobile Number",

                value: lead.mobileNo,
              ),

              const SizedBox(height: 10),

              // ==================================================
              // OWNER
              // ==================================================
              _buildInfoRow(
                icon: Icons.person_outline_rounded,

                title: "Owner",

                value: lead.leadOwner,
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
    Color color;

    final String lowerStatus = status.toLowerCase();

    if (lowerStatus.contains("converted")) {
      color = const Color(0xFF7EE787);
    } else if (lowerStatus.contains("open")) {
      color = const Color(0xFF54D6C1);
    } else if (lowerStatus.contains("closed")) {
      color = const Color(0xFFFF8A80);
    } else {
      color = const Color(0xFFFFD166);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),

      child: Text(
        status.isEmpty ? "No Status" : status,

        style: TextStyle(
          color: color,

          fontSize: 11,

          fontWeight: FontWeight.w700,
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
            width: 68,
            height: 68,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),

              shape: BoxShape.circle,

              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),

            child: const Padding(
              padding: EdgeInsets.all(19),

              child: CircularProgressIndicator(
                strokeWidth: 2.5,

                color: Color(0xFF7EE787),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Text(
            "Loading Leads...",

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
                width: 75,
                height: 75,

                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954).withValues(alpha: 0.13),

                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.people_outline_rounded,

                  size: 38,

                  color: Color(0xFF7EE787),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "No Leads Found",

                style: TextStyle(
                  color: Colors.white,

                  fontSize: 19,

                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                "There are no leads assigned to you.",

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
  // ERROR
  // ============================================================

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),

        child: GlassCard(
          radius: 24,
          blur: 15,
          opacity: 0.12,
          tint: Colors.white,

          padding: const EdgeInsets.all(25),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Container(
                width: 65,
                height: 65,

                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A80).withValues(alpha: 0.12),

                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.error_outline_rounded,

                  color: Color(0xFFFF8A80),

                  size: 34,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Unable to Load Leads",

                style: TextStyle(
                  color: Colors.white,

                  fontSize: 18,

                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                error,

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),

                  fontSize: 11,
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
              top: 100 - (value * 30),

              right: -110,

              child: _buildGlow(size: 300, color: const Color(0xFFFFD166)),
            ),

            // ==================================================
            // GREEN CENTER GLOW
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
