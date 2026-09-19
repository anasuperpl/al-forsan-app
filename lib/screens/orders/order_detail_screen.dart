import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/customer.dart';
import '../../models/maintenance_order.dart';
import '../../models/order_part.dart';
import '../../providers/customer_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/report_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  MaintenanceOrder? _order;
  Customer? _customer;
  List<OrderPart> _parts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final orders = context.read<OrderProvider>();
    final cust = context.read<CustomerProvider>();
    final order = await orders.getOrder(widget.orderId);
    if (order == null) return;
    final customer = await cust.getCustomer(order.customerId);
    final parts = await orders.getOrderParts(order.id!);
    setState(() {
      _order = order;
      _customer = customer;
      _parts = parts;
    });
  }

  Future<void> _printReport() async {
    if (_order == null) return;
    await ReportService.printSingleOrder(_order!, _customer, _parts);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_order == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final order = _order!;
    final partsTotal = _parts.fold(0.0, (s, p) => s + p.totalPrice);
    final grandTotal = partsTotal + order.laborCost;

    return Scaffold(
      appBar: AppBar(
        title: Text(order.orderNumber),
        actions: [
          IconButton(
            tooltip: loc.translate('print_report'),
            icon: const Icon(Icons.print),
            onPressed: _printReport,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statusBar(order.status),
            const SizedBox(height: 16),
            _section(
              loc.translate('customer_name'),
              [
                _row(Icons.person, _customer?.name ?? 'N/A'),
                _row(Icons.phone, _customer?.phone ?? 'N/A'),
                if (_customer?.email != null && _customer!.email!.isNotEmpty)
                  _row(Icons.email, _customer!.email!),
              ],
            ),
            const SizedBox(height: 12),
            _section(
              'Device',
              [
                _row(Icons.devices, '${order.deviceType} - ${order.deviceModel}'),
                if (order.serialNumber != null && order.serialNumber!.isNotEmpty)
                  _row(Icons.tag, order.serialNumber!),
                _row(Icons.error_outline, order.problemDescription),
                if (order.diagnosis != null && order.diagnosis!.isNotEmpty)
                  _row(Icons.medical_services, order.diagnosis!),
              ],
            ),
            const SizedBox(height: 12),
            _section(
              loc.translate('parts_used'),
              _parts.isEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('No parts'),
                      ),
                    ]
                  : _parts
                      .map(
                        (p) => ListTile(
                          dense: true,
                          title: Text(p.itemName),
                          subtitle:
                              Text('${p.itemSku} • ${loc.translate('qty')}: ${p.quantity}'),
                          trailing: Text(
                            '${loc.currencySymbol} ${p.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _totalRow(
                      loc.translate('subtotal'),
                      partsTotal,
                    ),
                    _totalRow(
                      loc.translate('labor_cost'),
                      order.laborCost,
                    ),
                    const Divider(),
                    _totalRow(
                      loc.translate('total_cost'),
                      grandTotal,
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _section(
              loc.translate('status'),
              [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: OrderStatus.values.map((s) {
                    return ChoiceChip(
                      label: Text(s.label),
                      selected: order.status == s,
                      onSelected: (_) async {
                        final orders = context.read<OrderProvider>();
                        await orders.updateOrderStatus(order.id!, s);
                        await _load();
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBar(OrderStatus s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _statusColor(s).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _statusColor(s)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: _statusColor(s)),
          const SizedBox(width: 12),
          Text(
            s.label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _statusColor(s),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool isBold = false}) {
    final loc = AppLocalizations.of(context)!;
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
            '${loc.currencySymbol} ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.inProgress:
        return Colors.blue;
      case OrderStatus.waitingParts:
        return Colors.purple;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.green.shade800;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
