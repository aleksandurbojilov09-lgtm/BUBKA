import 'package:flutter_test/flutter_test.dart';
import 'package:garage/main.dart' as app;

void main() {
  testWidgets('BUBKA starts and shows the initial version', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('BUBKA'), findsOneWidget);
    expect(find.text('0.0.1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
