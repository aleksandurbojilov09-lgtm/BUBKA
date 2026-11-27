import 'package:flutter/foundation.dart';

import '../domain/garage_models.dart';

class GarageViewModel extends ChangeNotifier {
  GarageViewModel(this._repo);
  final GarageRepository _repo;
  GarageSnapshot? snapshot;
  bool busy = false;
  bool _disposed = false;
  String? error;
  GarageVehicle? get active => snapshot?.active;

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<bool> _run(Future<GarageSnapshot> Function() action) async {
    if (busy || _disposed) return false;
    busy = true;
    error = null;
    _emit();
    try {
      snapshot = await action();
      return true;
    } on GarageValidation catch (e) {
      error = e.message;
      return false;
    } catch (_) {
      error = 'Данните не могат да бъдат обработени. Опитай отново.';
      return false;
    } finally {
      busy = false;
      _emit();
    }
  }

  Future<bool> load() => _run(_repo.read);
  Future<bool> save(VehicleDraft draft, {int? id}) =>
      _run(() => _repo.save(draft, id: id));
  Future<bool> select(int id) => _run(() => _repo.select(id));
  Future<bool> remove(int id) => _run(() => _repo.remove(id));
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
