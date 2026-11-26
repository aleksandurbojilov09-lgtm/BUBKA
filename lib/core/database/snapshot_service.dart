import 'dart:io';

import 'package:drift/native.dart';

import 'connection.dart';
import 'database.dart';

/// Create a consistent local snapshot; never call inside a transaction.
class SnapshotService {
  SnapshotService(this._database, {Future<Directory> Function()? directory})
    : _directory = directory ?? localDataDirectory;

  final AppDatabase _database;
  final Future<Directory> Function() _directory;
  bool _busy = false;

  Future<File> create() async {
    if (_busy) {
      throw StateError('Snapshot already running');
    }
    _busy = true;
    Directory? stage;
    try {
      final root = await _directory();
      final folder = Directory('${root.path}/snapshots');
      await folder.create(recursive: true);
      stage = await folder.createTemp('.snapshot-');
      final temporary = File('${stage.path}/candidate.sqlite');
      await _database.customStatement('VACUUM INTO ?', [temporary.path]);
      if (!await temporary.exists() || await temporary.length() == 0) {
        throw StateError('Empty snapshot');
      }
      final copy = AppDatabase(NativeDatabase(temporary));
      try {
        final integrity = await copy.customSelect('PRAGMA integrity_check').get();
        if (integrity.length != 1 || integrity.single.data.values.single != 'ok') {
          throw StateError('Snapshot integrity check failed');
        }
        final foreignKeys = await copy.customSelect('PRAGMA foreign_key_check').get();
        if (foreignKeys.isNotEmpty) {
          throw StateError('Snapshot foreign key check failed');
        }
      } finally {
        await copy.close();
      }
      return await temporary.rename('${folder.path}/latest.sqlite');
    } finally {
      try {
        if (stage != null && await stage.exists()) {
          await stage.delete(recursive: true);
        }
      } finally {
        _busy = false;
      }
    }
  }
}
