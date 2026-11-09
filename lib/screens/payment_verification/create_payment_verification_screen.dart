// screens/payment_verification/create_payment_verification_screen.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../repositories/payment_verification_repository.dart';
import '../../services/upload_service.dart';

class CreatePaymentVerificationScreen extends StatefulWidget {
  const CreatePaymentVerificationScreen({super.key});

  @override
  State<CreatePaymentVerificationScreen> createState() =>
      _CreatePaymentVerificationScreenState();
}

class _CreatePaymentVerificationScreenState
    extends State<CreatePaymentVerificationScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // FORM
  // ============================================================

  final _formKey = GlobalKey<FormState>();

  final PaymentVerificationRepository repository =
      PaymentVerificationRepository();

  final UploadService uploadService = UploadService();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final customerNameController = TextEditingController();
  final amountController = TextEditingController();
  final totalProjectCostController = TextEditingController();
  final kwController = TextEditingController();
  final placeController = TextEditingController();

  final utrNumberController = TextEditingController();
  final chequeNumberController = TextEditingController();

  final salesManagerController = TextEditingController();
  final managerNameController = TextEditingController();

  final accountsVerifiedPersonController = TextEditingController();

  // ============================================================
  // CUSTOMER
  // ============================================================

  List<Map<String, String>> customers = [];

  String? selectedCustomer;

  bool loadingCustomers = true;

  // ============================================================
  // IMAGES
  // ============================================================

  File? transactionImageFile;
  File? chequeImageFile;

  String transactionImageUrl = "";
  String chequeImageUrl = "";

  bool uploadingTransactionImage = false;
  bool uploadingChequeImage = false;

  // ============================================================
  // ACCOUNT VERIFICATION
  // ============================================================

  bool accountsVerified = false;

  // ============================================================
  // SAVE
  // ============================================================

  bool saving = false;

  // ============================================================
  // EMPLOYEE
  // ============================================================

  bool loadingEmployee = true;

  String? selectedSalesManager;

  String currentEmployeeName = "";

  // ============================================================
  // ANIMATION
  // ============================================================

  late AnimationController _animationController;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    loadInitialData();
  }

  // ============================================================
  // LOAD INITIAL DATA
  // ============================================================

  Future<void> loadInitialData() async {
    await Future.wait([loadCustomers(), loadCurrentEmployee()]);
  }

  // ============================================================
  // LOAD CUSTOMERS
  // ============================================================

  Future<void> loadCustomers() async {
    try {
      final data = await repository.getCustomers();

      if (!mounted) return;

      setState(() {
        customers = data;
        loadingCustomers = false;
      });
    } catch (e) {
      debugPrint("GET CUSTOMERS ERROR: $e");

      if (!mounted) return;

      setState(() {
        loadingCustomers = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Unable to load Customers\n$e")));
    }
  }

  // ============================================================
  // LOAD CURRENT EMPLOYEE
  // ============================================================

  Future<void> loadCurrentEmployee() async {
    try {
      final employee = await repository.getCurrentEmployee();

      final employeeId = employee["name"]?.toString().trim() ?? "";

      final employeeName = employee["employee_name"]?.toString().trim() ?? "";

      if (!mounted) return;

      setState(() {
        // Employee ID used when saving to ERPNext
        salesManagerController.text = employeeId;

        // Employee name shown to the user
        managerNameController.text = employeeName;

        // Only employee available in Sales Manager dropdown
        selectedSalesManager = employeeId;

        // Display name for the dropdown
        currentEmployeeName = employeeName;

        loadingEmployee = false;
      });
    } catch (e) {
      debugPrint("GET CURRENT EMPLOYEE ERROR: $e");

      if (!mounted) return;

      setState(() {
        loadingEmployee = false;
        selectedSalesManager = null;
        currentEmployeeName = "";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unable to load current employee\n$e")),
      );
    }
  }

  // ============================================================
  // CUSTOMER SELECTED
  // ============================================================

  void onCustomerChanged(String? value) {
    if (value == null) {
      return;
    }

    final selected = customers.firstWhere(
      (customer) => customer["name"] == value,
      orElse: () => {},
    );

    setState(() {
      selectedCustomer = value;

      customerNameController.text = selected["customer_name"] ?? "";
    });
  }

  // ============================================================
  // PICK TRANSACTION IMAGE
  // ============================================================

  Future<void> pickTransactionImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final path = result.files.single.path;

      if (path == null || path.isEmpty) {
        return;
      }

      final file = File(path);

      if (!mounted) return;

      setState(() {
        transactionImageFile = file;
        transactionImageUrl = "";
      });

      await uploadTransactionImage();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unable to select transaction image\n$e")),
      );
    }
  }

  // ============================================================
  // UPLOAD TRANSACTION IMAGE
  // ============================================================

  Future<void> uploadTransactionImage() async {
    final file = transactionImageFile;

    if (file == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      uploadingTransactionImage = true;
    });

    try {
      final fileUrl = await uploadService.uploadFile(file);

      if (!mounted) return;

      setState(() {
        transactionImageUrl = fileUrl ?? "";
        uploadingTransactionImage = false;
      });

      if (transactionImageUrl.isEmpty) {
        throw Exception("ERPNext did not return the transaction image URL.");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Transaction image uploaded successfully."),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        uploadingTransactionImage = false;
        transactionImageUrl = "";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Transaction image upload failed\n$e"),
          backgroundColor: const Color(0xFF8B2E2E),
        ),
      );
    }
  }
  // ============================================================
  // PICK CHEQUE IMAGE
  // ============================================================

  Future<void> pickChequeImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final path = result.files.single.path;

      if (path == null || path.isEmpty) {
        return;
      }

      final file = File(path);

      if (!mounted) return;

      setState(() {
        chequeImageFile = file;
        chequeImageUrl = "";
      });

      await uploadChequeImage();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unable to select cheque image\n$e")),
      );
    }
  }

  // ============================================================
  // UPLOAD CHEQUE IMAGE
  // ============================================================

  Future<void> uploadChequeImage() async {
    final file = chequeImageFile;

    if (file == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      uploadingChequeImage = true;
    });

    try {
      final fileUrl = await uploadService.uploadFile(file);

      if (!mounted) return;

      setState(() {
        chequeImageUrl = fileUrl ?? "";
        uploadingChequeImage = false;
      });

      if (chequeImageUrl.isEmpty) {
        throw Exception("ERPNext did not return the cheque image URL.");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cheque image uploaded successfully.")),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        uploadingChequeImage = false;
        chequeImageUrl = "";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cheque image upload failed\n$e"),
          backgroundColor: const Color(0xFF8B2E2E),
        ),
      );
    }
  }

  // ============================================================
  // SAVE PAYMENT VERIFICATION
  // ============================================================

  Future<void> savePaymentVerification() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a Customer.")),
      );

      return;
    }

    if (uploadingTransactionImage || uploadingChequeImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please wait until image upload is completed."),
        ),
      );

      return;
    }

    if (transactionImageFile != null && transactionImageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transaction image is not uploaded yet.")),
      );

      return;
    }

    if (chequeImageFile != null && chequeImageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cheque image is not uploaded yet.")),
      );

      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final selected = customers.firstWhere(
        (customer) => customer["name"] == selectedCustomer,
        orElse: () => {},
      );

      final customerName =
          selected["customer_name"] ?? customerNameController.text.trim();

      final paymentId = await repository.createPaymentVerification(
        customer: selectedCustomer!,
        customerName: customerName,
        amount: amountController.text.trim(),
        totalProjectCost: totalProjectCostController.text.trim(),
        kw: kwController.text.trim(),
        place: placeController.text.trim(),
        utrNumber: utrNumberController.text.trim(),
        transactionImage: transactionImageUrl,
        chequeNumber: chequeNumberController.text.trim(),
        chequeImage: chequeImageUrl,
        salesManager: salesManagerController.text.trim(),
        managerName: managerNameController.text.trim(),
        accountsVerified: accountsVerified,
        accountsVerifiedPerson: accountsVerifiedPersonController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Payment Verification created successfully.\n"
            "ID: $paymentId",
          ),
          backgroundColor: const Color(0xFF1DB954),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("CREATE PAYMENT VERIFICATION ERROR: $e");

      if (!mounted) return;

      setState(() {
        saving = false;
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
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    customerNameController.dispose();
    amountController.dispose();
    totalProjectCostController.dispose();
    kwController.dispose();
    placeController.dispose();

    utrNumberController.dispose();
    chequeNumberController.dispose();

    salesManagerController.dispose();
    managerNameController.dispose();

    accountsVerifiedPersonController.dispose();

    _animationController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041A1F),

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
          "Payment Verification",
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),

        centerTitle: true,
      ),

      body: Stack(
        children: [
          _buildBackground(),

          SafeArea(
            top: false,

            child: Form(
              key: _formKey,

              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 35),

                child: Column(
                  children: [
                    // ==================================================
                    // HEADER
                    // ==================================================
                    _buildGlassCard(
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1DB954), Color(0xFF0B5E4D)],
                              ),

                              border: Border.all(
                                color: const Color(
                                  0xFF7EE787,
                                ).withValues(alpha: 0.35),
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF1DB954,
                                  ).withValues(alpha: 0.22),
                                  blurRadius: 18,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),

                            child: const Icon(
                              Icons.payments_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 14),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "New Payment Verification",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),

                                SizedBox(height: 4),

                                Text(
                                  "Verify customer payment details",
                                  style: TextStyle(
                                    color: Colors.white70,
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

                    // ==================================================
                    // CUSTOMER
                    // ==================================================
                    _buildSectionTitle(
                      "Customer Details",
                      Icons.person_rounded,
                    ),

                    const SizedBox(height: 12),

                    _buildCustomerDropdown(),

                    const SizedBox(height: 13),

                    _buildTextField(
                      controller: customerNameController,
                      label: "Customer Name",
                      icon: Icons.person_outline_rounded,
                      readOnly: true,
                    ),

                    const SizedBox(height: 13),

                    _buildTextField(
                      controller: amountController,
                      label: "Amount *",
                      icon: Icons.currency_rupee_rounded,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final amount = double.tryParse(value?.trim() ?? "");

                        if (value == null || value.trim().isEmpty) {
                          return "Enter Amount";
                        }

                        if (amount == null || amount <= 0) {
                          return "Enter a valid Amount";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 13),

                    _buildTextField(
                      controller: totalProjectCostController,
                      label: "Total Project Cost *",
                      icon: Icons.account_balance_wallet_rounded,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final total = double.tryParse(value?.trim() ?? "");

                        if (value == null || value.trim().isEmpty) {
                          return "Enter Total Project Cost";
                        }

                        if (total == null || total <= 0) {
                          return "Enter a valid Total Project Cost";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 13),

                    _buildTextField(
                      controller: kwController,
                      label: "KW",
                      icon: Icons.bolt_rounded,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),

                    const SizedBox(height: 13),

                    _buildTextField(
                      controller: placeController,
                      label: "Place",
                      icon: Icons.location_on_rounded,
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // TRANSACTION
                    // ==================================================
                    _buildSectionTitle(
                      "Transaction Details",
                      Icons.account_balance_rounded,
                    ),

                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: utrNumberController,
                      label: "UTR Number",
                      icon: Icons.confirmation_number_rounded,
                    ),

                    const SizedBox(height: 13),

                    _buildImageUploadCard(
                      title: "Transaction Image",
                      subtitle: "Upload payment transaction proof",
                      icon: Icons.receipt_long_rounded,
                      file: transactionImageFile,
                      uploaded: transactionImageUrl.isNotEmpty,
                      uploading: uploadingTransactionImage,
                      onPressed: pickTransactionImage,
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // CHEQUE
                    // ==================================================
                    _buildSectionTitle(
                      "Cheque Details",
                      Icons.account_balance_wallet_rounded,
                    ),

                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: chequeNumberController,
                      label: "Cheque Number",
                      icon: Icons.numbers_rounded,
                    ),

                    const SizedBox(height: 13),

                    _buildImageUploadCard(
                      title: "Cheque Image",
                      subtitle: "Upload cheque image",
                      icon: Icons.image_rounded,
                      file: chequeImageFile,
                      uploaded: chequeImageUrl.isNotEmpty,
                      uploading: uploadingChequeImage,
                      onPressed: pickChequeImage,
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // SALES MANAGER
                    // ==================================================
                    _buildSectionTitle("Sales Manager", Icons.badge_rounded),

                    const SizedBox(height: 12),

                    _buildSalesManagerDropdown(),

                    const SizedBox(height: 13),

                    _buildTextField(
                      controller: managerNameController,
                      label: "Manager Name",
                      icon: Icons.account_circle_rounded,
                      readOnly: true,
                    ),

                    // ==================================================
                    // CREATE BUTTON
                    // ==================================================
                    _buildCreateButton(),

                    const SizedBox(height: 18),

                    Text(
                      "Madathil Solar ERP",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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
  // CUSTOMER SEARCH DROPDOWN
  // ============================================================

  Widget _buildCustomerDropdown() {
    final enabled = !loadingCustomers && customers.isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: enabled ? _showCustomerSearchDialog : null,
      child: InputDecorator(
        decoration: _dropdownDecoration(
          label: loadingCustomers ? "Loading Customers..." : "Customer *",
          icon: Icons.person_rounded,
          enabled: enabled,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedCustomer == null || selectedCustomer!.isEmpty
                    ? "Select Customer"
                    : _getSelectedCustomerDisplayName(),
                style: TextStyle(
                  color: selectedCustomer == null
                      ? Colors.white.withValues(alpha: 0.55)
                      : Colors.white,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SELECTED CUSTOMER DISPLAY NAME
  // ============================================================

  String _getSelectedCustomerDisplayName() {
    if (selectedCustomer == null) {
      return "Select Customer";
    }

    final customer = customers.firstWhere(
      (item) => item["name"] == selectedCustomer,
      orElse: () => {},
    );

    if (customer.isEmpty) {
      return selectedCustomer!;
    }

    final customerName = customer["customer_name"]?.toString() ?? "";

    final name = customer["name"]?.toString() ?? "";

    if (customerName.isEmpty) {
      return name;
    }

    return "$customerName  •  $name";
  }

  // ============================================================
  // CUSTOMER SEARCH DIALOG
  // ============================================================

  void _showCustomerSearchDialog() {
    final TextEditingController searchController = TextEditingController();

    List<Map<String, dynamic>> filteredCustomers =
        List<Map<String, dynamic>>.from(customers);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void searchCustomers(String value) {
              final query = value.trim().toLowerCase();

              setDialogState(() {
                if (query.isEmpty) {
                  filteredCustomers = List<Map<String, dynamic>>.from(
                    customers,
                  );
                } else {
                  filteredCustomers = customers.where((customer) {
                    final name =
                        customer["name"]?.toString().toLowerCase() ?? "";

                    final customerName =
                        customer["customer_name"]?.toString().toLowerCase() ??
                        "";

                    return name.contains(query) || customerName.contains(query);
                  }).toList();
                }
              });
            }

            return Dialog(
              backgroundColor: const Color(0xFF103D39),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.90,
                height: MediaQuery.of(context).size.height * 0.75,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ==================================================
                      // TITLE
                      // ==================================================
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Select Customer",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ==================================================
                      // SEARCH BAR
                      // ==================================================
                      TextField(
                        controller: searchController,
                        autofocus: true,
                        onChanged: searchCustomers,

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),

                        decoration: InputDecoration(
                          hintText: "Search customer...",
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.50),
                          ),

                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF7EE787),
                          ),

                          filled: true,

                          fillColor: Colors.white.withValues(alpha: 0.08),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Color(0xFF7EE787),
                              width: 1.4,
                            ),
                          ),

                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ==================================================
                      // CUSTOMER COUNT
                      // ==================================================
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "${filteredCustomers.length} customers",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      // ==================================================
                      // CUSTOMER LIST
                      // ==================================================
                      Expanded(
                        child: filteredCustomers.isEmpty
                            ? Center(
                                child: Text(
                                  "No customers found",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.60),
                                    fontSize: 15,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,

                                itemCount: filteredCustomers.length,

                                separatorBuilder: (_, _) => Divider(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  height: 1,
                                ),

                                itemBuilder: (context, index) {
                                  final customer = filteredCustomers[index];

                                  final name =
                                      customer["name"]?.toString() ?? "";

                                  final customerName =
                                      customer["customer_name"]?.toString() ??
                                      "";

                                  final displayName = customerName.isEmpty
                                      ? name
                                      : customerName;

                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),

                                    leading: Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF7EE787,
                                        ).withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person_rounded,
                                        color: Color(0xFF7EE787),
                                      ),
                                    ),

                                    title: Text(
                                      displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    subtitle: customerName.isEmpty
                                        ? null
                                        : Text(
                                            name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.50,
                                              ),
                                              fontSize: 12,
                                            ),
                                          ),

                                    onTap: () {
                                      Navigator.pop(dialogContext);

                                      onCustomerChanged(name);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // SALES MANAGER DROPDOWN
  // ============================================================

  Widget _buildSalesManagerDropdown() {
    final enabled =
        !loadingEmployee &&
        selectedSalesManager != null &&
        selectedSalesManager!.isNotEmpty;

    final safeValue = enabled ? selectedSalesManager : null;

    return DropdownButtonFormField<String>(
      initialValue: safeValue,

      onChanged: enabled
          ? (value) {
              if (value == null) return;

              setState(() {
                selectedSalesManager = value;

                // Keep Employee ID for ERPNext
                salesManagerController.text = value;

                // Keep employee name
                managerNameController.text = currentEmployeeName;
              });
            }
          : null,

      dropdownColor: const Color(0xFF103D39),

      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),

      decoration: _dropdownDecoration(
        label: loadingEmployee ? "Loading Sales Manager..." : "Sales Manager *",
        icon: Icons.person_pin_rounded,
        enabled: enabled,
      ),

      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.white70,
      ),

      items: enabled
          ? [
              DropdownMenuItem<String>(
                value: selectedSalesManager,
                child: Text(
                  currentEmployeeName.isEmpty
                      ? selectedSalesManager!
                      : currentEmployeeName,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]
          : const [],

      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Select Sales Manager";
        }

        return null;
      },
    );
  }

  // ============================================================
  // IMAGE UPLOAD CARD
  // ============================================================

  Widget _buildImageUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required File? file,
    required bool uploaded,
    required bool uploading,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: uploaded
              ? const Color(0xFF7EE787).withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.16),
        ),
      ),

      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,

                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954).withValues(alpha: 0.12),

                  borderRadius: BorderRadius.circular(13),
                ),

                child: Icon(
                  uploaded ? Icons.check_circle_rounded : icon,
                  color: uploaded
                      ? const Color(0xFF7EE787)
                      : const Color(0xFF7EE787),
                  size: 23,
                ),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      uploaded ? "Uploaded successfully" : subtitle,
                      style: TextStyle(
                        color: uploaded
                            ? const Color(0xFF7EE787)
                            : Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (file != null) ...[
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.insert_drive_file_rounded,
                    color: Colors.white54,
                    size: 19,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      file.path.split(Platform.pathSeparator).last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ),

                  if (uploaded)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF7EE787),
                      size: 18,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            height: 48,

            child: ElevatedButton.icon(
              onPressed: uploading ? null : onPressed,

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.10),

                disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),

                foregroundColor: Colors.white,

                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: const Color(0xFF7EE787).withValues(alpha: 0.25),
                  ),
                ),
              ),

              icon: uploading
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.3,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      uploaded
                          ? Icons.refresh_rounded
                          : Icons.upload_file_rounded,
                    ),

              label: Text(
                uploading
                    ? "Uploading..."
                    : uploaded
                    ? "CHANGE IMAGE"
                    : "UPLOAD IMAGE",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
        Container(
          width: 36,
          height: 36,

          decoration: BoxDecoration(
            color: const Color(0xFF1DB954).withValues(alpha: 0.12),

            borderRadius: BorderRadius.circular(11),

            border: Border.all(
              color: const Color(0xFF7EE787).withValues(alpha: 0.15),
            ),
          ),

          child: Icon(icon, color: const Color(0xFF7EE787), size: 19),
        ),

        const SizedBox(width: 10),

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
  // GLASS CARD
  // ============================================================

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: child,
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,

    required String label,

    required IconData icon,

    TextInputType? keyboardType,

    bool readOnly = false,

    int minLines = 1,

    int maxLines = 1,

    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,

      keyboardType: keyboardType,

      readOnly: readOnly,

      minLines: minLines,

      maxLines: maxLines,

      validator: validator,

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

        errorStyle: const TextStyle(color: Color(0xFFFF8A80), fontSize: 11),
      ),
    );
  }

  // ============================================================
  // DROPDOWN DECORATION
  // ============================================================

  InputDecoration _dropdownDecoration({
    required String label,
    required IconData icon,
    required bool enabled,
  }) {
    return InputDecoration(
      labelText: label,

      labelStyle: TextStyle(
        color: Colors.white.withValues(alpha: enabled ? 0.62 : 0.35),
      ),

      floatingLabelStyle: const TextStyle(
        color: Color(0xFF7EE787),
        fontWeight: FontWeight.w600,
      ),

      prefixIcon: Icon(
        icon,
        color: enabled ? const Color(0xFF7EE787) : Colors.white38,
      ),

      filled: true,

      fillColor: enabled
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.04),

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
      ),

      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
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

      errorStyle: const TextStyle(color: Color(0xFFFF8A80), fontSize: 11),
    );
  }

  // ============================================================
  // CREATE BUTTON
  // ============================================================

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,

      child: ElevatedButton.icon(
        onPressed: saving ? null : savePaymentVerification,

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1DB954),

          disabledBackgroundColor: const Color(
            0xFF1DB954,
          ).withValues(alpha: 0.45),

          foregroundColor: Colors.white,

          elevation: 8,

          shadowColor: const Color(0xFF1DB954).withValues(alpha: 0.30),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),

            side: BorderSide(
              color: const Color(0xFF7EE787).withValues(alpha: 0.30),
            ),
          ),
        ),

        icon: saving
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle_outline_rounded, size: 23),

        label: Text(
          saving ? "Saving..." : "CREATE PAYMENT VERIFICATION",

          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
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

            Positioned(
              top: -100 + (value * 35),
              left: -110,

              child: _buildGlow(size: 280, color: const Color(0xFF1DB954)),
            ),

            Positioned(
              top: 120 - (value * 30),
              right: -110,

              child: _buildGlow(size: 300, color: const Color(0xFFFFD166)),
            ),

            Positioned(
              top: 400 + (value * 25),
              left: 50,

              child: _buildGlow(size: 240, color: const Color(0xFF7EE787)),
            ),

            Positioned(
              top: 170 + (value * 30),
              right: 8,

              child: Transform.rotate(
                angle: -0.25 + (value * 0.15),

                child: const Icon(
                  Icons.account_balance_rounded,
                  size: 55,
                  color: Color(0x447EE787),
                ),
              ),
            ),

            Positioned(
              bottom: 130 - (value * 20),
              left: 8,

              child: Transform.rotate(
                angle: 0.30 - (value * 0.12),

                child: const Icon(
                  Icons.payments_rounded,
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
