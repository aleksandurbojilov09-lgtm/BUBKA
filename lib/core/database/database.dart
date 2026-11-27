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

@DataClassName('FuelEntryRow')
class FuelEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vehicleId =>
      integer().references(GarageVehicles, #id, onDelete: KeyAction.cascade)();
  TextColumn get entryDate => text()();
  IntColumn get odometerKm => integer()();
  IntColumn get fuelMl => integer().nullable()();
  IntColumn get priceCents => integer().nullable()();
  @override
  List<String> get customConstraints => [
    'CHECK (odometer_km >= 0)',
    'CHECK (fuel_ml IS NULL OR fuel_ml > 0)',
    'CHECK (price_cents IS NULL OR price_cents >= 0)',
    'CHECK (fuel_ml IS NOT NULL OR price_cents IS NULL)',
  ];
}

@DataClassName('VehicleDocumentRow')
class VehicleDocuments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vehicleId =>
      integer().references(GarageVehicles, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => text()();
  TextColumn get startDate => text().nullable()();
  TextColumn get endDate => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

@DataClassName('DocumentPaymentRow')
class DocumentPayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get documentId => integer().references(
    VehicleDocuments,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get dueDate => text()();
  IntColumn get amountCents => integer()();
  BoolColumn get paid => boolean().withDefault(const Constant(false))();
  @override
  List<String> get customConstraints => [
    'CHECK (amount_cents >= 0 AND amount_cents <= 99999999999)',
  ];
}

@DriftDatabase(
  tables: [
    DiagnosticRecords,
    ModulePreferences,
    GarageVehicles,
    ActiveGarageVehicles,
    FuelEntries,
    VehicleDocuments,
    DocumentPayments,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 1 || to > 4 || from >= to) {
        throw StateError('Unsupported schema migration: $from -> $to');
      }
      await transaction(() async {
        if (from == 1 && to >= 2) {
          await m.createTable(garageVehicles);
          await m.createTable(activeGarageVehicles);
        }
        if (from < 3 && to >= 3) await m.createTable(fuelEntries);
        if (from < 4 && to >= 4) {
          await m.createTable(vehicleDocuments);
          await m.createTable(documentPayments);
        }
      });
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
