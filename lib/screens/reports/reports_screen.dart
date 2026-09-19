import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/maintenance_order.dart';
import '../../providers/order_provider.dart';
import '../../services/report_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportPeriod _period = ReportPeriod.daily;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  List<MaintenanceOrder> _getFilteredOrders(List<MaintenanceOrder> all) {
    return all.where((o) {
      final d = o.receivedAt;
      switch (_period) {
        case ReportPeriod.daily:
          return d.year == _startDate.year &&
              d.month == _startDate.month &&
              d.day == _startDate.day;
        case ReportPeriod.weekly:
          final start = _startDate.subtract(Duration(days: _startDate.weekday - 1));
          final end = start.add(const Duration(days: 7));
          return d.isAfter(start.subtract(const Duration(seconds: 1))) &&
              d.isBefore(end);
        case ReportPeriod.monthly:
          return d.year == _startDate.year && d.month == _startDate.month;
      }
    }).toList();
  }

  void _adjustDate(int days) {
    setState(() {
      _startDate = _startDate.add(Duration(days: days));
      _endDate = _endDate.add(Duration(days: days));
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _endDate = picked;
      });
    }
  }

  Future<void> _printReport(List<MaintenanceOrder> orders) async {
    await ReportService.printPeriodReport(
      period: _period,
      orders: orders,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final allOrders = context.watch<OrderProvider>().allOrders;
    final filtered = _getFilteredOrders(allOrders);

    final completedOrders = filtered.where(
      (o) =>
          o.status == OrderStatus.completed ||
          o.status == OrderStatus.delivered,
    );
    final revenue = completedOrders.fold(0.0, (s, o) => s + o.laborCost);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('reports')),
        actions: [
          IconButton(
            tooltip: loc.translate('print'),
            icon: const Icon(Icons.print),
            onPressed: () => _printReport(filtered),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('period_report'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ReportPeriod.values.map((p) {
                return ChoiceChip(
                  label: Text(p.name),
                  selected: _period == p,
                  onSelected: (_) => setState(() => _period = p),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: _pickDate,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _adjustDate(-1),
                            icon: const Icon(Icons.chevron_left),
                            label: Text(_period == ReportPeriod.daily
                                ? 'Yesterday'
                                : 'Previous'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _adjustDate(1),
                            icon: const Icon(Icons.chevron_right),
                            label: Text(_period == ReportPeriod.daily
                                ? 'Tomorrow'
                                : 'Next'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _statCard(
                  loc.translate('orders_count'),
                  filtered.length.toString(),
                  Icons.list_alt,
                  Colors.blue,
                ),
                _statCard(
                  loc.translate('completed'),
                  completedOrders.length.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _statCard(
                  loc.translate('revenue'),
                  '${loc.currencySymbol} ${revenue.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.orange,
                ),
                _statCard(
                  loc.translate('open_orders'),
                  filtered
                      .where((o) =>
                          o.status != OrderStatus.completed &&
                          o.status != OrderStatus.delivered &&
                          o.status != OrderStatus.cancelled)
                      .length
                      .toString(),
                  Icons.build,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (filtered.isNotEmpty)
              Text(
                'Orders in this period',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 8),
            ...filtered.map(
              (o) => Card(
                child: ListTile(
                  title: Text(o.orderNumber),
                  subtitle: Text(
                    '${o.deviceType} - ${o.deviceModel}\n${o.status.label} • ${o.receivedAt.toString().split(' ')[0]}',
                  ),
                  trailing: Text(
                    '${loc.currencySymbol} ${o.laborCost.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  isThreeLine: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 12, color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: color, size: 18),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
