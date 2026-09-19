import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/maintenance_order.dart';
import '../../providers/order_provider.dart';
import '../../widgets/empty_state.dart';
import 'order_form_screen.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final orders = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('orders'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: loc.translate('search_orders'),
              ),
              onChanged: (v) => orders.setSearch(v),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _filterChip(context, null, loc.translate('all')),
                ...OrderStatus.values.map(
                  (s) => _filterChip(context, s, s.label),
                ),
              ],
            ),
          ),
          Expanded(
            child: orders.orders.isEmpty
                ? EmptyState(
                    icon: Icons.build,
                    message: loc.translate('no_orders'),
                    actionLabel: loc.translate('add_order'),
                    onAction: () => _openForm(context),
                  )
                : RefreshIndicator(
                    onRefresh: () => orders.loadOrders(),
                    child: ListView.builder(
                      itemCount: orders.orders.length,
                      itemBuilder: (context, idx) {
                        final o = orders.orders[idx];
                        return _OrderTile(order: o);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: Text(loc.translate('add_order')),
      ),
    );
  }

  Widget _filterChip(BuildContext context, OrderStatus? status, String label) {
    final orders = context.watch<OrderProvider>();
    final selected = orders.statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => orders.setStatusFilter(status),
      ),
    );
  }

  void _openForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OrderFormScreen()),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final MaintenanceOrder order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: order.id!),
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: _statusColor(order.status).withOpacity(0.2),
          child: Icon(Icons.build, color: _statusColor(order.status)),
        ),
        title: Text(
          order.orderNumber,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${order.deviceType} - ${order.deviceModel}'),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: _statusColor(order.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                order.status.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _statusColor(order.status),
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(orderId: order.id!),
            ),
          ),
        ),
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
