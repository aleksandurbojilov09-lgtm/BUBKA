import 'package:garage/design_system/cockpit_assets.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/app/modules/module_availability.dart';
import 'package:garage/app/providers/composition.dart';
import 'package:garage/app/router/router.dart';
import 'package:garage/core/database/database.dart';
import 'package:garage/design_system/theme.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'a direct route skips ignition; returning home does not replay it',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final availability = ModuleAvailability(db);
      addTearDown(availability.dispose);
      final router = createRouter(createRegistry(), availability);
      addTearDown(router.dispose);
      router.go('/stats');
      await tester.pumpWidget(
        MaterialApp.router(theme: BubkaDesign.dark, routerConfig: router),
      );
      await tester.pumpAndSettle();
      expect(find.text('Няма данни'), findsOneWidget);
      expect(find.byType(CockpitWordmark), findsNothing);
      router.go('/');
      await tester.pumpAndSettle();
      expect(find.byType(CockpitWordmark), findsOneWidget);
      expect(tester.binding.transientCallbackCount, 0);
      expect(find.text('DEMO 01'), findsNothing);
      router.go('/visual-review');
      await tester.pumpAndSettle();
      expect(find.text('Непознат екран'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'production home and garage never use demo fixtures even with preview enabled',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final availability = ModuleAvailability(db);
      addTearDown(availability.dispose);
      final router = createRouter(
        createRegistry(),
        availability,
        testingPreview: true,
      );
      addTearDown(router.dispose);
      router.go('/garage');
      await tester.pumpWidget(
        MaterialApp.router(theme: BubkaDesign.dark, routerConfig: router),
      );
      await tester.pumpAndSettle();
      expect(find.text('Гаражът е празен'), findsOneWidget);
      expect(find.text('BMW 320d'), findsNothing);
      expect(find.text('Toyota Corolla'), findsNothing);
      expect(find.textContaining('DEMO'), findsNothing);
      router.go('/');
      await tester.pumpAndSettle();
      expect(find.text('Няма добавен автомобил'), findsOneWidget);
      expect(find.text('Няма данни'), findsOneWidget);
      expect(find.textContaining('DEMO'), findsNothing);
      expect(find.text('14 дни'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
