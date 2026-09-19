import 'package:flutter_test/flutter_test.dart';
import 'package:al_forsan/models/item.dart';
import 'package:al_forsan/models/customer.dart';
import 'package:al_forsan/models/maintenance_order.dart';
import 'package:al_forsan/models/order_part.dart';

void main() {
  group('Item Model', () {
    test('should create an Item with all fields', () {
      final now = DateTime.now();
      final item = Item(
        id: 1,
        sku: 'SKU001',
        name: 'Oil Filter',
        category: 'Filters',
        purchasePrice: 10.0,
        salePrice: 15.0,
        quantity: 5,
        minStock: 2,
        description: 'High quality filter',
        createdAt: now,
        updatedAt: now,
      );

      expect(item.sku, 'SKU001');
      expect(item.name, 'Oil Filter');
      expect(item.quantity, 5);
      expect(item.isLowStock, false); // 5 > 2
    });

    test('should detect low stock correctly', () {
      final now = DateTime.now();
      final item = Item(
        sku: 'SKU002',
        name: 'Air Filter',
        category: 'Filters',
        purchasePrice: 10.0,
        salePrice: 15.0,
        quantity: 1,
        minStock: 5,
        createdAt: now,
        updatedAt: now,
      );

      expect(item.isLowStock, true);
    });

    test('should calculate profit margin correctly', () {
      final now = DateTime.now();
      final item = Item(
        sku: 'SKU003',
        name: 'Brake Pad',
        category: 'Brakes',
        purchasePrice: 20.0,
        salePrice: 50.0,
        quantity: 10,
        minStock: 2,
        createdAt: now,
        updatedAt: now,
      );

      // (50-20)/50 = 60%
      expect(item.profitMargin, 60.0);
    });

    test('toMap/fromMap round-trip', () {
      final now = DateTime.now();
      final item = Item(
        id: 7,
        sku: 'TEST',
        name: 'Test Item',
        category: 'Cat',
        purchasePrice: 9.99,
        salePrice: 19.99,
        quantity: 3,
        minStock: 1,
        description: 'desc',
        createdAt: now,
        updatedAt: now,
      );

      final map = item.toMap();
      final back = Item.fromMap(map);
      expect(back.sku, item.sku);
      expect(back.salePrice, item.salePrice);
      expect(back.id, item.id);
    });
  });

  group('Customer Model', () {
    test('should create a Customer', () {
      final c = Customer(
        id: 1,
        name: 'Ahmed',
        phone: '050-1234567',
        email: 'a@x.com',
        createdAt: DateTime.now(),
      );
      expect(c.name, 'Ahmed');
      expect(c.email, 'a@x.com');
    });

    test('toMap/fromMap round-trip', () {
      final c = Customer(
        id: 5,
        name: 'Mohammed',
        phone: '050-9999',
        createdAt: DateTime.now(),
      );
      final m = c.toMap();
      final back = Customer.fromMap(m);
      expect(back.id, 5);
      expect(back.phone, '050-9999');
    });
  });

  group('MaintenanceOrder Model', () {
    test('should create order with status enum', () {
      final now = DateTime.now();
      final order = MaintenanceOrder(
        id: 1,
        orderNumber: 'ORD-2025-00001',
        customerId: 1,
        deviceType: 'Laptop',
        deviceModel: 'Dell XPS',
        problemDescription: 'Won\'t turn on',
        status: OrderStatus.inProgress,
        laborCost: 100.0,
        receivedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(order.status, OrderStatus.inProgress);
      expect(order.status.label, 'In Progress');
    });

    test('status dbValue round-trips', () {
      for (final s in OrderStatus.values) {
        expect(orderStatusFromString(s.dbValue), s);
      }
    });
  });

  group('OrderPart Model', () {
    test('should calculate total price', () {
      final p = OrderPart(
        orderId: 1,
        itemId: 1,
        itemName: 'Filter',
        itemSku: 'F1',
        quantity: 3,
        unitPrice: 10.0,
        createdAt: DateTime.now(),
      );
      expect(p.totalPrice, 30.0);
    });
  });
}
