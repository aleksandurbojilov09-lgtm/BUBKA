import 'package:flutter/foundation.dart';

import '../../../design_system/resource_ring.dart';

@immutable
class VehiclePresentation {
  const VehiclePresentation({
    required this.id,
    required this.name,
    this.registration,
    required this.fuel,
    required this.year,
  });
  final String id, name, fuel;
  final String? registration;
  final int year;
}

/// Test-only visual data. No database or production store is involved.
class CockpitFixtureModel extends ChangeNotifier {
  static const vehicles = [
    VehiclePresentation(
      id: 'demo-1',
      name: 'BMW 320d',
      registration: 'DEMO 01',
      fuel: 'Дизел',
      year: 2018,
    ),
    VehiclePresentation(
      id: 'demo-2',
      name: 'Toyota Corolla',
      registration: 'DEMO 02',
      fuel: 'Бензин',
      year: 2020,
    ),
  ];
  int _index = 0;
  final Map<String, ResourceChoice> _choice = {};
  final Map<String, ResourceView> _resources = {
    'demo-1:insurance': const ResourceView(
      state: ResourceState.active,
      fraction: .5,
      remaining: 14,
    ),
    'demo-2:insurance': const ResourceView(
      state: ResourceState.active,
      fraction: 1,
      remaining: 365,
    ),
  };
  String get _resourceKey => '${selected.id}:${choice.name}';
  int get index => _index;
  VehiclePresentation get selected => vehicles[_index];
  ResourceChoice get choice => _choice[selected.id] ?? ResourceChoice.insurance;
  ResourceView get resource => _resources[_resourceKey] ?? const ResourceView();
  void select(int index) {
    if (index < 0 || index >= vehicles.length || _index == index) return;
    _index = index;
    notifyListeners();
  }

  void selectChoice(ResourceChoice value) {
    _choice[selected.id] = value;
    notifyListeners();
  }

  void showResource(ResourceView value) {
    _resources[_resourceKey] = value;
    notifyListeners();
  }
}
