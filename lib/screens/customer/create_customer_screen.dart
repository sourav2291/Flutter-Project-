// screens/customer/create_customer_screen.dart

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../repositories/customer_repository.dart';
import 'create_address_screen.dart';

class CreateCustomerScreen extends StatefulWidget {
  const CreateCustomerScreen({super.key});

  @override
  State<CreateCustomerScreen> createState() => _CreateCustomerScreenState();
}

class _CreateCustomerScreenState extends State<CreateCustomerScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // FORM
  // ============================================================

  final _formKey = GlobalKey<FormState>();

  final CustomerRepository repository = CustomerRepository();

  // ============================================================
  // CUSTOMER CONTROLLERS
  // ============================================================

  final customerName = TextEditingController();
  final mobileNo = TextEditingController();
  final whatsappNo = TextEditingController();

  // ============================================================
  // GPS
  // ============================================================

  final customerLocation = TextEditingController();

  double? latitude;
  double? longitude;

  String currentAddress = "";

  // ============================================================
  // STATE
  // ============================================================

  bool saving = false;

  // ============================================================
  // CUSTOMER TYPE
  // ============================================================

  String customerType = "Individual";

  final List<String> customerTypes = ["Individual", "Company"];

  // ============================================================
  // CUSTOMER GROUP
  // ============================================================

  List<String> customerGroups = [];

  String? selectedCustomerGroup;

  bool loadingCustomerGroups = true;

  // ============================================================
  // TERRITORY
  // ============================================================

  List<String> territories = [];

  String? selectedTerritory;

  bool loadingTerritories = true;

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

    loadMasters();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  // ============================================================
  // LOAD CUSTOMER GROUPS + TERRITORIES
  // ============================================================

  Future<void> loadMasters() async {
    // ----------------------------------------------------------
    // CUSTOMER GROUPS
    // ----------------------------------------------------------

    try {
      final data = await repository.getCustomerGroups();

      if (!mounted) return;

      setState(() {
        customerGroups = data;

        if (customerGroups.isNotEmpty) {
          selectedCustomerGroup = customerGroups.first;
        }

        loadingCustomerGroups = false;
      });
    } catch (e) {
      debugPrint("GET CUSTOMER GROUPS ERROR: $e");

      if (!mounted) return;

      setState(() {
        loadingCustomerGroups = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unable to load Customer Groups\n$e")),
      );
    }

    // ----------------------------------------------------------
    // TERRITORIES
    // ----------------------------------------------------------

    try {
      final data = await repository.getTerritories();

      if (!mounted) return;

      setState(() {
        territories = data;

        if (territories.isNotEmpty) {
          selectedTerritory = territories.first;
        }

        loadingTerritories = false;
      });
    } catch (e) {
      debugPrint("GET TERRITORIES ERROR: $e");

      if (!mounted) return;

      setState(() {
        loadingTerritories = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Unable to load Territories\n$e")));
    }
  }

  // ============================================================
  // GET CURRENT LOCATION
  // ============================================================

  Future<void> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enable Location Service")),
      );

      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );

      return;
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Location permission permanently denied. "
            "Please enable it from App Settings.",
          ),
        ),
      );

      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );

      latitude = position.latitude;
      longitude = position.longitude;

      // Reverse geocoding is ONLY for display.
      // It does not modify any customer fields.

      try {
        final placemarks = await placemarkFromCoordinates(
          latitude!,
          longitude!,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;

          currentAddress =
              [place.locality, place.administrativeArea, place.country]
                  .whereType<String>()
                  .map((value) => value.trim())
                  .where((value) => value.isNotEmpty)
                  .join(", ");
        }
      } catch (e) {
        debugPrint("REVERSE GEOCODING ERROR: $e");

        currentAddress = "";
      }

      customerLocation.text = "$latitude,$longitude";

      if (!mounted) return;

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unable to get current location\n$e")),
      );
    }
  }

  // ============================================================
  // SAVE CUSTOMER
  // ============================================================

  Future<void> saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCustomerGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Customer Group.")),
      );

      return;
    }

    if (selectedTerritory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select Territory.")));

      return;
    }

    setState(() {
      saving = true;
    });

    try {
      // ========================================================
      // STEP 1
      // CREATE CUSTOMER ONLY
      // ========================================================

      final customerId = await repository.createCustomer(
        customerName: customerName.text.trim(),

        customerType: customerType,

        customerGroup: selectedCustomerGroup!,

        territory: selectedTerritory!,

        mobileNo: mobileNo.text.trim(),

        whatsappNumber: whatsappNo.text.trim(),

        customerLocation: customerLocation.text.trim(),
      );

      debugPrint("CUSTOMER CREATED: $customerId");

      if (!mounted) return;

      setState(() {
        saving = false;
      });

      // ========================================================
      // STEP 2
      // OPEN ADDRESS SCREEN
      // ========================================================

      final addressCreated = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => CreateAddressScreen(
            customerId: customerId,
            customerName: customerName.text.trim(),
          ),
        ),
      );

      if (!mounted) return;

      // ========================================================
      // STEP 3
      // RESULT
      // ========================================================

      if (addressCreated == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Customer and Address created successfully."),
            backgroundColor: Color(0xFF1DB954),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Customer created successfully. "
              "Address was not added.",
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("CREATE CUSTOMER ERROR: $e");

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
    customerName.dispose();
    mobileNo.dispose();
    whatsappNo.dispose();
    customerLocation.dispose();

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
          "Create Customer",
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
                              Icons.person_add_alt_1_rounded,
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
                                  "New Customer",

                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),

                                SizedBox(height: 4),

                                Text(
                                  "Create a new customer profile",

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
                    // CUSTOMER NAME
                    // ==================================================
                    _buildTextField(
                      controller: customerName,

                      label: "Customer Name *",

                      icon: Icons.person_rounded,

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Enter Customer Name";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 13),

                    // ==================================================
                    // CUSTOMER TYPE
                    // ==================================================
                    _buildDropdown(
                      label: "Customer Type",

                      icon: Icons.business_rounded,

                      value: customerType,

                      items: customerTypes,

                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          customerType = value;
                        });
                      },
                    ),

                    const SizedBox(height: 13),

                    // ==================================================
                    // CUSTOMER GROUP
                    // ==================================================
                    _buildDropdown(
                      label: loadingCustomerGroups
                          ? "Loading Customer Groups..."
                          : "Customer Group *",

                      icon: Icons.group_rounded,

                      value: selectedCustomerGroup,

                      items: customerGroups,

                      onChanged: loadingCustomerGroups
                          ? null
                          : (value) {
                              setState(() {
                                selectedCustomerGroup = value;
                              });
                            },

                      validator: (value) {
                        if (value == null) {
                          return "Select Customer Group";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 13),

                    // ==================================================
                    // TERRITORY
                    // ==================================================
                    _buildDropdown(
                      label: loadingTerritories
                          ? "Loading Territories..."
                          : "Territory *",

                      icon: Icons.location_city_rounded,

                      value: selectedTerritory,

                      items: territories,

                      onChanged: loadingTerritories
                          ? null
                          : (value) {
                              setState(() {
                                selectedTerritory = value;
                              });
                            },

                      validator: (value) {
                        if (value == null) {
                          return "Select Territory";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 13),

                    // ==================================================
                    // MOBILE
                    // ==================================================
                    _buildTextField(
                      controller: mobileNo,

                      label: "Mobile Number",

                      icon: Icons.phone_rounded,

                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 13),

                    // ==================================================
                    // WHATSAPP
                    // ==================================================
                    _buildTextField(
                      controller: whatsappNo,

                      label: "WhatsApp Number",

                      icon: Icons.chat_rounded,

                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // LOCATION
                    // ==================================================
                    _buildSectionTitle("Location", Icons.location_on_rounded),

                    const SizedBox(height: 12),

                    _buildLocationButton(),

                    const SizedBox(height: 13),

                    _buildTextField(
                      controller: customerLocation,

                      label: "Customer Location",

                      icon: Icons.location_on_rounded,

                      readOnly: true,
                    ),

                    if (latitude != null) _buildGpsCard(),

                    const SizedBox(height: 25),

                    // ==================================================
                    // CREATE
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
  // DROPDOWN
  // ============================================================

  Widget _buildDropdown({
    required String label,

    required IconData icon,

    required String? value,

    required List<String> items,

    required ValueChanged<String?>? onChanged,

    String? Function(String?)? validator,
  }) {
    final enabled = onChanged != null && items.isNotEmpty;

    final safeValue = value != null && items.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      initialValue: safeValue,

      onChanged: enabled ? onChanged : null,

      dropdownColor: const Color(0xFF103D39),

      style: const TextStyle(color: Colors.white, fontSize: 15),

      decoration: InputDecoration(
        labelText: label,

        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.62)),

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
      ),

      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,

        color: Colors.white70,
      ),

      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,

          child: Text(
            item,

            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        );
      }).toList(),

      validator: validator,
    );
  }

  // ============================================================
  // LOCATION BUTTON
  // ============================================================

  Widget _buildLocationButton() {
    return SizedBox(
      width: double.infinity,

      height: 54,

      child: ElevatedButton.icon(
        onPressed: getCurrentLocation,

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.10),

          foregroundColor: Colors.white,

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),

            side: BorderSide(
              color: const Color(0xFF7EE787).withValues(alpha: 0.25),
            ),
          ),
        ),

        icon: const Icon(Icons.my_location_rounded, color: Color(0xFF7EE787)),

        label: const Text(
          "Get Current Location",

          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // ============================================================
  // GPS CARD
  // ============================================================

  Widget _buildGpsCard() {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(top: 13),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF1DB954).withValues(alpha: 0.09),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: const Color(0xFF7EE787).withValues(alpha: 0.20),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 38,

                height: 38,

                decoration: BoxDecoration(
                  color: const Color(0xFF7EE787).withValues(alpha: 0.12),

                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.gps_fixed_rounded,

                  color: Color(0xFF7EE787),

                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                "GPS Location",

                style: TextStyle(
                  color: Colors.white,

                  fontSize: 15,

                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _buildGpsRow("Latitude", latitude!.toStringAsFixed(6)),

          const SizedBox(height: 8),

          _buildGpsRow("Longitude", longitude!.toStringAsFixed(6)),

          if (currentAddress.isNotEmpty) ...[
            const SizedBox(height: 10),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(11),

              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Text(
                currentAddress,

                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.70),

                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // GPS ROW
  // ============================================================

  Widget _buildGpsRow(String title, String value) {
    return Row(
      children: [
        Text(
          "$title :",

          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.50),

            fontSize: 12,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            value,

            style: const TextStyle(
              color: Colors.white,

              fontSize: 13,

              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
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
        onPressed: saving ? null : saveCustomer,

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
          saving ? "Saving..." : "CREATE CUSTOMER",

          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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

                child: Icon(
                  Icons.eco_rounded,

                  size: 55,

                  color: const Color(0x447EE787),
                ),
              ),
            ),

            Positioned(
              bottom: 130 - (value * 20),

              left: 8,

              child: Transform.rotate(
                angle: 0.30 - (value * 0.12),

                child: Icon(
                  Icons.eco_rounded,

                  size: 38,

                  color: const Color(0x44FFD166),
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
