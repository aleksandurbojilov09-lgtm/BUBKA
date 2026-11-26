import 'package:flutter/widgets.dart';

import '../core/notifications/notification_service.dart';
import '../core/notifications/platform_notification_adapter.dart';
import '../core/updates/update_manifest.dart';
import '../core/updates/update_service.dart';
import 'app.dart';
import 'providers/update_controller.dart';
import 'version.dart';
import 'providers/composition.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    BubkaApp(
      database: createDatabase(),
      updates: UpdateController(
        UpdateService(
          current: ReleaseVersion(appVersion, int.parse(appBuild)),
          channel: UpdateChannel.testing,
        ),
      ),
      notifications: NotificationService(PlatformNotificationAdapter()),
    ),
  );
}
