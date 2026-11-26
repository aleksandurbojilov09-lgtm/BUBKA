import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/app/app.dart';
import 'package:garage/app/version.dart';
import 'package:garage/core/database/database.dart';

void main() {
  testWidgets('BUBKA starts with its generated version and navigation', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    await tester.runAsync(() async {
      await db.select(db.modulePreferences).get();
    });
    await tester.pumpWidget(BubkaApp(database: db));
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
    expect(find.text('BUBKA'), findsOneWidget);
    expect(find.text(appVersion), findsOneWidget);
    expect(find.text('Диагностика'), findsOneWidget);
    await tester.tap(find.text('Диагностика'));
    await tester.pumpAndSettle();
    expect(find.text('Добави тестов запис'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('BUBKA'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
