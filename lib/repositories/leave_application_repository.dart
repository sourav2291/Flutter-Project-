// repositories/leave_application_repository.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/leave_application.dart';
import '../services/session_service.dart';

class LeaveApplicationRepository {
  // ============================================================
  // GET LOGGED-IN USER
  // ============================================================

  Future<String> getLoggedInUser() async {
    final session = SessionService();

    final site = await session.getSite();
    final cookie = await session.getCookie();

    if (site == null || cookie == null) {
      throw Exception("Session not found. Please login again.");
    }

    final url = Uri.parse('$site/api/method/frappe.auth.get_logged_user');

    final response = await http.get(
      url,
      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    print("==========================================");
    print("GET LOGGED-IN USER");
    print("Status : ${response.statusCode}");
    print("Body   : ${response.body}");
    print("==========================================");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final user = jsonData["message"]?.toString() ?? "";

      if (user.isNotEmpty) {
        return user;
      }
    }

    throw Exception("Unable to get logged-in user.");
  }

  // ============================================================
  // GET LEAVE APPLICATION ACCESS
  //
  // Backend decides:
  //
  // HR:
  //   - all employees
  //   - all leave applications
  //
  // Normal Employee:
  //   - logged-in employee
  //   - only own leave applications
  //
  // ============================================================

