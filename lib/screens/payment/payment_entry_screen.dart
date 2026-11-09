// screens/payment/payment_entry_screen.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/sales_order.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';

class PaymentEntryScreen extends StatefulWidget {
  final SalesOrder salesOrder;

  const PaymentEntryScreen({super.key, required this.salesOrder});

  @override
  State<PaymentEntryScreen> createState() => _PaymentEntryScreenState();
}

class _PaymentEntryScreenState extends State<PaymentEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _amountController = TextEditingController();

  final TextEditingController _dateController = TextEditingController();

  // NEW - ERPNext standard fields
  final TextEditingController _referenceNoController = TextEditingController();

  final TextEditingController _referenceDateController =
      TextEditingController();

  // ============================================================
  // MODE OF PAYMENT
  // ============================================================

  List<String> _modeOfPayments = [];

  String? _selectedModeOfPayment;

  // ============================================================
  // ATTACHMENT
  // ============================================================

  String? _selectedFilePath;
  String? _selectedFileName;

  // ============================================================
  // STATE
  // ============================================================

  bool _loadingModes = true;
  bool _submitting = false;

  // ============================================================
  // SALES ORDER
  // ============================================================

  SalesOrder get salesOrder => widget.salesOrder;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Posting Date
    _dateController.text = DateFormat("yyyy-MM-dd").format(DateTime.now());

    // Reference Date
    _referenceDateController.text = DateFormat(
      "yyyy-MM-dd",
    ).format(DateTime.now());

    _loadModeOfPayments();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _referenceNoController.dispose();
    _referenceDateController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD MODE OF PAYMENT
  // ============================================================

  Future<void> _loadModeOfPayments() async {
    try {
      final cookie = await SessionService().getCookie();

      if (cookie == null || cookie.isEmpty) {
        if (mounted) {
          setState(() {
            _loadingModes = false;
          });
        }

        return;
      }

      final result = await ApiService.getModeOfPayments(cookie: cookie);

      if (!mounted) return;

      if (result["success"] == true) {
        final List data = result["data"] ?? [];

        setState(() {
          _modeOfPayments = data
              .map((item) => item["name"].toString())
              .toList();

          _loadingModes = false;
        });
      } else {
        setState(() {
          _loadingModes = false;
        });

        _showMessage(
          result["message"]?.toString() ?? "Unable to load Mode of Payment",
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingModes = false;
      });

      _showMessage(e.toString());
    }
  }

  // ============================================================
  // PICK ATTACHMENT
  // ============================================================

  Future<void> _pickAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: false);

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;

      if (file.path == null) {
        _showMessage("Unable to access selected file.");
        return;
      }

      setState(() {
        _selectedFilePath = file.path;
        _selectedFileName = file.name;
      });
    } catch (e) {
      _showMessage("Unable to select file: $e");
    }
  }

  // ============================================================
  // PICK REFERENCE DATE
  // ============================================================

  Future<void> _pickReferenceDate() async {
    final currentDate =
        DateTime.tryParse(_referenceDateController.text) ?? DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _referenceDateController.text = DateFormat(
          "yyyy-MM-dd",
        ).format(pickedDate);
      });
    }
  }

  // ============================================================
  // CREATE PAYMENT ENTRY
  // ============================================================

  Future<void> _createPaymentEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedModeOfPayment == null || _selectedModeOfPayment!.isEmpty) {
      _showMessage("Please select Mode of Payment.");
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      _showMessage("Please enter a valid Paid Amount.");
      return;
    }

    final referenceNo = _referenceNoController.text.trim();

    final referenceDate = _referenceDateController.text.trim();

    if (referenceNo.isEmpty) {
      _showMessage("Please enter Reference No.");
      return;
    }

    if (referenceDate.isEmpty) {
      _showMessage("Please select Reference Date.");
      return;
    }

    final cookie = await SessionService().getCookie();

    if (cookie == null || cookie.isEmpty) {
      _showMessage("Session expired. Please login again.");
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      String? attachmentUrl;

      // --------------------------------------------------------
      // Upload attachment first if selected
      // --------------------------------------------------------

      if (_selectedFilePath != null) {
        final uploadResult = await ApiService.uploadPaymentAttachment(
          cookie: cookie,
          filePath: _selectedFilePath!,
        );

        if (uploadResult["success"] != true) {
          throw Exception(
            uploadResult["message"] ?? "Attachment upload failed.",
          );
        }

        attachmentUrl = uploadResult["file_url"]?.toString();
      }

      // --------------------------------------------------------
      // Create Payment Entry
      // --------------------------------------------------------

      final result = await ApiService.createPaymentEntry(
        cookie: cookie,
        salesOrder: salesOrder.name,
        customer: salesOrder.customer,
        company: salesOrder.company,
        salesUser: salesOrder.salesUser,
        modeOfPayment: _selectedModeOfPayment!,
        paidAmount: amount,

        // NEW
        referenceNo: referenceNo,
        referenceDate: referenceDate,

        attachmentUrl: attachmentUrl,
      );

      if (!mounted) return;

      if (result["success"] == true) {
        await _showSuccessDialog(result["data"]?["name"]?.toString());
      } else {
        _showMessage(
          result["message"]?.toString() ?? "Payment Entry creation failed.",
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  Future<void> _showSuccessDialog(String? paymentEntryName) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Payment Entry Created"),
          content: Text(
            paymentEntryName != null && paymentEntryName.isNotEmpty
                ? "Payment Entry $paymentEntryName "
                      "created successfully."
                : "Payment Entry created successfully.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // READ ONLY FIELD
  // ============================================================

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
          filled: true,
          fillColor: const Color(0xFF17221B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final amount = _amountController.text.trim();

    return Scaffold(
      backgroundColor: const Color(0xFF0B120E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B120E),
        foregroundColor: Colors.white,
        title: const Text(
          "Payment Entry",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // SALES ORDER INFORMATION
                // ==================================================
                const Text(
                  "Sales Order Information",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 16),

                _buildReadOnlyField("Sales Order", salesOrder.name),

                _buildReadOnlyField("Customer", salesOrder.customer),

                _buildReadOnlyField("Company", salesOrder.company),

                _buildReadOnlyField("Sales User", salesOrder.salesUser),

                // ==================================================
                // PAYMENT INFORMATION
                // ==================================================
                const SizedBox(height: 8),

                const Text(
                  "Payment Information",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 16),

                _buildReadOnlyField("Payment Type", "Receive"),

                _buildReadOnlyField("Posting Date", _dateController.text),

                _buildReadOnlyField("Status", "Pending"),

                // ==================================================
                // MODE OF PAYMENT
                // ==================================================
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedModeOfPayment,
                    dropdownColor: const Color(0xFF17221B),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Mode of Payment",
                      labelStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF17221B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _modeOfPayments.map((mode) {
                      return DropdownMenuItem<String>(
                        value: mode,
                        child: Text(mode),
                      );
                    }).toList(),
                    onChanged: _loadingModes
                        ? null
                        : (value) {
                            setState(() {
                              _selectedModeOfPayment = value;
                            });
                          },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please select Mode of Payment";
                      }

                      return null;
                    },
                    hint: _loadingModes
                        ? const Text(
                            "Loading...",
                            style: TextStyle(color: Colors.white54),
                          )
                        : const Text(
                            "Select Mode of Payment",
                            style: TextStyle(color: Colors.white54),
                          ),
                  ),
                ),

                // ==================================================
                // PAID AMOUNT
                // ==================================================
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (_) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: "Paid Amount",
                    labelStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                    prefixText: "₹ ",
                    prefixStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: const Color(0xFF17221B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Paid Amount is required";
                    }

                    final amount = double.tryParse(value.trim());

                    if (amount == null || amount <= 0) {
                      return "Enter a valid amount";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ==================================================
                // REFERENCE NO
                // ==================================================
                TextFormField(
                  controller: _referenceNoController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Reference No",
                    hintText: "Enter bank transaction / UTR number",
                    labelStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF17221B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Reference No is required";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ==================================================
                // REFERENCE DATE
                // ==================================================
                TextFormField(
                  controller: _referenceDateController,
                  readOnly: true,
                  style: const TextStyle(color: Colors.white),
                  onTap: _pickReferenceDate,
                  decoration: InputDecoration(
                    labelText: "Reference Date",
                    labelStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                    suffixIcon: const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white70,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF17221B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Reference Date is required";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ==================================================
                // ALLOCATED AMOUNT
                // ==================================================
                _buildReadOnlyField(
                  "Allocated Amount",
                  amount.isEmpty ? "0.00" : amount,
                ),

                // ==================================================
                // ATTACHMENT
                // ==================================================
                const SizedBox(height: 4),

                const Text(
                  "Attachment (Optional)",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _submitting ? null : _pickAttachment,
                    icon: const Icon(Icons.attach_file_rounded),
                    label: Text(_selectedFileName ?? "Choose Attachment"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7EE787),
                      side: BorderSide(
                        color: const Color(0xFF7EE787).withValues(alpha: 0.35),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // CREATE BUTTON
                // ==================================================
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : _createPaymentEntry,
                    icon: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.payment_rounded),
                    label: Text(
                      _submitting
                          ? "Creating Payment..."
                          : "Create Payment Entry",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF238636),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
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
    );
  }
}
