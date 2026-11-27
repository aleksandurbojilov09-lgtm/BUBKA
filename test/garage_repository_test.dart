import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/database/database.dart';
import 'package:garage/features/garage/data/local_garage_repository.dart';
import 'package:garage/features/garage/garage.dart';
import 'package:garage/features/garage/domain/vehicle_catalog.dart';

VehicleDraft draft(String reg, {String brand = 'BMW', String model = '320d'}) =>
    VehicleDraft(brand: brand, model: model, registration: reg);
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
      draft('B-XY 87', brand: 'Custom', model: 'Custom model'),
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
      final a = (await repo.save(draft('A1'))).activeId!;
      final b = (await repo.save(draft('B2'))).vehicles.last.id;
      final c = (await repo.save(draft('C3'))).vehicles.last.id;
      expect((await repo.select(b)).activeId, b);
      expect(
        (await repo.save(draft('B3', model: 'X5'), id: b)).active!.name,
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
      expect((await stored.save(draft('D4'))).activeId, greaterThan(c));
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
    expect(await vm.save(draft('DE 123')), isTrue);
    final id = vm.active!.id;
    expect(await vm.save(draft('de123')), isFalse);
    expect(vm.error, contains('Вече има'));
    expect(vm.active!.id, id);
  });
}
