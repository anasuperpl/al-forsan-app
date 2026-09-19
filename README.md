# 🎯 Al-Forsan (الفرسان)

A complete Flutter mobile application for **spare parts inventory management**, **maintenance service tracking**, **customer management**, and **label/report printing**.

## ✨ Features

### 📦 Spare Parts Inventory
- Full CRUD for items (SKU, name, category, prices, quantity, min stock)
- Search & filter by category / SKU / name
- Low stock alerts
- Multi-language UI (English + Arabic)
- Currency: Israeli Shekel (₪)

### 🏷️ Label Printing (10cm × 5cm)
- Code128 barcode + QR-ready
- Item name, price, SKU, date
- Compatible with thermal printers (Xprinter, etc.)
- Batch printing supported

### 📄 Maintenance Reports (PDF)
- Single order report (A4): customer info, device, parts used, costs
- Period report (daily / weekly / monthly): summary + table
- Revenue calculations

### 🛠️ Maintenance Orders
- 6 statuses: Pending, In Progress, Waiting Parts, Completed, Delivered, Cancelled
- Auto order numbers (ORD-2025-00001…)
- Add parts from inventory (auto-deducts stock)
- Labor cost + parts cost = grand total

### 👥 Customer Management
- Add / edit / delete customers
- Phone, email, address, notes
- Search by name or phone

### 🌐 Localization
- Full English + Arabic translations
- One-tap toggle in the app bar
- RTL support for Arabic

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.10+ |
| Language | Dart 3.0+ |
| State Management | Provider |
| Database | SQLite (sqflite) - local, offline-first |
| PDF | pdf + printing |
| Barcode | barcode_widget |
| Localization | Custom + flutter_localizations |
| Settings | shared_preferences |

## 📁 Project Structure

```
al-forsan-app/
├── lib/
│   ├── main.dart                          # App entry, providers, theme
│   ├── l10n/
│   │   └── app_localizations.dart         # EN + AR translations (100+ keys)
│   ├── database/
│   │   └── database_helper.dart           # SQLite schema
│   ├── models/
│   │   ├── item.dart                      # Spare part
│   │   ├── customer.dart                  # Customer
│   │   ├── maintenance_order.dart         # Service order
│   │   └── order_part.dart                # Part linked to order
│   ├── providers/
│   │   ├── settings_provider.dart         # Language toggle
│   │   ├── inventory_provider.dart        # Items CRUD
│   │   ├── customer_provider.dart         # Customers CRUD
│   │   └── order_provider.dart            # Orders + parts
│   ├── services/
│   │   ├── label_service.dart             # 10×5cm label printing
│   │   └── report_service.dart            # Order / period reports
│   ├── screens/
│   │   ├── home_screen.dart               # Dashboard + tabs
│   │   ├── inventory/                     # 3 screens
│   │   ├── customers/                     # 2 screens
│   │   ├── orders/                        # 3 screens
│   │   └── reports/                       # 1 screen
│   └── widgets/
│       ├── stat_card.dart
│       └── empty_state.dart
├── test/
│   ├── models_test.dart                   # Model serialization + logic
│   ├── localization_test.dart             # EN/AR coverage
│   └── widget_test.dart                   # UI smoke tests
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >= 3.10
- Dart >= 3.0
- Android Studio / VS Code
- Android device or emulator (Android 5.0+)

### Install & Run

```bash
# 1. Navigate to project
cd al-forsan-app

# 2. Install dependencies
flutter pub get

# 3. Run on connected device / emulator
flutter run

# 4. (Optional) Run tests
flutter test

# 5. Build release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## 📱 Build Variants

### Android APK (release)
```bash
flutter build apk --release
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🖨️ Printer Compatibility

The app uses `printing` package which works with:
- ✅ Android system print (any printer paired/served)
- ✅ iOS AirPrint
- ✅ Save as PDF (default preview option)
- ✅ Network thermal printers via Android print spooler
- ✅ Xprinter, Epson, Star thermal printers

## 🧪 Testing

```bash
flutter test
```

Test coverage includes:
- Model serialization round-trips
- Profit margin / low stock calculations
- EN/AR translation completeness
- Widget smoke tests (stat cards, empty states)

## 📐 Database Schema

```
items (
  id, sku, name, category,
  purchase_price, sale_price,
  quantity, min_stock, description,
  created_at, updated_at
)

customers (
  id, name, phone, email, address, notes,
  created_at
)

maintenance_orders (
  id, order_number, customer_id,
  device_type, device_model, serial_number,
  problem_description, diagnosis, notes,
  status, labor_cost,
  received_at, completed_at, delivered_at,
  created_at, updated_at
)

order_parts (
  id, order_id, item_id, item_name, item_sku,
  quantity, unit_price,
  created_at
)
```

## 🌍 Localization Strategy

All UI strings live in `lib/l10n/app_localizations.dart`:
- A `_localizedValues` Map keyed by language code
- `translate(key)` for lookup with EN fallback
- Toggle via settings provider (persisted in shared_preferences)

To add a third language, copy one of the maps and add to `_localizedValues`.

## 📄 License

MIT - free for commercial & personal use.

## 🙌 Support

For issues, feature requests, or contributions, just message the agent.
