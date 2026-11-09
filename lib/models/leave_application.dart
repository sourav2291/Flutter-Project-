// models/leave_application.dart
class LeaveApplication {
  final String name;
  final String employee;
  final String employeeName;
  final String leaveType;
  final String company;
  final String fromDate;
  final String toDate;
  final String description;
  final String leaveApprover;
  final String leaveApproverName;
  final String postingDate;
  final String status;
  final bool halfDay;
  final double totalLeaveDays;

  LeaveApplication({
    required this.name,
    required this.employee,
    required this.employeeName,
    required this.leaveType,
    required this.company,
    required this.fromDate,
    required this.toDate,
    required this.description,
    required this.leaveApprover,
    required this.leaveApproverName,
    required this.postingDate,
    required this.status,
    required this.halfDay,
    required this.totalLeaveDays,
  });

  factory LeaveApplication.fromJson(Map<String, dynamic> json) {
    return LeaveApplication(
      name: json["name"]?.toString() ?? "",
      employee: json["employee"]?.toString() ?? "",
      employeeName: json["employee_name"]?.toString() ?? "",
      leaveType: json["leave_type"]?.toString() ?? "",
      company: json["company"]?.toString() ?? "",
      fromDate: json["from_date"]?.toString() ?? "",
      toDate: json["to_date"]?.toString() ?? "",
      description: json["description"]?.toString() ?? "",
      leaveApprover: json["leave_approver"]?.toString() ?? "",
      leaveApproverName: json["leave_approver_name"]?.toString() ?? "",
      postingDate: json["posting_date"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "",
      halfDay: json["half_day"] == 1 || json["half_day"] == true,
      totalLeaveDays:
          double.tryParse(json["total_leave_days"]?.toString() ?? "0") ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "employee": employee,
      "employee_name": employeeName,
      "leave_type": leaveType,
      "company": company,
      "from_date": fromDate,
      "to_date": toDate,
      "description": description,
      "leave_approver": leaveApprover,
      "leave_approver_name": leaveApproverName,
      "posting_date": postingDate,
      "status": status,
      "half_day": halfDay ? 1 : 0,
      "total_leave_days": totalLeaveDays,
    };
  }
}
