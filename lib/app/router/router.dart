import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../design_system/theme.dart';
import '../modules/module_availability.dart';
import '../modules/module_registry.dart';
import '../version.dart';

GoRouter createRouter(
  ModuleRegistry registry,
  ModuleAvailability availability,
) => GoRouter(
  initialLocation: '/',
  refreshListenable: availability,
  routes: [
    GoRoute(path: '/', builder: (_, _) => const _Home()),
    for (final module in registry.modules)
      GoRoute(
        path: module.path,
        redirect: (_, _) => availability.isEnabled(module.id) ? null : '/',
        builder: (context, _) => module.builder(context),
      ),
  ],
  errorBuilder: (context, _) => Scaffold(
    appBar: AppBar(title: const Text('Непознат екран')),
    body: Center(
      child: TextButton(
        onPressed: () => context.go('/'),
        child: const Text('Начало'),
      ),
    ),
  ),
);

class _Home extends StatelessWidget {
  const _Home();
  @override
  Widget build(BuildContext context) {
    final registry = context.read<ModuleRegistry>();
    final availability = context.watch<ModuleAvailability>();
    return Scaffold(
      appBar: AppBar(title: const Text('BUBKA')),
      body: ListView(
        padding: const EdgeInsets.all(BubkaDesign.spacing),
        children: [
          const Text(appVersion),
          const Text('Build $appBuild'),
          if (!availability.loaded) ...[
            Text(availability.error ?? 'Зареждане…'),
            if (availability.error != null)
              TextButton(
                onPressed: availability.load,
                child: const Text('Опитай отново'),
              ),
          ],
          if (availability.loaded)
            for (final module in registry.modules)
              ListTile(
                leading: Icon(module.icon),
                title: Text(module.name),
                onTap: availability.isEnabled(module.id)
                    ? () => context.push(module.path)
                    : null,
                trailing: Switch(
                  value: availability.isEnabled(module.id),
                  onChanged: (value) =>
                      availability.setEnabled(module.id, value),
                ),
              ),
        ],
      ),
    );
  }
}
