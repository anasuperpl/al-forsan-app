class Item {
  final int? id;
  final String sku;
  final String name;
  final String category;
  final double purchasePrice;
  final double salePrice;
  final int quantity;
  final int minStock;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Item({
    this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.purchasePrice,
    required this.salePrice,
    required this.quantity,
    required this.minStock,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'category': category,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'quantity': quantity,
      'min_stock': minStock,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as int?,
      sku: map['sku'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      purchasePrice: (map['purchase_price'] as num).toDouble(),
      salePrice: (map['sale_price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      minStock: map['min_stock'] as int,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Item copyWith({
    int? id,
    String? sku,
    String? name,
    String? category,
    double? purchasePrice,
    double? salePrice,
    int? quantity,
    int? minStock,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      category: category ?? this.category,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      quantity: quantity ?? this.quantity,
      minStock: minStock ?? this.minStock,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isLowStock => quantity <= minStock;
  double get profitMargin =>
      salePrice > 0 ? ((salePrice - purchasePrice) / salePrice) * 100 : 0;
}
