enum OrderStatus {
  pending,
  inProgress,
  waitingParts,
  completed,
  delivered,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.waitingParts:
        return 'Waiting Parts';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get dbValue => name;
}

OrderStatus orderStatusFromString(String value) {
  return OrderStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => OrderStatus.pending,
  );
}

class MaintenanceOrder {
  final int? id;
  final String orderNumber;
  final int customerId;
  final String deviceType;
  final String deviceModel;
  final String? serialNumber;
  final String problemDescription;
  final String? diagnosis;
  final String? notes;
  final OrderStatus status;
  final double laborCost;
  final DateTime receivedAt;
  final DateTime? completedAt;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaintenanceOrder({
    this.id,
    required this.orderNumber,
    required this.customerId,
    required this.deviceType,
    required this.deviceModel,
    this.serialNumber,
    required this.problemDescription,
    this.diagnosis,
    this.notes,
    required this.status,
    required this.laborCost,
    required this.receivedAt,
    this.completedAt,
    this.deliveredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'device_type': deviceType,
      'device_model': deviceModel,
      'serial_number': serialNumber,
      'problem_description': problemDescription,
      'diagnosis': diagnosis,
      'notes': notes,
      'status': status.dbValue,
      'labor_cost': laborCost,
      'received_at': receivedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory MaintenanceOrder.fromMap(Map<String, dynamic> map) {
    return MaintenanceOrder(
      id: map['id'] as int?,
      orderNumber: map['order_number'] as String,
      customerId: map['customer_id'] as int,
      deviceType: map['device_type'] as String,
      deviceModel: map['device_model'] as String,
      serialNumber: map['serial_number'] as String?,
      problemDescription: map['problem_description'] as String,
      diagnosis: map['diagnosis'] as String?,
      notes: map['notes'] as String?,
      status: orderStatusFromString(map['status'] as String),
      laborCost: (map['labor_cost'] as num).toDouble(),
      receivedAt: DateTime.parse(map['received_at'] as String),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      deliveredAt: map['delivered_at'] != null
          ? DateTime.parse(map['delivered_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  MaintenanceOrder copyWith({
    int? id,
    String? orderNumber,
    int? customerId,
    String? deviceType,
    String? deviceModel,
    String? serialNumber,
    String? problemDescription,
    String? diagnosis,
    String? notes,
    OrderStatus? status,
    double? laborCost,
    DateTime? receivedAt,
    DateTime? completedAt,
    DateTime? deliveredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaintenanceOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      deviceType: deviceType ?? this.deviceType,
      deviceModel: deviceModel ?? this.deviceModel,
      serialNumber: serialNumber ?? this.serialNumber,
      problemDescription: problemDescription ?? this.problemDescription,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      laborCost: laborCost ?? this.laborCost,
      receivedAt: receivedAt ?? this.receivedAt,
      completedAt: completedAt ?? this.completedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
