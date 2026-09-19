import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Al-Forsan',
      // Navigation
      'home': 'Home',
      'inventory': 'Inventory',
      'orders': 'Orders',
      'customers': 'Customers',
      'reports': 'Reports',
      'settings': 'Settings',
      'language': 'Language',
      // Dashboard
      'dashboard': 'Dashboard',
      'total_items': 'Total Items',
      'low_stock_items': 'Low Stock Items',
      'open_orders': 'Open Orders',
      'total_customers': 'Total Customers',
      'total_revenue': 'Total Revenue',
      'recent_orders': 'Recent Orders',
      'low_stock_alert': 'Low Stock Alert',
      // Inventory
      'add_item': 'Add Item',
      'edit_item': 'Edit Item',
      'item_name': 'Item Name',
      'sku': 'SKU',
      'category': 'Category',
      'purchase_price': 'Purchase Price',
      'sale_price': 'Sale Price',
      'quantity': 'Quantity',
      'min_stock': 'Min Stock',
      'description': 'Description',
      'search_items': 'Search items...',
      'no_items': 'No items yet. Add your first item!',
      'confirm_delete_item': 'Are you sure you want to delete this item?',
      'print_label': 'Print Label',
      'profit_margin': 'Profit Margin',
      'stock_status': 'Stock Status',
      'in_stock': 'In Stock',
      'low_stock': 'Low Stock',
      'out_of_stock': 'Out of Stock',
      // Customers
      'add_customer': 'Add Customer',
      'edit_customer': 'Edit Customer',
      'customer_name': 'Customer Name',
      'phone': 'Phone',
      'email': 'Email',
      'address': 'Address',
      'notes': 'Notes',
      'search_customers': 'Search customers...',
      'no_customers': 'No customers yet.',
      'customer_history': 'Customer History',
      // Orders
      'add_order': 'Add Order',
      'edit_order': 'Edit Order',
      'order_number': 'Order Number',
      'device_type': 'Device Type',
      'device_model': 'Device Model',
      'serial_number': 'Serial Number',
      'problem_description': 'Problem Description',
      'diagnosis': 'Diagnosis',
      'status': 'Status',
      'labor_cost': 'Labor Cost',
      'received_at': 'Received At',
      'completed_at': 'Completed At',
      'delivered_at': 'Delivered At',
      'select_customer': 'Select Customer',
      'select_item': 'Select Item',
      'qty': 'Qty',
      'price': 'Price',
      'subtotal': 'Subtotal',
      'parts_used': 'Parts Used',
      'add_part': 'Add Part',
      'total_cost': 'Total Cost',
      'pending': 'Pending',
      'in_progress': 'In Progress',
      'waiting_parts': 'Waiting Parts',
      'completed': 'Completed',
      'delivered': 'Delivered',
      'cancelled': 'Cancelled',
      'search_orders': 'Search orders...',
      'no_orders': 'No maintenance orders yet.',
      'print_report': 'Print Report',
      'mark_completed': 'Mark as Completed',
      'mark_delivered': 'Mark as Delivered',
      // Reports
      'period_report': 'Period Report',
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'orders_count': 'Orders Count',
      'parts_consumed': 'Parts Consumed',
      'revenue': 'Revenue',
      'generate': 'Generate',
      'print': 'Print',
      'preview': 'Preview',
      // Actions
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'search': 'Search',
      'add': 'Add',
      'update': 'Update',
      'close': 'Close',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      // Validation
      'required_field': 'This field is required',
      'invalid_number': 'Please enter a valid number',
      // Currency
      'currency_symbol': '₪',
    },
    'ar': {
      'app_name': 'الفرسان',
      // Navigation
      'home': 'الرئيسية',
      'inventory': 'المخزن',
      'orders': 'أوامر الصيانة',
      'customers': 'الزبائن',
      'reports': 'التقارير',
      'settings': 'الإعدادات',
      'language': 'اللغة',
      // Dashboard
      'dashboard': 'لوحة التحكم',
      'total_items': 'إجمالي الأصناف',
      'low_stock_items': 'أصناف تحت الحد الأدنى',
      'open_orders': 'أوامر مفتوحة',
      'total_customers': 'إجمالي الزبائن',
      'total_revenue': 'إجمالي الإيرادات',
      'recent_orders': 'أحدث الأوامر',
      'low_stock_alert': 'تنبيه: نقص في المخزون',
      // Inventory
      'add_item': 'إضافة صنف',
      'edit_item': 'تعديل الصنف',
      'item_name': 'اسم الصنف',
      'sku': 'الكود',
      'category': 'الفئة',
      'purchase_price': 'سعر الشراء',
      'sale_price': 'سعر البيع',
      'quantity': 'الكمية',
      'min_stock': 'الحد الأدنى',
      'description': 'الوصف',
      'search_items': 'بحث عن صنف...',
      'no_items': 'لا توجد أصناف بعد. أضف أول صنف!',
      'confirm_delete_item': 'هل أنت متأكد من حذف هذا الصنف؟',
      'print_label': 'طباعة ليبل',
      'profit_margin': 'هامش الربح',
      'stock_status': 'حالة المخزون',
      'in_stock': 'متوفر',
      'low_stock': 'كمية قليلة',
      'out_of_stock': 'نفد المخزون',
      // Customers
      'add_customer': 'إضافة زبون',
      'edit_customer': 'تعديل الزبون',
      'customer_name': 'اسم الزبون',
      'phone': 'الهاتف',
      'email': 'البريد الإلكتروني',
      'address': 'العنوان',
      'notes': 'ملاحظات',
      'search_customers': 'بحث عن زبون...',
      'no_customers': 'لا يوجد زبائن بعد.',
      'customer_history': 'سجل الزبون',
      // Orders
      'add_order': 'إضافة أمر صيانة',
      'edit_order': 'تعديل أمر الصيانة',
      'order_number': 'رقم الأمر',
      'device_type': 'نوع الجهاز',
      'device_model': 'موديل الجهاز',
      'serial_number': 'الرقم التسلسلي',
      'problem_description': 'وصف المشكلة',
      'diagnosis': 'التشخيص',
      'status': 'الحالة',
      'labor_cost': 'تكلفة العمل',
      'received_at': 'تاريخ الاستلام',
      'completed_at': 'تاريخ الإكمال',
      'delivered_at': 'تاريخ التسليم',
      'select_customer': 'اختر الزبون',
      'select_item': 'اختر الصنف',
      'qty': 'الكمية',
      'price': 'السعر',
      'subtotal': 'المجموع',
      'parts_used': 'القطع المستخدمة',
      'add_part': 'إضافة قطعة',
      'total_cost': 'التكلفة الإجمالية',
      'pending': 'قيد الانتظار',
      'in_progress': 'قيد التنفيذ',
      'waiting_parts': 'بانتظار قطع',
      'completed': 'مكتمل',
      'delivered': 'مُسلَّم',
      'cancelled': 'ملغي',
      'search_orders': 'بحث عن أمر...',
      'no_orders': 'لا توجد أوامر صيانة بعد.',
      'print_report': 'طباعة تقرير',
      'mark_completed': 'وضع كمكتمل',
      'mark_delivered': 'وضع كمُسلَّم',
      // Reports
      'period_report': 'تقرير فترة',
      'daily': 'يومي',
      'weekly': 'أسبوعي',
      'monthly': 'شهري',
      'orders_count': 'عدد الأوامر',
      'parts_consumed': 'قطع مستهلكة',
      'revenue': 'الإيرادات',
      'generate': 'إنشاء',
      'print': 'طباعة',
      'preview': 'معاينة',
      // Actions
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'edit': 'تعديل',
      'search': 'بحث',
      'add': 'إضافة',
      'update': 'تحديث',
      'close': 'إغلاق',
      'yes': 'نعم',
      'no': 'لا',
      'ok': 'موافق',
      // Validation
      'required_field': 'هذا الحقل مطلوب',
      'invalid_number': 'يرجى إدخال رقم صحيح',
      // Currency
      'currency_symbol': '₪',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }

  // Convenience getters
  String get appName => translate('app_name');
  String get currencySymbol => translate('currency_symbol');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
