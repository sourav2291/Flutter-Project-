// screens/franchise/create_franchise_screen.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../repositories/franchise_repository.dart';
import '../../services/upload_service.dart';
import '../../widgets/glass_card.dart';

class CreateFranchiseScreen extends StatefulWidget {
  const CreateFranchiseScreen({super.key});

  @override
  State<CreateFranchiseScreen> createState() => _CreateFranchiseScreenState();
}

class _CreateFranchiseScreenState extends State<CreateFranchiseScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // FORM
  // ============================================================

  final _formKey = GlobalKey<FormState>();

  // ============================================================
  // PERSONAL DETAILS
  // ============================================================

  final franchiseName = TextEditingController();
  final applicantName = TextEditingController();
  final phoneNumber = TextEditingController();
  final email = TextEditingController();
  final aadhaarNumber = TextEditingController();
  final panNumber = TextEditingController();

  // ============================================================
  // OFFICE DETAILS
  // ============================================================

  final officeAddress = TextEditingController();
  final branch = TextEditingController();
  final panchayath = TextEditingController();
  final municipality = TextEditingController();

  // ============================================================
  // BANK DETAILS
  // ============================================================

  final bankName = TextEditingController();
  final bankAccountNumber = TextEditingController();
  final ifsc = TextEditingController();

  // ============================================================
  // SERVICES
  // ============================================================

  final FranchiseRepository repository = FranchiseRepository();

  final UploadService uploadService = UploadService();

  final ImagePicker picker = ImagePicker();

  // ============================================================
  // LOADING
  // ============================================================

  bool isLoading = false;

  // ============================================================
  // FILES
  // ============================================================

  File? aadhaarFile;
  File? panFile;
  File? bankFile;

  String? aadhaarUrl;
  String? panUrl;
  String? bankUrl;

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
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _animationController.dispose();

    franchiseName.dispose();
    applicantName.dispose();
    phoneNumber.dispose();
    email.dispose();
    aadhaarNumber.dispose();
    panNumber.dispose();

    officeAddress.dispose();
    branch.dispose();
    panchayath.dispose();
    municipality.dispose();

    bankName.dispose();
    bankAccountNumber.dispose();
    ifsc.dispose();

    super.dispose();
  }

  // ============================================================
  // COMMON TEXT FIELD
  // ============================================================

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,

        style: const TextStyle(color: Colors.white, fontSize: 14),

        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "$label is required";
          }

          return null;
        },

        decoration: InputDecoration(
          labelText: label,

          labelStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 13,
          ),

          floatingLabelStyle: const TextStyle(
            color: Color(0xFF7EE787),
            fontWeight: FontWeight.w600,
          ),

          prefixIcon: icon == null
              ? null
              : Icon(icon, color: const Color(0xFF7EE787), size: 20),

          filled: true,

          fillColor: Colors.white.withValues(alpha: 0.07),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xFF7EE787), width: 1.2),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PICK FILE
  // ============================================================

  Future<File?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result == null) {
      return null;
    }

    return File(result.files.single.path!);
  }

  // ============================================================
  // PICK IMAGE FROM GALLERY
  // ============================================================

  Future<File?> pickImageFromGallery() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image == null) {
      return null;
    }

    return File(image.path);
  }

  // ============================================================
  // PICK IMAGE FROM CAMERA
  // ============================================================

  Future<File?> pickImageFromCamera() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (image == null) {
      return null;
    }

    return File(image.path);
  }

  // ============================================================
  // DOCUMENT PICKER
  // ============================================================

  Future<File?> showDocumentPicker({bool allowPdf = false}) async {
    return await showModalBottomSheet<File>(
      context: context,

      backgroundColor: const Color(0xFF073D3A),

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),

      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 15, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // HANDLE
                Container(
                  width: 45,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  "Choose Document",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 18),

                // CAMERA
                _buildPickerOption(
                  icon: Icons.camera_alt_rounded,
                  title: "Camera",
                  subtitle: "Take a photo",
                  onTap: () async {
                    final file = await pickImageFromCamera();

                    if (context.mounted) {
                      Navigator.pop(context, file);
                    }
                  },
                ),

                const SizedBox(height: 9),

                // GALLERY
                _buildPickerOption(
                  icon: Icons.photo_library_rounded,
                  title: "Gallery",
                  subtitle: "Choose from gallery",
                  onTap: () async {
                    final file = await pickImageFromGallery();

                    if (context.mounted) {
                      Navigator.pop(context, file);
                    }
                  },
                ),

                // PDF / FILES
                if (allowPdf) ...[
                  const SizedBox(height: 9),

                  _buildPickerOption(
                    icon: Icons.picture_as_pdf_rounded,
                    title: "PDF / Files",
                    subtitle: "Choose a document",
                    onTap: () async {
                      final file = await pickFile();

                      if (context.mounted) {
                        Navigator.pop(context, file);
                      }
                    },
                  ),
                ],

                const SizedBox(height: 9),

                // CANCEL
                _buildPickerOption(
                  icon: Icons.close_rounded,
                  title: "Cancel",
                  subtitle: "Close this menu",
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PICKER OPTION
  // ============================================================

  Widget _buildPickerOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      radius: 17,
      blur: 10,
      opacity: 0.10,
      tint: Colors.white,
      padding: EdgeInsets.zero,

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: onTap,

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),

            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,

                  decoration: BoxDecoration(
                    color: const Color(0xFF1DB954).withValues(alpha: 0.12),

                    borderRadius: BorderRadius.circular(13),

                    border: Border.all(
                      color: const Color(0xFF7EE787).withValues(alpha: 0.18),
                    ),
                  ),

                  child: Icon(icon, color: const Color(0xFF7EE787), size: 21),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle({required String title, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 14),

      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: const Color(0xFF1DB954).withValues(alpha: 0.13),

              borderRadius: BorderRadius.circular(12),

              border: Border.all(
                color: const Color(0xFF7EE787).withValues(alpha: 0.18),
              ),
            ),

            child: Icon(icon, color: const Color(0xFF7EE787), size: 20),
          ),

          const SizedBox(width: 11),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DOCUMENT CARD
  // ============================================================

  Widget _buildDocumentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onChoose,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),

      child: GlassCard(
        radius: 19,
        blur: 12,
        opacity: 0.11,
        tint: Colors.white,

        padding: const EdgeInsets.all(14),

        child: Row(
          children: [
            Container(
              width: 47,
              height: 47,

              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),

                borderRadius: BorderRadius.circular(14),

                border: Border.all(color: iconColor.withValues(alpha: 0.20)),
              ),

              child: Icon(icon, color: iconColor, size: 23),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onChoose,

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954).withValues(alpha: 0.12),

                  borderRadius: BorderRadius.circular(12),

                  border: Border.all(
                    color: const Color(0xFF7EE787).withValues(alpha: 0.22),
                  ),
                ),

                child: const Text(
                  "Choose",
                  style: TextStyle(
                    color: Color(0xFF7EE787),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
          "Create Franchise",
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
          _buildBackground(),

          SafeArea(
            top: false,

            child: Form(
              key: _formKey,

              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 35),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // ==================================================
                    // HEADER
                    // ==================================================
                    _buildHeader(),

                    const SizedBox(height: 20),

                    // ==================================================
                    // PERSONAL DETAILS
                    // ==================================================
                    _buildSectionTitle(
                      title: "Personal Details",
                      icon: Icons.person_rounded,
                    ),

                    GlassCard(
                      radius: 23,
                      blur: 14,
                      opacity: 0.11,
                      tint: Colors.white,

                      padding: const EdgeInsets.all(16),

                      child: Column(
                        children: [
                          buildTextField(
                            "Franchise Name",
                            franchiseName,
                            icon: Icons.storefront_rounded,
                          ),

                          buildTextField(
                            "Applicant Name",
                            applicantName,
                            icon: Icons.person_outline_rounded,
                          ),

                          buildTextField(
                            "Phone Number",
                            phoneNumber,
                            keyboard: TextInputType.phone,
                            icon: Icons.phone_rounded,
                          ),

                          buildTextField(
                            "Email",
                            email,
                            keyboard: TextInputType.emailAddress,
                            icon: Icons.email_rounded,
                          ),

                          buildTextField(
                            "Aadhaar Number",
                            aadhaarNumber,
                            keyboard: TextInputType.number,
                            icon: Icons.badge_rounded,
                          ),

                          buildTextField(
                            "PAN Number",
                            panNumber,
                            icon: Icons.credit_card_rounded,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // OFFICE DETAILS
                    // ==================================================
                    _buildSectionTitle(
                      title: "Office Details",
                      icon: Icons.business_rounded,
                    ),

                    GlassCard(
                      radius: 23,
                      blur: 14,
                      opacity: 0.11,
                      tint: Colors.white,

                      padding: const EdgeInsets.all(16),

                      child: Column(
                        children: [
                          buildTextField(
                            "Office Address",
                            officeAddress,
                            maxLines: 3,
                            icon: Icons.location_on_rounded,
                          ),

                          buildTextField(
                            "Branch",
                            branch,
                            icon: Icons.account_tree_rounded,
                          ),

                          buildTextField(
                            "Panchayath",
                            panchayath,
                            icon: Icons.location_city_rounded,
                          ),

                          buildTextField(
                            "Municipality",
                            municipality,
                            icon: Icons.apartment_rounded,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // BANK DETAILS
                    // ==================================================
                    _buildSectionTitle(
                      title: "Bank Details",
                      icon: Icons.account_balance_rounded,
                    ),

                    GlassCard(
                      radius: 23,
                      blur: 14,
                      opacity: 0.11,
                      tint: Colors.white,

                      padding: const EdgeInsets.all(16),

                      child: Column(
                        children: [
                          buildTextField(
                            "Bank Name",
                            bankName,
                            icon: Icons.account_balance_rounded,
                          ),

                          buildTextField(
                            "Bank Account Number",
                            bankAccountNumber,
                            keyboard: TextInputType.number,
                            icon: Icons.credit_card_rounded,
                          ),

                          buildTextField(
                            "IFSC Code",
                            ifsc,
                            icon: Icons.code_rounded,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // DOCUMENTS
                    // ==================================================
                    _buildSectionTitle(
                      title: "Upload Documents",
                      icon: Icons.upload_file_rounded,
                    ),

                    _buildDocumentCard(
                      title: "Aadhaar Card",

                      subtitle: aadhaarFile == null
                          ? "No file selected"
                          : aadhaarFile!.path.split('/').last,

                      icon: Icons.badge_rounded,

                      iconColor: const Color(0xFF64B5F6),

                      onChoose: () async {
                        final file = await showDocumentPicker();

                        if (file != null) {
                          setState(() {
                            aadhaarFile = file;
                          });
                        }
                      },
                    ),

                    _buildDocumentCard(
                      title: "PAN Card",

                      subtitle: panFile == null
                          ? "No file selected"
                          : panFile!.path.split('/').last,

                      icon: Icons.credit_card_rounded,

                      iconColor: const Color(0xFF7EE787),

                      onChoose: () async {
                        final file = await showDocumentPicker();

                        if (file != null) {
                          setState(() {
                            panFile = file;
                          });
                        }
                      },
                    ),

                    _buildDocumentCard(
                      title: "Bank Document",

                      subtitle: bankFile == null
                          ? "No file selected"
                          : bankFile!.path.split('/').last,

                      icon: Icons.account_balance_rounded,

                      iconColor: const Color(0xFFFFD166),

                      onChoose: () async {
                        final file = await showDocumentPicker(allowPdf: true);

                        if (file != null) {
                          setState(() {
                            bankFile = file;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // SUBMIT
                    // ==================================================
                    _buildSubmitButton(),

                    const SizedBox(height: 25),

                    Center(
                      child: Text(
                        "Madathil Solar ERP",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.30),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
      radius: 25,
      blur: 15,
      opacity: 0.13,
      tint: Colors.white,

      padding: const EdgeInsets.all(20),

      child: Row(
        children: [
          Container(
            width: 65,
            height: 65,

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

                  blurRadius: 20,

                  offset: const Offset(0, 7),
                ),
              ],
            ),

            child: const Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "Franchise Application",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Join the Madathil Solar network",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.52),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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
  // SUBMIT BUTTON
  // ============================================================

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 58,

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,

          colors: [Color(0xFF0B5E4D), Color(0xFF1DB954), Color(0xFF7EE787)],
        ),

        borderRadius: BorderRadius.circular(19),

        border: Border.all(
          color: const Color(0xFF7EE787).withValues(alpha: 0.30),
        ),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1DB954).withValues(alpha: 0.20),

            blurRadius: 18,

            offset: const Offset(0, 7),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(19),

          onTap: isLoading ? null : _submitFranchise,

          child: Center(
            child: isLoading
                ? const Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      SizedBox(
                        width: 21,
                        height: 21,

                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(width: 10),

                      Text(
                        "Submitting...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Icon(Icons.send_rounded, color: Colors.white, size: 20),

                      SizedBox(width: 9),

                      Text(
                        "SUBMIT APPLICATION",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUBMIT FRANCHISE
  // ============================================================

  Future<void> _submitFranchise() async {
    // FORM VALIDATION

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ==========================================================
    // AADHAAR VALIDATION
    // ==========================================================

    if (aadhaarFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload Aadhaar Card")),
      );

      return;
    }

    // ==========================================================
    // PAN VALIDATION
    // ==========================================================

    if (panFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please upload PAN Card")));

      return;
    }

    // ==========================================================
    // BANK DOCUMENT VALIDATION
    // ==========================================================

    if (bankFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload Bank Document")),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // ========================================================
      // UPLOAD AADHAAR
      // ========================================================

      aadhaarUrl = await uploadService.uploadFile(aadhaarFile!);

      // ========================================================
      // UPLOAD PAN
      // ========================================================

      panUrl = await uploadService.uploadFile(panFile!);

      // ========================================================
      // UPLOAD BANK DOCUMENT
      // ========================================================

      bankUrl = await uploadService.uploadFile(bankFile!);

      // ========================================================
      // CREATE FRANCHISE
      // ========================================================

      bool success = await repository.createFranchiseApplication(
        franchiseName: franchiseName.text.trim(),

        applicantName: applicantName.text.trim(),

        phoneNumber: phoneNumber.text.trim(),

        email: email.text.trim(),

        aadhaarNumber: aadhaarNumber.text.trim(),

        panNumber: panNumber.text.trim(),

        officeAddress: officeAddress.text.trim(),

        bankName: bankName.text.trim(),

        bankAccountNumber: bankAccountNumber.text.trim(),

        ifsc: ifsc.text.trim(),

        branch: branch.text.trim(),

        panchayath: panchayath.text.trim(),

        municipality: municipality.text.trim(),

        aadhaarCard: aadhaarUrl!,

        panCard: panUrl!,

        bankAccountAttachment: bankUrl!,
      );

      // ========================================================
      // SUCCESS
      // ========================================================

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF1DB954),

              content: Text("Application Submitted Successfully"),
            ),
          );

          Navigator.pop(context, true);
        }
      }
      // ========================================================
      // FAILED
      // ========================================================
      else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,

              content: Text("Failed to submit application"),
            ),
          );
        }
      }
    }
    // ==========================================================
    // ERROR
    // ==========================================================
    catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
        );
      }
    }
    // ==========================================================
    // FINISH LOADING
    // ==========================================================
    finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
              top: 160 - (value * 30),

              right: -120,

              child: _buildGlow(size: 300, color: const Color(0xFFFFD166)),
            ),

            // ==================================================
            // GREEN BOTTOM GLOW
            // ==================================================
            Positioned(
              bottom: -120 + (value * 20),

              left: 30,

              child: _buildGlow(size: 290, color: const Color(0xFF7EE787)),
            ),

            // ==================================================
            // FLOATING LEAF
            // ==================================================
            Positioned(
              top: 230 + (value * 35),

              right: 8,

              child: Transform.rotate(
                angle: -0.25 + (value * 0.15),

                child: Icon(
                  Icons.eco_rounded,
                  size: 62,
                  color: const Color(0x447EE787),
                ),
              ),
            ),

            // ==================================================
            // SECOND LEAF
            // ==================================================
            Positioned(
              bottom: 160 - (value * 25),

              left: 5,

              child: Transform.rotate(
                angle: 0.30 - (value * 0.12),

                child: Icon(
                  Icons.eco_rounded,
                  size: 42,
                  color: const Color(0x44FFD166),
                ),
              ),
            ),

            // ==================================================
            // SMALL SOLAR CIRCLE
            // ==================================================
            Positioned(
              top: 420 + (value * 20),

              right: 40,

              child: Container(
                width: 85,
                height: 85,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  border: Border.all(color: const Color(0x447EE787)),
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
