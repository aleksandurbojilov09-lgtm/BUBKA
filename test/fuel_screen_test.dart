import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/app/modules/module_availability.dart';
import 'package:garage/app/providers/composition.dart';
import 'package:garage/app/router/router.dart';
import 'package:garage/core/database/database.dart';
import 'package:garage/design_system/theme.dart';
import 'package:garage/features/garage/garage.dart' hide GarageVehicle;
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'real fuel route, empty garage, narrow enlarged form saves active car',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final garage = createGarage(db);
      addTearDown(garage.dispose);
      final fuel = createFuel(db);
      final availability = ModuleAvailability(db);
      addTearDown(availability.dispose);
      await tester.runAsync(() async {
        await garage.load();
        await availability.load();
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
      await tester.pumpAndSettle();
      final garageButton = find.text('Към гаража');
      await tester.scrollUntilVisible(
        garageButton,
        100,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.ensureVisible(garageButton);
      await tester.pumpAndSettle();
      expect(garageButton.hitTestable(), findsOneWidget);
      await tester.tap(garageButton);
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/garage');
      router.go('/fuel');
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await garage.save(
          const VehicleDraft(
            brand: 'BMW',
            model: '320d',
            registration: 'CA 1001 AB',
          ),
        );
      });
      for (
        var i = 0;
        i < 30 && find.byKey(const Key('fuel-add')).evaluate().isEmpty;
        i++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();
      final add = find.byKey(const Key('fuel-add'));
      final scroller = find.descendant(
        of: find.byType(ListView),
        matching: find.byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        ),
      );
      await tester.scrollUntilVisible(add, 100, scrollable: scroller.first);
      await tester.ensureVisible(add);
      await tester.pumpAndSettle();
      expect(add.hitTestable(), findsOneWidget);
      await tester.tap(add);
      await tester.pumpAndSettle();
      final litres = find.byKey(const Key('fuel-litres'));
      await tester.ensureVisible(litres);
      await tester.enterText(litres, '40');
      final km = find.byKey(const Key('fuel-km'));
      await tester.ensureVisible(km);
      await tester.enterText(km, '154000');
      foundation.debugPrint('BUBKA-006: narrow fuel form actual hit test');
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      final save = find.byKey(const Key('fuel-save'));
      await tester.scrollUntilVisible(
        save,
        100,
        scrollable: find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            )
            .last,
      );
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      expect(save.hitTestable(), findsOneWidget);
      await tester.tap(save);
      for (
        var i = 0;
        i < 30 && find.byKey(const Key('fuel-save')).evaluate().isNotEmpty;
        i++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(
        await tester.runAsync(() => fuel.latestOdometerKm(garage.active!.id)),
        154000,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
