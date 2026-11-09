// models/product.dart
class ProductBundle {
  final String name;
  final String totalPrice;

  ProductBundle({required this.name, required this.totalPrice});

  factory ProductBundle.fromJson(Map<String, dynamic> json) {
    return ProductBundle(
      name: json["name"] ?? "",
      totalPrice: json["custom_product_total_price"]?.toString() ?? "0",
    );
  }
}
