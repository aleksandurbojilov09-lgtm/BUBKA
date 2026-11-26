import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<Directory> localDataDirectory() async {
  final support = await getApplicationSupportDirectory();
  final folder = Directory('${support.path}/bubka-data');
  await folder.create(recursive: true);
  if (Platform.isIOS) {
    // Fail closed if the exclusion cannot be applied; never open the DB first.
    await const MethodChannel('bubka/local_storage')
        .invokeMethod<void>('excludeFromBackup', folder.path);
  }
  return folder;
}

QueryExecutor localExecutor() => LazyDatabase(() async {
  final folder = await localDataDirectory();
  return NativeDatabase.createInBackground(File('${folder.path}/bubka.sqlite'));
});
