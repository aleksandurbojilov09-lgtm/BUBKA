import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/notifications/notification_service.dart';
import '../domain/document_models.dart';

class DocumentsViewModel extends ChangeNotifier {
  DocumentsViewModel(this.repository, this.notifications);
  final DocumentsRepository repository;
  final NotificationService? notifications;
  StreamSubscription<List<DocumentRecord>>? _subscription;
  List<DocumentRecord>? records;
  String? error, notificationError;
  bool busy = false, _disposed = false;
  Future<void> _queue = Future.value();
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  void load() {
    if (_subscription != null) return;
    _subscription = repository.watch().listen(
      (rows) {
        records = rows;
        error = null;
        _emit();
        unawaited(sync());
      },
      onError: (Object e) {
        error = 'Данните не могат да бъдат заредени.';
        _emit();
      },
    );
  }

  Future<void> sync() {
    _queue = _queue.then((_) async {
      final rows = records;
      final service = notifications;
      if (_disposed || rows == null) return;
      if (service == null) {
        _emit();
        return;
      }
      try {
        final reminders = <LocalReminder>[];
        for (final d in deadlinesFor(rows)) {
          final day = parseDate(d.date)!;
          for (final offset in [7, 1]) {
            reminders.add(
              LocalReminder(
                id: d.reminderId(offset),
                title: d.label,
                body: '${d.vehicleName} · ${displayDate(d.date)}',
                localDateTime: DateTime(
                  day.year,
                  day.month,
                  day.day - offset,
                  9,
                ),
              ),
            );
          }
        }
        await service.replaceRange(1000000000, 1900000001, reminders);
        notificationError = null;
      } catch (_) {
        notificationError =
            'Напомнянията не са синхронизирани. Записите са запазени.';
      }
      _emit();
    });
    return _queue;
  }

  Future<void> permission() async {
    final service = notifications;
    if (service == null) return;
    try {
      if (!await service.requestPermission()) {
        notificationError =
            'Известията са отказани. Сроковете остават достъпни.';
        _emit();
        return;
      }
      await sync();
    } catch (_) {
      notificationError = 'Известията не са достъпни.';
      _emit();
    }
  }

  Future<bool> run(Future<void> Function() action) async {
    if (busy || _disposed) return false;
    busy = true;
    error = null;
    _emit();
    try {
      await action();
      return true;
    } on DocumentValidation catch (e) {
      error = e.message;
      return false;
    } catch (_) {
      error = 'Промяната не може да бъде записана.';
      return false;
    } finally {
      busy = false;
      _emit();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
