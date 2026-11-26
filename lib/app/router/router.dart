import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../design_system/cockpit_components.dart';
import '../../design_system/theme.dart';
import '../../features/cockpit/cockpit.dart';
import '../modules/module_availability.dart';
import '../modules/module_registry.dart';
import '../version.dart';
import 'update_panel.dart';

GoRouter createRouter(
  ModuleRegistry registry,
  ModuleAvailability availability, {
  bool testingPreview = false,
}) {
  var coldStart = true;
  final allowPreview = testingPreview || visualPreviewEnabled;
  return GoRouter(
    initialLocation: '/',
    refreshListenable: availability,
    redirect: (_, state) {
      if (state.uri.path != '/') coldStart = false;
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) {
          final intro = coldStart;
          coldStart = false;
          return CockpitHome(actions: _actions(context), playIntro: intro);
        },
      ),
      GoRoute(
        path: '/garage',
        pageBuilder: (context, state) =>
            _page(state, GarageScreen(actions: _actions(context))),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _page(
          state,
          _Settings(actions: _actions(context), showPreview: allowPreview),
        ),
      ),
      for (final entry in _futureRoutes.entries)
        GoRoute(
          path: entry.key,
          pageBuilder: (context, state) => _page(
            state,
            _FutureScreen(
              title: entry.value,
              actions: _actions(context),
              active: entry.key,
            ),
          ),
        ),
      if (allowPreview)
        GoRoute(
          path: '/visual-review',
          builder: (_, _) => const VisualReview(),
        ),
      for (final module in registry.modules)
        GoRoute(
          path: module.path,
          redirect: (_, _) =>
              availability.loaded && !availability.isEnabled(module.id)
              ? '/settings'
              : null,
          builder: (context, _) => availability.loaded
              ? module.builder(context)
              : _ModuleLoading(availability: availability),
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
}

const _futureRoutes = {
  '/fuel': 'Гориво',
  '/service': 'Сервиз',
  '/documents': 'Документи',
  '/deadlines': 'Срокове',
  '/stats': 'Статистика',
  '/notifications': 'Известия',
};
CustomTransitionPage<void> _page(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: Builder(
        builder: (context) => PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) context.go('/');
          },
          child: child,
        ),
      ),
      transitionDuration: BubkaDesign.motion,
      reverseTransitionDuration: BubkaDesign.motion,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (MediaQuery.of(context).disableAnimations ||
            WidgetsBinding
                .instance
                .platformDispatcher
                .accessibilityFeatures
                .reduceMotion) {
          return child;
        }
        return FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
CockpitActions _actions(BuildContext context) => CockpitActions(
  navigate: (path) => context.go(path),
  quick: () =>
      showQuickSheet(context, (title) => _futureNotice(context, title)),
  future: (title) => _futureNotice(context, title),
);
void _futureNotice(BuildContext context, String title) => showDialog<void>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: Text(title),
    content: const Text(
      'Функцията ще бъде активирана в съответната следваща фаза. Не са записани данни.',
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(dialogContext),
        child: const Text('Разбрах'),
      ),
    ],
  ),
);

class _FutureScreen extends StatelessWidget {
  const _FutureScreen({
    required this.title,
    required this.actions,
    required this.active,
  });
  final String title, active;
  final CockpitActions actions;
  @override
  Widget build(BuildContext context) => CockpitShell(
    active: active,
    actions: actions,
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              tooltip: 'Начало',
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.arrow_back),
            ),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          ],
        ),
        const SizedBox(height: 16),
        EmptyPanel(
          title: active == '/notifications'
              ? 'Няма въведени автомобилни срокове'
              : 'Няма данни',
          detail: active == '/notifications'
              ? 'Автомобилните напомняния предстоят. Тестовите локални известия остават в Настройки → Диагностика.'
              : 'Функционалността ще бъде реализирана в съответната фаза. Тук не се показват примерни стойности.',
        ),
      ],
    ),
  );
}

class _ModuleLoading extends StatelessWidget {
  const _ModuleLoading({required this.availability});
  final ModuleAvailability availability;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Диагностика')),
    body: Center(
      child: availability.error == null
          ? const CircularProgressIndicator()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(availability.error!),
                TextButton(
                  onPressed: availability.load,
                  child: const Text('Опитай отново'),
                ),
              ],
            ),
    ),
  );
}

class _Settings extends StatelessWidget {
  const _Settings({required this.actions, required this.showPreview});
  final bool showPreview;
  final CockpitActions actions;
  @override
  Widget build(BuildContext context) {
    final registry = context.read<ModuleRegistry>();
    final availability = context.watch<ModuleAvailability>();
    return CockpitShell(
      active: '/settings',
      actions: actions,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          const Text(
            'Настройки',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 22),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'За приложението',
                  style: TextStyle(fontSize: 14, color: BubkaDesign.muted),
                ),
                const SizedBox(height: 4),
                const Text(
                  'BUBA · Cockpit Premium',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text('Български · EUR / км / л'),
                const Text(
                  'Големината на текста и намаленото движение следват системните настройки.',
                ),
                const Divider(),
                const Text('Версия'),
                const Text(appVersion),
                const Text('Build $appBuild'),
                const SizedBox(height: 8),
                const Text(
                  'Developed by A.Bozhilov',
                  style: TextStyle(color: BubkaDesign.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Актуализации',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                SizedBox(height: 8),
                UpdatePanel(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Локална диагностика',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
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
          ),
          const SizedBox(height: 12),
          if (showPreview)
            PremiumCard(
              onTap: () => context.push('/visual-review'),
              child: const Row(
                children: [
                  Icon(Icons.science_outlined, color: BubkaDesign.accent),
                  SizedBox(width: 12),
                  Expanded(child: Text('Визуален тест · примерни данни')),
                  Icon(Icons.chevron_right),
                ],
              ),
            ),
          const SizedBox(height: 12),
          const EmptyPanel(
            title: 'Локално съхранение',
            detail: 'Без акаунти и облак. Пълният архив и автомобилните настройки предстоят.',
          ),
        ],
      ),
    );
  }
}
