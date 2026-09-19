import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/item.dart';
import '../../providers/inventory_provider.dart';
import '../../services/label_service.dart';
import 'item_form_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final int itemId;
  const ItemDetailScreen({Key? key, required this.itemId}) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  Item? _item;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    final inv = context.read<InventoryProvider>();
    final item = await inv.getItem(widget.itemId);
    if (mounted) setState(() => _item = item);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_item == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final item = _item!;
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          IconButton(
            tooltip: loc.translate('print_label'),
            icon: const Icon(Icons.print),
            onPressed: () => LabelService.printLabel(item),
          ),
          IconButton(
            tooltip: loc.translate('edit'),
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ItemFormScreen(item: item),
                ),
              );
              await _loadItem();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: item.isLowStock ? Colors.orange.shade50 : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: item.isLowStock
                          ? Colors.orange.shade100
                          : Colors.blue.shade100,
                      child: Icon(
                        item.isLowStock
                            ? Icons.warning_amber
                            : Icons.inventory_2,
                        size: 32,
                        color: item.isLowStock ? Colors.orange : Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.isLowStock
                                ? loc.translate('low_stock')
                                : loc.translate('in_stock'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: item.isLowStock
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ),
                          Text(
                            '${loc.translate('quantity')}: ${item.quantity}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _infoTile(loc.translate('sku'), item.sku, icon: Icons.qr_code),
            _infoTile(loc.translate('category'), item.category, icon: Icons.category),
            _infoTile(
              '${loc.translate('purchase_price')}: ${loc.currencySymbol} ${item.purchasePrice.toStringAsFixed(2)}',
              '',
              icon: Icons.shopping_cart,
            ),
            _infoTile(
              '${loc.translate('sale_price')}: ${loc.currencySymbol} ${item.salePrice.toStringAsFixed(2)}',
              '',
              icon: Icons.attach_money,
            ),
            _infoTile(
              '${loc.translate('profit_margin')}: ${item.profitMargin.toStringAsFixed(1)}%',
              '',
              icon: Icons.trending_up,
            ),
            _infoTile(
              '${loc.translate('min_stock')}: ${item.minStock}',
              '',
              icon: Icons.warning_amber,
            ),
            if (item.description != null && item.description!.isNotEmpty)
              _infoTile(loc.translate('description'), item.description!,
                  icon: Icons.notes),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final inv = context.read<InventoryProvider>();
                      await inv.adjustStock(item.id!, 1);
                      await _loadItem();
                    },
                    icon: const Icon(Icons.add),
                    label: Text('+1 ${loc.translate('quantity')}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final inv = context.read<InventoryProvider>();
                      await inv.adjustStock(item.id!, -1);
                      await _loadItem();
                    },
                    icon: const Icon(Icons.remove),
                    label: Text('-1 ${loc.translate('quantity')}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String subtitle, {IconData? icon}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: icon != null
            ? Icon(icon, color: Theme.of(context).primaryColor)
            : null,
        title: Text(title),
        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      ),
    );
  }
}
