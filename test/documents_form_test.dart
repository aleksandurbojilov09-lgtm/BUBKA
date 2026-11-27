import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:garage/features/documents/documents.dart';
import 'package:garage/features/documents/presentation/document_form.dart';

class FakeDocuments implements DocumentsRepository {
  DocumentDraft? saved;
  @override
  Stream<List<DocumentRecord>> watch() => Stream.value([]);
  @override
  Future<void> save(
    int vehicleId,
    DocumentDraft draft, {
    int? id,
    int? renewId,
  }) async {
    draft.validate();
    saved = draft;
  }

  @override
  Future<void> remove(int vehicleId, int id) async {}
  @override
  Future<void> setPaid(
    int vehicleId,
    int documentId,
    int paymentId,
    bool paid,
  ) async {}
}

void main() {
  testWidgets('320 px and 200 percent text: add a document', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = FakeDocuments();
    final vm = DocumentsViewModel(repo, null);
    addTearDown(vm.dispose);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => DocumentForm(
                    model: vm,
                    vehicleId: 1,
                    vehicleName: 'BMW 320d',
                  ),
                ),
              ),
              child: const Text('Отвори'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Отвори'));
    await tester.pumpAndSettle();
    final end = find.widgetWithText(TextFormField, 'Валидна до');
    await tester.ensureVisible(end);
    await tester.enterText(end, '31.12.2027');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    final save = find.byKey(const Key('document-save'));
    await tester.scrollUntilVisible(
      save,
      180,
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
    await tester.pumpAndSettle();
    expect(repo.saved?.end, '2027-12-31');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
