import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/customer.dart';

class CustomerProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Customer> _customers = [];
  String _search = '';

  List<Customer> get customers {
    if (_search.isEmpty) return _customers;
    final q = _search.toLowerCase();
    return _customers.where(
      (c) =>
          c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q),
    ).toList();
  }

  int get totalCount => _customers.length;
  String get search => _search;

  void setSearch(String s) {
    _search = s;
    notifyListeners();
  }

  Future<void> loadCustomers() async {
    final db = await _db.database;
    final rows = await db.query('customers', orderBy: 'name ASC');
    _customers = rows.map((r) => Customer.fromMap(r)).toList();
    notifyListeners();
  }

  Future<Customer?> getCustomer(int id) async {
    final db = await _db.database;
    final rows =
        await db.query('customers', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Customer.fromMap(rows.first);
  }

  Future<int> addCustomer(Customer c) async {
    final db = await _db.database;
    final id = await db.insert('customers', c.toMap()..remove('id'));
    await loadCustomers();
    return id;
  }

  Future<void> updateCustomer(Customer c) async {
    final db = await _db.database;
    await db.update(
      'customers',
      c.toMap(),
      where: 'id = ?',
      whereArgs: [c.id],
    );
    await loadCustomers();
  }

  Future<void> deleteCustomer(int id) async {
    final db = await _db.database;
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
    await loadCustomers();
  }
}
