import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import '../domain/fuel_models.dart';

class LocalFuelRepository implements FuelRepository {
  LocalFuelRepository(this.db);
  final AppDatabase db;

  @override
  Future<FuelHistory> read(int vehicleId) async {
    final rows =
        await (db.select(db.fuelEntries)
              ..where((t) => t.vehicleId.equals(vehicleId))
              ..orderBy([
                (t) => OrderingTerm.asc(t.entryDate),
                (t) => OrderingTerm.asc(t.odometerKm),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    return FuelHistory([
      for (final row in rows)
        FuelRecord(
          row.id,
          row.vehicleId,
          FuelDraft(
            date: row.entryDate,
            odometerKm: row.odometerKm,
            fuelMl: row.fuelMl,
            priceCents: row.priceCents,
          ),
        ),
    ]);
  }

  @override
  Future<int?> latestOdometerKm(int vehicleId) async =>
      (await read(vehicleId)).latestKm;

  @override
  Future<FuelHistory> save(int vehicleId, FuelDraft draft, {int? id}) =>
      db.transaction(() async {
        draft.validate();
        final vehicle = await (db.select(
          db.garageVehicles,
        )..where((t) => t.id.equals(vehicleId))).getSingleOrNull();
        if (vehicle == null) {
          throw const FuelValidation('Автомобилът вече не съществува.');
        }
        final history = await read(vehicleId);
        if (id != null && !history.entries.any((e) => e.id == id)) {
          throw const FuelValidation('Записът вече не съществува.');
        }
        for (final entry in history.entries.where((e) => e.id != id)) {
          final order = entry.draft.date.compareTo(draft.date);
          if ((order < 0 && entry.draft.odometerKm > draft.odometerKm) ||
              (order > 0 && entry.draft.odometerKm < draft.odometerKm)) {
            throw const FuelValidation(
              'Километражът не съвпада с показанията преди или след тази дата.',
            );
          }
        }
        final value = FuelEntriesCompanion.insert(
          vehicleId: vehicleId,
          entryDate: draft.date,
          odometerKm: draft.odometerKm,
          fuelMl: Value(draft.fuelMl),
          priceCents: Value(draft.priceCents),
        );
        if (id == null) {
          await db.into(db.fuelEntries).insert(value);
        } else {
          final changed =
              await (db.update(db.fuelEntries)..where(
                    (t) => t.id.equals(id) & t.vehicleId.equals(vehicleId),
                  ))
                  .write(value);
          if (changed != 1) {
            throw const FuelValidation('Записът вече не съществува.');
          }
        }
        return read(vehicleId);
      });

  @override
  Future<FuelHistory> remove(int vehicleId, int id) => db.transaction(() async {
    final changed = await (db.delete(
      db.fuelEntries,
    )..where((t) => t.id.equals(id) & t.vehicleId.equals(vehicleId))).go();
    if (changed != 1) throw const FuelValidation('Записът вече не съществува.');
    return read(vehicleId);
  });
}
