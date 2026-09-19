import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/customer.dart';
import '../../models/item.dart';
import '../../models/maintenance_order.dart';
import '../../models/order_part.dart';
import '../../providers/customer_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/order_provider.dart';

class OrderFormScreen extends StatefulWidget {
  final MaintenanceOrder? order;
  const OrderFormScreen({Key? key, this.order}) : super(key: key);

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceTypeCtrl = TextEditingController();
  final _deviceModelCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();
  final _problemCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _laborCostCtrl = TextEditingController(text: '0');
  final List<OrderPart> _parts = [];

  Customer? _selectedCustomer;
  OrderStatus _status = OrderStatus.pending;
  DateTime _receivedAt = DateTime.now();
  String? _orderNumber;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final orders = context.read<OrderProvider>();
    if (widget.order != null) {
      final o = widget.order!;
      _orderNumber = o.orderNumber;
      _deviceTypeCtrl.text = o.deviceType;
      _deviceModelCtrl.text = o.deviceModel;
      _serialCtrl.text = o.serialNumber ?? '';
      _problemCtrl.text = o.problemDescription;
      _diagnosisCtrl.text = o.diagnosis ?? '';
      _notesCtrl.text = o.notes ?? '';
      _laborCostCtrl.text = o.laborCost.toString();
      _status = o.status;
      _receivedAt = o.receivedAt;

      final cust = context.read<CustomerProvider>();
      _selectedCustomer = await cust.getCustomer(o.customerId);

      final parts = await orders.getOrderParts(o.id!);
      setState(() => _parts.addAll(parts));
    } else {
      _orderNumber = await orders.generateOrderNumber();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _deviceTypeCtrl.dispose();
    _deviceModelCtrl.dispose();
    _serialCtrl.dispose();
    _problemCtrl.dispose();
    _diagnosisCtrl.dispose();
    _notesCtrl.dispose();
    _laborCostCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final customers = context.watch<CustomerProvider>().customers;
    final items = context.watch<InventoryProvider>().items;

    final partsTotal =
        _parts.fold(0.0, (s, p) => s + p.unitPrice * p.quantity);
    final labor = double.tryParse(_laborCostCtrl.text) ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order == null
            ? loc.translate('add_order')
            : loc.translate('edit_order')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_orderNumber != null)
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.confirmation_number),
                        const SizedBox(width: 8),
                        Text(
                          '${loc.translate('order_number')}: $_orderNumber',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Customer>(
                decoration: InputDecoration(
                  labelText: loc.translate('select_customer'),
                  prefixIcon: const Icon(Icons.person),
                ),
                value: _selectedCustomer,
                items: customers
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text('${c.name} - ${c.phone}'),
                      ),
                    )
                    .toList(),
                validator: (v) =>
                    v == null ? loc.translate('required_field') : null,
                onChanged: (v) => setState(() => _selectedCustomer = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deviceTypeCtrl,
                decoration: InputDecoration(
                  labelText: loc.translate('device_type'),
                  prefixIcon: const Icon(Icons.devices),
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? loc.translate('required_field')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deviceModelCtrl,
                decoration: InputDecoration(
                  labelText: loc.translate('device_model'),
                  prefixIcon: const Icon(Icons.info),
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? loc.translate('required_field')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _serialCtrl,
                decoration: InputDecoration(
                  labelText: loc.translate('serial_number'),
                  prefixIcon: const Icon(Icons.tag),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _problemCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: loc.translate('problem_description'),
                  prefixIcon: const Icon(Icons.error_outline),
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? loc.translate('required_field')
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<OrderStatus>(
                decoration: InputDecoration(
                  labelText: loc.translate('status'),
                  prefixIcon: const Icon(Icons.info_outline),
                ),
                value: _status,
                items: OrderStatus.values
                    .map((s) =>
                        DropdownMenuItem(value: s, child: Text(s.label)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _laborCostCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '${loc.translate('labor_cost')} (${loc.currencySymbol})',
                  prefixIcon: const Icon(Icons.work),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.translate('parts_used'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _addPart(items),
                    icon: const Icon(Icons.add),
                    label: Text(loc.translate('add_part')),
                  ),
                ],
              ),
              if (_parts.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No parts added',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              else
                ..._parts.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final p = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(top: 8),
                    child: ListTile(
                      title: Text(p.itemName),
                      subtitle: Text(
                        '${p.itemSku} • ${loc.translate('qty')}: ${p.quantity} • ${loc.currencySymbol} ${p.unitPrice.toStringAsFixed(2)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${loc.currencySymbol} ${p.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() => _parts.removeAt(idx)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 16),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _totalRow(
                        '${loc.translate('subtotal')} (parts)',
                        partsTotal,
                      ),
                      _totalRow(
                        loc.translate('labor_cost'),
                        labor,
                      ),
                      const Divider(),
                      _totalRow(
                        loc.translate('total_cost'),
                        partsTotal + labor,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: Text(loc.translate('save')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            '${AppLocalizations.of(context)!.currencySymbol} ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addPart(List<Item> items) async {
    final result = await showModalBottomSheet<OrderPart>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PartPickerSheet(items: items),
    );
    if (result != null) {
      setState(() => _parts.add(result));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final orders = context.read<OrderProvider>();
    final inv = context.read<InventoryProvider>();
    final now = DateTime.now();

    final order = MaintenanceOrder(
      id: widget.order?.id,
      orderNumber: _orderNumber!,
      customerId: _selectedCustomer!.id!,
      deviceType: _deviceTypeCtrl.text.trim(),
      deviceModel: _deviceModelCtrl.text.trim(),
      serialNumber: _serialCtrl.text.trim().isEmpty
          ? null
          : _serialCtrl.text.trim(),
      problemDescription: _problemCtrl.text.trim(),
      diagnosis: _diagnosisCtrl.text.trim().isEmpty
          ? null
          : _diagnosisCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      status: _status,
      laborCost: double.tryParse(_laborCostCtrl.text) ?? 0,
      receivedAt: _receivedAt,
      completedAt: widget.order?.completedAt,
      deliveredAt: widget.order?.deliveredAt,
      createdAt: widget.order?.createdAt ?? now,
      updatedAt: now,
    );

    int orderId;
    if (widget.order == null) {
      orderId = await orders.addOrder(order);
      for (final p in _parts) {
        await orders.addPart(p.copyWith(orderId: orderId));
        // Deduct stock
        await inv.reserveStock(p.itemId, p.quantity);
      }
    } else {
      orderId = widget.order!.id!;
      await orders.updateOrder(order);
    }

    if (mounted) Navigator.pop(context);
  }
}

class _PartPickerSheet extends StatefulWidget {
  final List<Item> items;
  const _PartPickerSheet({required this.items});

  @override
  State<_PartPickerSheet> createState() => _PartPickerSheetState();
}

class _PartPickerSheetState extends State<_PartPickerSheet> {
  Item? _selected;
  final _qtyCtrl = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final inStock = widget.items.where((i) => i.quantity > 0).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('select_item'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Item>(
            decoration: const InputDecoration(
              labelText: 'Item',
              prefixIcon: Icon(Icons.inventory),
            ),
            value: _selected,
            isExpanded: true,
            items: inStock
                .map((i) => DropdownMenuItem(
                      value: i,
                      child: Text(
                        '${i.name} (${i.sku}) - ${loc.currencySymbol} ${i.salePrice.toStringAsFixed(2)}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selected = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _qtyCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: loc.translate('qty'),
              prefixIcon: const Icon(Icons.numbers),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_selected == null) return;
                final qty = int.tryParse(_qtyCtrl.text) ?? 1;
                if (qty <= 0 || qty > _selected!.quantity) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Quantity must be between 1 and ${_selected!.quantity}'),
                    ),
                  );
                  return;
                }
                Navigator.pop(
                  context,
                  OrderPart(
                    orderId: 0,
                    itemId: _selected!.id!,
                    itemName: _selected!.name,
                    itemSku: _selected!.sku,
                    quantity: qty,
                    unitPrice: _selected!.salePrice,
                    createdAt: DateTime.now(),
                  ),
                );
              },
              child: Text(loc.translate('add')),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
