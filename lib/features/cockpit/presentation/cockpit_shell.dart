import 'package:flutter/services.dart';
import 'package:flutter/painting.dart' as painting;
import 'package:material_ui/material_ui.dart';

import '../../../design_system/theme.dart';
import '../../../design_system/cockpit_assets.dart';

class CockpitActions {
  const CockpitActions({
    required this.navigate,
    required this.quick,
    required this.future,
  });
  final ValueChanged<String> navigate;
  final VoidCallback quick;
  final ValueChanged<String> future;
}

class CockpitShell extends StatelessWidget {
  const CockpitShell({
    super.key,
    required this.body,
    required this.actions,
    required this.active,
    this.navigationOpacity = 1,
    this.background = BubkaDesign.background,
    this.depth = 1,
  });
  final Widget body;
  final CockpitActions actions;
  final String active;
  final double navigationOpacity;
  final Color background;
  final double depth;
  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: BubkaDesign.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
    child: Scaffold(
      backgroundColor: background,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-.74, -.92),
            radius: .92,
            colors: [
              Color.lerp(background, const Color(0xFF2B2C30), depth)!,
              Color.lerp(background, const Color(0xFF1E1F23), depth)!,
              background,
            ],
            stops: const [0, .42, 1],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (depth > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: depth,
                    child: const CockpitAsset(
                      'surfaces/grain_tile.png',
                      fit: BoxFit.none,
                      repeat: ImageRepeat.repeat,
                    ),
                  ),
                ),
              ),
            if (depth > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: depth,
                    child: const CockpitAsset(
                      'surfaces/soft_light.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            SafeArea(bottom: false, child: body),
          ],
        ),
      ),
      bottomNavigationBar: IgnorePointer(
        ignoring: navigationOpacity < .99,
        child: Opacity(
          opacity: navigationOpacity,
          child: SafeArea(
            top: false,
            child: PremiumNavigation(active: active, actions: actions),
          ),
        ),
      ),
    ),
  );
}

class PremiumNavigation extends StatelessWidget {
  const PremiumNavigation({
    super.key,
    required this.active,
    required this.actions,
  });
  final String active;
  final CockpitActions actions;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF232428), Color(0xFF1B1C20), Color(0xFF17181B)],
        stops: [0, .52, 1],
      ),
      borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
    ),
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final labelStyle = DefaultTextStyle.of(context).style.merge(
          const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
        );
        double labelWidth(String value) {
          final painter = painting.TextPainter(
            text: painting.TextSpan(text: value, style: labelStyle),
            textDirection: TextDirection.ltr,
            textScaler: MediaQuery.textScalerOf(context),
            maxLines: 1,
          )..layout();
          final width = painter.width;
          painter.dispose();
          return width;
        }

        final maxLabel = [
          'Начало',
          'Гараж',
          'Статистика',
          'Настройки',
        ].map(labelWidth).reduce((a, b) => a > b ? a : b);
        final compact = constraints.maxWidth / 5 - 4 < maxLabel;
        if (compact && constraints.maxWidth / 2 - 4 < maxLabel) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _item(context, '/', 'Начало', Icons.home_outlined),
                  _item(
                    context,
                    '/garage',
                    'Гараж',
                    Icons.directions_car_outlined,
                  ),
                  SizedBox(width: 54, child: _quick()),
                ],
              ),
              Row(
                children: [
                  _item(
                    context,
                    '/stats',
                    'Статистика',
                    Icons.bar_chart_outlined,
                    horizontal: true,
                  ),
                ],
              ),
              Row(
                children: [
                  _item(
                    context,
                    '/settings',
                    'Настройки',
                    Icons.settings_outlined,
                    horizontal: true,
                  ),
                ],
              ),
            ],
          );
        }
        if (compact) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _item(context, '/', 'Начало', Icons.home_outlined),
                  _item(
                    context,
                    '/garage',
                    'Гараж',
                    Icons.directions_car_outlined,
                  ),
                  SizedBox(width: 64, child: _quick()),
                ],
              ),
              Row(
                children: [
                  _item(
                    context,
                    '/stats',
                    'Статистика',
                    Icons.bar_chart_outlined,
                  ),
                  _item(
                    context,
                    '/settings',
                    'Настройки',
                    Icons.settings_outlined,
                  ),
                ],
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _item(context, '/', 'Начало', Icons.home_outlined),
            _item(context, '/garage', 'Гараж', Icons.directions_car_outlined),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: _quick(),
              ),
            ),
            _item(context, '/stats', 'Статистика', Icons.bar_chart_outlined),
            _item(context, '/settings', 'Настройки', Icons.settings_outlined),
          ],
        );
      },
    ),
  );

  Widget _quick() => Center(
    heightFactor: 1,
    child: Semantics(
      button: true,
      label: 'Бързи действия',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: actions.quick,
          child: Ink(
            key: const Key('v5-quick-plus'),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: BubkaDesign.goldGradient,
            ),
            width: 54,
            height: 54,
            child: const Center(
              child: CockpitAsset(
                'icons/plus.png',
                width: 30,
                height: 30,
                tint: BubkaDesign.background,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _item(
    BuildContext context,
    String path,
    String label,
    IconData icon, {
    bool horizontal = false,
  }) {
    final selected = active == path;
    final color = selected ? BubkaDesign.goldHighlight : BubkaDesign.text;
    final name = switch (path) {
      '/' => 'home',
      '/garage' => 'garage',
      '/stats' => 'stats',
      '/settings' => 'settings',
      _ => null,
    };
    final glyph = name == null
        ? Icon(icon, size: 25, color: color)
        : CockpitAsset('icons/$name.png', width: 25, height: 25, tint: color);
    final caption = Text(
      label,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color,
        fontSize: 10.5,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => actions.navigate(path),
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: horizontal ? 48 : 56,
                minWidth: 48,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 1),
                child: horizontal
                    ? Row(
                        children: [
                          glyph,
                          const SizedBox(width: 4),
                          Expanded(child: caption),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [glyph, const SizedBox(height: 4), caption],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
