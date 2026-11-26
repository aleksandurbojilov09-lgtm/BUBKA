import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import '../domain/repository.dart';

class LocalDiagnosticsRepository implements DiagnosticsRepository {
  LocalDiagnosticsRepository(this.db);
  final AppDatabase db;

  @override
  Future<List<DiagnosticItem>> read() async {
    final rows = await (db.select(
      db.diagnosticRecords,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
    return rows
        .map((r) => DiagnosticItem(r.id, r.value))
        .toList(growable: false);
  }

  @override
  Future<void> add() async {
    await db
        .into(db.diagnosticRecords)
        .insert(DiagnosticRecordsCompanion.insert(value: 'Тестов запис'));
  }

  @override
  Future<void> edit(int id) async {
    await (db.update(
      db.diagnosticRecords,
    )..where((t) => t.id.equals(id))).write(
      const DiagnosticRecordsCompanion(value: Value('Редактиран запис')),
    );
  }

  @override
  Future<void> remove(int id) async {
    await (db.delete(db.diagnosticRecords)..where((t) => t.id.equals(id))).go();
  }
}
