import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:al_forsan/l10n/app_localizations.dart';

void main() {
  group('Localization', () {
    test('should translate to English', () {
      final loc = AppLocalizations(const Locale('en'));
      expect(loc.translate('inventory'), 'Inventory');
      expect(loc.translate('orders'), 'Orders');
      expect(loc.translate('customers'), 'Customers');
      expect(loc.translate('currency_symbol'), '₪');
    });

    test('should translate to Arabic', () {
      final loc = AppLocalizations(const Locale('ar'));
      expect(loc.translate('inventory'), 'المخزن');
      expect(loc.translate('orders'), 'أوامر الصيانة');
      expect(loc.translate('customers'), 'الزبائن');
      expect(loc.translate('currency_symbol'), '₪');
    });

    test('should fall back to English for unknown key in unknown locale', () {
      final loc = AppLocalizations(const Locale('en'));
      expect(loc.translate('unknown_key'), 'unknown_key');
    });

    test('should support both English and Arabic locales', () {
      expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
      expect(AppLocalizations.supportedLocales, contains(const Locale('ar')));
    });

    test('all critical keys should be present in both languages', () {
      final en = AppLocalizations(const Locale('en'));
      final ar = AppLocalizations(const Locale('ar'));

      final keys = [
        'app_name', 'inventory', 'orders', 'customers', 'reports',
        'add_item', 'edit_item', 'add_customer', 'add_order',
        'save', 'cancel', 'delete', 'edit',
        'item_name', 'sku', 'category', 'quantity',
        'customer_name', 'phone', 'order_number',
      ];

      for (final key in keys) {
        expect(en.translate(key), isNotEmpty, reason: 'EN missing: $key');
        expect(ar.translate(key), isNotEmpty, reason: 'AR missing: $key');
      }
    });
  });
}
