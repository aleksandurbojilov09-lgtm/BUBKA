import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/database/database.dart';

import 'drift/app_database/generated/schema.dart';

void main() {
  test('production v1 to v3 schema preserves existing rows', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(1);
    // Separate connections to the same frozen schema, as documented by Drift.
    final old = GeneratedHelper().databaseForVersion(schema.newConnection(), 1);
    await old.customStatement(
      "INSERT INTO diagnostic_records(value) VALUES ('retained')",
    );
    await old.customStatement(
      "INSERT INTO module_preferences(module_id, enabled) VALUES ('diagnostics', 0)",
    );
    await old.close();
    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 3);
    expect(
      (await db.select(db.diagnosticRecords).get()).single.value,
      'retained',
    );
    expect(
      (await db.select(db.modulePreferences).get()).single.enabled,
      isFalse,
    );
    expect(await db.select(db.garageVehicles).get(), isEmpty);
    expect(await db.select(db.activeGarageVehicles).get(), isEmpty);
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  });
  test('fresh v3 creates empty garage and retains FK integrity', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();
    await db.select(db.activeGarageVehicles).get();
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    expect(db.schemaVersion, 3);
    expect(await db.select(db.garageVehicles).get(), isEmpty);
  });
}
