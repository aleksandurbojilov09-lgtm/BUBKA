import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/database/database.dart';

import 'drift/app_database/generated/schema.dart';

void main() {
  test('schema 3 to 4 preserves realistic garage, choice, fuel, odometer and preferences', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(3);
    final old = GeneratedHelper().databaseForVersion(schema.newConnection(), 3);
    await old.customStatement(
      "INSERT INTO diagnostic_records(value) VALUES ('old')",
    );
    await old.customStatement(
      "INSERT INTO module_preferences(module_id,enabled) VALUES ('diagnostics',0)",
    );
    await old.customStatement(
      "INSERT INTO garage_vehicles(id,brand,model,registration,registration_key,year,fuel) VALUES (9,'BMW','320d','CA 1001 AB','CA1001AB',2018,'Дизел'),(10,'Toyota','Corolla','CA 1002 AB','CA1002AB',2020,NULL)",
    );
    await old.customStatement(
      'INSERT INTO active_garage_vehicles(slot,vehicle_id) VALUES (1,10)',
    );
    await old.customStatement(
      "INSERT INTO fuel_entries(id,vehicle_id,entry_date,odometer_km,fuel_ml,price_cents) VALUES (12,9,'2026-01-01',153000,35000,5800),(13,9,'2026-01-05',153500,NULL,NULL),(14,10,'2026-01-04',82000,40000,6500)",
    );
    await old.close();
    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 4);
    expect(
      (await db.select(db.garageVehicles).get()).map((c) => c.id),
      unorderedEquals([9, 10]),
    );
    expect(
      (await db.select(db.activeGarageVehicles).get()).single.vehicleId,
      10,
    );
    final fuel = await db.select(db.fuelEntries).get();
    expect(
      fuel.map(
        (r) => [
          r.id,
          r.vehicleId,
          r.entryDate,
          r.odometerKm,
          r.fuelMl,
          r.priceCents,
        ],
      ),
      unorderedEquals([
        [12, 9, '2026-01-01', 153000, 35000, 5800],
        [13, 9, '2026-01-05', 153500, null, null],
        [14, 10, '2026-01-04', 82000, 40000, 6500],
      ]),
    );
    expect(
      (await db.select(db.modulePreferences).get()).single.enabled,
      isFalse,
    );
    expect((await db.select(db.diagnosticRecords).get()).single.value, 'old');
    expect(await db.select(db.vehicleDocuments).get(), isEmpty);
    expect(await db.select(db.documentPayments).get(), isEmpty);
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  });
}
