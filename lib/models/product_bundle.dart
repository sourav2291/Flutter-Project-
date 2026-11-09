// models/product_bundle.dart

class ProductBundleItem {
  final String itemCode;
  final double qty;
  final String uom;
  final String description;

  ProductBundleItem({
    required this.itemCode,
    required this.qty,
    required this.uom,
    required this.description,
  });

  factory ProductBundleItem.fromJson(Map<String, dynamic> json) {
    return ProductBundleItem(
      itemCode: json["item_code"]?.toString() ?? "",

      qty: _toDouble(json["qty"]),

      uom: json["uom"]?.toString() ?? "",

      description: json["description"]?.toString() ?? "",
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }
}

class ProductBundle {
  final String name;
  final List<ProductBundleItem> items;
  final double totalPrice;

  ProductBundle({
    required this.name,
    required this.items,
    required this.totalPrice,
  });

  factory ProductBundle.fromJson(Map<String, dynamic> json) {
    final rawItems = json["items"];

    final List<ProductBundleItem> parsedItems = [];

    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map<String, dynamic>) {
          parsedItems.add(ProductBundleItem.fromJson(item));
        }
      }
    }

    return ProductBundle(
      name: json["name"]?.toString() ?? "",

      items: parsedItems,

      totalPrice: _toDouble(json["custom_product_total_price"]),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }
}
