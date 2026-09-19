import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:al_forsan/widgets/stat_card.dart';
import 'package:al_forsan/widgets/empty_state.dart';

void main() {
  group('StatCard Widget', () {
    testWidgets('renders title and value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              title: 'Total Items',
              value: '42',
              icon: Icons.inventory_2,
              color: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('Total Items'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2), findsOneWidget);
    });

    testWidgets('responds to tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              title: 'Tap me',
              value: 'X',
              icon: Icons.touch_app,
              color: Colors.red,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(StatCard));
      await tester.pump();
      expect(tapped, true);
    });
  });

  group('EmptyState Widget', () {
    testWidgets('renders message and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              message: 'Nothing here',
            ),
          ),
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('shows action button when provided', (tester) async {
      var acted = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.add,
              message: 'Empty',
              actionLabel: 'Add New',
              onAction: () => acted = true,
            ),
          ),
        ),
      );

      expect(find.text('Add New'), findsOneWidget);
      await tester.tap(find.text('Add New'));
      await tester.pump();
      expect(acted, true);
    });
  });
}
