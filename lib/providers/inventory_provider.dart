import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/item.dart';

class InventoryProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Item> _items = [];
  String _search = '';
  String? _categoryFilter;

  List<Item> get items {
    Iterable<Item> result = _items;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      result = result.where(
        (i) =>
            i.name.toLowerCase().contains(q) ||
            i.sku.toLowerCase().contains(q) ||
            i.category.toLowerCase().contains(q),
      );
    }
    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      result = result.where((i) => i.category == _categoryFilter);
    }
    return result.toList();
  }

  List<Item> get allItems => _items;
  List<String> get categories =>
      _items.map((i) => i.category).toSet().toList()..sort();

  List<Item> get lowStockItems =>
      _items.where((i) => i.isLowStock).toList();

  int get totalCount => _items.length;
  double get inventoryValue =>
      _items.fold(0.0, (s, i) => s + (i.salePrice * i.quantity));

  String get search => _search;
  String? get categoryFilter => _categoryFilter;

  void setSearch(String s) {
    _search = s;
    notifyListeners();
  }

  void setCategoryFilter(String? c) {
    _categoryFilter = c;
    notifyListeners();
  }

  Future<void> loadItems() async {
    final db = await _db.database;
    final rows = await db.query('items', orderBy: 'name ASC');
    _items = rows.map((r) => Item.fromMap(r)).toList();
    notifyListeners();
  }

  Future<Item?> getItem(int id) async {
    final db = await _db.database;
    final rows =
        await db.query('items', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Item.fromMap(rows.first);
  }

  Future<int> addItem(Item item) async {
    final db = await _db.database;
    final id = await db.insert('items', item.toMap()..remove('id'));
    await loadItems();
    return id;
  }

  Future<void> updateItem(Item item) async {
    final db = await _db.database;
    await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
    await loadItems();
  }

  Future<void> deleteItem(int id) async {
    final db = await _db.database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
    await loadItems();
  }

  Future<void> adjustStock(int id, int delta) async {
    final item = await getItem(id);
    if (item == null) return;
    final newQty = (item.quantity + delta).clamp(0, 999999);
    await updateItem(
      item.copyWith(quantity: newQty, updatedAt: DateTime.now()),
    );
  }

  Future<bool> reserveStock(int id, int qty) async {
    final item = await getItem(id);
    if (item == null || item.quantity < qty) return false;
    await updateItem(
      item.copyWith(quantity: item.quantity - qty, updatedAt: DateTime.now()),
    );
    return true;
  }
}
