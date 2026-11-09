// screens/lead/create_lead_screen.dart

// screens/lead/create_lead_screen.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../repositories/lead_repository.dart';

class CreateLeadScreen extends StatefulWidget {
  const CreateLeadScreen({super.key});

  @override
  State<CreateLeadScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends State<CreateLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final LeadRepository repository = LeadRepository();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final franchiseController = TextEditingController();

  bool isSaving = false;

  List<String> leadSources = [];
  String? selectedLeadSource;

  // KSEB BILLS
  List<File> selectedKsebBills = [];
  bool isUploadingKsebBills = false;

  @override
  void initState() {
    super.initState();
    loadLeadSources();
  }

  Future<void> loadLeadSources() async {
    try {
      final data = await repository.getLeadSources();

      if (!mounted) return;

      setState(() {
        leadSources = data;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to load Lead Sources")),
      );
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    franchiseController.dispose();
    super.dispose();
  }

  // KSEB BILL PICKER
  Future<void> pickKsebBills() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ["pdf", "jpg", "jpeg", "png"],
      );

      if (result == null) return;

      final files = result.paths
          .whereType<String>()
          .where((path) => path.trim().isNotEmpty)
          .map((path) => File(path))
          .toList();

      if (!mounted) return;

      setState(() {
        selectedKsebBills.addAll(files);
      });
    } catch (e) {
      debugPrint("KSEB BILL PICK ERROR: $e");
    }
  }

  String _ksebFileName(File file) =>
      file.path.split(Platform.pathSeparator).last;

  Future<void> uploadKsebBills(String leadName) async {
    if (selectedKsebBills.isEmpty) return;

    setState(() {
      isUploadingKsebBills = true;
    });

    try {
      for (final file in selectedKsebBills) {
        await repository.uploadKsebBill(leadName: leadName, file: file);
      }
    } catch (e) {
      debugPrint("KSEB BILL UPLOAD ERROR: $e");
    } finally {
      if (mounted) {
        setState(() {
          isUploadingKsebBills = false;
        });
      }
    }
  }

  // SAVE LEAD — ASSIGN DIALOG REMOVED
  Future<void> saveLead() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final leadName = await repository.createLead(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        mobileNo: mobileController.text.trim(),
        email: emailController.text.trim(),
        franchiseName: franchiseController.text.trim(),
        leadSource: selectedLeadSource ?? "",
      );

      if (!mounted) return;

      if (leadName != null) {
        await uploadKsebBills(leadName);
      }

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      if (leadName != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lead created successfully"),
            backgroundColor: Colors.green,
          ),
        );

        // Return to the previous screen.
        // Do not show the Assign Lead dialog.
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to create Lead"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041A1F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Create Lead",
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Stack(
        children: [
          // BACKGROUND
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

          // Green glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1DB954).withValues(alpha: 0.30),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Gold glow
          Positioned(
            top: 180,
            right: -120,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFD166).withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Green bottom glow
          Positioned(
            bottom: -100,
            left: 40,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7EE787).withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Decorative leaf
          Positioned(
            top: 100,
            right: 10,
            child: Transform.rotate(
              angle: -0.3,
              child: Icon(
                Icons.eco_rounded,
                size: 65,
                color: const Color(0xFF7EE787).withValues(alpha: 0.10),
              ),
            ),
          ),

          // FORM
          SafeArea(
            top: false,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                child: Column(
                  children: [
                    // HEADER GLASS CARD
                    _glassContainer(
                      child: Row(
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1DB954), Color(0xFF0B5E4D)],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Colors.white,
                              size: 27,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "New Lead",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Add a new potential customer",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.58),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // FIRST NAME
                    _glassTextField(
                      controller: firstNameController,
                      label: "First Name *",
                      icon: Icons.person_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Enter First Name";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 13),

                    // LAST NAME
                    _glassTextField(
                      controller: lastNameController,
                      label: "Last Name",
                      icon: Icons.person_outline_rounded,
                    ),

                    const SizedBox(height: 13),

                    // MOBILE
                    _glassTextField(
                      controller: mobileController,
                      label: "Mobile Number *",
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Enter Mobile Number";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 13),

                    // EMAIL
                    _glassTextField(
                      controller: emailController,
                      label: "Email",
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 13),

                    // FRANCHISE
                    _glassTextField(
                      controller: franchiseController,
                      label: "Franchise Name",
                      icon: Icons.store_rounded,
                    ),

                    const SizedBox(height: 13),

                    // KSEB BILLS
                    _buildKsebBillCard(),

                    const SizedBox(height: 13),

                    // LEAD SOURCE
                    _glassDropdown(),

                    const SizedBox(height: 24),

                    // SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton.icon(
                        onPressed: isSaving ? null : saveLead,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF1DB954),
                          disabledBackgroundColor: const Color(
                            0xFF1DB954,
                          ).withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: const Color(
                                0xFF7EE787,
                              ).withValues(alpha: 0.35),
                            ),
                          ),
                        ),
                        icon: isSaving
                            ? const SizedBox(
                                width: 21,
                                height: 21,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.check_circle_outline_rounded,
                                color: Colors.white,
                              ),
                        label: Text(
                          isSaving ? "Saving..." : "SAVE LEAD",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // KSEB BILL CARD
  Widget _buildKsebBillCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: selectedKsebBills.isNotEmpty
              ? const Color(0xFF7EE787)
              : Colors.white.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1DB954).withValues(alpha: 0.18),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Color(0xFF7EE787),
                  size: 24,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "KSEB Bill",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Optional • PDF, JPG, JPEG, PNG",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: isSaving ? null : pickKsebBills,
                icon: const Icon(Icons.add_rounded, color: Color(0xFF7EE787)),
              ),
            ],
          ),
          if (selectedKsebBills.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...selectedKsebBills.asMap().entries.map((entry) {
              final file = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  children: [
                    const Icon(
                      Icons.insert_drive_file_outlined,
                      size: 18,
                      color: Color(0xFF7EE787),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _ksebFileName(file),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: isSaving
                          ? null
                          : () {
                              setState(() {
                                selectedKsebBills.removeAt(entry.key);
                              });
                            },
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // GLASS CONTAINER
  Widget _glassContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.20),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  // GLASS TEXT FIELD
  Widget _glassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: const Color(0xFF7EE787),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.62),
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF7EE787),
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF7EE787)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFF7EE787), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFFFF8A80)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFFFF8A80), width: 1.4),
        ),
      ),
    );
  }

  // GLASS DROPDOWN
  Widget _glassDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedLeadSource,
      dropdownColor: const Color(0xFF123D3A),
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: "Lead Source",
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.62)),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF7EE787),
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: const Icon(
          Icons.campaign_rounded,
          color: Color(0xFF7EE787),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFF7EE787), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFFFF8A80)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFFFF8A80), width: 1.4),
        ),
      ),
      items: leadSources.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedLeadSource = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please select Lead Source";
        }
        return null;
      },
    );
  }
}
