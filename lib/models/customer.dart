// models/customer.dart

class Customer {
  final String name;
  final String customerName;
  final String customerType;
  final String? customerGroup;
  final String? territory;
  final String? gstin;
  final String? zoneName;
  final String? customerOwner;
  final String? mobileNo;
  final String? emailId;
  final String? primaryAddress;
  final String? customerPrimaryContact;

  Customer({
    required this.name,
    required this.customerName,
    required this.customerType,
    this.customerGroup,
    this.territory,
    this.gstin,
    this.zoneName,
    this.customerOwner,
    this.mobileNo,
    this.emailId,
    this.primaryAddress,
    this.customerPrimaryContact,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json["name"] ?? "",
      customerName: json["customer_name"] ?? "",
      customerType: json["customer_type"] ?? "",
      customerGroup: json["customer_group"],
      territory: json["territory"],
      gstin: json["gstin"],
      zoneName: json["custom_zone_name"],
      customerOwner: json["custom_customer_owner"],
      mobileNo: json["mobile_no"],
      emailId: json["email_id"],
      primaryAddress: json["primary_address"],
      customerPrimaryContact: json["customer_primary_contact"],
    );
  }
}
