import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../design_system/theme.dart';
import '../view_models/diagnostics_view_model.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key, required this.version});
  final String version;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiagnosticsViewModel>();
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
