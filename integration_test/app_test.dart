import 'package:garage/design_system/cockpit_assets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Native startup and database access', (tester) async {
    app.main();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 3400));
    await tester.pumpAndSettle();
    expect(find.byType(CockpitWordmark), findsOneWidget);
    await tester.tap(find.text('Настройки'));
    await tester.pumpAndSettle();
    for (
      var i = 0;
      i < 100 && find.text('Диагностика').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Диагностика'), findsOneWidget);
    await tester.tap(find.text('Диагностика'));
    await tester.pumpAndSettle();
    expect(find.text('Добави тестов запис'), findsOneWidget);
  });
}
