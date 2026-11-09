// screens/lead/lead_details_screen.dart

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';

import 'package:http/http.dart' as http;

import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:open_filex/open_filex.dart';

import '../../models/lead.dart';

import '../../repositories/lead_repository.dart';
import 'create_address_screen.dart';

import '../../widgets/glass_card.dart';

import '../../services/session_service.dart';

class LeadDetailsScreen extends StatefulWidget {
  final Lead lead;

  const LeadDetailsScreen({super.key, required this.lead});

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends State<LeadDetailsScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================

  // BACKGROUND ANIMATION

  // ============================================================

  late AnimationController _animationController;

  // ============================================================

  // KSEB BILLS

  // ============================================================

  List<Map<String, dynamic>> ksebBills = [];

  bool isLoadingKsebBills = false;

  bool isUploadingKsebBill = false;

  late Lead currentLead;

  @override
  void initState() {
    super.initState();

    currentLead = widget.lead;

    _animationController = AnimationController(
      vsync: this,

      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _loadKsebBills();
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
    final lead = currentLead;

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
          "Lead Details",

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

          // BACKGROUND

          // ======================================================
          _buildBackground(),

          // ======================================================

          // CONTENT

          // ======================================================
          SafeArea(
            top: false,

            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 30),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // ==================================================

                  // LEAD HEADER

                  // ==================================================
                  _buildLeadHeader(lead),

                  const SizedBox(height: 16),

                  // ==================================================

                  // LEAD INFORMATION

                  // ==================================================
                  _buildSectionTitle(
                    "Lead Information",

                    Icons.person_outline_rounded,
                  ),

                  const SizedBox(height: 10),

                  _buildLeadInformation(lead),

                  const SizedBox(height: 24),

                  // ==================================================

                  // ADDRESS

                  // ==================================================
                  Row(
                    children: [
                      Expanded(
                        child: _buildSectionTitle(
                          "Address",
                          Icons.location_on_outlined,
                        ),
                      ),
                      _buildAddAddressButton(),
                    ],
                  ),

                  const SizedBox(height: 10),

                  if (lead.addresses.isNotEmpty)
                    _buildAddresses(lead)
                  else
                    GlassCard(
                      radius: 20,
                      blur: 13,
                      opacity: 0.12,
                      tint: Colors.white,
                      padding: const EdgeInsets.all(18),
                      child: Center(
                        child: Text(
                          "No address added yet.",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // KSEB BILLS

                  // ==================================================
                  _buildKsebBills(lead),

                  const SizedBox(height: 24),

                  // FOLLOW-UPS

                  // ==================================================
                  Row(
                    children: [
                      Expanded(
                        child: _buildSectionTitle(
                          "Follow-ups",

                          Icons.history_rounded,
                        ),
                      ),

                      _buildAddFollowUpButton(),
                    ],
                  ),

                  const SizedBox(height: 10),

                  _buildFollowUps(lead),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================

  // KSEB BILLS

  // ============================================================

  Future<void> _addLeadAddress() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAddressScreen(
          leadName: currentLead.name,
          leadDisplayName: currentLead.leadName,
        ),
      ),
    );

    if (!mounted || result != true) return;

    try {
      final leads = await LeadRepository().getLeads();
      Lead? refreshedLead;
      for (final item in leads) {
        if (item.name == currentLead.name) {
          refreshedLead = item;
          break;
        }
      }

      if (!mounted) return;

      if (refreshedLead != null) {
        setState(() {
          currentLead = refreshedLead!;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address added successfully.")),
      );
    } catch (e) {
      debugPrint("REFRESH LEAD ADDRESSES ERROR: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Address saved. Please reopen Lead Details to refresh.",
          ),
        ),
      );
    }
  }

  Widget _buildAddAddressButton() {
    return InkWell(
      onTap: _addLeadAddress,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF1DB954).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF7EE787).withValues(alpha: 0.25),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 17, color: Color(0xFF7EE787)),
            SizedBox(width: 4),
            Text(
              "Add Address",
              style: TextStyle(
                color: Color(0xFF7EE787),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadKsebBills() async {
    if (!mounted) return;

    setState(() {
      isLoadingKsebBills = true;
    });

    try {
      final bills = await LeadRepository().getKsebBills(widget.lead.name);

      if (!mounted) return;

      setState(() {
        ksebBills = bills;
      });
    } catch (e) {
      debugPrint("GET KSEB BILLS ERROR: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoadingKsebBills = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadKsebBills() async {
    if (isUploadingKsebBill) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ["pdf", "jpg", "jpeg", "png"],
      );

      if (result == null) return;

      final files = result.paths
          .whereType<String>()
          .where((p) => p.trim().isNotEmpty)
          .map((p) => File(p))
          .toList();

      if (files.isEmpty || !mounted) return;

      setState(() {
        isUploadingKsebBill = true;
      });

      final repository = LeadRepository();

      for (final file in files) {
        await repository.uploadKsebBill(leadName: widget.lead.name, file: file);
      }

      await _loadKsebBills();
    } catch (e) {
      debugPrint("KSEB BILL UPLOAD ERROR: $e");
    } finally {
      if (mounted) {
        setState(() {
          isUploadingKsebBill = false;
        });
      }
    }
  }

  Future<void> _openKsebBill(Map<String, dynamic> bill) async {
    try {
      final session = SessionService();

      final site = await session.getSite();

      final cookie = await session.getCookie();

      if (site == null || cookie == null) {
        throw Exception("Session expired. Please login again.");
      }

      final fileUrl = bill["file_url"]?.toString() ?? "";

      if (fileUrl.isEmpty) throw Exception("File URL is empty.");

      final url = fileUrl.startsWith("http")
          ? Uri.parse(fileUrl)
          : Uri.parse("$site$fileUrl");

      final response = await http.get(
        url,
        headers: {"Cookie": cookie, "Accept": "*/*"},
      );

      if (response.statusCode != 200) {
        throw Exception("Unable to open file. Status: ${response.statusCode}");
      }

      final directory = await getTemporaryDirectory();

      final originalName = bill["file_name"]?.toString() ?? "KSEB_BILL";

      final safeName = originalName.replaceAll(RegExp(r'[\\\\/:*?"<>|]'), "_");

      final localFile = File("${directory.path}/$safeName");

      await localFile.writeAsBytes(response.bodyBytes);

      final result = await OpenFilex.open(localFile.path);

      debugPrint("OPEN KSEB BILL: ${result.type} ${result.message}");
    } catch (e) {
      debugPrint("OPEN KSEB BILL ERROR: $e");
    }
  }

  Widget _buildKsebBills(Lead lead) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSectionTitle(
                "KSEB Bills",
                Icons.receipt_long_rounded,
              ),
            ),

            InkWell(
              onTap: isUploadingKsebBill ? null : _pickAndUploadKsebBills,

              borderRadius: BorderRadius.circular(20),

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF7EE787).withValues(alpha: 0.25),
                  ),
                ),

                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isUploadingKsebBill)
                      const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF7EE787),
                        ),
                      )
                    else
                      const Icon(
                        Icons.add_rounded,
                        size: 17,
                        color: Color(0xFF7EE787),
                      ),

                    const SizedBox(width: 4),

                    Text(
                      isUploadingKsebBill ? "Uploading" : "Add Bill",
                      style: const TextStyle(
                        color: Color(0xFF7EE787),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (isLoadingKsebBills)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF7EE787)),
            ),
          )
        else if (ksebBills.isEmpty)
          GlassCard(
            radius: 20,
            blur: 13,
            opacity: 0.12,
            tint: Colors.white,
            padding: const EdgeInsets.all(22),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    color: Colors.white.withValues(alpha: 0.45),
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "No KSEB Bills",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Add a KSEB bill when available.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: ksebBills.map((bill) {
              final fileName = bill["file_name"]?.toString() ?? "KSEB Bill";

              final extension = fileName.contains(".")
                  ? fileName.split(".").last.toUpperCase()
                  : "FILE";

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  radius: 20,
                  blur: 13,
                  opacity: 0.12,
                  tint: Colors.white,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF1DB954,
                          ).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          extension == "PDF"
                              ? Icons.picture_as_pdf_rounded
                              : Icons.image_rounded,
                          color: const Color(0xFF7EE787),
                          size: 22,
                        ),
                      ),

                      const SizedBox(width: 11),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              extension,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      TextButton(
                        onPressed: () => _openKsebBill(bill),
                        child: const Text(
                          "OPEN",
                          style: TextStyle(
                            color: Color(0xFF7EE787),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // LEAD HEADER

  // ============================================================

  Widget _buildLeadHeader(Lead lead) {
    final String leadName = lead.leadName.isNotEmpty
        ? lead.leadName
        : "Unnamed Lead";

    final String firstLetter = lead.leadName.isNotEmpty
        ? lead.leadName[0].toUpperCase()
        : "?";

    return GlassCard(
      radius: 24,

      blur: 14,

      opacity: 0.14,

      tint: Colors.white,

      padding: const EdgeInsets.all(18),

      child: Row(
        children: [
          // ==================================================

          // AVATAR

          // ==================================================
          Container(
            width: 64,

            height: 64,

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
                  color: const Color(0xFF1DB954).withValues(alpha: 0.22),

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

                  fontSize: 25,

                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(width: 15),

          // ==================================================

          // NAME + STATUS

          // ==================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  leadName,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.white,

                    fontSize: 21,

                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 9),

                _buildStatusChip(lead.currentStatus),
              ],
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
        Icon(icon, size: 20, color: const Color(0xFF7EE787)),

        const SizedBox(width: 8),

        Text(
          title,

          style: const TextStyle(
            color: Colors.white,

            fontSize: 18,

            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================

  // LEAD INFORMATION

  // ============================================================

  Widget _buildLeadInformation(Lead lead) {
    return GlassCard(
      radius: 20,

      blur: 13,

      opacity: 0.12,

      tint: Colors.white,

      padding: const EdgeInsets.all(16),

      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.phone_rounded,

            title: "Mobile Number",

            value: lead.mobileNo,
          ),

          const SizedBox(height: 13),

          _buildInfoRow(
            icon: Icons.chat_rounded,

            title: "WhatsApp Number",

            value: lead.whatsappNo,
          ),

          const SizedBox(height: 13),

          _buildInfoRow(
            icon: Icons.email_outlined,

            title: "Email",

            value: lead.emailId ?? "",
          ),

          const SizedBox(height: 13),

          _buildInfoRow(
            icon: Icons.source_rounded,

            title: "Lead Source",

            value: lead.source,
          ),

          const SizedBox(height: 13),

          _buildInfoRow(
            icon: Icons.person_outline_rounded,

            title: "Lead Owner",

            value: lead.leadOwner,
          ),
        ],
      ),
    );
  }

  // ============================================================

  // ADDRESS

  // ============================================================

  Widget _buildAddresses(Lead lead) {
    return Column(
      children: lead.addresses.map((address) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),

          child: GlassCard(
            radius: 20,

            blur: 13,

            opacity: 0.12,

            tint: Colors.white,

            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                if (address.addressTitle.isNotEmpty)
                  Text(
                    address.addressTitle,

                    style: const TextStyle(
                      color: Colors.white,

                      fontSize: 15,

                      fontWeight: FontWeight.w700,
                    ),
                  ),

                if (address.addressTitle.isNotEmpty) const SizedBox(height: 8),

                _buildAddressText(address),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddressText(LeadAddress address) {
    final List<String> lines = [];

    if (address.addressLine1.isNotEmpty) {
      lines.add(address.addressLine1);
    }

    if (address.addressLine2.isNotEmpty) {
      lines.add(address.addressLine2);
    }

    if (address.city.isNotEmpty) {
      lines.add(address.city);
    }

    if (address.state.isNotEmpty) {
      lines.add(address.state);
    }

    if (address.country.isNotEmpty) {
      lines.add(address.country);
    }

    if (address.pincode.isNotEmpty) {
      lines.add(address.pincode);
    }

    if (lines.isEmpty) {
      return Text(
        "-",

        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.60),

          fontSize: 13,
        ),
      );
    }

    return Text(
      lines.join(", "),

      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.80),

        fontSize: 13,

        height: 1.5,
      ),
    );
  }

  // ============================================================

  // FOLLOW-UPS

  // ============================================================

  Widget _buildFollowUps(Lead lead) {
    if (lead.leadTracking.isEmpty) {
      return GlassCard(
        radius: 20,

        blur: 13,

        opacity: 0.12,

        tint: Colors.white,

        padding: const EdgeInsets.all(25),

        child: Center(
          child: Column(
            children: [
              Container(
                width: 58,

                height: 58,

                decoration: BoxDecoration(
                  color: const Color(0xFF7EE787).withValues(alpha: 0.10),

                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.history_rounded,

                  color: Color(0xFF7EE787),

                  size: 28,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "No Follow-ups Yet",

                style: TextStyle(
                  color: Colors.white,

                  fontSize: 16,

                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                "Add a follow-up to keep track of this lead.",

                textAlign: TextAlign.center,

                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),

                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: lead.leadTracking.map((tracking) {
        return _buildFollowUpCard(tracking);
      }).toList(),
    );
  }

  // ============================================================

  // FOLLOW-UP CARD

  // ============================================================

  Widget _buildFollowUpCard(LeadTracking tracking) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: GlassCard(
        radius: 20,

        blur: 13,

        opacity: 0.12,

        tint: Colors.white,

        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================

            // DATE + STATUS

            // ==================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Expanded(
                  child: _buildFollowUpInfo(
                    icon: Icons.calendar_today_rounded,

                    title: "Date & Time",

                    value: tracking.dateAndTime,
                  ),
                ),

                const SizedBox(width: 10),

                _buildFollowUpStatus(tracking.status),
              ],
            ),

            const SizedBox(height: 15),

            // ==================================================

            // FEEDBACK

            // ==================================================
            _buildFollowUpInfo(
              icon: Icons.notes_rounded,

              title: "Feedback",

              value: tracking.feedback,
            ),

            const SizedBox(height: 15),

            // ==================================================

            // USER

            // ==================================================
            _buildFollowUpInfo(
              icon: Icons.person_outline_rounded,

              title: "User",

              value: tracking.userLink,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================

  // FOLLOW-UP INFO

  // ============================================================

  Widget _buildFollowUpInfo({
    required IconData icon,

    required String title,

    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Container(
          width: 35,

          height: 35,

          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),

            borderRadius: BorderRadius.circular(10),

            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),

          child: Icon(icon, size: 17, color: const Color(0xFF7EE787)),
        ),

        const SizedBox(width: 10),

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

              const SizedBox(height: 3),

              Text(
                value.isEmpty ? "-" : value,

                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),

                  fontSize: 13,

                  fontWeight: FontWeight.w600,

                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================

  // FOLLOW-UP STATUS

  // ============================================================

  Widget _buildFollowUpStatus(String status) {
    Color color;

    final String lowerStatus = status.toLowerCase();

    if (lowerStatus.contains("completed") ||
        lowerStatus.contains("converted") ||
        lowerStatus.contains("success")) {
      color = const Color(0xFF7EE787);
    } else if (lowerStatus.contains("open") ||
        lowerStatus.contains("pending") ||
        lowerStatus.contains("follow")) {
      color = const Color(0xFF54D6C1);
    } else if (lowerStatus.contains("closed") ||
        lowerStatus.contains("cancel")) {
      color = const Color(0xFFFF8A80);
    } else {
      color = const Color(0xFFFFD166);
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 110),

      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),

      child: Text(
        status.isEmpty ? "No Status" : status,

        maxLines: 1,

        overflow: TextOverflow.ellipsis,

        style: TextStyle(
          color: color,

          fontSize: 10,

          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================

  // ADD FOLLOW-UP BUTTON

  // ============================================================

  Widget _buildAddFollowUpButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),

      onTap: _showAddFollowUpDialog,

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),

        decoration: BoxDecoration(
          color: const Color(0xFF1DB954).withValues(alpha: 0.15),

          borderRadius: BorderRadius.circular(20),

          border: Border.all(
            color: const Color(0xFF7EE787).withValues(alpha: 0.25),
          ),
        ),

        child: const Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(Icons.add_rounded, size: 17, color: Color(0xFF7EE787)),

            SizedBox(width: 4),

            Text(
              "Add Follow-up",

              style: TextStyle(
                color: Color(0xFF7EE787),

                fontSize: 11,

                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================

  // ADD FOLLOW-UP DIALOG

  // ============================================================

  void _showAddFollowUpDialog() {
    final TextEditingController statusController = TextEditingController();

    final TextEditingController feedbackController = TextEditingController();

    String? selectedStatus;

    const List<String> followUpStatuses = [
      "Fresh Lead",

      "Do Not Contact",

      "Call Back",

      "Invalid Number",

      "Rejected",

      "Not Interested",

      "Busy",

      "No Response",

      "Wrong Number",

      "Replied",

      "Opportunity",

      "Interested",
    ];

    // Keep the same date & time for the whole dialog.

    final DateTime followUpDateTime = DateTime.now();

    showDialog(
      context: context,

      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF103F39),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),

              title: const Text(
                "Add Follow-up",

                style: TextStyle(
                  color: Colors.white,

                  fontSize: 20,

                  fontWeight: FontWeight.w800,
                ),
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // ==================================================

                    // DATE & TIME

                    // ==================================================
                    Text(
                      "Date & Time",

                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),

                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(13),

                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),

                        borderRadius: BorderRadius.circular(12),

                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),

                      child: Text(
                        _formatDateTime(followUpDateTime),

                        style: const TextStyle(
                          color: Colors.white,

                          fontSize: 13,

                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==================================================

                    // STATUS

                    // ==================================================
                    Text(
                      "Status",

                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),

                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 5),

                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,

                      isExpanded: true,

                      dropdownColor: const Color(0xFF103F39),

                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,

                        color: Color(0xFF7EE787),
                      ),

                      style: const TextStyle(color: Colors.white, fontSize: 14),

                      hint: Text(
                        "Select follow-up status",

                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),

                      decoration: InputDecoration(
                        filled: true,

                        fillColor: Colors.white.withValues(alpha: 0.07),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),

                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.10),
                          ),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),

                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.10),
                          ),
                        ),

                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),

                          borderSide: BorderSide(color: Color(0xFF7EE787)),
                        ),
                      ),

                      items: followUpStatuses.map((status) {
                        return DropdownMenuItem<String>(
                          value: status,

                          child: Text(status),
                        );
                      }).toList(),

                      onChanged: isSaving
                          ? null
                          : (value) {
                              setDialogState(() {
                                selectedStatus = value;

                                statusController.text = value ?? "";
                              });
                            },
                    ),

                    const SizedBox(height: 16),

                    // ==================================================

                    // FEEDBACK

                    // ==================================================
                    Text(
                      "Feedback",

                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),

                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 5),

                    TextField(
                      controller: feedbackController,

                      enabled: !isSaving,

                      maxLines: 4,

                      style: const TextStyle(color: Colors.white),

                      decoration: InputDecoration(
                        hintText: "Enter follow-up feedback",

                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),

                        filled: true,

                        fillColor: Colors.white.withValues(alpha: 0.07),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),

                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.10),
                          ),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),

                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.10),
                          ),
                        ),

                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),

                          borderSide: BorderSide(color: Color(0xFF7EE787)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),

              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },

                  child: Text(
                    "Cancel",

                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.60),
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (statusController.text.trim().isEmpty &&
                              feedbackController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please enter status or feedback.",
                                ),
                              ),
                            );

                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            final dateTime =
                                "${followUpDateTime.year.toString().padLeft(4, '0')}-"
                                "${followUpDateTime.month.toString().padLeft(2, '0')}-"
                                "${followUpDateTime.day.toString().padLeft(2, '0')} "
                                "${followUpDateTime.hour.toString().padLeft(2, '0')}:"
                                "${followUpDateTime.minute.toString().padLeft(2, '0')}:"
                                "${followUpDateTime.second.toString().padLeft(2, '0')}";

                            final repository = LeadRepository();

                            final success = await repository.addLeadFollowUp(
                              leadName: widget.lead.name,

                              status: statusController.text.trim(),

                              feedback: feedbackController.text.trim(),

                              dateAndTime: dateTime,
                            );

                            if (!success) {
                              throw Exception("Failed to save follow-up.");
                            }

                            // Fetch the updated lead so the newly

                            // saved follow-up is immediately visible.

                            final leads = await repository.getLeads();

                            Lead? updatedLead;

                            for (final item in leads) {
                              if (item.name == widget.lead.name) {
                                updatedLead = item;

                                break;
                              }
                            }

                            if (!mounted) return;

                            Navigator.pop(dialogContext);

                            if (updatedLead != null) {
                              await _showAssignDialog(widget.lead.name);

                              if (!mounted) return;

                              Navigator.pushReplacement(
                                this.context,

                                MaterialPageRoute(
                                  builder: (_) =>
                                      LeadDetailsScreen(lead: updatedLead!),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Follow-up saved successfully.",
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;

                            setDialogState(() {
                              isSaving = false;
                            });

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to save follow-up: $e"),
                              ),
                            );
                          }
                        },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),

                    disabledBackgroundColor: const Color(
                      0xFF1DB954,
                    ).withValues(alpha: 0.45),

                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: isSaving
                      ? const SizedBox(
                          width: 20,

                          height: 20,

                          child: CircularProgressIndicator(
                            strokeWidth: 2,

                            color: Colors.white,
                          ),
                        )
                      : const Text("Save Follow-up"),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      statusController.dispose();

      feedbackController.dispose();
    });
  }

  // ============================================================

  // ASSIGN LEAD

  // ============================================================

  Future<void> _showAssignDialog(String leadName) async {
    Map<String, String> manager = {};

    try {
      final repository = LeadRepository();

      manager = await repository.getQuotationManager();
    } catch (e) {
      debugPrint("GET QUOTATION MANAGER ERROR: $e");

      return;
    }

    if (!mounted) return;

    await showDialog(
      context: context,

      barrierDismissible: false,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Assign Lead",

            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                "Lead created successfully.",

                style: TextStyle(
                  color: Colors.green,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                "Lead : $leadName",

                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              const Text(
                "Quotation Manager",

                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),

                  borderRadius: BorderRadius.circular(8),
                ),

                child: Text(
                  manager["name"] ?? "",

                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text("Skip"),
            ),

            ElevatedButton(
              onPressed: () async {
                final repository = LeadRepository();

                final success = await repository.assignLead(
                  leadName: leadName,

                  allocatedTo: manager["email"]!,
                );

                if (!mounted) return;

                Navigator.pop(dialogContext);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Lead Assigned Successfully"),

                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Unable to assign Lead"),

                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },

              child: const Text("Assign"),
            ),
          ],
        );
      },
    );
  }

  // ============================================================

  // DATE & TIME

  // ============================================================

  String _formatDateTime(DateTime dateTime) {
    final String day = dateTime.day.toString().padLeft(2, "0");

    final String month = dateTime.month.toString().padLeft(2, "0");

    final String year = dateTime.year.toString();

    final int hour12 = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
        ? dateTime.hour - 12
        : dateTime.hour;

    final String hour = hour12.toString().padLeft(2, "0");

    final String minute = dateTime.minute.toString().padLeft(2, "0");

    final String period = dateTime.hour >= 12 ? "PM" : "AM";

    return "$day-$month-$year $hour:$minute $period";
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
      crossAxisAlignment: CrossAxisAlignment.start,

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

                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),

                  fontSize: 13,

                  fontWeight: FontWeight.w600,

                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
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
