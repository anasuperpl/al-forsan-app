import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/customer.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/empty_state.dart';
import 'customer_form_screen.dart';

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final customers = context.watch<CustomerProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('customers'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: loc.translate('search_customers'),
              ),
              onChanged: (v) => customers.setSearch(v),
            ),
          ),
          Expanded(
            child: customers.customers.isEmpty
                ? EmptyState(
                    icon: Icons.people,
                    message: loc.translate('no_customers'),
                    actionLabel: loc.translate('add_customer'),
                    onAction: () => _openForm(context),
                  )
                : ListView.builder(
                    itemCount: customers.customers.length,
                    itemBuilder: (context, idx) {
                      final c = customers.customers[idx];
                      return _CustomerTile(customer: c);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: Text(loc.translate('add_customer')),
      ),
    );
  }

  void _openForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  final Customer customer;
  const _CustomerTile({required this.customer});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final prov = context.read<CustomerProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade100,
          child: Text(
            customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.phone, size: 14),
                const SizedBox(width: 4),
                Text(customer.phone),
              ],
            ),
            if (customer.email != null && customer.email!.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.email, size: 14),
                  const SizedBox(width: 4),
                  Text(customer.email!),
                ],
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CustomerFormScreen(customer: customer),
            ),
          ),
        ),
        onLongPress: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('${loc.translate('delete')}?'),
              content: Text(customer.name),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(loc.translate('no')),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(loc.translate('yes')),
                ),
              ],
            ),
          );
          if (ok == true) await prov.deleteCustomer(customer.id!);
        },
      ),
    );
  }
}
