import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/item.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/empty_state.dart';
import 'item_form_screen.dart';
import 'item_detail_screen.dart';

class InventoryListScreen extends StatelessWidget {
  const InventoryListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final inv = context.watch<InventoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('inventory')),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) => inv.setCategoryFilter(v),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: null,
                child: Text(loc.translate('category')),
              ),
              ...inv.categories.map(
                (c) => PopupMenuItem(
                  value: c,
                  child: Text(c),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: loc.translate('search_items'),
              ),
              onChanged: (v) => inv.setSearch(v),
            ),
          ),
          if (inv.categoryFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Chip(
                label: Text(inv.categoryFilter!),
                onDeleted: () => inv.setCategoryFilter(null),
              ),
            ),
          Expanded(
            child: inv.items.isEmpty
                ? EmptyState(
                    icon: Icons.inventory_2,
                    message: loc.translate('no_items'),
                    actionLabel: loc.translate('add_item'),
                    onAction: () => _openForm(context),
                  )
                : ListView.builder(
                    itemCount: inv.items.length,
                    itemBuilder: (context, idx) {
                      final item = inv.items[idx];
                      return _ItemTile(item: item);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: Text(loc.translate('add_item')),
      ),
    );
  }

  void _openForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ItemFormScreen()),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final Item item;
  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final inv = context.read<InventoryProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ItemDetailScreen(itemId: item.id!),
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: item.isLowStock
              ? Colors.orange.shade100
              : Colors.blue.shade100,
          child: Icon(
            item.isLowStock ? Icons.warning : Icons.inventory_2,
            color: item.isLowStock ? Colors.orange : Colors.blue,
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${loc.translate('sku')}: ${item.sku}'),
            Text(
              '${loc.translate('category')}: ${item.category}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            Text(
              '${loc.currencySymbol} ${item.salePrice.toStringAsFixed(2)} • ${loc.translate('quantity')}: ${item.quantity}',
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            if (v == 'edit') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ItemFormScreen(item: item),
                ),
              );
            } else if (v == 'delete') {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  content: Text(loc.translate('confirm_delete_item')),
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
              if (ok == true) await inv.deleteItem(item.id!);
            } else if (v == 'print') {
              // Print label - handled via detail screen for now
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(value: 'edit', child: Text(loc.translate('edit_item'))),
            PopupMenuItem(value: 'delete', child: Text(loc.translate('delete'))),
          ],
        ),
      ),
    );
  }
}
