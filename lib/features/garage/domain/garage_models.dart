import 'package:flutter/foundation.dart';

import 'vehicle_catalog.dart';
import 'vehicle_rules.dart';

@immutable
class VehicleDraft {
  const VehicleDraft({
    required this.brand,
    required this.model,
    required this.registration,
    this.year,
    this.fuel,
    this.registrationMode = RegistrationMode.bulgarian,
    this.manualModel = false,
  });
  final String brand, model, registration;
  final int? year;
  final String? fuel;
  final RegistrationMode registrationMode;
  final bool manualModel;

  static String registrationKey(String value) => registrationIdentity(value);

  VehicleDraft validated({VehicleDraft? previous}) {
    final brandChanged = previous == null || brand != previous.brand;
    final modelChanged =
        previous == null || brandChanged || model != previous.model;
    final registrationChanged =
        previous == null || registration != previous.registration;
    final yearChanged = previous == null || year != previous.year;
    final fuelChanged = previous == null || fuel != previous.fuel;
    if (brandChanged && !vehicleCatalog.containsKey(brand)) {
      throw const GarageValidation('Избери марка от каталога.');
    }
    if (modelChanged &&
        (model.trim().isEmpty ||
            (!manualModel && !modelsForBrand(brand).contains(model)))) {
      throw const GarageValidation(
        'Избери модел или използвай „Моят модел липсва“.',
      );
    }
    final normalized = registrationChanged
        ? normalizedRegistration(registration, registrationMode)
        : registration;
    if (normalized == null) {
      throw const GarageValidation(
        'Невалиден или неподдържан формат на регистрационния номер.',
      );
    }
    if (yearChanged && !validYear(year)) {
      throw const GarageValidation('Въведи валидна година.');
    }
    if (fuelChanged && fuel != null && !fuelOptions.contains(fuel)) {
      throw const GarageValidation('Избери гориво от списъка.');
    }
    return VehicleDraft(
      brand: brand,
      model: modelChanged ? model.trim() : model,
      registration: normalized,
      year: year,
      fuel: fuel,
      registrationMode: registrationMode,
      manualModel: manualModel,
    );
  }
}

class GarageValidation implements Exception {
  const GarageValidation(this.message);
  final String message;
}

@immutable
class GarageVehicle {
  const GarageVehicle(this.id, this.details);
  final int id;
  final VehicleDraft details;
  String get name => '${details.brand} ${details.model}';
  String get registration => details.registration;
}

@immutable
class GarageSnapshot {
  GarageSnapshot(List<GarageVehicle> vehicles, this.activeId)
    : vehicles = List.unmodifiable(vehicles);
  final List<GarageVehicle> vehicles;
  final int? activeId;
  GarageVehicle? get active {
    for (final car in vehicles) {
      if (car.id == activeId) return car;
    }
    return null;
  }
}

abstract interface class GarageRepository {
  Future<GarageSnapshot> read();
  Future<GarageSnapshot> save(VehicleDraft draft, {int? id});
  Future<GarageSnapshot> select(int id);
  Future<GarageSnapshot> remove(int id);
}
