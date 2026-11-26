import 'package:flutter/foundation.dart';

import '../../core/database/database.dart';
import '../../core/errors/local_failure.dart';

class ModuleAvailability extends ChangeNotifier {
  ModuleAvailability(this.db);
  final AppDatabase db;
  final Map<String, bool> _enabled = {};
  bool loaded = false;
  bool _disposed = false;
  String? error;
  bool isEnabled(String id) => loaded && (_enabled[id] ?? true);

  Future<void> load() async {
    try {
      final values = await db.select(db.modulePreferences).get();
      _enabled.clear();
      for (final value in values) {
        _enabled[value.moduleId] = value.enabled;
      }
      loaded = true;
      error = null;
    } catch (_) {
      error = localDatabaseError;
      loaded = false;
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> setEnabled(String id, bool enabled) async {
    if (!loaded || _disposed) return;
    try {
      await db
          .into(db.modulePreferences)
          .insertOnConflictUpdate(
            ModulePreferencesCompanion.insert(moduleId: id, enabled: enabled),
          );
      _enabled[id] = enabled;
      error = null;
    } catch (_) {
      error = localDatabaseError;
    }
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
