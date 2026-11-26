import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data' as td;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/design_system/resource_ring.dart';
import 'package:garage/design_system/cockpit_assets.dart';
import 'package:garage/design_system/theme.dart';
import 'package:garage/design_system/cockpit_components.dart';
import 'package:garage/features/cockpit/cockpit.dart';
import 'package:material_ui/material_ui.dart';

const _capture = Key('visual-capture');
bool _reviewFontLoaded = false;
final _actions = CockpitActions(navigate: (_) {}, quick: () {}, future: (_) {});
Widget _app(Widget child, {double scale = 1, bool reduced = false}) =>
    RepaintBoundary(
      key: _capture,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _reviewFontLoaded
            ? BubkaDesign.dark.copyWith(
                textTheme: BubkaDesign.dark.textTheme.apply(
                  fontFamily: 'BubkaReviewSans',
                ),
                primaryTextTheme: BubkaDesign.dark.primaryTextTheme.apply(
                  fontFamily: 'BubkaReviewSans',
                ),
              )
            : BubkaDesign.dark,
        builder: (context, body) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            disableAnimations: reduced,
          ),
          child: body!,
        ),
        home: child,
      ),
    );
void _size(WidgetTester tester, double width, double height) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _export(WidgetTester tester, String filename) async {
  final output = Platform.environment['BUBKA_VISUAL_OUTPUT'];
  if (output == null) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_capture),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory(output).create(recursive: true);
      await File('$output/$filename.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}

void _visualTest(String name, Future<void> Function(WidgetTester) body) {
  testWidgets(name, (tester) async {
    await tester.runAsync(() async {
      for (final name in CockpitAssets.names) {
        final stream = CockpitAssets.provider(name)
            .resolve(ImageConfiguration.empty);
        final loaded = Completer<void>();
        final listener = ImageStreamListener(
          (info, sync) {
            info.dispose();
            if (!loaded.isCompleted) {
              loaded.complete();
            }
          },
          onError: (Object error, StackTrace? stack) {
            if (!loaded.isCompleted) {
              loaded.completeError(error, stack);
            }
          },
        );
        stream.addListener(listener);
        try {
          await loaded.future.timeout(const Duration(seconds: 10));
        } finally {
          stream.removeListener(listener);
        }
      }
    });
    await body(tester);
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final iconFont = Platform.environment['BUBKA_TEST_ICON_FONT'];
    if (Platform.environment['BUBKA_VISUAL_OUTPUT'] != null &&
        iconFont == null) {
      throw StateError('Visual export requires the pinned MaterialIcons font');
    }
    if (iconFont != null) {
      final bytes = await File(iconFont).readAsBytes();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(Future.value(td.ByteData.sublistView(bytes)))).load();
    }

    final font = Platform.environment['BUBKA_TEST_FONT'];
    if (Platform.environment['BUBKA_VISUAL_OUTPUT'] != null && font == null) {
      throw StateError(
        'Visual geometry export requires the pinned review font',
      );
    }
    if (font != null) {
      final loader = FontLoader('BubkaReviewSans')
        ..addFont(
          File(font)
              .readAsBytes()
              .then((bytes) => td.ByteData.sublistView(bytes)),
        );
      final bold = Platform.environment['BUBKA_TEST_FONT_BOLD'];
      if (bold != null) {
        loader.addFont(
          File(bold)
              .readAsBytes()
              .then((bytes) => td.ByteData.sublistView(bytes)),
        );
      }
      await loader.load();
      _reviewFontLoaded = true;
    }
  });
  for (final width in [320.0, 390.0, 700.0]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      _visualTest(
        'empty and fixture cockpit/garage at $width dp, $scale text',
        (tester) async {
          _size(tester, width, width >= 700 ? 1000 : 844);
          final model = CockpitFixtureModel();
          addTearDown(model.dispose);
          await tester.pumpWidget(
            _app(CockpitHome(actions: _actions), scale: scale),
          );
          await tester.pumpAndSettle();
          expect(find.text('Няма добавен автомобил'), findsOneWidget);
          expect(find.text('DEMO 01'), findsNothing);
          expect(tester.takeException(), isNull);
          await _export(tester, 'home-empty-${width.toInt()}-$scale');
          await tester.pumpWidget(
            _app(
              CockpitHome(actions: _actions, fixture: model),
              scale: scale,
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('BMW 320d'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await _export(tester, 'home-fixture-${width.toInt()}-$scale');
          await tester.pumpWidget(
            _app(
              GarageScreen(actions: _actions, fixture: model),
              scale: scale,
            ),
          );
          await tester.pumpAndSettle();

          expect(
            tester.getSize(find.byType(PremiumNavigation)).height,
            lessThan(180),
          );
          for (final label in ['Начало', 'Гараж', 'Статистика', 'Настройки']) {
            expect(
              find.descendant(
                of: find.byType(PremiumNavigation),
                matching: find.text(label),
              ),
              findsOneWidget,
            );
          }

          final garageScroll = find.descendant(
            of: find.byType(GarageScreen),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            ),
          );
          expect(garageScroll, findsOneWidget);
          await tester.scrollUntilVisible(
            find.text('Toyota Corolla'),
            100,
            scrollable: garageScroll,
          );
          await tester.pumpAndSettle();
          expect(find.text('Toyota Corolla').hitTestable(), findsOneWidget);

          expect(tester.takeException(), isNull);
          await _export(tester, 'garage-fixture-${width.toInt()}-$scale');
          await tester.pumpWidget(
            _app(GarageScreen(actions: _actions), scale: scale),
          );
          await tester.pumpAndSettle();
          expect(find.text('Гаражът е празен'), findsOneWidget);
          expect(find.text('DEMO 01'), findsNothing);
          expect(tester.takeException(), isNull);
          await _export(tester, 'garage-empty-${width.toInt()}-$scale');
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }
  _visualTest('render fixture resource states, selection and unknown plate', (
    tester,
  ) async {
    _size(tester, 390, 844);
    final model = CockpitFixtureModel();
    addTearDown(model.dispose);
    await tester.pumpWidget(
      _app(CockpitHome(actions: _actions, fixture: model)),
    );
    await tester.pumpAndSettle();
    for (final resource in const [
      ResourceView(state: ResourceState.active, fraction: 1, remaining: 365),
      ResourceView(state: ResourceState.active, fraction: .5, remaining: 182),
      ResourceView(state: ResourceState.active, fraction: .25, remaining: 91),
      ResourceView(state: ResourceState.active, fraction: .05, remaining: 18),
      ResourceView(state: ResourceState.due, fraction: 0, remaining: 0),
      ResourceView(state: ResourceState.overdue, fraction: 0, remaining: -1),
      ResourceView(),
      ResourceView(state: ResourceState.daysOnly, remaining: 14),
    ]) {
      model.showResource(resource);
      await tester.pumpAndSettle();
      expect(find.text(resource.metric), findsWidgets);
      expect(tester.takeException(), isNull);
      await _export(
        tester,
        'ring-${resource.state.name}-${resource.fraction ?? 'unknown'}',
      );
    }
    await tester.tap(find.byKey(const Key('signature-car')));
    await tester.pumpAndSettle();
    expect(find.text('Какво да следи Cockpit?'), findsOneWidget);
    await _export(tester, 'ring-selector');
    await tester.tap(find.text('Смяна на масло'));
    await tester.pumpAndSettle();
    expect(model.choice, ResourceChoice.oil);
    await tester.pumpWidget(
      _app(const Scaffold(body: Center(child: RegistrationPlate()))),
    );
    await tester.pumpAndSettle();
    expect(find.text('Без регистрационен номер'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  _visualTest(
    'ignition frames preserve car geometry, wordmark aligns and ticker stops',
    (tester) async {
      _size(tester, 390, 844);
      final model = CockpitFixtureModel();
      addTearDown(model.dispose);
      await tester.pumpWidget(
        _app(CockpitHome(actions: _actions, fixture: model, playIntro: true)),
      );
      await tester.pump();
      final car = find.byKey(const Key('signature-car'));
      final initial = tester.getRect(car);
      var prior = 0;
      for (final ms in [0, 500, 1000, 1350, 1700, 2200, 2700, 3400]) {
        await tester.pump(Duration(milliseconds: ms - prior));
        prior = ms;
        expect(tester.getRect(car), initial);
        expect(tester.takeException(), isNull);
        await _export(tester, 'ignition-$ms');
      }
      await tester.pumpAndSettle();
      expect(
        tester.getCenter(find.byKey(const Key('cockpit-wordmark'))).dx,
        closeTo(195, 1),
      );
      expect(tester.binding.transientCallbackCount, 0);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.label == 'BUBA',
        ),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.binding.transientCallbackCount, 0);
    },
  );
  _visualTest('reduced motion is direct home, no decorative ticker', (
    tester,
  ) async {
    _size(tester, 390, 844);
    await tester.pumpWidget(
      _app(CockpitHome(actions: _actions, playIntro: true), reduced: true),
    );
    await tester.pumpAndSettle();
    expect(tester.binding.transientCallbackCount, 0);
    expect(
      tester.getCenter(find.byKey(const Key('cockpit-wordmark'))).dx,
      closeTo(195, 1),
    );
    expect(tester.takeException(), isNull);
  });
  _visualTest(
    'quick sheet and fuel form have no historical or full-tank controls',
    (tester) async {
      _size(tester, 320, 740);
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: GoldButton(
                  label: 'Отвори',
                  onPressed: () => showQuickSheet(context, (_) {}),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Отвори'));
      await tester.pumpAndSettle();
      expect(find.text('Бързи действия'), findsOneWidget);
      await _export(tester, 'quick-sheet');
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Зареждане'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(_app(const FuelFormPreview()));
      await tester.pumpAndSettle();
      expect(find.text('Литри гориво *'), findsOneWidget);
      expect(find.text('Общ километраж *'), findsOneWidget);
      expect(find.byType(Checkbox), findsNothing);
      expect(find.textContaining('Пълен резервоар'), findsNothing);
      expect(find.textContaining('Исторически'), findsNothing);
      expect(tester.takeException(), isNull);
      await _export(tester, 'fuel-form');
    },
  );

  _visualTest(
    '320dp 200 percent full labels and reachable resource information',
    (tester) async {
      _size(tester, 320, 844);
      final model = CockpitFixtureModel();
      addTearDown(model.dispose);
      await tester.pumpWidget(
        _app(CockpitHome(actions: _actions, fixture: model), scale: 2),
      );
      await tester.pumpAndSettle();
      for (final label in ['Начало', 'Гараж', 'Статистика', 'Настройки']) {
        final finder = find.descendant(
          of: find.byType(PremiumNavigation),
          matching: find.text(label),
        );
        expect(finder, findsOneWidget);
        expect(tester.getSize(finder).height, lessThan(36));
        expect(finder.hitTestable(), findsOneWidget);
      }
      await tester.ensureVisible(find.text('14 дни'));
      await tester.pumpAndSettle();
      expect(find.text('14 дни').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _export(tester, 'home-fixture-320-2.0-scrolled-resource');
    },
  );
  _visualTest('landscape cockpit and garage at 844 by 390', (tester) async {
    _size(tester, 844, 390);
    final model = CockpitFixtureModel();
    addTearDown(model.dispose);
    await tester.pumpWidget(
      _app(CockpitHome(actions: _actions, fixture: model)),
    );
    await tester.pumpAndSettle();
    expect(find.text('BMW 320d'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _export(tester, 'home-fixture-landscape');
    await tester.pumpWidget(
      _app(GarageScreen(actions: _actions, fixture: model)),
    );
    await tester.pumpAndSettle();
    expect(find.text('BMW 320d'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _export(tester, 'garage-fixture-landscape');
  });
  _visualTest('fuel preview date defaults to today and is editable', (
    tester,
  ) async {
    _size(tester, 390, 844);
    await tester.pumpWidget(_app(const FuelFormPreview()));
    await tester.pumpAndSettle();
    final now = DateTime.now();
    final date = find.widgetWithText(PremiumField, 'Дата');
    expect(date, findsOneWidget);
    final field = tester.widget<PremiumField>(date);
    expect(
      field.controller!.text,
      '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}',
    );
    final input = find.descendant(of: date, matching: find.byType(TextField));
    await tester.ensureVisible(input);
    await tester.enterText(input, '01.01.2026');
    expect(field.controller!.text, '01.01.2026');
    expect(find.text('Обща цена (EUR) · по желание'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  _visualTest(
    'V4 enlarged quick cards and registration are single-line and reachable',
    (tester) async {
      _size(tester, 320, 844);
      final model = CockpitFixtureModel();
      addTearDown(model.dispose);
      await tester.pumpWidget(
        _app(CockpitHome(actions: _actions, fixture: model), scale: 2),
      );
      await tester.pumpAndSettle();
      for (final label in ['Гориво', 'Сервиз', 'Документи', 'Срокове']) {
        final f = find.text(label);
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        expect(f.hitTestable(), findsOneWidget);
        expect(tester.getSize(f).height, lessThan(40));
      }
      final summary = find.byKey(const Key('v4-metrics'));
      expect(
        find.descendant(of: summary, matching: find.byType(Divider)),
        findsOneWidget,
      );
      expect(find.byKey(const Key('v5-summary-divider')), findsNothing);
      await _export(tester, 'home-fixture-320-2.0-quick');
      final plate = find.text('DEMO 01');
      await tester.ensureVisible(plate);
      await tester.pumpAndSettle();
      expect(plate.hitTestable(), findsOneWidget);
      expect(tester.getSize(plate).height, lessThan(50));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        _app(GarageScreen(actions: _actions, fixture: model), scale: 2),
      );
      await tester.pumpAndSettle();
      final garagePlate = find.text('DEMO 01');
      await tester.ensureVisible(garagePlate);
      await tester.pumpAndSettle();
      expect(garagePlate.hitTestable(), findsOneWidget);
      expect(tester.getSize(garagePlate).height, lessThan(46));
      expect(tester.takeException(), isNull);
    },
  );
  _visualTest(
    'V4 landscape all resource labels and quick actions can be reached',
    (tester) async {
      _size(tester, 844, 390);
      final model = CockpitFixtureModel();
      addTearDown(model.dispose);
      await tester.pumpWidget(
        _app(CockpitHome(actions: _actions, fixture: model)),
      );
      await tester.pumpAndSettle();
      for (final label in [
        'Оставащ ресурс',
        '14 дни',
        'Гражданска отговорност',
        'Гориво',
        'Сервиз',
        'Документи',
        'Срокове',
        'Разходи този месец',
        'Среден разход',
      ]) {
        final f = find.text(label);
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        expect(f.hitTestable(), findsOneWidget, reason: label);
      }
      await tester.ensureVisible(find.text('14 дни'));
      await tester.pumpAndSettle();
      await _export(tester, 'home-landscape-scrolled-resource');
      expect(tester.takeException(), isNull);
    },
  );
  _visualTest('V5 390 geometry export and actual home and garage layout', (
    tester,
  ) async {
    _size(tester, 390, 844);
    final model = CockpitFixtureModel();
    addTearDown(model.dispose);
    final result = <String, Map<String, List<double>>>{};
    List<double> bounds(Finder f) {
      expect(f, findsOneWidget);
      final r = tester.getRect(f);
      return [r.left, r.top, r.width, r.height];
    }

    await tester.pumpWidget(
      _app(CockpitHome(actions: _actions, fixture: model)),
    );
    await tester.pumpAndSettle();
    result['home'] = {
      'wordmark': bounds(find.byKey(const Key('cockpit-wordmark'))),
      'vehicle_name': bounds(find.text('BMW 320d')),
      'plate': bounds(find.byType(RegistrationPlate)),
      'ring_layout': bounds(find.byKey(const Key('v4-ring-layout'))),
      'car_layout': bounds(find.byKey(const Key('signature-car'))),
      'resource_status': bounds(find.text('Оставащ ресурс')),
      'resource_metric': bounds(find.text('14 дни')),
      'resource_choice': bounds(find.text('Гражданска отговорност')),
      'metrics': bounds(find.byKey(const Key('v4-metrics'))),
      'summary_divider': bounds(find.byKey(const Key('v5-summary-divider'))),
      'plus': bounds(find.byKey(const Key('v5-quick-plus'))),
      'nav': bounds(find.byType(PremiumNavigation)),
      for (var i = 0; i < 4; i++)
        'tile_$i': bounds(find.byKey(ValueKey('v4-tile-$i'))),
    };
    if (_reviewFontLoaded) {
      final home = result['home']!;
      for (var i = 0; i < 4; i++) {
        final tile = home['tile_$i']!;
        expect(tile[0], closeTo(10 + 94.25 * i, 1));
        expect(tile[1], closeTo(447, 2));
        expect(tile[2], closeTo(87.25, 1));
        expect(tile[3], closeTo(88, 2));
      }
      for (final label in ['Гориво', 'Сервиз', 'Документи', 'Срокове']) {
        final finder = find.text(label);
        expect(finder.hitTestable(), findsOneWidget);
        expect(tester.getSize(finder).height, lessThan(22));
      }
      expect(home['wordmark']![0], closeTo(119, 1));
      expect(home['wordmark']![1], closeTo(11, 1));
      expect(home['ring_layout']!, [60.0, 172.0, 270.0, 270.0]);
      expect(home['car_layout']![0], closeTo(137, 1));
      expect(home['car_layout']![1], closeTo(207, 1));
      expect(home['metrics']![1], closeTo(550, 3));
      expect(home['metrics']![3], closeTo(85, 1));
      final divider = home['summary_divider']!;
      expect(divider[0] + divider[2] / 2, closeTo(195, 0.5));
      expect(divider[2], 1);
      expect(divider[3], greaterThan(30));
      final plus = find.byKey(const Key('v5-quick-plus'));
      expect(tester.getSize(plus), const Size(54, 54));
      expect(tester.getCenter(plus).dx, closeTo(195, 1));
      expect(tester.getCenter(plus).dy, closeTo(799, 1));
      expect(plus.hitTestable(), findsOneWidget);
      const labels = ['Гориво', 'Сервиз', 'Документи', 'Срокове'];
      const names = ['fuel', 'service', 'documents', 'deadlines'];
      for (var i = 0; i < labels.length; i++) {
        final tile = find.byKey(ValueKey('v4-tile-$i'));
        final glyph = find.descendant(
          of: tile,
          matching: find.byType(CockpitAsset),
        );
        expect(glyph, findsOneWidget);
        final asset = tester.widget<CockpitAsset>(glyph);
        expect(asset.name, 'icons/${names[i]}.png');
        expect(asset.tint, BubkaDesign.accent);
        final center = tester.getCenter(tile).dx;
        expect(tester.getCenter(glyph).dx, closeTo(center, 0.5));
        expect(tester.getCenter(find.text(labels[i])).dx, closeTo(center, 0.5));
      }
      final metricAssets = tester
          .widgetList<CockpitAsset>(
            find.descendant(
              of: find.byKey(const Key('v4-metrics')),
              matching: find.byType(CockpitAsset),
            ),
          )
          .toList();
      expect(metricAssets.map((a) => a.name), [
        'icons/coins.png',
        'icons/fuel.png',
      ]);
      expect(metricAssets.every((a) => a.tint == BubkaDesign.accent), isTrue);
    }
    await tester.pumpWidget(
      _app(GarageScreen(actions: _actions, fixture: model)),
    );
    await tester.pumpAndSettle();
    result['garage'] = {
      'title': bounds(find.text('Гараж').first),
      'selected_card': bounds(find.byKey(const ValueKey('v4-car-demo-1'))),
      'second_card': bounds(find.byKey(const ValueKey('v4-car-demo-2'))),
      'dashed_add': bounds(find.byKey(const Key('v4-add'))),
      'nav': bounds(find.byType(PremiumNavigation)),
    };
    if (_reviewFontLoaded) {
      final garage = result['garage']!;
      expect(garage['selected_card']![0], closeTo(12, 1));
      expect(garage['selected_card']![2], closeTo(366, 1));
      expect(garage['selected_card']![3], closeTo(120, 6));
      expect(garage['second_card']![1], closeTo(234, 8));
      expect(garage['dashed_add']![1], closeTo(373, 12));
    }
    final output = Platform.environment['BUBKA_VISUAL_OUTPUT'];
    if (output != null) {
      await tester.runAsync(() async {
        await Directory(output).create(recursive: true);
        await File('$output/geometry-v5.json')
            .writeAsString(jsonEncode(result));
      });
    }
    expect(tester.takeException(), isNull);
  });
  _visualTest('V5 actual bundled local assets decode with expected geometry', (
    tester,
  ) async {
    final expected = <String, List<int>>{
      'car/body.png': [411, 216],
      'car/contours.png': [411, 216],
      'car/glow_left.png': [411, 216],
      'car/glow_right.png': [411, 216],
      'car/highlights.png': [411, 216],
      'car/lamp_left.png': [411, 216],
      'car/lamp_right.png': [411, 216],
      'car/shadow.png': [411, 216],
      'icons/bell.png': [96, 96],
      'icons/coins.png': [96, 96],
      'icons/deadlines.png': [96, 96],
      'icons/documents.png': [96, 96],
      'icons/fuel.png': [96, 96],
      'icons/garage.png': [96, 96],
      'icons/home.png': [96, 96],
      'icons/plus.png': [96, 96],
      'icons/service.png': [96, 96],
      'icons/settings.png': [96, 96],
      'icons/stats.png': [96, 96],
      'ignition/asphalt.png': [1170, 1170],
      'ignition/beam_left.png': [1170, 1170],
      'ignition/beam_right.png': [1170, 1170],
      'ignition/halo_left.png': [1170, 1170],
      'ignition/halo_right.png': [1170, 1170],
      'ignition/road_pool.png': [1170, 1170],
      'ignition/wordmark_reflection.png': [540, 102],
      'surfaces/grain_tile.png': [192, 192],
      'surfaces/selected_inner_glow.png': [736, 240],
      'surfaces/soft_light.png': [512, 512],
      'wordmark/bubka.png': [540, 102],
    };
    expect(CockpitAssets.names.toSet(), expected.keys.toSet());
    await tester.runAsync(() async {
      for (final entry in expected.entries) {
        final data = await rootBundle.load(
          '${CockpitAssets.prefix}${entry.key}',
        );
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
        try {
          final frame = await codec.getNextFrame();
          try {
            expect([frame.image.width, frame.image.height], entry.value);
          } finally {
            frame.image.dispose();
          }
        } finally {
          codec.dispose();
        }
      }
    });
    expect(tester.takeException(), isNull);
  });
}
