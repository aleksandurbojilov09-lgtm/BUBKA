import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/database/database.dart';
import 'package:garage/features/diagnostics/diagnostics.dart';

void main() {
  test('CRUD, foreign keys and rollback', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = LocalDiagnosticsRepository(db);
    expect(await repo.read(), isEmpty);
    await repo.add();
    final id = (await repo.read()).single.id;
    await repo.edit(id);
    expect((await repo.read()).single.value, 'Редактиран запис');
    expect(
      (await db.customSelect('PRAGMA foreign_keys').getSingle()).read<int>(
        'foreign_keys',
      ),
      1,
    );
    await expectLater(
      db.transaction(() async {
        await repo.add();
        throw StateError('Rollback test');
      }),
      throwsStateError,
    );
    expect((await repo.read()).length, 1);
    await repo.remove(id);
    expect(await repo.read(), isEmpty);
  });

  test('Persistence after reopening database', () async {
    final dir = await Directory.systemTemp.createTemp('bubka-test-');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/test.sqlite');
    final first = AppDatabase(NativeDatabase(file));
    try {
      await LocalDiagnosticsRepository(first).add();
    } finally {
      await first.close();
    }
    final second = AppDatabase(NativeDatabase(file));
    try {
      expect(
        (await LocalDiagnosticsRepository(second).read()).single.value,
        'Тестов запис',
      );
    } finally {
      await second.close();
    }
  });

  test('Separate test schema: additive migration preserves data and rollback', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customStatement(
      'CREATE TABLE migration_probe (id INTEGER PRIMARY KEY, value TEXT NOT NULL)',
    );
    await db.customStatement(
      "INSERT INTO migration_probe VALUES (1, 'retained')",
    );
    await db.transaction(() async {
      await db.customStatement(
        "ALTER TABLE migration_probe ADD COLUMN note TEXT NOT NULL DEFAULT ''",
      );
    });
    final row = await db
        .customSelect('SELECT value, note FROM migration_probe')
        .getSingle();
    expect(row.read<String>('value'), 'retained');
    expect(row.read<String>('note'), '');
    await expectLater(
      db.transaction(() async {
        await db.customStatement(
          'ALTER TABLE migration_probe ADD COLUMN fail_probe INTEGER',
        );
        throw StateError('simulated failure');
      }),
      throwsStateError,
    );
    final columns = await db
        .customSelect('PRAGMA table_info(migration_probe)')
        .get();
    expect(
      columns.map((r) => r.read<String>('name')),
      isNot(contains('fail_probe')),
    );
    expect(db.schemaVersion, 1);
  });
}
