import 'package:drift/drift.dart';

import '../../../core/database/database.dart' hide GarageVehicle;
import '../domain/garage_models.dart';

class LocalGarageRepository implements GarageRepository {
  LocalGarageRepository(this.db);
  final AppDatabase db;

  Future<GarageSnapshot> _snapshot() async {
    final rows = await (db.select(
      db.garageVehicles,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
    final active = await db.select(db.activeGarageVehicles).getSingleOrNull();
    return GarageSnapshot([
      for (final row in rows)
        GarageVehicle(
          row.id,
          VehicleDraft(
            brand: row.brand,
            model: row.model,
            registration: row.registration,
            year: row.year,
            fuel: row.fuel,
          ),
        ),
    ], active?.vehicleId);
  }

  @override
  Future<GarageSnapshot> read() => db.transaction(_snapshot);

  Future<void> _setActive(int id) async {
    await db
        .into(db.activeGarageVehicles)
        .insertOnConflictUpdate(
          ActiveGarageVehiclesCompanion(
            slot: const Value(1),
            vehicleId: Value(id),
          ),
        );
  }

  @override
  Future<GarageSnapshot> save(VehicleDraft draft, {int? id}) =>
      db.transaction(() async {
        final value = draft.validated();
        final key = VehicleDraft.registrationKey(value.registration);
        final existing = await (db.select(
          db.garageVehicles,
        )..where((t) => t.registrationKey.equals(key))).getSingleOrNull();
        if (existing != null && existing.id != id) {
          throw const GarageValidation(
            'Вече има автомобил с този регистрационен номер.',
          );
        }
        final companion = GarageVehiclesCompanion.insert(
          brand: value.brand,
          model: value.model,
          registration: value.registration,
          registrationKey: key,
          year: Value(value.year),
          fuel: Value(value.fuel == '' ? null : value.fuel),
        );
        if (id == null) {
          final newId = await db.into(db.garageVehicles).insert(companion);
          if ((await db.select(db.activeGarageVehicles).get()).isEmpty) {
            await _setActive(newId);
          }
        } else {
          final changed = await (db.update(
            db.garageVehicles,
          )..where((t) => t.id.equals(id))).write(companion);
          if (changed != 1) {
            throw const GarageValidation('Автомобилът вече не съществува.');
          }
        }
        return _snapshot();
      });

  @override
  Future<GarageSnapshot> select(int id) => db.transaction(() async {
    final car = await (db.select(
      db.garageVehicles,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (car == null) {
      throw const GarageValidation('Автомобилът вече не съществува.');
    }
    await _setActive(id);
    return _snapshot();
  });

  @override
  Future<GarageSnapshot> remove(int id) => db.transaction(() async {
    final before = await _snapshot();
    if (!before.vehicles.any((car) => car.id == id)) {
      throw const GarageValidation('Автомобилът вече не съществува.');
    }
    if (before.activeId == id) await db.delete(db.activeGarageVehicles).go();
    await (db.delete(db.garageVehicles)..where((t) => t.id.equals(id))).go();
    final after = await _snapshot();
    if (after.activeId == null && after.vehicles.isNotEmpty) {
      await _setActive(after.vehicles.first.id);
    }
    return _snapshot();
  });
}
