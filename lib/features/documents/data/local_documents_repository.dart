import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import '../domain/document_models.dart';

class LocalDocumentsRepository implements DocumentsRepository {
  LocalDocumentsRepository(this.db);
  final AppDatabase db;
  Future<List<DocumentRecord>> read() => db.transaction(() async {
    final cars = {
      for (final c in await db.select(db.garageVehicles).get()) c.id: c,
    };
    final rows = await db.select(db.vehicleDocuments).get();
    final payments = await db.select(db.documentPayments).get();
    return [
      for (final r in rows)
        if (cars.containsKey(r.vehicleId))
          DocumentRecord(
            r.id,
            r.vehicleId,
            '${cars[r.vehicleId]!.brand} ${cars[r.vehicleId]!.model} · ${cars[r.vehicleId]!.registration}',
            r.active,
            DocumentDraft(
              kind: DocumentKind.values.byName(r.kind),
              start: r.startDate,
              end: r.endDate,
              payments: [
                for (final p in payments.where((p) => p.documentId == r.id))
                  PaymentDraft(
                    id: p.id,
                    due: p.dueDate,
                    cents: p.amountCents,
                    paid: p.paid,
                  ),
              ]..sort((a, b) => a.due.compareTo(b.due)),
            ),
          ),
    ];
  });
  @override
  Stream<List<DocumentRecord>> watch() => db
      .customSelect(
        'SELECT 1',
        readsFrom: {
          db.vehicleDocuments,
          db.documentPayments,
          db.garageVehicles,
        },
      )
      .watch()
      .asyncMap((_) => read());
  Future<VehicleDocumentRow> _owned(int vehicleId, int id) async {
    final r =
        await (db.select(db.vehicleDocuments)
              ..where((t) => t.id.equals(id) & t.vehicleId.equals(vehicleId)))
            .getSingleOrNull();
    if (r == null) {
      throw const DocumentValidation('Документът вече не съществува.');
    }
    return r;
  }

  @override
  Future<void> save(
    int vehicleId,
    DocumentDraft draft, {
    int? id,
    int? renewId,
  }) => db.transaction(() async {
    draft.validate();
    if (id != null && renewId != null) {
      throw const DocumentValidation('Невалидна редакция.');
    }
    if (await (db.select(
          db.garageVehicles,
        )..where((t) => t.id.equals(vehicleId))).getSingleOrNull() ==
        null) {
      throw const DocumentValidation('Автомобилът вече не съществува.');
    }
    final previous = id == null ? null : await _owned(vehicleId, id);
    if (previous != null && previous.kind != draft.kind.name) {
      throw const DocumentValidation(
        'Видът на документа не може да бъде променен.',
      );
    }
    if (renewId != null) {
      final old = await _owned(vehicleId, renewId);
      if (!old.active || old.kind != draft.kind.name) {
        throw const DocumentValidation('Невалидно подновяване.');
      }
      await (db.update(db.vehicleDocuments)..where((t) => t.id.equals(renewId)))
          .write(const VehicleDocumentsCompanion(active: Value(false)));
    }
    final row = VehicleDocumentsCompanion.insert(
      vehicleId: vehicleId,
      kind: draft.kind.name,
      startDate: Value(draft.start),
      endDate: Value(draft.end),
    );
    final int docId;
    if (id == null) {
      docId = await db.into(db.vehicleDocuments).insert(row);
    } else {
      docId = id;
      await (db.update(
        db.vehicleDocuments,
      )..where((t) => t.id.equals(id))).write(row);
    }
    final old = await (db.select(
      db.documentPayments,
    )..where((t) => t.documentId.equals(docId))).get();
    final kept = <int>{};
    for (final p in draft.payments) {
      final value = DocumentPaymentsCompanion.insert(
        documentId: docId,
        dueDate: p.due,
        amountCents: p.cents,
        paid: Value(p.paid),
      );
      if (p.id == null) {
        await db.into(db.documentPayments).insert(value);
      } else {
        if (!old.any((x) => x.id == p.id)) {
          throw const DocumentValidation(
            'Вноската не принадлежи към документа.',
          );
        }
        kept.add(p.id!);
        await (db.update(
          db.documentPayments,
        )..where((t) => t.id.equals(p.id!))).write(value);
      }
    }
    for (final p in old.where((p) => !kept.contains(p.id))) {
      await (db.delete(
        db.documentPayments,
      )..where((t) => t.id.equals(p.id))).go();
    }
  });
  @override
  Future<void> remove(int vehicleId, int id) => db.transaction(() async {
    await _owned(vehicleId, id);
    await (db.delete(db.vehicleDocuments)..where((t) => t.id.equals(id))).go();
  });
  @override
  Future<void> setPaid(
    int vehicleId,
    int documentId,
    int paymentId,
    bool paid,
  ) => db.transaction(() async {
    await _owned(vehicleId, documentId);
    final count =
        await (db.update(db.documentPayments)..where(
              (t) => t.id.equals(paymentId) & t.documentId.equals(documentId),
            ))
            .write(DocumentPaymentsCompanion(paid: Value(paid)));
    if (count != 1) {
      throw const DocumentValidation('Вноската вече не съществува.');
    }
  });
}
