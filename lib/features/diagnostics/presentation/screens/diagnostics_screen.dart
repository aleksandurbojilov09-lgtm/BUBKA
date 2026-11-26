import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../core/notifications/notification_service.dart';
import '../../../../design_system/theme.dart';
import '../view_models/diagnostics_view_model.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key, required this.version});
  final String version;

  Future<void> _testNotification(
    BuildContext context,
    NotificationService service,
  ) async {
    String message;
    try {
      if (await service.requestPermission()) {
        await service.upsert(
          LocalReminder(
            id: 2147483647,
            title: 'BUBKA',
            body: 'Тестово локално известие',
            localDateTime: DateTime.now().add(const Duration(minutes: 2)),
          ),
        );
        message = 'Планирано тестово известие (около 2 минути).';
      } else {
        message = 'Разрешението за известия е отказано.';
      }
    } catch (_) {
      message = 'Неуспешно планиране на известието.';
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiagnosticsViewModel>();
    final notifications = context.read<NotificationService?>();
    return Scaffold(
      appBar: AppBar(title: const Text('Диагностика')),
      body: ListView(
        padding: const EdgeInsets.all(BubkaDesign.spacing),
        children: [
          Text('Версия: $version'),
          Text(
            vm.error ??
                (vm.ready ? 'Локална база: достъпна' : 'Проверка на базата…'),
          ),
          if (vm.busy) const LinearProgressIndicator(),
          FilledButton(
            onPressed: vm.busy ? null : vm.load,
            child: const Text('Провери базата'),
          ),
          FilledButton(
            onPressed: vm.busy ? null : vm.add,
            child: const Text('Добави тестов запис'),
          ),
          if (notifications != null)
            FilledButton(
              onPressed: () => _testNotification(context, notifications),
              child: const Text('Тестово известие'),
            ),
          if (notifications != null)
            FilledButton(
              onPressed: () => notifications.cancel(2147483647),
              child: const Text('Отмени тестовото известие'),
            ),
          for (final item in vm.items)
            Card(
              child: ListTile(
                title: Text(item.value),
                subtitle: Text('ID: ${item.id}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Редактирай',
                      onPressed: vm.busy ? null : () => vm.edit(item.id),
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      tooltip: 'Изтрий',
                      onPressed: vm.busy ? null : () => vm.remove(item.id),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
