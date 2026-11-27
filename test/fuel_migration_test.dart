import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/database/database.dart';

import 'drift/app_database/generated/schema.dart';

void main() {
  test('published v2 upgrades without changing cars, active choice or technical records', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(2);
    final old = GeneratedHelper().databaseForVersion(schema.newConnection(), 2);
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
    await old.close();
    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 3);
    final cars = await db.select(db.garageVehicles).get();
    expect(cars.map((c) => c.id), unorderedEquals([9, 10]));
    final first = cars.singleWhere((c) => c.id == 9);
    final second = cars.singleWhere((c) => c.id == 10);
    expect(
      [
        first.brand,
        first.model,
        first.registration,
        first.registrationKey,
        first.year,
        first.fuel,
      ],
      ['BMW', '320d', 'CA 1001 AB', 'CA1001AB', 2018, 'Дизел'],
    );
    expect(
      [
        second.brand,
        second.model,
        second.registration,
        second.registrationKey,
        second.year,
        second.fuel,
      ],
      ['Toyota', 'Corolla', 'CA 1002 AB', 'CA1002AB', 2020, null],
    );
    expect(
      (await db.select(db.activeGarageVehicles).get()).single.vehicleId,
      10,
    );
    expect(
      (await db.select(db.modulePreferences).get()).single.enabled,
      isFalse,
    );
    expect((await db.select(db.diagnosticRecords).get()).single.value, 'old');
    expect(await db.select(db.fuelEntries).get(), isEmpty);
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  });
}
