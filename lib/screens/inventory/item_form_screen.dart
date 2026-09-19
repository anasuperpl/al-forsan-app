import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../../models/item.dart';
import '../../providers/inventory_provider.dart';

class ItemFormScreen extends StatefulWidget {
  final Item? item;
  const ItemFormScreen({Key? key, this.item}) : super(key: key);

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _skuCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _purchaseCtrl;
  late final TextEditingController _saleCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _minStockCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    _skuCtrl = TextEditingController(text: i?.sku ?? '');
    _nameCtrl = TextEditingController(text: i?.name ?? '');
    _categoryCtrl = TextEditingController(text: i?.category ?? '');
    _purchaseCtrl =
        TextEditingController(text: i?.purchasePrice.toString() ?? '');
    _saleCtrl = TextEditingController(text: i?.salePrice.toString() ?? '');
    _quantityCtrl = TextEditingController(text: i?.quantity.toString() ?? '0');
    _minStockCtrl = TextEditingController(text: i?.minStock.toString() ?? '0');
    _descCtrl = TextEditingController(text: i?.description ?? '');
  }

  @override
  void dispose() {
    _skuCtrl.dispose();
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _purchaseCtrl.dispose();
    _saleCtrl.dispose();
    _quantityCtrl.dispose();
    _minStockCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isEdit = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit
            ? loc.translate('edit_item')
            : loc.translate('add_item')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _skuCtrl,
                decoration: InputDecoration(
                  labelText: loc.translate('sku'),
                  prefixIcon: const Icon(Icons.qr_code),
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? loc.translate('required_field')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: loc.translate('item_name'),
                  prefixIcon: const Icon(Icons.label),
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? loc.translate('required_field')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryCtrl,
                decoration: InputDecoration(
                  labelText: loc.translate('category'),
                  prefixIcon: const Icon(Icons.category),
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? loc.translate('required_field')
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _purchaseCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: loc.translate('purchase_price'),
                        prefixIcon: const Icon(Icons.shopping_cart),
                      ),
                      validator: _validateNumber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _saleCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: loc.translate('sale_price'),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      validator: _validateNumber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: loc.translate('quantity'),
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                      validator: _validateNumber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _minStockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: loc.translate('min_stock'),
                        prefixIcon: const Icon(Icons.warning_amber),
                      ),
                      validator: _validateNumber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: loc.translate('description'),
                  prefixIcon: const Icon(Icons.notes),
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

  String? _validateNumber(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    if (double.tryParse(v) == null) return 'Invalid';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final inv = context.read<InventoryProvider>();
    final now = DateTime.now();
    final isEdit = widget.item != null;

    final item = Item(
      id: widget.item?.id,
      sku: _skuCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      category: _categoryCtrl.text.trim(),
      purchasePrice: double.parse(_purchaseCtrl.text),
      salePrice: double.parse(_saleCtrl.text),
      quantity: int.parse(_quantityCtrl.text),
      minStock: int.parse(_minStockCtrl.text),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      createdAt: widget.item?.createdAt ?? now,
      updatedAt: now,
    );

    if (isEdit) {
      await inv.updateItem(item);
    } else {
      await inv.addItem(item);
    }
    if (mounted) Navigator.pop(context);
  }
}
