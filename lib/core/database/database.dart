import 'package:drift/drift.dart';

part 'database.g.dart';

// Technical infrastructure only; business tables are registered later.
class DiagnosticRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get value => text()();
}

class ModulePreferences extends Table {
  TextColumn get moduleId => text()();
  BoolColumn get enabled => boolean()();
  @override
  Set<Column> get primaryKey => {moduleId};
}

@DriftDatabase(tables: [DiagnosticRecords, ModulePreferences])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // No production migration before a real schema change.
      throw StateError('Unsupported schema migration: $from -> $to');
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
