import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/database/database.dart';
import '../core/notifications/notification_service.dart';
import '../design_system/theme.dart';
import '../features/diagnostics/diagnostics.dart';
import 'modules/module_availability.dart';
import 'modules/module_registry.dart';
import 'providers/composition.dart';
import 'providers/update_controller.dart';
import 'router/router.dart';

class BubkaApp extends StatefulWidget {
  const BubkaApp({super.key, required this.database, this.notifications, this.updates});
  final AppDatabase database;
  final NotificationService? notifications;
  final UpdateController? updates;

  @override
  State<BubkaApp> createState() => _BubkaAppState();
}

class _BubkaAppState extends State<BubkaApp> {
  late final ModuleRegistry _registry;
  late final ModuleAvailability _availability;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _registry = createRegistry();
    _availability = ModuleAvailability(widget.database);
    _router = createRouter(_registry, _availability);
    unawaited(_availability.load());
    final updates = widget.updates;
    if (updates != null) {
      unawaited(updates.check());
    }
    final notifications = widget.notifications;
    if (notifications != null) {
      unawaited(_restoreNotifications(notifications));
    }
  }

  Future<void> _restoreNotifications(NotificationService service) async {
    try {
      await service.synchronize();
    } catch (_) {
      // Permission or platform errors must not prevent offline startup.
    }
  }

  @override
  void dispose() {
    _router.dispose();
    _availability.dispose();
    unawaited(widget.database.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      Provider<AppDatabase>.value(value: widget.database),
      Provider<NotificationService?>.value(value: widget.notifications),
      ChangeNotifierProvider<UpdateController?>.value(value: widget.updates),
      Provider<ModuleRegistry>.value(value: _registry),
      Provider<DiagnosticsRepository>(
        create: (_) => LocalDiagnosticsRepository(widget.database),
      ),
      ChangeNotifierProvider<ModuleAvailability>.value(value: _availability),
    ],
    child: MaterialApp.router(
      title: 'BUBKA',
      debugShowCheckedModeBanner: false,
      theme: BubkaDesign.dark,
      routerConfig: _router,
    ),
  );
}
