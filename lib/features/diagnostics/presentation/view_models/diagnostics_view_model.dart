import 'package:flutter/foundation.dart';

import '../../../../core/errors/local_failure.dart';
import '../../domain/repository.dart';

class DiagnosticsViewModel extends ChangeNotifier {
  DiagnosticsViewModel(this.repository);
  final DiagnosticsRepository repository;
  List<DiagnosticItem> items = const [];
  bool busy = false;
  bool ready = false;
  String? error;
  bool _disposed = false;

  Future<void> load() => _run(() async {});
  Future<void> add() => _run(repository.add);
  Future<void> edit(int id) => _run(() => repository.edit(id));
  Future<void> remove(int id) => _run(() => repository.remove(id));

  Future<void> _run(Future<void> Function() operation) async {
    if (busy || _disposed) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await operation();
      items = List.unmodifiable(await repository.read());
      ready = true;
    } catch (_) {
      error = localDatabaseError;
      ready = false;
    } finally {
      busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
