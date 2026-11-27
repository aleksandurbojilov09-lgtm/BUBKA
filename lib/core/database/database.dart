import 'package:drift/drift.dart';

part 'database.g.dart';

// Technical tables retained unchanged across schema versions.
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

class GarageVehicles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get brand => text()();
  TextColumn get model => text()();
  TextColumn get registration => text()();
  TextColumn get registrationKey => text().unique()();
  IntColumn get year => integer().nullable()();
  TextColumn get fuel => text().nullable()();
}

class ActiveGarageVehicles extends Table {
  late final IntColumn slot = integer().check(slot.equals(1))();
  IntColumn get vehicleId =>
      integer().references(GarageVehicles, #id, onDelete: KeyAction.cascade)();
  @override
  Set<Column> get primaryKey => {slot};
}

@DriftDatabase(
  tables: [
    DiagnosticRecords,
    ModulePreferences,
    GarageVehicles,
    ActiveGarageVehicles,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from != 1 || to != 2) {
        throw StateError('Unsupported schema migration: $from -> $to');
      }
      await transaction(() async {
        await m.createTable(garageVehicles);
        await m.createTable(activeGarageVehicles);
      });
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
