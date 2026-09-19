import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/maintenance_order.dart';
import '../models/order_part.dart';

class OrderProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<MaintenanceOrder> _orders = [];
  String _search = '';
  OrderStatus? _statusFilter;

  List<MaintenanceOrder> get orders {
    Iterable<MaintenanceOrder> result = _orders;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      result = result.where(
        (o) =>
            o.orderNumber.toLowerCase().contains(q) ||
            o.deviceType.toLowerCase().contains(q) ||
            o.deviceModel.toLowerCase().contains(q),
      );
    }
    if (_statusFilter != null) {
      result = result.where((o) => o.status == _statusFilter);
    }
    return result.toList();
  }

  List<MaintenanceOrder> get allOrders => _orders;
  String get search => _search;
  OrderStatus? get statusFilter => _statusFilter;

  int get openCount => _orders
      .where((o) =>
          o.status != OrderStatus.completed &&
          o.status != OrderStatus.delivered &&
          o.status != OrderStatus.cancelled)
      .length;

  int get totalCount => _orders.length;

  double get totalRevenue => _orders
      .where((o) =>
          o.status == OrderStatus.completed || o.status == OrderStatus.delivered)
      .fold(0.0, (s, o) => s + o.laborCost);

  void setSearch(String s) {
    _search = s;
    notifyListeners();
  }

  void setStatusFilter(OrderStatus? s) {
    _statusFilter = s;
    notifyListeners();
  }

  Future<void> loadOrders() async {
    final db = await _db.database;
    final rows =
        await db.query('maintenance_orders', orderBy: 'received_at DESC');
    _orders = rows.map((r) => MaintenanceOrder.fromMap(r)).toList();
    notifyListeners();
  }

  Future<MaintenanceOrder?> getOrder(int id) async {
    final db = await _db.database;
    final rows = await db.query(
      'maintenance_orders',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return MaintenanceOrder.fromMap(rows.first);
  }

  Future<int> addOrder(MaintenanceOrder o) async {
    final db = await _db.database;
    final id = await db.insert(
      'maintenance_orders',
      o.toMap()..remove('id'),
    );
    await loadOrders();
    return id;
  }

  Future<void> updateOrder(MaintenanceOrder o) async {
    final db = await _db.database;
    await db.update(
      'maintenance_orders',
      o.toMap(),
      where: 'id = ?',
      whereArgs: [o.id],
    );
    await loadOrders();
  }

  Future<void> deleteOrder(int id) async {
    final db = await _db.database;
    await db.delete('maintenance_orders', where: 'id = ?', whereArgs: [id]);
    await loadOrders();
  }

  Future<List<OrderPart>> getOrderParts(int orderId) async {
    final db = await _db.database;
    final rows = await db.query(
      'order_parts',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    return rows.map((r) => OrderPart.fromMap(r)).toList();
  }

  Future<void> addPart(OrderPart p) async {
    final db = await _db.database;
    await db.insert('order_parts', p.toMap()..remove('id'));
  }

  Future<void> deletePart(int partId) async {
    final db = await _db.database;
    await db.delete('order_parts', where: 'id = ?', whereArgs: [partId]);
  }

  Future<void> updateOrderStatus(int id, OrderStatus status) async {
    final order = await getOrder(id);
    if (order == null) return;
    final now = DateTime.now();
    final updated = order.copyWith(
      status: status,
      completedAt: status == OrderStatus.completed ? now : order.completedAt,
      deliveredAt: status == OrderStatus.delivered ? now : order.deliveredAt,
      updatedAt: now,
    );
    await updateOrder(updated);
  }

  Future<String> generateOrderNumber() async {
    final db = await _db.database;
    final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM maintenance_orders'),
        ) ??
        0;
    final year = DateTime.now().year;
    return 'ORD-$year-${(count + 1).toString().padLeft(5, '0')}';
  }
}
