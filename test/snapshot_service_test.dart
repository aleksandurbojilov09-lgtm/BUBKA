import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/database/database.dart';
import 'package:garage/core/database/snapshot_service.dart';
import 'package:garage/features/diagnostics/diagnostics.dart';

void main() {
  test('snapshot contains committed WAL records and preserves the previous copy on failure', () async {
    final root = await Directory.systemTemp.createTemp('bubka-snapshot-');
    addTearDown(() => root.delete(recursive: true));
    final database = AppDatabase(
      NativeDatabase(File('${root.path}/source.sqlite')),
    );
    addTearDown(database.close);
    await database.customSelect('PRAGMA journal_mode=WAL').get();
    final repository = LocalDiagnosticsRepository(database);
    await repository.add();
    var fail = false;
    final service = SnapshotService(
      database,
      directory: () async {
        if (fail) {
          throw const FileSystemException('Simulated unavailable storage');
        }
        return root;
      },
    );
    final snapshot = await service.create();
    final original = await snapshot.readAsBytes();
    await repository.add();
    fail = true;
    await expectLater(service.create(), throwsA(isA<FileSystemException>()));
    expect(await snapshot.readAsBytes(), original);
    final copy = AppDatabase(NativeDatabase(snapshot));
    try {
      expect(await LocalDiagnosticsRepository(copy).read(), hasLength(1));
    } finally {
      await copy.close();
    }
    expect(await repository.read(), hasLength(2));
  });
}
