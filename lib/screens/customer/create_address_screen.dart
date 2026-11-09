// screens/customer/create_address_screen.dart

import 'package:flutter/material.dart';

import '../../repositories/customer_repository.dart';

class CreateAddressScreen extends StatefulWidget {
  final String customerId;
  final String customerName;

  const CreateAddressScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<CreateAddressScreen> createState() => _CreateAddressScreenState();
}

class _CreateAddressScreenState extends State<CreateAddressScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final CustomerRepository repository = CustomerRepository();

  final TextEditingController addressTitle = TextEditingController();
  final TextEditingController addressLine1 = TextEditingController();
  final TextEditingController addressLine2 = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController country = TextEditingController(text: "India");
  final TextEditingController pincode = TextEditingController();
  final TextEditingController phone = TextEditingController();

  // Display value -> actual ERPNext State value.
  final Map<String, String> stateOptions = {};

  String? selectedState;
  bool loadingStates = true;
  String? stateError;

  String selectedAddressType = "Billing";

  bool isPrimaryAddress = false;
  bool isShippingAddress = false;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadStates();
  }

  Future<void> loadStates() async {
    try {
      final states = await repository.getStates();

      final Map<String, String> options = {};

      for (final state in states) {
        final actualState = state.trim();
        final normalized = actualState.toLowerCase();

        if (normalized == "kerala") {
          options["KERALA"] = actualState;
        } else if (normalized == "tamil nadu") {
          options["TAMIL"] = actualState;
        } else if (normalized == "karnataka") {
          options["KARANATAKA"] = actualState;
        }
      }

      if (!mounted) return;

      setState(() {
        stateOptions
          ..clear()
          ..addAll(options);

        if (stateOptions.containsKey("KERALA")) {
          selectedState = "KERALA";
        } else if (stateOptions.isNotEmpty) {
          selectedState = stateOptions.keys.first;
        } else {
          selectedState = null;
        }

        loadingStates = false;

        if (stateOptions.isEmpty) {
          stateError = "Required States were not found in ERPNext.";
        } else if (selectedState == null) {
          stateError = "Required State is not available in ERPNext State list.";
        } else {
          stateError = null;
        }
      });
    } catch (e) {
      debugPrint("GET STATES ERROR: $e");

      if (!mounted) return;

      setState(() {
        loadingStates = false;
        stateError = "Unable to load States.";
      });
    }
  }

  Future<void> saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedState == null || selectedState!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select State."),
          backgroundColor: Color(0xFF8B2E2E),
        ),
      );

      return;
    }

    // Convert display value to the actual ERPNext State value.
    final String erpNextState = stateOptions[selectedState!] ?? "";

    if (erpNextState.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a valid State from available options."),
          backgroundColor: Color(0xFF8B2E2E),
        ),
      );

      return;
    }

    setState(() {
      saving = true;
    });

    try {
      debugPrint("====================================");
      debugPrint("CREATE CUSTOMER ADDRESS");
      debugPrint("====================================");
      debugPrint("Customer ID   : ${widget.customerId}");
      debugPrint("Customer Name : ${widget.customerName}");
      debugPrint("Address Line1 : ${addressLine1.text.trim()}");
      debugPrint("Address Line2 : ${addressLine2.text.trim()}");
      debugPrint("City          : ${city.text.trim()}");
      debugPrint("State         : $erpNextState");
      debugPrint("Country       : ${country.text.trim()}");
      debugPrint("Pincode       : ${pincode.text.trim()}");
      debugPrint("====================================");

      final String addressId = await repository.createAddress(
        // Customer ID returned after Customer creation.
        customerName: widget.customerId,

        addressLine1: addressLine1.text.trim(),

        addressLine2: addressLine2.text.trim(),

        city: city.text.trim(),

        // Actual ERPNext State value.
        state: erpNextState,

        country: country.text.trim().isEmpty ? "India" : country.text.trim(),

        pincode: pincode.text.trim(),
      );

      debugPrint("====================================");
      debugPrint("CUSTOMER ADDRESS CREATED SUCCESSFULLY");
      debugPrint("Address ID : $addressId");
      debugPrint("Customer ID: ${widget.customerId}");
      debugPrint("====================================");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Address created successfully."),
          backgroundColor: Color(0xFF1DB954),
        ),
      );

      // Return true to CreateCustomerScreen.
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("====================================");
      debugPrint("CREATE CUSTOMER ADDRESS ERROR");
      debugPrint(e.toString());
      debugPrint("====================================");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFF8B2E2E),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    addressTitle.dispose();
    addressLine1.dispose();
    addressLine2.dispose();
    city.dispose();
    country.dispose();
    pincode.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041A1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00232C),
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 28),
          onPressed: saving ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Address",
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLeadAddressCard(),

                    const SizedBox(height: 22),

                    _buildTextField(
                      controller: addressTitle,
                      label: "Address Title *",
                      icon: Icons.title_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Enter Address Title";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 13),

                    _buildAddressTypeDropdown(),

                    const SizedBox(height: 13),

                    _buildTextField(
                      controller: addressLine1,
                      label: "Address Line 1 *",
                      icon: Icons.home_rounded,
                      keyboardType: TextInputType.streetAddress,
                      minLines: 2,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Enter Address Line 1";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 13),

                    _buildTextField(
                      controller: addressLine2,
                      label: "Address Line 2",
                      icon: Icons.home_outlined,
                      keyboardType: TextInputType.streetAddress,
                      minLines: 1,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 13),

                    _buildTextField(
                      controller: city,
                      label: "City *",
                      icon: Icons.location_city_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Enter City";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 13),

                    _buildStateDropdown(),

                    const SizedBox(height: 13),

                    _buildTextField(
                      controller: country,
                      label: "Country *",
                      icon: Icons.public_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Enter Country";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 13),

                    _buildTextField(
                      controller: pincode,
                      label: "Pincode",
                      icon: Icons.markunread_mailbox_rounded,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 13),

                    _buildTextField(
                      controller: phone,
                      label: "Phone",
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 18),

                    _buildCheckbox(
                      title: "Primary Address",
                      value: isPrimaryAddress,
                      onChanged: (value) {
                        setState(() {
                          isPrimaryAddress = value ?? false;
                        });
                      },
                    ),

                    const SizedBox(height: 5),

                    _buildCheckbox(
                      title: "Shipping Address",
                      value: isShippingAddress,
                      onChanged: (value) {
                        setState(() {
                          isShippingAddress = value ?? false;
                        });
                      },
                    ),

                    const SizedBox(height: 25),

                    _buildSaveButton(),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: saving ? null : () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "Madathil Solar ERP",
                      textAlign: TextAlign.center,
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

  Widget _buildLeadAddressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1DB954), Color(0xFF0B5E4D)],
              ),
              border: Border.all(
                color: const Color(0xFF7EE787).withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1DB954).withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on_rounded,
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
                  "Lead Address",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Enter lead address details",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 13,
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

  Widget _buildAddressTypeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedAddressType,
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          selectedAddressType = value;
        });
      },
      dropdownColor: const Color(0xFF103D39),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: _dropdownDecoration(
        label: "Address Type *",
        icon: Icons.category_rounded,
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.white70,
      ),
      items: const [
        DropdownMenuItem(value: "Billing", child: Text("Billing")),
        DropdownMenuItem(value: "Shipping", child: Text("Shipping")),
        DropdownMenuItem(value: "Office", child: Text("Office")),
        DropdownMenuItem(value: "Personal", child: Text("Personal")),
        DropdownMenuItem(value: "Plant", child: Text("Plant")),
        DropdownMenuItem(value: "Other", child: Text("Other")),
      ],
    );
  }

  Widget _buildStateDropdown() {
    final displayStates = stateOptions.keys.toList();

    if (loadingStates) {
      return InputDecorator(
        decoration: _dropdownDecoration(
          label: "State *",
          icon: Icons.map_rounded,
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(
              "Loading States...",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: displayStates.contains(selectedState)
          ? selectedState
          : null,
      onChanged: saving
          ? null
          : (value) {
              if (value == null) return;

              setState(() {
                selectedState = value;
              });
            },
      dropdownColor: const Color(0xFF103D39),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: _dropdownDecoration(
        label: "State *",
        icon: Icons.map_rounded,
        helperText: stateError,
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.white70,
      ),
      items: displayStates.map((displayName) {
        return DropdownMenuItem<String>(
          value: displayName,
          child: Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Select State";
        }

        return null;
      },
    );
  }

  InputDecoration _dropdownDecoration({
    required String label,
    required IconData icon,
    String? helperText,
  }) {
    return InputDecoration(
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      helperText: helperText,
      helperStyle: const TextStyle(color: Color(0xFFFF8A80), fontSize: 11),
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
    );
  }

  Widget _buildCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF1DB954),
        checkColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int minLines = 1,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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

  Widget _buildSaveButton() {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: saving || loadingStates ? null : saveAddress,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1DB954),
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.12),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          elevation: 0,
        ),
        child: saving
            ? const SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                "SAVE ADDRESS",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF041A1F), Color(0xFF08262B), Color(0xFF041A1F)],
        ),
      ),
    );
  }
}
