import 'package:flutter/widgets.dart';

import '../core/notifications/notification_service.dart';
import '../core/notifications/platform_notification_adapter.dart';
import 'app.dart';
import 'providers/composition.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    BubkaApp(
      database: createDatabase(),
      notifications: NotificationService(PlatformNotificationAdapter()),
    ),
  );
}
