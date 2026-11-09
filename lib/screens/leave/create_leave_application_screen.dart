// screens/leave/create_leave_application_screen.dart

import 'package:flutter/material.dart';

import '../../repositories/leave_application_repository.dart';

class CreateLeaveApplicationScreen extends StatefulWidget {
  const CreateLeaveApplicationScreen({super.key});

  @override
  State<CreateLeaveApplicationScreen> createState() =>
      _CreateLeaveApplicationScreenState();
}

class _CreateLeaveApplicationScreenState
    extends State<CreateLeaveApplicationScreen> {
  final LeaveApplicationRepository repository = LeaveApplicationRepository();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController employeeController = TextEditingController();

  final TextEditingController employeeNameController = TextEditingController();

  final TextEditingController fromDateController = TextEditingController();

  final TextEditingController toDateController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  // ============================================================
  // LEAVE DATA
  // ============================================================

  String? selectedLeaveType;

  List<String> leaveTypes = [];

  // ============================================================
  // EMPLOYEE DATA
  // ============================================================

  bool isHr = false;

  List<Map<String, dynamic>> employees = [];

  String? selectedEmployeeId;

  // ============================================================
  // LOADING / SAVING
  // ============================================================

  bool loading = true;

  bool saving = false;

  bool loadingLeaveTypes = false;

  // ============================================================
  // DATES
  // ============================================================

  DateTime? fromDate;

  DateTime? toDate;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    loadInitialData();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    employeeController.dispose();
    employeeNameController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD INITIAL DATA
  // ============================================================

  Future<void> loadInitialData() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      // ----------------------------------------------------------
      // GET ACCESS + LEAVE TYPES
      // ----------------------------------------------------------

      final results = await Future.wait([
        repository.getLeaveApplicationAccess(),
        repository.getLeaveTypes(),
      ]);

      final access = results[0] as Map<String, dynamic>;

      final types = results[1] as List<String>;

      // ----------------------------------------------------------
      // CHECK HR
      // ----------------------------------------------------------

      final bool hr = access["is_hr"] == true;

      // ----------------------------------------------------------
      // GET EMPLOYEES
      // ----------------------------------------------------------

      final List<Map<String, dynamic>> loadedEmployees = [];

      final employeeData = access["employees"];

      if (employeeData is List) {
        for (final item in employeeData) {
          if (item is! Map) {
            continue;
          }

          final employee = Map<String, dynamic>.from(item);

          final employeeId = employee["name"]?.toString().trim() ?? "";

          if (employeeId.isEmpty) {
            continue;
          }

          loadedEmployees.add({
            "name": employeeId,
            "employee_name": employee["employee_name"]?.toString() ?? "",
            "user_id": employee["user_id"]?.toString() ?? "",
            "company": employee["company"]?.toString() ?? "",
          });
        }
      }

      // ----------------------------------------------------------
      // NORMAL EMPLOYEE
      // ----------------------------------------------------------

      Map<String, dynamic>? normalEmployee;

      if (!hr) {
        final employee = access["employee"];

        if (employee is Map) {
          normalEmployee = Map<String, dynamic>.from(employee);
        }

        // Fallback
        if (normalEmployee == null && loadedEmployees.isNotEmpty) {
          normalEmployee = loadedEmployees.first;
        }

        if (normalEmployee == null) {
          throw Exception(
            "No Employee record is linked to the logged-in user.",
          );
        }
      }

      // ----------------------------------------------------------
      // INITIAL EMPLOYEE
      // ----------------------------------------------------------

      String? initialEmployeeId;

      if (hr) {
        final loggedInUser = access["logged_in_user"]?.toString().trim() ?? "";

        // If HR itself is linked to Employee,
        // automatically select that employee.
        for (final employee in loadedEmployees) {
          final userId = employee["user_id"]?.toString().trim() ?? "";

          if (userId == loggedInUser) {
            initialEmployeeId = employee["name"]?.toString();

            break;
          }
        }
      } else {
        initialEmployeeId = normalEmployee?["name"]?.toString();
      }

      // ----------------------------------------------------------
      // UPDATE UI
      // ----------------------------------------------------------

      if (!mounted) return;

      setState(() {
        isHr = hr;

        employees = loadedEmployees;

        leaveTypes = types;

        selectedEmployeeId = initialEmployeeId;

        // --------------------------------------------------------
        // NORMAL EMPLOYEE
        // --------------------------------------------------------

        if (!hr && normalEmployee != null) {
          employeeController.text = normalEmployee["name"]?.toString() ?? "";

          employeeNameController.text =
              normalEmployee["employee_name"]?.toString() ?? "";
        }

        // --------------------------------------------------------
        // HR WITH AUTOMATIC EMPLOYEE
        // --------------------------------------------------------

        if (hr && initialEmployeeId != null) {
          final selected = loadedEmployees.firstWhere(
            (employee) => employee["name"]?.toString() == initialEmployeeId,
            orElse: () => <String, dynamic>{},
          );

          employeeController.text = selected["name"]?.toString() ?? "";

          employeeNameController.text =
              selected["employee_name"]?.toString() ?? "";
        }

        // --------------------------------------------------------
        // HR WITHOUT EMPLOYEE LINK
        // --------------------------------------------------------

        if (hr && initialEmployeeId == null) {
          employeeController.clear();
          employeeNameController.clear();
        }

        loading = false;
      });

      // ----------------------------------------------------------
      // DEBUG
      // ----------------------------------------------------------

      debugPrint("==========================================");

      debugPrint("LEAVE APPLICATION INITIAL DATA");

      debugPrint("Is HR         : $hr");

      debugPrint(
        "Logged User   : "
        "${access["logged_in_user"]}",
      );

      debugPrint(
        "Employees     : "
        "${loadedEmployees.length}",
      );

      debugPrint(
        "Selected Emp  : "
        "$initialEmployeeId",
      );

      debugPrint("Leave Types   : $types");

      debugPrint("==========================================");
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showError(e.toString());
    }
  }

  // ============================================================
  // SELECT EMPLOYEE
  // ============================================================

  void selectEmployee(Map<String, dynamic> employee) {
    final employeeId = employee["name"]?.toString().trim() ?? "";

    final employeeName = employee["employee_name"]?.toString().trim() ?? "";

    if (employeeId.isEmpty) {
      return;
    }

    setState(() {
      selectedEmployeeId = employeeId;

      employeeController.text = employeeId;

      employeeNameController.text = employeeName;
    });

    debugPrint(
      "Selected Employee : "
      "$employeeId",
    );

    debugPrint(
      "Selected Employee Name : "
      "$employeeName",
    );
  }

  // ============================================================
  // OPEN EMPLOYEE SEARCH PAGE
  //
  // HR ONLY
  //
  // IMPORTANT:
  // We use Navigator.push instead of a Dialog.
  //
  // This avoids the Flutter '_dependents.isEmpty'
  // assertion that appeared when closing the search dialog.
  //
  // ============================================================

  Future<void> _openEmployeeSearch() async {
    if (!isHr) {
      return;
    }

    if (employees.isEmpty) {
      _showError("No employees available.");

      return;
    }

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => EmployeeSearchScreen(
          employees: employees,
          selectedEmployeeId: selectedEmployeeId,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result != null) {
      selectEmployee(result);
    }
  }

  // ============================================================
  // FROM DATE
  // ============================================================

  Future<void> selectFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF1DB954),
              surface: Color(0xFF103F39),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) {
      return;
    }

    setState(() {
      fromDate = picked;

      fromDateController.text = _formatDateForERP(picked);

      // --------------------------------------------------------
      // Clear To Date if invalid
      // --------------------------------------------------------

      if (toDate != null && toDate!.isBefore(picked)) {
        toDate = null;

        toDateController.clear();
      }
    });
  }

  // ============================================================
  // TO DATE
  // ============================================================

  Future<void> selectToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? fromDate ?? DateTime.now(),
      firstDate: fromDate ?? DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF1DB954),
              surface: Color(0xFF103F39),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) {
      return;
    }

    setState(() {
      toDate = picked;

      toDateController.text = _formatDateForERP(picked);
    });
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDateForERP(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  // ============================================================
  // SAVE LEAVE APPLICATION
  // ============================================================

  Future<void> saveLeaveApplication() async {
    // ----------------------------------------------------------
    // FORM VALIDATION
    // ----------------------------------------------------------

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ----------------------------------------------------------
    // EMPLOYEE
    // ----------------------------------------------------------

    final employee = employeeController.text.trim();

    if (employee.isEmpty) {
      _showError(
        isHr
            ? "Please select an Employee."
            : "Employee information is not available.",
      );

      return;
    }

    // ----------------------------------------------------------
    // HR VALIDATION
    // ----------------------------------------------------------

    if (isHr && selectedEmployeeId == null) {
      _showError("Please select an Employee.");

      return;
    }

    // ----------------------------------------------------------
    // LEAVE TYPE
    // ----------------------------------------------------------

    final leaveType = selectedLeaveType?.trim() ?? "";

    if (leaveType.isEmpty) {
      _showError("Please select a Leave Type.");

      return;
    }

    // ----------------------------------------------------------
    // DATES
    // ----------------------------------------------------------

    if (fromDate == null || toDate == null) {
      _showError("Please select From Date and To Date.");

      return;
    }

    if (toDate!.isBefore(fromDate!)) {
      _showError("To Date cannot be before From Date.");

      return;
    }

    // ----------------------------------------------------------
    // DESCRIPTION
    // ----------------------------------------------------------

    final description = descriptionController.text.trim();

    // ----------------------------------------------------------
    // START SAVING
    // ----------------------------------------------------------

    if (!mounted) {
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      // --------------------------------------------------------
      // CREATE ERPNext LEAVE APPLICATION
      // --------------------------------------------------------

      final createdName = await repository.createLeaveApplication(
        employee: employee,
        leaveType: leaveType,
        fromDate: _formatDateForERP(fromDate!),
        toDate: _formatDateForERP(toDate!),
        description: description,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        saving = false;
      });

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Leave Application "
            "$createdName "
            "created successfully.",
          ),
          backgroundColor: const Color(0xFF1DB954),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // --------------------------------------------------------
      // RETURN TO LIST
      // --------------------------------------------------------

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        saving = false;
      });

      _showError(e.toString());
    }
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF8B2635),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF062E2A),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: const Color(0xFF103F39),

        elevation: 0,

        iconTheme: const IconThemeData(color: Colors.white),

        title: const Text(
          "Apply Leave",
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1DB954)),
            )
          : SafeArea(
              child: Form(
                key: _formKey,

                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 18, 14, 35),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // ==================================================
                      // EMPLOYEE DETAILS
                      // ==================================================
                      _buildSectionTitle(
                        "Employee Details",
                        Icons.person_rounded,
                      ),

                      const SizedBox(height: 12),

                      // ==================================================
                      // HR -> SEARCH FIELD
                      // ==================================================
                      if (isHr)
                        _buildHrEmployeeField()
                      // ==================================================
                      // NORMAL USER
                      // ==================================================
                      else
                        _buildTextField(
                          controller: employeeNameController,
                          label: "Employee",
                          icon: Icons.badge_rounded,
                          readOnly: true,
                        ),

                      const SizedBox(height: 13),

                      // ==================================================
                      // LEAVE DETAILS
                      // ==================================================
                      _buildSectionTitle(
                        "Leave Details",
                        Icons.event_available_rounded,
                      ),

                      const SizedBox(height: 12),

                      _buildLeaveTypeDropdown(),

                      const SizedBox(height: 13),

                      // ==================================================
                      // FROM DATE
                      // ==================================================
                      _buildDateField(
                        controller: fromDateController,
                        label: "From Date *",
                        icon: Icons.calendar_month_rounded,
                        onTap: selectFromDate,
                      ),

                      const SizedBox(height: 13),

                      // ==================================================
                      // TO DATE
                      // ==================================================
                      _buildDateField(
                        controller: toDateController,
                        label: "To Date *",
                        icon: Icons.event_rounded,
                        onTap: selectToDate,
                      ),

                      const SizedBox(height: 13),

                      // ==================================================
                      // REASON / DESCRIPTION
                      // ==================================================
                      _buildTextField(
                        controller: descriptionController,
                        label: "Reason / Description",
                        icon: Icons.notes_rounded,
                        maxLines: 4,
                        hint: "Enter reason for leave",
                      ),

                      const SizedBox(height: 28),

                      // ==================================================
                      // SUBMIT
                      // ==================================================
                      _buildCreateButton(),

                      const SizedBox(height: 18),

                      Center(
                        child: Text(
                          "Madathil Solar ERP",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
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
    );
  }

  // ============================================================
  // HR EMPLOYEE SEARCH FIELD
  // ============================================================

  Widget _buildHrEmployeeField() {
    final bool selected = employeeController.text.trim().isNotEmpty;

    return TextFormField(
      controller: employeeNameController,

      readOnly: true,

      onTap: _openEmployeeSearch,

      style: const TextStyle(color: Colors.white, fontSize: 15),

      decoration: _inputDecoration(
        label: selected ? "Employee" : "Search Employee *",
        icon: Icons.badge_rounded,
        suffixIcon: const Icon(Icons.search_rounded, color: Color(0xFF7EE787)),
      ),

      validator: (value) {
        if (employeeController.text.trim().isEmpty) {
          return "Select Employee";
        }

        return null;
      },
    );
  }

  // ============================================================
  // LEAVE TYPE DROPDOWN
  // ============================================================

  Widget _buildLeaveTypeDropdown() {
    final enabled = !loadingLeaveTypes && leaveTypes.isNotEmpty;

    return DropdownButtonFormField<String>(
      initialValue: selectedLeaveType,

      onChanged: enabled
          ? (value) {
              setState(() {
                selectedLeaveType = value;
              });
            }
          : null,

      dropdownColor: const Color(0xFF103F39),

      style: const TextStyle(color: Colors.white, fontSize: 15),

      decoration: _inputDecoration(
        label: enabled ? "Leave Type *" : "Loading Leave Types...",
        icon: Icons.category_rounded,
      ),

      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.white70,
      ),

      items: leaveTypes.map((type) {
        return DropdownMenuItem<String>(
          value: type,

          child: Text(
            type,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),

      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Select Leave Type";
        }

        return null;
      },
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,

      readOnly: true,

      onTap: onTap,

      style: const TextStyle(color: Colors.white, fontSize: 15),

      decoration: _inputDecoration(label: label, icon: icon),

      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Select date";
        }

        return null;
      },
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    String? hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,

      readOnly: readOnly,

      maxLines: maxLines,

      style: const TextStyle(color: Colors.white, fontSize: 15),

      decoration: _inputDecoration(label: label, icon: icon, hint: hint),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,

      hintText: hint,

      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.62)),

      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),

      floatingLabelStyle: const TextStyle(
        color: Color(0xFF7EE787),
        fontWeight: FontWeight.w600,
      ),

      prefixIcon: Icon(icon, color: const Color(0xFF7EE787)),

      suffixIcon: suffixIcon,

      filled: true,

      fillColor: Colors.white.withValues(alpha: 0.08),

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

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

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7EE787), size: 21),

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
  // CREATE / SUBMIT BUTTON
  // ============================================================

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,

      height: 56,

      child: ElevatedButton.icon(
        onPressed: saving ? null : saveLeaveApplication,

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1DB954),

          foregroundColor: Colors.white,

          disabledBackgroundColor: const Color(
            0xFF1DB954,
          ).withValues(alpha: 0.45),

          elevation: 8,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
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
            : const Icon(Icons.send_rounded, size: 22),

        label: Text(
          saving ? "Submitting..." : "SUBMIT LEAVE APPLICATION",

          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

// ==================================================================
// EMPLOYEE SEARCH SCREEN
// ==================================================================

class EmployeeSearchScreen extends StatefulWidget {
  final List<Map<String, dynamic>> employees;

  final String? selectedEmployeeId;

  const EmployeeSearchScreen({
    super.key,
    required this.employees,
    this.selectedEmployeeId,
  });

  @override
  State<EmployeeSearchScreen> createState() => _EmployeeSearchScreenState();
}

class _EmployeeSearchScreenState extends State<EmployeeSearchScreen> {
  // ============================================================
  // SEARCH CONTROLLER
  // ============================================================

  final TextEditingController searchController = TextEditingController();

  // ============================================================
  // SEARCH TEXT
  // ============================================================

  String searchQuery = "";

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // FILTER EMPLOYEES
  // ============================================================

  List<Map<String, dynamic>> get filteredEmployees {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return widget.employees;
    }

    return widget.employees.where((employee) {
      final name = employee["employee_name"]?.toString().toLowerCase() ?? "";

      final id = employee["name"]?.toString().toLowerCase() ?? "";

      final company = employee["company"]?.toString().toLowerCase() ?? "";

      final userId = employee["user_id"]?.toString().toLowerCase() ?? "";

      return name.contains(query) ||
          id.contains(query) ||
          company.contains(query) ||
          userId.contains(query);
    }).toList();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final filtered = filteredEmployees;

    return Scaffold(
      backgroundColor: const Color(0xFF062E2A),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: const Color(0xFF103F39),

        elevation: 0,

        iconTheme: const IconThemeData(color: Colors.white),

        titleSpacing: 8,

        title: TextField(
          controller: searchController,

          autofocus: true,

          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },

          style: const TextStyle(color: Colors.white, fontSize: 15),

          cursorColor: const Color(0xFF7EE787),

          decoration: InputDecoration(
            hintText: "Search employee...",
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),

            border: InputBorder.none,

            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      searchController.clear();

                      setState(() {
                        searchQuery = "";
                      });
                    },
                    icon: const Icon(
                      Icons.clear_rounded,
                      color: Colors.white70,
                    ),
                  )
                : null,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: Column(
        children: [
          // ======================================================
          // SEARCH INFO
          // ======================================================
          Container(
            width: double.infinity,

            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),

            color: const Color(0xFF083631),

            child: Row(
              children: [
                const Icon(
                  Icons.people_alt_rounded,
                  color: Color(0xFF7EE787),
                  size: 20,
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Text(
                    searchQuery.trim().isEmpty
                        ? "${widget.employees.length} employees"
                        : "${filtered.length} employee(s) found",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // EMPLOYEE LIST
          // ======================================================
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          color: Colors.white38,
                          size: 52,
                        ),

                        SizedBox(height: 12),

                        Text(
                          "No employees found",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),

                    itemCount: filtered.length,

                    separatorBuilder: (context, index) {
                      return Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.08),
                      );
                    },

                    itemBuilder: (context, index) {
                      final employee = filtered[index];

                      final employeeId = employee["name"]?.toString() ?? "";

                      final employeeName =
                          employee["employee_name"]?.toString().trim() ?? "";

                      final company =
                          employee["company"]?.toString().trim() ?? "";

                      final userId =
                          employee["user_id"]?.toString().trim() ?? "";

                      final isSelected =
                          employeeId == widget.selectedEmployeeId;

                      final displayName = employeeName.isNotEmpty
                          ? employeeName
                          : employeeId;

                      return Material(
                        color: isSelected
                            ? const Color(0xFF1DB954).withValues(alpha: 0.10)
                            : Colors.transparent,

                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context, employee);
                          },

                          borderRadius: BorderRadius.circular(14),

                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 13,
                            ),

                            child: Row(
                              children: [
                                // --------------------------------
                                // AVATAR
                                // --------------------------------
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF1DB954,
                                    ).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: Color(0xFF7EE787),
                                    size: 23,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // --------------------------------
                                // EMPLOYEE DETAILS
                                // --------------------------------
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        company.isNotEmpty
                                            ? "$employeeId • $company"
                                            : employeeId,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.52,
                                          ),
                                          fontSize: 11,
                                        ),
                                      ),

                                      if (userId.isNotEmpty) ...[
                                        const SizedBox(height: 3),

                                        Text(
                                          userId,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.35,
                                            ),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // --------------------------------
                                // SELECTED ICON
                                // --------------------------------
                                isSelected
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFF7EE787),
                                        size: 22,
                                      )
                                    : const Icon(
                                        Icons.chevron_right_rounded,
                                        color: Colors.white38,
                                      ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
