import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/database/database.dart';
import 'package:garage/features/documents/data/local_documents_repository.dart';
import 'package:garage/features/documents/documents.dart';
import 'package:garage/features/garage/data/local_garage_repository.dart';
import 'package:garage/features/garage/garage.dart' hide GarageVehicle;

void main() {
  test('local calendar and cents validation', () {
    expect(parseDate('29.02.2024'), DateTime(2024, 2, 29));
    expect(parseDate('29.02.2025'), isNull);
    expect(parseCents('123,45'), 12345);
    expect(parseCents('0'), 0);
    expect(parseCents('1.001'), isNull);
    expect(dueStatus('2026-11-27', DateTime(2026, 11, 27, 23, 59)), 'Днес');
    expect(dueStatus('2026-11-26', DateTime(2026, 11, 27)), 'Просрочено');
    expect(
      () => const DocumentDraft(kind: DocumentKind.tax).validate(),
      throwsA(isA<DocumentValidation>()),
    );
    expect(
      () => const DocumentDraft(
        kind: DocumentKind.casco,
        start: '2026-11-29',
        end: '2026-11-28',
      ).validate(),
      throwsA(isA<DocumentValidation>()),
    );
  });
  test(
    'vehicle isolation, payments, renewal, edits, restart and cascade',
    () async {
      final dir = await Directory.systemTemp.createTemp('bubka-docs-');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/data.db');
      final db = AppDatabase(NativeDatabase(file));
      final garage = LocalGarageRepository(db);
      final repo = LocalDocumentsRepository(db);
      final a = (await garage.save(
        const VehicleDraft(
          brand: 'BMW',
          model: '320d',
          registration: 'CA 1001 AB',
        ),
      )).activeId!;
      final b = (await garage.save(
        const VehicleDraft(
          brand: 'BMW',
          model: '320d',
          registration: 'CA 1002 AB',
        ),
      )).vehicles.last.id;
      final policy = DocumentDraft(
        kind: DocumentKind.liability,
        start: '2026-01-01',
        end: '2026-12-31',
        payments: [
          for (var i = 1; i <= 4; i++)
            PaymentDraft(due: '2026-0$i-01', cents: 10000, paid: i == 1),
        ],
      );
      await repo.save(a, policy);
      await repo.save(
        b,
        const DocumentDraft(kind: DocumentKind.vignette, end: '2027-01-01'),
      );
      final initial = await repo.read();
      expect(initial, hasLength(2));
      final p = initial.singleWhere((r) => r.vehicleId == a);
      final other = initial.singleWhere((r) => r.vehicleId == b);
      final before = deadlinesFor(initial);
      expect(before, hasLength(5));
      await repo.setPaid(a, p.id, p.draft.payments[1].id!, true);
      final updated = (await repo.read()).singleWhere((r) => r.id == p.id);
      expect(
        updated.draft.payments.firstWhere((p) => !p.paid).due,
        '2026-03-01',
      );
      expect(updated.draft.end, policy.end);
      expect(deadlinesFor(await repo.read()), hasLength(4));
      await expectLater(
        repo.remove(b, p.id),
        throwsA(isA<DocumentValidation>()),
      );
      await expectLater(
        repo.save(
          a,
          const DocumentDraft(kind: DocumentKind.inspection, end: '2026-02-31'),
        ),
        throwsA(isA<DocumentValidation>()),
      );
      await repo.save(
        a,
        const DocumentDraft(kind: DocumentKind.liability, end: '2027-12-31'),
        renewId: p.id,
      );
      expect(
        (await repo.read()).singleWhere((r) => r.id == p.id).active,
        isFalse,
      );
      expect(deadlinesFor(await repo.read()), hasLength(4));
      await repo.save(
        b,
        const DocumentDraft(kind: DocumentKind.vignette, end: '2027-02-01'),
        id: other.id,
      );
      await db.close();
      final next = AppDatabase(NativeDatabase(file));
      addTearDown(next.close);
      final stored = LocalDocumentsRepository(next);
      expect(
        (await stored.read()).singleWhere((r) => r.id == other.id).draft.end,
        '2027-02-01',
      );
      await stored.remove(b, other.id);
      expect(await stored.read(), hasLength(2));
      await LocalGarageRepository(next).remove(a);
      expect(await stored.read(), isEmpty);
      expect(
        await next.customSelect('PRAGMA foreign_key_check').get(),
        isEmpty,
      );
    },
  );
}
