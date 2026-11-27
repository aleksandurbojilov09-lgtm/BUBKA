import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/notifications/notification_service.dart';
import 'package:garage/features/documents/documents.dart';

import 'notification_service_test.dart' show FakeAdapter;

class FakeRepository implements DocumentsRepository {
  final events = StreamController<List<DocumentRecord>>.broadcast(sync: true);
  @override
  Stream<List<DocumentRecord>> watch() => events.stream;
  @override
  Future<void> save(
    int vehicleId,
    DocumentDraft draft, {
    int? id,
    int? renewId,
  }) async {}
  @override
  Future<void> remove(int vehicleId, int id) async {}
  @override
  Future<void> setPaid(
    int vehicleId,
    int documentId,
    int paymentId,
    bool paid,
  ) async {}
}

void main() {
  test(
    'remaining calendar offset, two cars, denial, edits and paid cancellation',
    () async {
      final dir = await Directory.systemTemp.createTemp(
        'bubka-doc-notifications-',
      );
      addTearDown(() => dir.delete(recursive: true));
      final adapter = FakeAdapter();
      final service = NotificationService(
        adapter,
        directory: () async => dir,
        clock: () => DateTime(2026, 11, 27, 10),
      );
      final repo = FakeRepository();
      addTearDown(repo.events.close);
      final vm = DocumentsViewModel(repo, service)..load();
      addTearDown(vm.dispose);
      List<DocumentRecord> rows(bool paid, String end) => [
        DocumentRecord(
          1,
          1,
          'BMW',
          true,
          DocumentDraft(
            kind: DocumentKind.liability,
            end: end,
            payments: [
              PaymentDraft(id: 1, due: '2026-12-02', cents: 10000, paid: paid),
            ],
          ),
        ),
        const DocumentRecord(
          2,
          2,
          'Toyota',
          true,
          DocumentDraft(kind: DocumentKind.vignette, end: '2026-12-15'),
        ),
      ];
      repo.events.add(rows(false, '2026-12-03'));
      await vm.sync();
      expect(
        adapter.pending.keys,
        unorderedEquals([1000000003, 1500000003, 1000000004, 1000000005]),
      );
      expect(
        adapter.pending[1000000003]!.localDateTime,
        DateTime(2026, 12, 2, 9),
      );
      await vm.permission();
      expect(vm.notificationError, contains('отказани'));
      await vm.sync();
      expect(adapter.pending.length, 4);
      repo.events.add(rows(true, '2026-12-05'));
      await vm.sync();
      expect(
        adapter.pending.keys,
        unorderedEquals([1000000002, 1000000003, 1000000004, 1000000005]),
      );
      expect(
        adapter.pending[1000000003]!.localDateTime,
        DateTime(2026, 12, 4, 9),
      );
      repo.events.add([]);
      await vm.sync();
      expect(adapter.pending, isEmpty);
    },
  );
}
