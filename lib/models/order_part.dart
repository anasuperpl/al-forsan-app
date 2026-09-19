class OrderPart {
  final int? id;
  final int orderId;
  final int itemId;
  final String itemName;
  final String itemSku;
  final int quantity;
  final double unitPrice;
  final DateTime createdAt;

  OrderPart({
    this.id,
    required this.orderId,
    required this.itemId,
    required this.itemName,
    required this.itemSku,
    required this.quantity,
    required this.unitPrice,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'item_id': itemId,
      'item_name': itemName,
      'item_sku': itemSku,
      'quantity': quantity,
      'unit_price': unitPrice,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory OrderPart.fromMap(Map<String, dynamic> map) {
    return OrderPart(
      id: map['id'] as int?,
      orderId: map['order_id'] as int,
      itemId: map['item_id'] as int,
      itemName: map['item_name'] as String,
      itemSku: map['item_sku'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  double get totalPrice => quantity * unitPrice;
}
