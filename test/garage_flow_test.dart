import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/app/modules/module_availability.dart';
import 'package:garage/app/providers/composition.dart';
import 'package:garage/app/router/router.dart';
import 'package:garage/core/database/database.dart';
import 'package:garage/design_system/theme.dart';
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
    final firstAdd = find.descendant(
      of: find.byKey(const Key('v4-add')),
      matching: find.byType(OutlinedButton),
    );
    final firstScroll = find.descendant(
      of: find.byType(ListView),
      matching: find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      ),
    );
    await tester.scrollUntilVisible(firstAdd, 100, scrollable: firstScroll);
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(tester.element(firstAdd), alignment: 0.5);
    await tester.pumpAndSettle();
    expect(firstAdd.hitTestable(), findsOneWidget);
    await tester.tap(firstAdd);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Запази'));
    await tester.pumpAndSettle();
    expect(find.text('Задължително поле'), findsWidgets);
    await tester.tap(find.byTooltip('Избери Марка от списък'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('search-Марка')), 'Бмв');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('BMW'));
    await tester.tap(find.text('BMW'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Избери Модел от списък'));
    await tester.pumpAndSettle();
    expect(find.text('Golf'), findsNothing);
    await tester.enterText(find.byKey(const ValueKey('search-Модел')), '320');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('320d'));
    await tester.tap(find.text('320d'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('Регистрационен номер')),
      'CA 1234 AB',
    );
    await tester.enterText(
      find.byKey(const ValueKey('Регистрационен номер')),
      'Александър',
    );
    await tester.tap(find.text('Запази'));
    await tester.pumpAndSettle();
    expect(find.text('Невалиден или неподдържан формат'), findsOneWidget);
    expect(vm.active, isNull);
    await tester.enterText(
      find.byKey(const ValueKey('Регистрационен номер')),
      'CA 1234 AB',
    );
    final fuelField = find.byKey(const ValueKey('Гориво (по желание)'));
    expect(tester.widget<TextFormField>(fuelField).controller!.text, isEmpty);
    expect(
      tester
          .widget<EditableText>(
            find.descendant(of: fuelField, matching: find.byType(EditableText)),
          )
          .readOnly,
      isTrue,
    );
    await tester.ensureVisible(fuelField);
    await tester.tap(find.byTooltip('Избери Гориво (по желание) от списък'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Дизел'));
    await tester.tap(find.text('Дизел'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Запази'));
    for (var i = 0; i < 50 && vm.active == null; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(vm.active!.name, 'BMW 320d');
    expect(vm.active!.details.fuel, 'Дизел');
    expect(find.text('BMW 320d'), findsOneWidget);
    await tester.tap(find.text('Изтрий'));
    await tester.pumpAndSettle();
    expect(find.textContaining('необратимо'), findsOneWidget);
    expect(find.textContaining('CA 1234 AB'), findsWidgets);
    await tester.tap(find.text('Отказ'));
    await tester.pumpAndSettle();
    expect(vm.snapshot!.vehicles, hasLength(1));
    final secondAdd = find.descendant(
      of: find.byKey(const Key('v4-add')),
      matching: find.byType(OutlinedButton),
    );
    final listScroll = find.descendant(
      of: find.byType(ListView),
      matching: find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      ),
    );
    await tester.scrollUntilVisible(secondAdd, 100, scrollable: listScroll);
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(tester.element(secondAdd), alignment: 0.5);
    await tester.pumpAndSettle();
    expect(secondAdd.hitTestable(), findsOneWidget);
    await tester.tap(secondAdd);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Избери Марка от списък'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('search-Марка')), 'Панда');
    await tester.pumpAndSettle();
    expect(find.text('Марката не е в локалния каталог.'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('search-Марка')), 'fiat');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Fiat'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Избери Модел от списък'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Моят модел липсва'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('manual-model')), 'Other');
    await tester.pumpAndSettle();
    final manualDialog = find.widgetWithText(AlertDialog, 'Моят модел липсва');
    expect(manualDialog, findsOneWidget);
    final confirmModel = find.descendant(
      of: manualDialog,
      matching: find.widgetWithText(FilledButton, 'Избери модел'),
    );
    expect(confirmModel, findsOneWidget);
    expect(tester.widget<FilledButton>(confirmModel).onPressed, isNotNull);
    expect(confirmModel.hitTestable(), findsOneWidget);
    await tester.tap(confirmModel);
    await tester.pumpAndSettle();
    // The manual-model dialog must have closed before interacting with the form.
    expect(find.byKey(const ValueKey('manual-model')), findsNothing);
    expect(find.byKey(const ValueKey('search-Модел')), findsNothing);
    final vehicleDialog = find.widgetWithText(AlertDialog, 'Добави автомобил');
    expect(vehicleDialog, findsOneWidget);
    final modelField = find.descendant(
      of: vehicleDialog,
      matching: find.byKey(const ValueKey('Модел')),
    );
    expect(tester.widget<TextFormField>(modelField).controller!.text, 'Other');
    final modeButton = find.descendant(
      of: vehicleDialog,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is OutlinedButton &&
            widget.key == const ValueKey('registration-mode'),
      ),
    );
    expect(modeButton, findsOneWidget);
    expect(tester.widget<OutlinedButton>(modeButton).onPressed, isNotNull);
    final modeContext = tester.element(modeButton);
    final scroll = Scrollable.of(modeContext);
    final viewport = find.byWidget(scroll.widget);
    expect(viewport, findsOneWidget);
    void measure(String stage) {
      final rect = tester.getRect(modeButton);
      final visible = tester.getRect(viewport);
      final hits = tester.hitTestOnBinding(rect.center).path.toList();
      final render = tester.renderObject(modeButton);
      foundation.debugPrint(
        'MODE_DIAG $stage focus=${FocusManager.instance.primaryFocus?.debugLabel} focusWidget=${FocusManager.instance.primaryFocus?.context?.widget.runtimeType} inset=${MediaQuery.of(modeContext).viewInsets.bottom} testInset=${tester.view.viewInsets.bottom} button=$rect viewport=$visible scroll=${scroll.position.pixels}/${scroll.position.maxScrollExtent} enabled=${tester.widget<OutlinedButton>(modeButton).onPressed != null} hitTestable=${modeButton.hitTestable().evaluate().length} centerInViewport=${visible.contains(rect.center)} renderInHitPath=${hits.any((entry) => identical(entry.target, render))}',
      );
      foundation.debugPrint(
        'MODE_DIAG $stage hitPath=${hits.map((entry) => entry.target).join(" | ")}',
      );
    }

    measure('before ensureVisible');
    await tester.ensureVisible(modeButton);
    measure('immediate after ensureVisible');
    await tester.pumpAndSettle();
    measure('after frame');
    if (modeButton.hitTestable().evaluate().isEmpty) {
      await Scrollable.ensureVisible(modeContext, alignment: 0.5);
      await tester.pumpAndSettle();
      measure('after centered scroll');
    }
    // If still clipped, emulate normal scrolling in the dialog itself.
    for (
      var attempt = 0;
      attempt < 6 && modeButton.hitTestable().evaluate().isEmpty;
      attempt++
    ) {
      final rect = tester.getRect(modeButton);
      final visible = tester.getRect(viewport);
      if (visible.contains(rect.center)) break;
      final delta = rect.center.dy < visible.center.dy ? 80.0 : -80.0;
      await tester.dragFrom(visible.center, Offset(0, delta));
      await tester.pumpAndSettle();
      measure('after normal drag $attempt');
    }
    expect(
      modeButton.hitTestable(),
      findsOneWidget,
      reason: 'Registration mode must be reachable in the real dialog',
    );
    await tester.tap(modeButton);
    await tester.pumpAndSettle();
    final foreign = find.widgetWithText(SimpleDialogOption, 'Чуждестранен');
    expect(foreign, findsOneWidget);
    await tester.ensureVisible(foreign);
    await tester.pumpAndSettle();
    expect(foreign.hitTestable(), findsOneWidget);
    await tester.tap(foreign);
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: modeButton, matching: find.text('Чуждестранен')),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const ValueKey('Регистрационен номер')),
      'XY 987',
    );
    await tester.tap(find.text('Запази'));
    for (var i = 0; i < 50 && vm.snapshot!.vehicles.length < 2; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(vm.snapshot!.vehicles, hasLength(2));
    expect(vm.snapshot!.vehicles.last.registration, 'XY 987');
    expect(vm.snapshot!.vehicles.last.name, 'Fiat Other');
    expect(tester.takeException(), isNull);
    expect(vm.active!.name, 'BMW 320d');
    final second = vm.snapshot!.vehicles.last.id;
    await tester.runAsync(() => vm.select(second));
    await tester.pumpAndSettle();
    router.go('/');
    await tester.pumpAndSettle();
    expect(find.text('Fiat Other'), findsOneWidget);
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
    final brandField = find.byKey(const ValueKey('Марка'));
    await tester.ensureVisible(brandField);
    await tester.tap(find.byTooltip('Избери Марка от списък'));
    await tester.pumpAndSettle();
    final search = find.byKey(const ValueKey('search-Марка'));
    await tester.ensureVisible(search);
    await tester.enterText(search, 'Мерц');
    await tester.pumpAndSettle();
    final option = find.widgetWithText(ListTile, 'Mercedes-Benz');
    await tester.ensureVisible(option);
    await tester.pumpAndSettle();
    expect(option.hitTestable(), findsOneWidget);
    await tester.tap(option);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(brandField).controller!.text,
      'Mercedes-Benz',
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
