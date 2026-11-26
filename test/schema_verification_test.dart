import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/database/database.dart';

import 'schema_v1/schema.dart';

void main() {
  test('production v1 schema matches the exported Drift schema', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 1);
    expect(db.schemaVersion, 1);
  });
}
