import 'package:flutter/foundation.dart';

@immutable
class VehicleDraft {
  const VehicleDraft({
    required this.brand,
    required this.model,
    required this.registration,
    this.year,
    this.fuel,
  });
  final String brand, model, registration;
  final int? year;
  final String? fuel;

  static String registrationKey(String value) =>
      value.replaceAll(RegExp(r'\s+', unicode: true), '').toUpperCase();

  VehicleDraft validated() {
    final normalized = VehicleDraft(
      brand: brand.trim(),
      model: model.trim(),
      registration: registration.trim(),
      year: year,
      fuel: fuel?.trim(),
    );
    if (normalized.brand.isEmpty ||
        normalized.model.isEmpty ||
        registrationKey(normalized.registration).isEmpty) {
      throw const GarageValidation(
        'Попълни марка, модел и регистрационен номер.',
      );
    }
    if (year != null && (year! < 1 || year! > 9999)) {
      throw const GarageValidation('Въведи валидна година.');
    }
    return normalized;
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
