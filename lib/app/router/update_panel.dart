import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/update_controller.dart';

class UpdatePanel extends StatelessWidget {
  const UpdatePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UpdateController?>();
    if (controller == null) {
      return const SizedBox.shrink();
    }
    final update = controller.available;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (update != null && !controller.dismissed) ...[
          Text(
            'Нова версия: ${update.asset.version.version}+${update.asset.version.build}',
          ),
          Text(
            'Размер: ${(update.asset.size / 1000000).toStringAsFixed(1)} MB',
          ),
          if (update.notes.isNotEmpty) Text(update.notes),
          FilledButton(
            onPressed: controller.busy ? null : controller.install,
            child: const Text('Актуализирай сега'),
          ),
          TextButton(
            onPressed: controller.later,
            child: const Text('По-късно'),
          ),
        ],
        if (controller.progress != null)
          LinearProgressIndicator(value: controller.progress),
        if (controller.message != null) Text(controller.message!),
        TextButton(
          onPressed: controller.busy
              ? null
              : () => controller.check(manual: true),
          child: const Text('Провери за актуализации'),
        ),
      ],
    );
  }
}