  Future<Map<String, dynamic>> getLeaveApplicationAccess() async {
    final session = SessionService();

    final site = await session.getSite();
    final cookie = await session.getCookie();

    if (site == null || cookie == null) {
      throw Exception("Session not found. Please login again.");
    }

    final url = Uri.parse(
      '$site/api/method/'
      'madathilapp.madathilapp.api.'
      'get_leave_application_access',
    );

    print("==========================================");
    print("GET LEAVE APPLICATION ACCESS");
    print("URL : $url");
    print("==========================================");

    final response = await http.get(
      url,
      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    print("==========================================");
    print("LEAVE ACCESS RESPONSE");
    print("Status : ${response.statusCode}");
    print("Body   : ${response.body}");
    print("==========================================");

    if (response.statusCode != 200) {
      String errorMessage = "Failed to load Leave Application access.";

      try {
        final jsonData = jsonDecode(response.body);

        if (jsonData["_server_messages"] != null) {
          errorMessage = jsonData["_server_messages"].toString();
        } else if (jsonData["exception"] != null) {
          errorMessage = jsonData["exception"].toString();
        } else if (jsonData["message"] is String) {
          errorMessage = jsonData["message"].toString();
        }
      } catch (_) {
        errorMessage = response.body;
      }

      throw Exception(
        "$errorMessage\n"
        "Status: ${response.statusCode}",
      );
    }

    final jsonData = jsonDecode(response.body);

    final message = jsonData["message"];

    if (message == null || message is! Map) {
      throw Exception(
        "Invalid response received from "
        "Leave Application access API.",
      );
    }

    return Map<String, dynamic>.from(message);
  }

  // ============================================================
  // GET CURRENT EMPLOYEE
  //
  // Used for NORMAL EMPLOYEE.
  //
  // HR users are handled separately in the
  // Create Leave screen because an HR login
  // may not have an Employee record linked
  // to the same ERPNext user.
  //
  // ============================================================

  Future<Map<String, dynamic>> getCurrentEmployee() async {
    final access = await getLeaveApplicationAccess();

    final isHr = access["is_hr"] == true;

    // ------------------------------------------------------------
    // NORMAL EMPLOYEE
    // ------------------------------------------------------------

    if (!isHr) {
      final employee = access["employee"];

      if (employee is Map) {
        final result = Map<String, dynamic>.from(employee);

        final employeeId = result["name"]?.toString() ?? "";

        if (employeeId.isNotEmpty) {
          print("==========================================");
          print("CURRENT EMPLOYEE FOUND");
          print(
            "Employee ID   : "
            "${result["name"]}",
          );
          print(
            "Employee Name : "
            "${result["employee_name"]}",
          );
          print(
            "User ID       : "
            "${result["user_id"]}",
          );
          print(
            "Company       : "
            "${result["company"]}",
          );
          print("==========================================");

          return result;
        }
      }

      // ----------------------------------------------------------
      // FALLBACK
      // ----------------------------------------------------------

      final employees = access["employees"];

      if (employees is List && employees.isNotEmpty) {
        for (final item in employees) {
          if (item is Map) {
            final employee = Map<String, dynamic>.from(item);

            final employeeId = employee["name"]?.toString() ?? "";

            if (employeeId.isNotEmpty) {
              return employee;
            }
          }
        }
      }

      throw Exception(
        "No Employee record is linked "
        "to the logged-in user.",
      );
    }

    // ------------------------------------------------------------
    // HR USER
    //
    // HR does NOT need an Employee record.
    // HR employee selection is handled by
    // the Create Leave screen.
    // ------------------------------------------------------------

    final loggedInUser = access["logged_in_user"]?.toString() ?? "";

    final employees = access["employees"];

    if (employees is List) {
      for (final item in employees) {
        if (item is! Map) {
          continue;
        }

        final employee = Map<String, dynamic>.from(item);

        final userId = employee["user_id"]?.toString() ?? "";

        if (userId == loggedInUser) {
          return employee;
        }
      }
    }

    throw Exception(
      "HR user is not linked to an Employee record. "
      "Please select an Employee.",
    );
  }

  // ============================================================
  // GET LEAVE APPLICATIONS
  //
  // HR:
  //   ALL Leave Applications
  //
  // Normal Employee:
  //   ONLY their own Leave Applications
  //
  // ============================================================

  Future<List<LeaveApplication>> getLeaveApplications() async {
    final access = await getLeaveApplicationAccess();

    final data = access["leave_applications"];

    if (data is! List) {
      throw Exception(
        "Invalid Leave Application data "
        "received from server.",
      );
    }

    print("==========================================");
    print("GET LEAVE APPLICATIONS");
    print(
      "Is HR        : "
      "${access["is_hr"]}",
    );
    print(
      "Logged User  : "
      "${access["logged_in_user"]}",
    );
    print(
      "Total Records: "
      "${data.length}",
    );
    print("==========================================");

    return data
        .map((e) => LeaveApplication.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ============================================================
  // GET LEAVE TYPES
  // ============================================================

  Future<List<String>> getLeaveTypes() async {
    final session = SessionService();

    final site = await session.getSite();
    final cookie = await session.getCookie();

    if (site == null || cookie == null) {
      throw Exception("Session not found. Please login again.");
    }

    final url = Uri.parse('$site/api/resource/Leave Type').replace(
      queryParameters: {
        "fields": jsonEncode(["name"]),
        "limit_page_length": "100",
      },
    );

    final response = await http.get(
      url,
      headers: {"Cookie": cookie, "Accept": "application/json"},
    );

    print("==========================================");
    print("GET LEAVE TYPES");
    print("Status : ${response.statusCode}");
    print("Body   : ${response.body}");
    print("==========================================");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final List data = jsonData["data"] ?? [];

      return data
          .map<String>((e) => e["name"]?.toString() ?? "")
          .where((name) => name.isNotEmpty)
          .toList();
    }

    throw Exception("Unable to load Leave Types.");
  }

  // ============================================================
  // CREATE LEAVE APPLICATION
  //
  // No approver is sent from mobile.
  //
  // ERPNext handles approval/workflow.
  //
  // ============================================================

  Future<String> createLeaveApplication({
    required String employee,
    required String leaveType,
    required String fromDate,
    required String toDate,
    required String description,
  }) async {
    final session = SessionService();

    final site = await session.getSite();

    final cookie = await session.getCookie();

    if (site == null || cookie == null) {
      throw Exception("Session not found. Please login again.");
    }

    // ----------------------------------------------------------
    // BASIC VALIDATION
    // ----------------------------------------------------------

    if (employee.trim().isEmpty) {
      throw Exception("Employee is required.");
    }

    if (leaveType.trim().isEmpty) {
      throw Exception("Leave Type is required.");
    }

    if (fromDate.trim().isEmpty) {
      throw Exception("From Date is required.");
    }

    if (toDate.trim().isEmpty) {
      throw Exception("To Date is required.");
    }

    // ----------------------------------------------------------
    // API URL
    // ----------------------------------------------------------

    final url = Uri.parse('$site/api/resource/Leave Application');

    // ----------------------------------------------------------
    // REQUEST BODY
    // ----------------------------------------------------------

    final Map<String, dynamic> body = {
      "employee": employee.trim(),
      "leave_type": leaveType.trim(),
      "from_date": fromDate.trim(),
      "to_date": toDate.trim(),
      "description": description.trim(),
    };

    print("==========================================");
    print("CREATE LEAVE APPLICATION");
    print("URL  : $url");
    print("BODY : ${jsonEncode(body)}");
    print("==========================================");

    // ----------------------------------------------------------
    // POST REQUEST
    // ----------------------------------------------------------

    final response = await http.post(
      url,
      headers: {
        "Cookie": cookie,
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    );

    print("==========================================");
    print("CREATE LEAVE APPLICATION RESPONSE");
    print("Status : ${response.statusCode}");
    print("Body   : ${response.body}");
    print("==========================================");

    // ----------------------------------------------------------
    // SUCCESS
    // ----------------------------------------------------------

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);

      final data = jsonData["data"];

      final createdName = data?["name"]?.toString() ?? "";

      if (createdName.isNotEmpty) {
        return createdName;
      }

      throw Exception(
        "Leave Application was created, "
        "but ERPNext did not return "
        "the document name.",
      );
    }

    // ----------------------------------------------------------
    // ERPNext ERROR
    // ----------------------------------------------------------

    String errorMessage = "Failed to create Leave Application.";

    try {
      final jsonData = jsonDecode(response.body);

      // --------------------------------------------------------
      // GET ALL POSSIBLE ERROR TEXT
      // --------------------------------------------------------

      String serverMessages = jsonData["_server_messages"]?.toString() ?? "";

      String exception = jsonData["exception"]?.toString() ?? "";

      String message = jsonData["message"]?.toString() ?? "";

      // --------------------------------------------------------
      // DECODE _server_messages WHEN IT IS
      // A JSON-ENCODED STRING
      // --------------------------------------------------------

      if (serverMessages.isNotEmpty) {
        try {
          final decoded = jsonDecode(serverMessages);

          if (decoded is List) {
            final List<String> decodedMessages = [];

            for (final item in decoded) {
              if (item is Map) {
                final itemMessage = item["message"]?.toString() ?? "";

                if (itemMessage.isNotEmpty) {
                  decodedMessages.add(itemMessage);
                }
              } else {
                decodedMessages.add(item.toString());
              }
            }

            if (decodedMessages.isNotEmpty) {
              serverMessages = decodedMessages.join(" ");
            }
          }
        } catch (_) {
          // Keep original text if
          // it is not valid JSON.
        }
      }

      // --------------------------------------------------------
      // COMBINE ERROR TEXT
      // --------------------------------------------------------

      final combinedError =
          "$serverMessages "
                  "$exception "
                  "$message"
              .toLowerCase();

      // --------------------------------------------------------
      // LEAVE ALREADY EXISTS
      // --------------------------------------------------------
      //
      // ERPNext commonly sends:
      //
      // "has already applied for"
      //
      // when a leave overlaps an
      // existing Leave Application.
      //
      // --------------------------------------------------------

      final bool leaveAlreadyExists =
          response.statusCode == 417 &&
          (combinedError.contains("has already applied for") ||
              combinedError.contains("already applied") ||
              combinedError.contains("overlapping") ||
              combinedError.contains("leave application exists") ||
              combinedError.contains("overlap with existing"));

      if (leaveAlreadyExists) {
        errorMessage =
            "Leave already exists for this employee "
            "for the selected date range.";
      }
      // --------------------------------------------------------
      // OTHER SERVER MESSAGES
      // --------------------------------------------------------
      else if (serverMessages.trim().isNotEmpty) {
        errorMessage = serverMessages.trim();
      }
      // --------------------------------------------------------
      // OTHER EXCEPTIONS
      // --------------------------------------------------------
      else if (exception.trim().isNotEmpty) {
        errorMessage = exception.trim();
      }
      // --------------------------------------------------------
      // OTHER MESSAGES
      // --------------------------------------------------------
      else if (message.trim().isNotEmpty) {
        errorMessage = message.trim();
      }
    } catch (_) {
      errorMessage = response.body;
    }

    // ----------------------------------------------------------
    // IMPORTANT
    //
    // Do NOT show HTTP status to the user for normal
    // validation errors such as duplicate leave.
    // ----------------------------------------------------------

    throw Exception(errorMessage);
  }
}
