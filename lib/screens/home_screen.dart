import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/stat_card.dart';
import 'inventory/inventory_list_screen.dart';
import 'customers/customer_list_screen.dart';
import 'orders/order_list_screen.dart';
import 'reports/reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _DashboardTab(),
    InventoryListScreen(),
    OrderListScreen(),
    CustomerListScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: loc.translate('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            label: loc.translate('inventory'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.build_outlined),
            selectedIcon: const Icon(Icons.build),
            label: loc.translate('orders'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outlined),
            selectedIcon: const Icon(Icons.people),
            label: loc.translate('customers'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.assessment_outlined),
            selectedIcon: const Icon(Icons.assessment),
            label: loc.translate('reports'),
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final inv = context.watch<InventoryProvider>();
    final cust = context.watch<CustomerProvider>();
    final orders = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('app_name')),
        actions: [
          IconButton(
            tooltip: loc.translate('language'),
            icon: Text(
              settings.locale.languageCode == 'en' ? 'AR' : 'EN',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            onPressed: () => settings.toggleLocale(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await inv.loadItems();
          await cust.loadCustomers();
          await orders.loadOrders();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate('dashboard'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  StatCard(
                    title: loc.translate('total_items'),
                    value: '${inv.totalCount}',
                    icon: Icons.inventory_2,
                    color: Colors.blue,
                  ),
                  StatCard(
                    title: loc.translate('low_stock_items'),
                    value: '${inv.lowStockItems.length}',
                    icon: Icons.warning_amber,
                    color: Colors.orange,
                  ),
                  StatCard(
                    title: loc.translate('open_orders'),
                    value: '${orders.openCount}',
                    icon: Icons.build,
                    color: Colors.purple,
                  ),
                  StatCard(
                    title: loc.translate('total_customers'),
                    value: '${cust.totalCount}',
                    icon: Icons.people,
                    color: Colors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade400,
                      Colors.green.shade700,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.translate('total_revenue'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${loc.currencySymbol} ${orders.totalRevenue.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (inv.lowStockItems.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      loc.translate('low_stock_alert'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...inv.lowStockItems.take(5).map(
                      (i) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.warning, color: Colors.orange),
                          title: Text(i.name),
                          subtitle: Text(
                            '${loc.translate('quantity')}: ${i.quantity}',
                          ),
                          trailing: Text(
                            i.sku,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
