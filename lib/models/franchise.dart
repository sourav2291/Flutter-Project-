// models/franchise.dart
class Franchise {
  final String franchiseName;

  Franchise({required this.franchiseName});

  factory Franchise.fromJson(Map<String, dynamic> json) {
    return Franchise(franchiseName: json["franchise_name"] ?? "");
  }
}
