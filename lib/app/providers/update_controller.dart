import 'package:flutter/foundation.dart';

import '../../core/updates/update_service.dart';

class UpdateController extends ChangeNotifier {
  UpdateController(this.service);
  final UpdateService service;
  AvailableUpdate? available;
  bool busy = false;
  double? progress;
  String? message;
  bool dismissed = false;

  Future<void> check({bool manual = false}) async {
    if (busy) {
      return;
    }
    busy = true;
    if (manual) {
      dismissed = false;
    }
    message = null;
    notifyListeners();
    try {
      available = await service.check(manual: manual);
      if (manual && available == null) {
        message = 'Няма налична актуализация.';
      }
    } catch (_) {
      if (manual) {
        message = 'Проверката е неуспешна. Опитай по-късно.';
      }
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void later() {
    dismissed = true;
    notifyListeners();
  }

  Future<void> install() async {
    final update = available;
    if (busy || update == null) {
      return;
    }
    busy = true;
    progress = 0;
    message = null;
    notifyListeners();
    try {
      final result = await service.install(update, (value) {
        progress = value;
        notifyListeners();
      });
      message = result == 'permission'
          ? 'Разреши инсталиране от BUBA и натисни отново.'
          : 'Завърши инсталацията в системния прозорец или SideStore.';
    } catch (_) {
      message = 'Актуализацията не премина проверката или изтеглянето.';
    } finally {
      busy = false;
      progress = null;
      notifyListeners();
    }
  }
}
