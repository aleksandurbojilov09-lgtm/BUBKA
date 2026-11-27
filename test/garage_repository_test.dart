import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/database/database.dart';
import 'package:garage/features/garage/data/local_garage_repository.dart';
import 'package:garage/features/garage/garage.dart';
import 'package:garage/features/garage/domain/vehicle_catalog.dart';

VehicleDraft draft(
  String reg, {
  String brand = 'BMW',
  String model = '320d',
  RegistrationMode mode = RegistrationMode.bulgarian,
  bool manual = false,
}) => VehicleDraft(
  brand: brand,
  model: model,
  registration: reg,
  registrationMode: mode,
  manualModel: manual,
);
void main() {
  test('validation, catalog and duplicate rules', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = LocalGarageRepository(db);
    expect(modelsForBrand('bmw'), contains('320d'));
    expect(modelsForBrand('BMW'), isNot(contains('Golf')));
    expect(modelsForBrand('Missing brand'), isEmpty);
    for (final invalid in [
      draft('  '),
      draft('CA 1', brand: ' '),
      draft('CA 1', model: ' '),
    ]) {
      await expectLater(repo.save(invalid), throwsA(isA<GarageValidation>()));
    }
    final first = await repo.save(draft('CA 1234 AB'));
    expect(first.active!.registration, 'CA 1234 AB');
    expect(first.active!.details.year, isNull);
    expect(first.active!.details.fuel, isNull);
    await expectLater(
      repo.save(draft('ca1234ab')),
      throwsA(isA<GarageValidation>()),
    );
    final second = await repo.save(
      draft(
        'B-XY 87',
        model: 'Custom model',
        manual: true,
        mode: RegistrationMode.foreign,
      ),
    );
    expect(second.activeId, first.activeId);
    final other = second.vehicles.last.id;
    await expectLater(
      repo.save(draft('ca 1234 ab'), id: other),
      throwsA(isA<GarageValidation>()),
    );
    expect(
      (await repo.save(draft('ca 1234 ab'), id: first.activeId)).activeId,
      first.activeId,
    );
    expect((await repo.read()).vehicles, hasLength(2));
  });
  test(
    'active choice, editing, persistence and deterministic deletion',
    () async {
      final dir = await Directory.systemTemp.createTemp('garage-test-');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/test.sqlite');
      final db = AppDatabase(NativeDatabase(file));
      final repo = LocalGarageRepository(db);
      expect((await repo.read()).active, isNull);
      final a = (await repo.save(draft('CA 1001 AB'))).activeId!;
      final b = (await repo.save(draft('CA 1002 AB'))).vehicles.last.id;
      final c = (await repo.save(draft('CA 1003 AB'))).vehicles.last.id;
      expect((await repo.select(b)).activeId, b);
      expect(
        (await repo.save(draft('CA 1004 AB', model: 'X5'), id: b)).active!.name,
        'BMW X5',
      );
      await db.close();
      final reopened = AppDatabase(NativeDatabase(file));
      addTearDown(reopened.close);
      final stored = LocalGarageRepository(reopened);
      expect((await stored.read()).activeId, b);
      expect((await stored.remove(c)).activeId, b);
      expect((await stored.remove(b)).activeId, a);
      expect((await stored.remove(a)).active, isNull);
      expect((await stored.read()).vehicles, isEmpty);
      expect((await stored.save(draft('CA 1005 AB'))).activeId, greaterThan(c));
      expect(
        await reopened.customSelect('PRAGMA foreign_key_check').get(),
        isEmpty,
      );
    },
  );
  test('viewmodel publishes real state and safe validation errors', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final vm = GarageViewModel(LocalGarageRepository(db));
    addTearDown(vm.dispose);
    expect(await vm.load(), isTrue);
    expect(await vm.save(draft('CA 1006 AB')), isTrue);
    final id = vm.active!.id;
    expect(await vm.save(draft('ca1006ab')), isFalse);
    expect(vm.error, contains('Вече има'));
    expect(vm.active!.id, id);
  });
  test('catalog search and strict validation modes', () {
    expect(searchBrands('МеРц'), contains('Mercedes-Benz'));
    expect(searchBrands('merc'), contains('Mercedes-Benz'));
    expect(searchBrands('Панда'), isEmpty);
    expect(searchModels('Fiat', 'pan'), ['Panda']);
    expect(searchModels('BMW', 'Golf'), isEmpty);
    expect(draft('КH 1234 АB').validated().registration, 'KH 1234 AB');
    expect(draft('СВ 5678 КА').validated().registration, 'CB 5678 KA');
    expect(draft('C 1234 A').validated().registration, 'C 1234 A');
    for (final value in [
      'Александър',
      'Дупница',
      'Моята кола',
      'AB123',
      'X-1',
      'C 12345 AB',
    ]) {
      expect(() => draft(value).validated(), throwsA(isA<GarageValidation>()));
    }
    for (final value in [
      'Александър',
      'Дупница',
      'Моята кола',
      'A',
      'A!123',
      'A--123',
      'ABCDEFGHIJKL9',
    ]) {
      expect(
        () => draft(value, mode: RegistrationMode.foreign).validated(),
        throwsA(isA<GarageValidation>()),
      );
    }
    expect(
      draft(
        'DE AB-123',
        mode: RegistrationMode.foreign,
      ).validated().registration,
      'DE AB-123',
    );
    expect(
      draft(
        'СА КАТЕРА',
        mode: RegistrationMode.personalized,
      ).validated().registration,
      'CA KATEPA',
    );
    expect(
      () =>
          draft('Александър', mode: RegistrationMode.personalized).validated(),
      throwsA(isA<GarageValidation>()),
    );
    expect(
      () => draft('CA 1234 AB', brand: 'Panda').validated(),
      throwsA(isA<GarageValidation>()),
    );
    expect(
      () => draft('CA 1234 AB', model: 'Golf').validated(),
      throwsA(isA<GarageValidation>()),
    );
    expect(
      draft('CA 1234 AB', model: 'E46 custom', manual: true).validated().model,
      'E46 custom',
    );
    final now = DateTime.now().year;
    expect(validYearText('1886'), isTrue);
    expect(validYearText('$now'), isTrue);
    for (final value in ['1885', '${now + 1}', '123', '02000', '20a0']) {
      expect(validYearText(value), isFalse);
    }
    for (final fuel in fuelOptions) {
      expect(
        VehicleDraft(
          brand: 'BMW',
          model: '320d',
          registration: 'CA 1234 AB',
          fuel: fuel,
        ).validated().fuel,
        fuel,
      );
    }
    expect(
      () => const VehicleDraft(
        brand: 'BMW',
        model: '320d',
        registration: 'CA 1234 AB',
        fuel: 'Дупница',
      ).validated(),
      throwsA(isA<GarageValidation>()),
    );
  });
  test('legacy rows preserved literally, duplicate across modes and scripts rejected', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final id = await db
        .into(db.garageVehicles)
        .insert(
          GarageVehiclesCompanion.insert(
            brand: 'Panda',
            model: 'Unknown ',
            registration: 'КН 1234 АВ',
            registrationKey: 'КН1234АВ',
            year: const Value(1),
            fuel: const Value('Дупница'),
          ),
        );
    final repo = LocalGarageRepository(db);
    await repo.select(id);
    final old = (await repo.read()).active!.details;
    await expectLater(
      repo.save(draft('KH1234AB')),
      throwsA(isA<GarageValidation>()),
    );
    await expectLater(
      repo.save(draft('KH-1234-AB', mode: RegistrationMode.foreign)),
      throwsA(isA<GarageValidation>()),
    );
    final edited = await repo.save(
      VehicleDraft(
        brand: old.brand,
        model: old.model,
        registration: old.registration,
        year: 2001,
        fuel: old.fuel,
      ),
      id: id,
    );
    expect(edited.activeId, id);
    expect(edited.active!.details.brand, 'Panda');
    expect(edited.active!.details.model, 'Unknown ');
    expect(edited.active!.registration, 'КН 1234 АВ');
    expect(edited.active!.details.fuel, 'Дупница');
    expect(
      (await db.select(db.garageVehicles).getSingle()).registrationKey,
      'КН1234АВ',
    );
    await expectLater(
      repo.save(
        VehicleDraft(
          brand: old.brand,
          model: old.model,
          registration: old.registration,
          year: 2001,
          fuel: 'София',
        ),
        id: id,
      ),
      throwsA(isA<GarageValidation>()),
    );
    final fixed = await repo.save(
      const VehicleDraft(
        brand: 'BMW',
        model: 'X5',
        registration: 'KH 1234 AB',
        year: 2001,
        fuel: 'Дизел',
      ),
      id: id,
    );
    expect(fixed.activeId, id);
    expect(fixed.active!.details.fuel, 'Дизел');
    expect(
      (await db.select(db.garageVehicles).getSingle()).registrationKey,
      'KH1234AB',
    );
    final legacyId = await db
        .into(db.garageVehicles)
        .insert(
          GarageVehiclesCompanion.insert(
            brand: 'BMW',
            model: 'X5',
            registration: 'Александър',
            registrationKey: 'АЛЕКСАНДЪР',
          ),
        );
    final unchanged = await repo.save(
      const VehicleDraft(
        brand: 'BMW',
        model: 'X5',
        registration: 'Александър',
        fuel: 'Бензин',
      ),
      id: legacyId,
    );
    expect(unchanged.vehicles.last.registration, 'Александър');
    expect(unchanged.activeId, id);
    await expectLater(
      repo.save(
        const VehicleDraft(
          brand: 'BMW',
          model: 'X5',
          registration: 'Дупница',
          fuel: 'Бензин',
        ),
        id: legacyId,
      ),
      throwsA(isA<GarageValidation>()),
    );
  });
}
