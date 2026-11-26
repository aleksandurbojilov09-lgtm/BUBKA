import 'dart:convert';
import 'dart:io';

import '../database/connection.dart';

class LocalReminder {
  const LocalReminder({
    required this.id,
    required this.title,
    required this.body,
    required this.localDateTime,
  });

  final int id;
  final String title;
  final String body;

  /// Calendar wall time, without a UTC offset; resolve in the device time zone.
  final DateTime localDateTime;

  factory LocalReminder.fromJson(Map<String, dynamic> json) => LocalReminder(
    id: json['id'] as int,
    title: json['title'] as String,
    body: json['body'] as String,
    localDateTime: DateTime.parse(json['date'] as String),
  );

  Map<String, Object> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'date': localDateTime.toIso8601String(),
  };
}

abstract interface class NotificationAdapter {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<Set<int>> pendingIds();
  Future<void> schedule(LocalReminder reminder);
  Future<void> cancel(int id);
  bool get limitedPending;
}

class NotificationService {
  NotificationService(this._adapter, {Future<Directory> Function()? directory})
    : _directory = directory ?? localDataDirectory;

  final NotificationAdapter _adapter;
  final Future<Directory> Function() _directory;
  Future<void> _queue = Future<void>.value();

  Future<T> _serialize<T>(Future<T> Function() action) {
    final result = _queue.then((_) => action());
    _queue = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<File> _planFile() async {
    final root = await _directory();
    return File('${root.path}/notification-plan.json');
  }

  Future<List<LocalReminder>> _load() async {
    final file = await _planFile();
    if (!await file.exists()) {
      return [];
    }
    final rows = jsonDecode(await file.readAsString()) as List<dynamic>;
    return rows
        .map((row) => LocalReminder.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> _save(List<LocalReminder> plan) async {
    final file = await _planFile();
    final stage = File('${file.path}.tmp');
    await stage.writeAsString(
      jsonEncode(plan.map((entry) => entry.toJson()).toList()),
      flush: true,
    );
    await stage.rename(file.path);
  }

  Future<bool> requestPermission() => _serialize(() async {
    await _adapter.initialize();
    return _adapter.requestPermission();
  });

  Future<void> upsert(LocalReminder reminder) => _serialize(() async {
    if (reminder.id < 1 ||
        reminder.id > 2147483647 ||
        reminder.localDateTime.isUtc ||
        !reminder.localDateTime.isAfter(DateTime.now())) {
      throw ArgumentError('Expected a future local calendar time and valid ID');
    }
    final plan = await _load();
    plan.removeWhere((entry) => entry.id == reminder.id);
    plan.add(reminder);
    await _save(plan);
    await _reconcile(plan);
  });

  Future<void> cancel(int id) => _serialize(() async {
    final plan = await _load();
    plan.removeWhere((entry) => entry.id == id);
    await _save(plan);
    await _reconcile(plan);
  });

  Future<void> synchronize() => _serialize(() async {
    final plan = await _load();
    await _reconcile(plan);
  });

  Future<void> _reconcile(List<LocalReminder> plan) async {
    await _adapter.initialize();
    final now = DateTime.now();
    final future =
        plan.where((entry) => entry.localDateTime.isAfter(now)).toList()
          ..sort((a, b) => a.localDateTime.compareTo(b.localDateTime));
    final selected = _adapter.limitedPending ? future.take(60) : future;
    final wanted = selected.map((entry) => entry.id).toSet();
    final pending = await _adapter.pendingIds();
    for (final id in pending.difference(wanted)) {
      await _adapter.cancel(id);
    }
    for (final reminder in selected) {
      // A stable ID replaces its own request and adjusts for time zone changes.
      await _adapter.schedule(reminder);
    }
    await _save(future);
  }
}
