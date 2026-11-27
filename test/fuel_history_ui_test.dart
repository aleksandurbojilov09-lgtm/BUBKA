import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/app/modules/module_availability.dart';
import 'package:garage/app/providers/composition.dart';
import 'package:garage/app/router/router.dart';
import 'package:garage/core/database/database.dart';
import 'package:garage/design_system/theme.dart';
import 'package:garage/features/fuel/fuel.dart';
import 'package:garage/features/garage/garage.dart' hide GarageVehicle;
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'latest three fills, separate complete archive, shared odometer',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final garage = createGarage(db);
      addTearDown(garage.dispose);
      final fuel = createFuel(db);
      final availability = ModuleAvailability(db);
      addTearDown(availability.dispose);
      late int carId;
      final ids = <int>[];
      late int odoId;
      await tester.runAsync(() async {
        await garage.load();
        await availability.load();
        await garage.save(
          const VehicleDraft(
            brand: 'BMW',
            model: '320d',
            registration: 'CA 1001 AB',
          ),
        );
        carId = garage.active!.id;
        for (var i = 0; i < 5; i++) {
          final h = await fuel.save(
            carId,
            FuelDraft(
              date: '2025-01-01',
              odometerKm: 154000 + i * 500,
              fuelMl: 40000,
            ),
          );
          ids.add(h.entries.last.id);
        }
        final h = await fuel.save(
          carId,
          const FuelDraft(date: '2025-01-02', odometerKm: 157000),
        );
        odoId = h.entries.last.id;
      });
      final router = createRouter(
        createRegistry(),
        availability,
        garage: garage,
        fuel: fuel,
      );
      addTearDown(router.dispose);
      router.go('/fuel');
      await tester.pumpWidget(
        MaterialApp.router(theme: BubkaDesign.dark, routerConfig: router),
      );
      final all = find.byKey(const Key('fuel-show-all'));
      for (var i = 0; i < 50 && all.evaluate().isEmpty; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();
      Finder row(int id) => find.byKey(ValueKey('fuel-record-$id'));
      expect(find.text('Добави километраж'), findsNothing);
      expect(find.byKey(const Key('odometer-add')), findsNothing);
      expect(find.text('157000 км'), findsOneWidget);
      for (final id in ids.skip(2)) {
        expect(row(id), findsOneWidget);
      }
      expect(row(ids[0]), findsNothing);
      expect(row(ids[1]), findsNothing);
      expect(row(odoId), findsNothing);
      await tester.ensureVisible(all);
      await tester.pumpAndSettle();
      expect(all.hitTestable(), findsOneWidget);
      await tester.tap(all);
      await tester.pumpAndSettle();
      expect(find.text('История на зарежданията'), findsOneWidget);
      final archive = find.byKey(const Key('fuel-full-history'));
      expect(
        tester.widget<ListView>(archive).childrenDelegate.estimatedChildCount,
        6,
      );
      final scroller = find.descendant(
        of: archive,
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(row(ids[0]), 100, scrollable: scroller);
      expect(row(ids[0]), findsOneWidget);
      await tester.scrollUntilVisible(row(ids[4]), -100, scrollable: scroller);
      final delete = find.descendant(
        of: row(ids[4]),
        matching: find.text('Изтрий'),
      );
      await tester.ensureVisible(delete);
      await tester.tap(delete);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Изтрий окончателно'));
      for (
        var i = 0;
        i < 50 &&
            tester
                    .widget<ListView>(archive)
                    .childrenDelegate
                    .estimatedChildCount !=
                5;
        i++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(
        tester.widget<ListView>(archive).childrenDelegate.estimatedChildCount,
        5,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(row(ids[1]), findsOneWidget);
      expect(row(ids[4]), findsNothing);
      expect(await tester.runAsync(() => fuel.latestOdometerKm(carId)), 157000);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
