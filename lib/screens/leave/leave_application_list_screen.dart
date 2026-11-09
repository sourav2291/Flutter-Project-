// screens/leave/leave_application_list_screen.dart
import 'package:flutter/material.dart';

import '../../models/leave_application.dart';
import '../../repositories/leave_application_repository.dart';
import 'create_leave_application_screen.dart';

class LeaveApplicationListScreen extends StatefulWidget {
  const LeaveApplicationListScreen({super.key});

  @override
  State<LeaveApplicationListScreen> createState() =>
      _LeaveApplicationListScreenState();
}

class _LeaveApplicationListScreenState
    extends State<LeaveApplicationListScreen> {
  final LeaveApplicationRepository repository = LeaveApplicationRepository();

  List<LeaveApplication> leaveApplications = [];

  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadLeaveApplications();
  }

  // ============================================================
  // LOAD MY LEAVE APPLICATIONS
  // ============================================================

  Future<void> loadLeaveApplications() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final data = await repository.getLeaveApplications();

      if (!mounted) return;

      setState(() {
        leaveApplications = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return const Color(0xFF68D391);

      case "rejected":
        return const Color(0xFFFF6B6B);

      case "cancelled":
        return const Color(0xFFFFB86C);

      case "open":
      case "pending":
        return const Color(0xFFFFD166);

      default:
        return Colors.white70;
    }
  }

  // ============================================================
  // STATUS ICON
  // ============================================================

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Icons.check_circle_rounded;

      case "rejected":
        return Icons.cancel_rounded;

      case "cancelled":
        return Icons.remove_circle_rounded;

      case "open":
      case "pending":
        return Icons.access_time_rounded;

      default:
        return Icons.info_outline_rounded;
    }
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(String date) {
    if (date.isEmpty) return "-";

    try {
      final parsed = DateTime.parse(date);

      return "${parsed.day.toString().padLeft(2, '0')}/"
          "${parsed.month.toString().padLeft(2, '0')}/"
          "${parsed.year}";
    } catch (_) {
      return date;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF062E2A),

      appBar: AppBar(
        backgroundColor: const Color(0xFF103F39),
        elevation: 0,

        title: const Text(
          "My Leave Applications",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 19,
          ),
        ),

        iconTheme: const IconThemeData(color: Colors.white),

        actions: [
          IconButton(
            onPressed: loadLeaveApplications,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1DB954),
        foregroundColor: Colors.white,

        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateLeaveApplicationScreen(),
            ),
          );

          if (result == true) {
            loadLeaveApplications();
          }
        },

        icon: const Icon(Icons.add_rounded),

        label: const Text(
          "Apply Leave",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: loadLeaveApplications,

        color: const Color(0xFF1DB954),
        backgroundColor: const Color(0xFF103F39),

        child: _buildBody(),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1DB954)),
      );
    }

    if (errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.30),

          Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent.withValues(alpha: 0.8),
            size: 55,
          ),

          const SizedBox(height: 15),

          const Center(
            child: Text(
              "Unable to load leave applications",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: ElevatedButton.icon(
              onPressed: loadLeaveApplications,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Try Again"),
            ),
          ),
        ],
      );
    }

    if (leaveApplications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.28),

          const Icon(
            Icons.event_available_rounded,
            color: Color(0xFF7EE787),
            size: 65,
          ),

          const SizedBox(height: 15),

          const Center(
            child: Text(
              "No Leave Applications",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 7),

          Center(
            child: Text(
              "You haven't applied for any leave yet.",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 13,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 100),

      physics: const AlwaysScrollableScrollPhysics(),

      itemCount: leaveApplications.length,

      itemBuilder: (context, index) {
        return _buildLeaveCard(leaveApplications[index]);
      },
    );
  }

  // ============================================================
  // LEAVE CARD
  // ============================================================

  Widget _buildLeaveCard(LeaveApplication leave) {
    final status = leave.status.isEmpty ? "Open" : leave.status;

    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 13),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ==================================================
          // TOP ROW
          // ==================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      leave.leaveType.isEmpty ? "Leave" : leave.leaveType,

                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      leave.name.isEmpty ? "Leave Application" : leave.name,

                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // STATUS
              // ==================================================
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),

                  borderRadius: BorderRadius.circular(20),

                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.30),
                  ),
                ),

                child: Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Icon(_statusIcon(status), color: statusColor, size: 15),

                    const SizedBox(width: 5),

                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ==================================================
          // DATE
          // ==================================================
          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.12),

              borderRadius: BorderRadius.circular(14),
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.date_range_rounded,
                  color: Color(0xFF7EE787),
                  size: 22,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        "Leave Period",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 10,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        "${_formatDate(leave.fromDate)}"
                        "  →  "
                        "${_formatDate(leave.toDate)}",

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                if (leave.totalLeaveDays > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,

                    children: [
                      Text(
                        "Days",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 10,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        leave.totalLeaveDays.toStringAsFixed(
                          leave.totalLeaveDays.truncateToDouble() ==
                                  leave.totalLeaveDays
                              ? 0
                              : 1,
                        ),

                        style: const TextStyle(
                          color: Color(0xFF7EE787),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // ==================================================
          // DESCRIPTION
          // ==================================================
          if (leave.description.isNotEmpty) ...[
            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Icon(
                  Icons.notes_rounded,
                  color: Colors.white.withValues(alpha: 0.45),
                  size: 18,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    leave.description,

                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // ==================================================
          // APPROVER
          // ==================================================
          if (leave.leaveApproverName.isNotEmpty ||
              leave.leaveApprover.isNotEmpty) ...[
            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  Icons.person_pin_rounded,
                  color: Colors.white.withValues(alpha: 0.45),
                  size: 18,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    leave.leaveApproverName.isNotEmpty
                        ? "Approver: ${leave.leaveApproverName}"
                        : "Approver: ${leave.leaveApprover}",

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
