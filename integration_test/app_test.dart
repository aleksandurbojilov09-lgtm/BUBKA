import 'package:flutter_test/flutter_test.dart';
import 'package:garage/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Native startup and database access', (tester) async {
    app.main();
    for (
      var i = 0;
      i < 100 && find.text('Диагностика').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Диагностика'), findsOneWidget);
  });
}
