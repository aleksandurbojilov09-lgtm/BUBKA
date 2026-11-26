import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/app/modules/module_availability.dart';
import 'package:garage/app/modules/module_registry.dart';
import 'package:garage/app/providers/composition.dart';
import 'package:garage/app/router/router.dart';
import 'package:garage/core/database/database.dart';
import 'package:garage/features/diagnostics/diagnostics.dart';
import 'package:material_ui/material_ui.dart';

class BrokenRepository implements DiagnosticsRepository {
  @override
  Future<void> add() async => throw StateError('private details');
  @override
  Future<void> edit(int id) async => throw StateError('private details');
  @override
  Future<void> remove(int id) async => throw StateError('private details');
  @override
  Future<List<DiagnosticItem>> read() async =>
      throw StateError('private details');
}

void main() {
  test('Static registry rejects duplicate identifiers and routes', () {
    final m = createRegistry().modules.single;
    expect(m.id, 'diagnostics');
    expect(() => ModuleRegistry([m, m]), throwsArgumentError);
    final other = AppModule(
      id: 'other',
      name: 'Other',
      icon: m.icon,
      path: m.path,
      builder: m.builder,
    );
    expect(() => ModuleRegistry([m, other]), throwsArgumentError);
  });
  test(
    'Local module availability persists without deleting feature data',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = LocalDiagnosticsRepository(db);
      await repo.add();
      final a = ModuleAvailability(db);
      addTearDown(a.dispose);
      await a.load();
      expect(a.isEnabled('diagnostics'), isTrue);
      await a.setEnabled('diagnostics', false);
      final b = ModuleAvailability(db);
      addTearDown(b.dispose);
      await b.load();
      expect(b.isEnabled('diagnostics'), isFalse);
      expect(await repo.read(), hasLength(1));
    },
  );
  test('ViewModel handles success and hides internal errors', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final vm = DiagnosticsViewModel(LocalDiagnosticsRepository(db));
    addTearDown(vm.dispose);
    await vm.add();
    expect(vm.ready, isTrue);
    expect(vm.items, hasLength(1));
    final bad = DiagnosticsViewModel(BrokenRepository());
    addTearDown(bad.dispose);
    await bad.load();
    expect(bad.ready, isFalse);
    expect(bad.error, isNotNull);
    expect(bad.error, isNot(contains('private details')));
  });
  testWidgets('Unknown route is handled', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final availability = ModuleAvailability(db);
    addTearDown(availability.dispose);
    final router = createRouter(createRegistry(), availability);
    addTearDown(router.dispose);
    router.go('/nonexistent');
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('Непознат екран'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
