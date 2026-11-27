import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/database/database.dart';
import 'package:garage/core/odometer/odometer_reader.dart';
import 'package:garage/features/fuel/fuel.dart';
import 'package:garage/features/fuel/fuel_factory.dart';
import 'package:garage/features/garage/data/local_garage_repository.dart';
import 'package:garage/features/garage/garage.dart' hide GarageVehicle;

FuelDraft entry(String date, int km, [int? ml, int? cents]) =>
    FuelDraft(date: date, odometerKm: km, fuelMl: ml, priceCents: cents);
VehicleDraft car(String reg) =>
    VehicleDraft(brand: 'BMW', model: '320d', registration: reg);
void main() {
  test('scaled input and invalid dates, quantities and odometer', () {
    expect(calendarDateInput('01.02.2024'), '2024-02-01');
    expect(displayCalendarDate('2024-02-01'), '01.02.2024');
    expect(parseQuantity('12,345', 3), 12345);
    expect(parseQuantity('9.9', 2), 990);
    expect(parseQuantity('0', 0), 0);
    for (final text in ['-1', '1.2', '1e3', '']) {
      expect(parseQuantity(text, 0), isNull);
    }
    expect(parseQuantity('1.001', 2), isNull);
    for (final draft in [
      entry('2024-02-30', 1),
      entry('2024-01-01', -1),
      entry('2024-01-01', 1, 0),
      entry('2024-01-01', 1, 100, -1),
      entry('2024-01-01', 1, null, 10),
    ]) {
      expect(draft.validate, throwsA(isA<FuelValidation>()));
    }
  });
  test('two cars, shared odometer, intervals, historical checks, edit, deletion and restart', () async {
    final dir = await Directory.systemTemp.createTemp('bubka-fuel-');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/test.sqlite');
    final db = AppDatabase(NativeDatabase(file));
    final garage = LocalGarageRepository(db);
    final a = (await garage.save(car('CA 1001 AB'))).activeId!;
    final b = (await garage.save(car('CA 1002 AB'))).vehicles.last.id;
    final repo = createFuelRepository(db);
    final OdometerReader reader = repo;
    expect(await reader.latestOdometerKm(a), isNull);
    expect(await reader.latestOdometerKm(b), isNull);
    final first = await repo.save(a, entry('2024-01-01', 153000, 30000));
    expect(first.estimatedConsumption, isNull);
    expect(
      (await repo.save(
        a,
        entry('2024-01-01', 153000, 1000),
      )).estimatedConsumption,
      isNull,
    );
    final middle = await repo.save(a, entry('2024-01-03', 153500, 39000));
    final middleId = middle.entries.last.id;
    final last = await repo.save(a, entry('2024-01-05', 154000, 40000));
    expect(last.estimatedConsumption, closeTo(8, 0.00001));
    expect(await reader.latestOdometerKm(a), 154000);
    expect(await reader.latestOdometerKm(b), isNull);
    await garage.select(b);
    await repo.save(b, entry('2024-01-05', 500));
    await repo.save(a, entry('2024-01-02', 153200));
    expect(await reader.latestOdometerKm(a), 154000);
    await expectLater(
      repo.save(a, entry('2024-01-02', 152999)),
      throwsA(isA<FuelValidation>()),
    );
    await expectLater(
      repo.save(a, entry('2024-01-02', 153501)),
      throwsA(isA<FuelValidation>()),
    );
    await expectLater(
      repo.save(b, entry('2024-01-03', 1), id: middleId),
      throwsA(isA<FuelValidation>()),
    );
    final edited = await repo.save(
      a,
      entry('2024-01-03', 153500, 49000, 0),
      id: middleId,
    );
    expect(edited.estimatedConsumption, closeTo(9, 0.00001));
    final lastId = edited.entries.last.id;
    final manual = await repo.save(a, entry('2024-01-06', 155000));
    expect(manual.estimatedConsumption, closeTo(9, 0.00001));
    expect(await reader.latestOdometerKm(a), 155000);
    await repo.remove(a, manual.entries.last.id);
    expect(await reader.latestOdometerKm(a), 154000);
    await repo.save(a, entry('2024-01-05', 154100, 40000), id: lastId);
    expect(await reader.latestOdometerKm(a), 154100);
    await repo.save(a, entry('2024-01-05', 154000, 40000), id: lastId);
    final order = (await repo.read(a)).entries.map((e) => e.id).toList();
    await db.close();
    final reopened = AppDatabase(NativeDatabase(file));
    addTearDown(reopened.close);
    final next = createFuelRepository(reopened);
    expect((await next.read(a)).entries.map((e) => e.id), order);
    expect(await next.latestOdometerKm(a), 154000);
    await next.remove(a, lastId);
    expect(await next.latestOdometerKm(a), 153500);
    await LocalGarageRepository(reopened).remove(a);
    expect(await next.latestOdometerKm(a), isNull);
    expect(await next.latestOdometerKm(b), 500);
    expect(
      await reopened.customSelect('PRAGMA foreign_key_check').get(),
      isEmpty,
    );
  });
}
