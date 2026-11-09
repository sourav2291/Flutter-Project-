// models/lead.dart

class Lead {
  final String name;
  final String leadName;
  final String currentStatus;
  final String leadOwner;
  final String type;
  final String mobileNo;
  final String? emailId;
  final String source;
  final String whatsappNo;
  final String address;
  final List<LeadTracking> leadTracking;
  final List<LeadAddress> addresses;

  Lead({
    required this.name,
    required this.leadName,
    required this.currentStatus,
    required this.leadOwner,
    required this.type,
    required this.mobileNo,
    this.emailId,
    required this.source,
    required this.whatsappNo,
    required this.address,
    required this.leadTracking,
    required this.addresses,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      name: json["name"] ?? "",
      leadName: json["lead_name"] ?? "",

      // API returns "status"
      currentStatus: json["status"] ?? "",

      leadOwner: json["lead_owner"] ?? "",
      type: json["type"] ?? "",
      mobileNo: json["mobile_no"] ?? "",
      emailId: json["email_id"],

      source: json["source"] ?? "",
      whatsappNo: json["whatsapp_no"] ?? "",
      address: json["address"] ?? "",

      leadTracking: (json["lead_tracking"] as List? ?? [])
          .map((item) => LeadTracking.fromJson(Map<String, dynamic>.from(item)))
          .toList(),

      addresses: (json["addresses"] as List? ?? [])
          .map((item) => LeadAddress.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

// ============================================================
// LEAD TRACKING / FOLLOW-UP
// ============================================================

class LeadTracking {
  final String dateAndTime;
  final String status;
  final String feedback;
  final String userLink;

  LeadTracking({
    required this.dateAndTime,
    required this.status,
    required this.feedback,
    required this.userLink,
  });

  factory LeadTracking.fromJson(Map<String, dynamic> json) {
    return LeadTracking(
      dateAndTime: json["date_and_time"] ?? "",
      status: json["status"] ?? "",
      feedback: json["feedback"] ?? "",
      userLink: json["userlink"] ?? "",
    );
  }
}

// ============================================================
// LEAD ADDRESS
// ============================================================

class LeadAddress {
  final String name;
  final String addressTitle;
  final String addressType;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String emailId;
  final String phone;
  final int isPrimaryAddress;
  final int isShippingAddress;

  LeadAddress({
    required this.name,
    required this.addressTitle,
    required this.addressType,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.emailId,
    required this.phone,
    required this.isPrimaryAddress,
    required this.isShippingAddress,
  });

  factory LeadAddress.fromJson(Map<String, dynamic> json) {
    return LeadAddress(
      name: json["name"] ?? "",
      addressTitle: json["address_title"] ?? "",
      addressType: json["address_type"] ?? "",
      addressLine1: json["address_line1"] ?? "",
      addressLine2: json["address_line2"] ?? "",
      city: json["city"] ?? "",
      state: json["state"] ?? "",
      country: json["country"] ?? "",
      pincode: json["pincode"] ?? "",
      emailId: json["email_id"] ?? "",
      phone: json["phone"] ?? "",
      isPrimaryAddress: json["is_primary_address"] ?? 0,
      isShippingAddress: json["is_shipping_address"] ?? 0,
    );
  }
}
