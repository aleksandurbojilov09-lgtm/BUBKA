import 'package:flutter/foundation.dart';

import '../domain/fuel_models.dart';

class FuelViewModel extends ChangeNotifier {
  FuelViewModel(this.repository, this.vehicleId);
  final FuelRepository repository;
  final int vehicleId;
  FuelHistory? history;
  bool busy = false, _disposed = false;
  String? error;
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<bool> _run(Future<FuelHistory> Function() action) async {
    if (busy || _disposed) return false;
    busy = true;
    error = null;
    _emit();
    try {
      history = await action();
      return true;
    } on FuelValidation catch (e) {
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

  Future<bool> load() => _run(() => repository.read(vehicleId));
  Future<bool> save(FuelDraft draft, {int? id}) =>
      _run(() => repository.save(vehicleId, draft, id: id));
  Future<bool> remove(int id) => _run(() => repository.remove(vehicleId, id));
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
