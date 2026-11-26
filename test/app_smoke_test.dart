import 'package:garage/design_system/cockpit_assets.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/app/app.dart';
import 'package:garage/app/version.dart';
import 'package:garage/core/database/database.dart';

void main() {
  testWidgets('BUBA starts with its generated version and navigation', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    await tester.runAsync(() async {
      await db.select(db.modulePreferences).get();
    });
    await tester.pumpWidget(BubkaApp(database: db));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 3400));
    await tester.pumpAndSettle();
    expect(find.byType(CockpitWordmark), findsOneWidget);
    await tester.tap(find.text('Настройки'));
    await tester.pumpAndSettle();
    for (
      var i = 0;
      i < 30 && find.text('Диагностика').evaluate().isEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }

    await tester.scrollUntilVisible(find.text(appVersion), 100);
    await tester.pumpAndSettle();
    expect(find.text(appVersion), findsOneWidget);
    expect(find.text('За приложението'), findsOneWidget);
    expect(find.text('Developed by A.Bozhilov'), findsOneWidget);
    expect(find.text('BUBA · Cockpit Premium'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Диагностика'), 100);
    await tester.pumpAndSettle();

    expect(find.text('Диагностика'), findsOneWidget);
    await tester.tap(find.text('Диагностика'));
    await tester.pumpAndSettle();
    expect(find.text('Добави тестов запис'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Начало'));
    await tester.pumpAndSettle();
    expect(find.byType(CockpitWordmark), findsOneWidget);
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
