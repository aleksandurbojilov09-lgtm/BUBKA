import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/notifications/notification_service.dart';

class FakeAdapter implements NotificationAdapter {
  final pending = <int, LocalReminder>{};

  @override
  bool get limitedPending => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<Set<int>> pendingIds() async => pending.keys.toSet();

  @override
  Future<void> schedule(LocalReminder reminder) async {
    pending[reminder.id] = reminder;
  }

  @override
  Future<void> cancel(int id) async {
    pending.remove(id);
  }
}

void main() {
  test('stable IDs, persistence, cancellation and denied permission', () async {
    final root = await Directory.systemTemp.createTemp('bubka-notify-');
    addTearDown(() => root.delete(recursive: true));
    final adapter = FakeAdapter();
    final service = NotificationService(adapter, directory: () async => root);
    expect(await service.requestPermission(), isFalse);
    final time = DateTime.now().add(const Duration(days: 2));
    await service.upsert(
      LocalReminder(id: 1, title: 'A', body: '', localDateTime: time),
    );
    await service.upsert(
      LocalReminder(id: 1, title: 'B', body: '', localDateTime: time),
    );
    expect(adapter.pending.values.single.title, 'B');
    adapter.pending.clear();
    final restored = NotificationService(adapter, directory: () async => root);
    await restored.synchronize();
    expect(adapter.pending.values.single.title, 'B');
    await restored.cancel(1);
    expect(adapter.pending, isEmpty);
  });

  test('iOS window keeps nearest 60 requests', () async {
    final root = await Directory.systemTemp.createTemp('bubka-notify-');
    addTearDown(() => root.delete(recursive: true));
    final adapter = FakeAdapter();
    final service = NotificationService(adapter, directory: () async => root);
    final time = DateTime.now().add(const Duration(days: 1));
    for (var id = 65; id >= 1; id--) {
      await service.upsert(
        LocalReminder(
          id: id,
          title: '$id',
          body: '',
          localDateTime: time.add(Duration(days: id)),
        ),
      );
    }
    expect(adapter.pending.keys, unorderedEquals(List.generate(60, (i) => i + 1)));
    await service.cancel(1);
    expect(adapter.pending.keys, contains(61));
  });
}
