import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/app/modules/module_availability.dart';
import 'package:garage/app/providers/composition.dart';
import 'package:garage/app/router/router.dart';
import 'package:garage/core/database/database.dart';
import 'package:garage/design_system/theme.dart';
import 'package:garage/features/garage/garage.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('real router, form, catalog and active vehicle home', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final vm = createGarage(db);
    addTearDown(vm.dispose);
    final availability = ModuleAvailability(db);
    addTearDown(availability.dispose);
    await tester.runAsync(() async {
      await vm.load();
      await availability.load();
    });
    final router = createRouter(createRegistry(), availability, garage: vm);
    addTearDown(router.dispose);
    router.go('/garage');
    await tester.pumpWidget(
      MaterialApp.router(theme: BubkaDesign.dark, routerConfig: router),
    );
    await tester.pumpAndSettle();
    expect(find.text('Гаражът е празен'), findsOneWidget);
    await tester.tap(find.text('Добави автомобил'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Запази'));
    await tester.pumpAndSettle();
    expect(find.text('Задължително поле'), findsWidgets);
    await tester.tap(find.byTooltip('Избери Марка от списък'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('BMW'));
    await tester.tap(find.text('BMW'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Избери Модел от списък'));
    await tester.pumpAndSettle();
    expect(find.text('Golf'), findsNothing);
    await tester.ensureVisible(find.text('320d'));
    await tester.tap(find.text('320d'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('Регистрационен номер')),
      'DE AB 123',
    );
    await tester.tap(find.text('Запази'));
    for (var i = 0; i < 50 && vm.active == null; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(vm.active!.name, 'BMW 320d');
    expect(find.text('BMW 320d'), findsOneWidget);
    await tester.tap(find.text('Изтрий'));
    await tester.pumpAndSettle();
    expect(find.textContaining('необратимо'), findsOneWidget);
    expect(find.textContaining('DE AB 123'), findsWidgets);
    await tester.tap(find.text('Отказ'));
    await tester.pumpAndSettle();
    expect(vm.snapshot!.vehicles, hasLength(1));
    await tester.runAsync(
      () => vm.save(
        const VehicleDraft(
          brand: 'Custom',
          model: 'Other',
          registration: 'XY 987',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(vm.active!.name, 'BMW 320d');
    final second = vm.snapshot!.vehicles.last.id;
    await tester.runAsync(() => vm.select(second));
    await tester.pumpAndSettle();
    router.go('/');
    await tester.pumpAndSettle();
    expect(find.text('Custom Other'), findsOneWidget);
    expect(find.text('BMW 320d'), findsNothing);
    expect(find.textContaining('DEMO'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('real garage and form at narrow width and large text', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final vm = createGarage(db);
    addTearDown(vm.dispose);
    final availability = ModuleAvailability(db);
    addTearDown(availability.dispose);
    await tester.runAsync(() async {
      await vm.load();
      await availability.load();
    });
    final router = createRouter(createRegistry(), availability, garage: vm);
    addTearDown(router.dispose);
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    router.go('/garage');
    await tester.pumpWidget(
      MaterialApp.router(
        theme: BubkaDesign.dark,
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final garageScroll = find.descendant(
      of: find.byType(ListView),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    expect(garageScroll, findsOneWidget);
    final addButton = find.descendant(
      of: find.byKey(const Key('v4-add')),
      matching: find.byType(OutlinedButton),
    );
    try {
      await tester.scrollUntilVisible(addButton, 100, scrollable: garageScroll);
      await tester.pumpAndSettle();
      await Scrollable.ensureVisible(tester.element(addButton), alignment: 0.5);
      await tester.pumpAndSettle();
    } finally {
      final viewport = tester.getRect(garageScroll);
      final position = tester.state<ScrollableState>(garageScroll).position;
      foundation.debugPrint(
        'GARAGE_DIAG viewport=$viewport scroll=${position.pixels}/${position.maxScrollExtent}',
      );
      if (addButton.evaluate().length == 1) {
        final rect = tester.getRect(addButton);
        final enabled =
            tester.widget<OutlinedButton>(addButton).onPressed != null;
        final hits = tester.hitTestOnBinding(rect.center).path.toList();
        final render = tester.renderObject(addButton);
        foundation.debugPrint(
          'GARAGE_DIAG button=$rect enabled=$enabled centerInViewport=${viewport.contains(rect.center)} hitTestable=${addButton.hitTestable().evaluate().length} renderInHitPath=${hits.any((entry) => identical(entry.target, render))}',
        );
        foundation.debugPrint(
          'GARAGE_DIAG hitPath=${hits.map((entry) => entry.target).join(" | ")}',
        );
      } else {
        foundation.debugPrint(
          'GARAGE_DIAG buttonMatches=${addButton.evaluate().length}',
        );
      }
    }
    expect(addButton, findsOneWidget);
    expect(
      find.descendant(of: addButton, matching: find.text('Добави автомобил')),
      findsOneWidget,
    );
    expect(tester.widget<OutlinedButton>(addButton).onPressed, isNotNull);
    expect(addButton.hitTestable(), findsOneWidget);
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byKey(const ValueKey('Марка')),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
