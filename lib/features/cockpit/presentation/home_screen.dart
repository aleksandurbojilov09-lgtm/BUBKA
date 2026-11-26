import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart' as painting;

import 'package:material_ui/material_ui.dart';

import '../../../design_system/cockpit_components.dart';
import '../../../design_system/cockpit_assets.dart';
import '../../../design_system/resource_ring.dart';
import '../../../design_system/signature_car.dart';
import '../../../design_system/theme.dart';
import 'cockpit_models.dart';
import 'cockpit_shell.dart';
import 'ignition.dart';

Widget _reveal(double value, Widget child) => value >= 1
    ? child
    : IgnorePointer(
        ignoring: true,
        child: ExcludeSemantics(
          child: Opacity(opacity: value, child: child),
        ),
      );

class CockpitHome extends StatefulWidget {
  const CockpitHome({
    super.key,
    required this.actions,
    this.playIntro = false,
    this.fixture,
  });
  final CockpitActions actions;
  final bool playIntro;
  final CockpitFixtureModel? fixture;
  @override
  State<CockpitHome> createState() => _CockpitHomeState();
}

class _CockpitHomeState extends State<CockpitHome>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  bool _started = false;
  bool _preloaded = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      vsync: this,
      duration: IgnitionFrame.duration,
      animationBehavior: AnimationBehavior.preserve,
      value: widget.playIntro ? 0 : 1,
    );
  }

  bool get _reduced =>
      MediaQuery.of(context).disableAnimations ||
      WidgetsBinding
          .instance
          .platformDispatcher
          .accessibilityFeatures
          .reduceMotion;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_preloaded) {
      _preloaded = true;
      unawaited(CockpitAssets.warm(context));
    }
    if (_reduced) {
      _controller.value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      if (widget.playIntro) _controller.forward();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _controller.isAnimating) {
      _controller.value = 1;
    }
  }

  @override
  void didChangeAccessibilityFeatures() {
    if (mounted && _reduced && _controller.isAnimating) _controller.value = 1;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([
      _controller,
      if (widget.fixture != null) widget.fixture!,
    ]),
    builder: (context, _) {
      final frame = IgnitionFrame(ms: _controller.value * 3400);
      final fixture = widget.fixture;
      return CockpitShell(
        active: '/',
        actions: widget.actions,
        navigationOpacity: frame.navigation,
        depth: frame.background,
        background: Color.lerp(
          Colors.black,
          BubkaDesign.background,
          frame.background,
        )!,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final scale = MediaQuery.textScalerOf(context).scale(1);
            final twoColumns = constraints.maxWidth >= 680 && scale <= 1.3;
            final maxWidth = math.min(constraints.maxWidth, 920.0);
            final actions = widget.actions;
            final stage = _Stage(
              frame: frame,
              actions: actions,
              fixture: fixture,
            );
            final lower = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _reveal(frame.quick, _QuickCards(actions: actions)),
                const SizedBox(height: 15),
                _reveal(frame.summary, const _Summary()),
                if (fixture == null) ...[
                  const SizedBox(height: 16),
                  _reveal(
                    frame.details,
                    EmptyPanel(
                      title: 'Твоят дигитален гараж',
                      detail: 'Добави автомобил, за да следиш неговите документи и обслужване. Данните остават локално.',
                      action: GoldButton(
                        label: 'Добави автомобил',
                        icon: Icons.add,
                        onPressed: () =>
                            actions.future('Добавяне на автомобил · фаза 05'),
                      ),
                    ),
                  ),
                ],
              ],
            );
            return SingleChildScrollView(
              key: const Key('cockpit-scroll'),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: twoColumns
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: stage),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 72),
                                child: lower,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [stage, const SizedBox(height: 5), lower],
                        ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

class _Stage extends StatelessWidget {
  const _Stage({required this.frame, required this.actions, this.fixture});
  final IgnitionFrame frame;
  final CockpitActions actions;
  final CockpitFixtureModel? fixture;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final scale = MediaQuery.textScalerOf(context).scale(1);
      final headerHeight = math.max(60.0, scale * 23 + 20);
      final diameter = math.min(scale > 1.15 ? 238.0 : 270.0, c.maxWidth - 22);
      final selected = fixture?.selected;
      final standard = scale <= 1.05 && c.maxWidth >= 340;
      final travel = frame.wordmarkTravel;
      final markStart = diameter * .92 + 86.25 * math.max(1.0, scale);
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _CockpitArcPainter(frame.background)),
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: headerHeight,
                child: _reveal(
                  frame.details,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        tooltip: 'Гараж',
                        onPressed: () => actions.navigate('/garage'),
                        icon: const CockpitAsset(
                          'icons/garage.png',
                          width: 26,
                          height: 26,
                          tint: BubkaDesign.accent,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Известия',
                        onPressed: () => actions.navigate('/notifications'),
                        icon: const CockpitAsset(
                          'icons/bell.png',
                          width: 26,
                          height: 26,
                          tint: BubkaDesign.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 9),
              _reveal(
                frame.details,
                selected == null
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Text(
                          'Няма добавен автомобил',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : standard
                    ? ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 103),
                        child: _VehicleHeader(model: fixture!),
                      )
                    : _VehicleHeader(model: fixture!),
              ),
              if (!standard || selected == null) const SizedBox(height: 4),
              _ResourcePanel(
                frame: frame,
                diameter: diameter,
                resource: fixture?.resource ?? const ResourceView(),
                choice: fixture?.choice,
                hasVehicle: selected != null,
                onTap: selected == null
                    ? null
                    : () => showRingSelector(context, fixture!),
              ),
            ],
          ),
          Positioned(
            top: 11,
            left: 50,
            right: 50,
            height: 152 * 34 / 180,
            child: IgnorePointer(
              child: Opacity(
                opacity: frame.wordmark,
                child: Transform.translate(
                  offset: Offset(0, markStart * (1 - travel)),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, .002)
                      ..rotateX((1 - travel) * .84),
                    child: Center(
                      child: CockpitWordmark(
                        key: const Key('cockpit-wordmark'),
                        tint: travel < 1
                            ? Color.lerp(
                                const Color(0xFFFFF3D8),
                                BubkaDesign.text,
                                travel,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _VehicleHeader extends StatelessWidget {
  const _VehicleHeader({required this.model});
  final CockpitFixtureModel model;
  @override
  Widget build(BuildContext context) {
    final previous = IconButton(
      tooltip: 'Предишен автомобил',
      onPressed: () => model.select(
        (model.index + CockpitFixtureModel.vehicles.length - 1) %
            CockpitFixtureModel.vehicles.length,
      ),
      icon: const Icon(Icons.chevron_left),
    );
    final next = IconButton(
      tooltip: 'Следващ автомобил',
      onPressed: () =>
          model.select((model.index + 1) % CockpitFixtureModel.vehicles.length),
      icon: const Icon(Icons.chevron_right),
    );
    final info = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          model.selected.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            height: 1.2,
            fontWeight: FontWeight.w600,
            letterSpacing: -.3,
          ),
        ),
        const SizedBox(height: 6),
        RegistrationPlate(number: model.selected.registration),
      ],
    );
    final dots = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < CockpitFixtureModel.vehicles.length; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == model.index ? BubkaDesign.accent : BubkaDesign.border,
            ),
          ),
      ],
    );
    final enlarged = MediaQuery.textScalerOf(context).scale(17) > 22;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (enlarged) ...[
          info,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [previous, dots, next],
          ),
        ] else ...[
          Row(
            children: [
              previous,
              Expanded(child: info),
              next,
            ],
          ),
          const SizedBox(height: 12),
          dots,
        ],
      ],
    );
  }
}

class _ResourcePanel extends StatelessWidget {
  const _ResourcePanel({
    required this.frame,
    required this.diameter,
    required this.resource,
    required this.hasVehicle,
    this.choice,
    this.onTap,
  });
  final IgnitionFrame frame;
  final double diameter;
  final ResourceView resource;
  final bool hasVehicle;
  final ResourceChoice? choice;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final separate = scale > 1.15;
    final carWidth = diameter * 116 / 270, carTop = diameter * 35 / 270;
    final lightWidth = carWidth * 390 / 116;
    final lightTop = carTop + carWidth * 43 / 137 - lightWidth * 24 / 390;
    final label = _ResourceLabel(
      resource: resource,
      choice: choice,
      hasVehicle: hasVehicle,
    );
    return Semantics(
      label: hasVehicle
          ? '${choice?.label ?? ''}, ${resource.semanticLabel}'
          : 'Ресурс няма данни',
      button: onTap != null,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: frame.done ? onTap : null,
          borderRadius: BorderRadius.circular(28),
          child: Column(
            children: [
              SizedBox(
                key: const Key('v4-ring-layout'),
                width: diameter,
                height: diameter,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: frame.ring,
                        child: CustomPaint(
                          painter: ResourceRingPainter(
                            resource,
                            progress: frame.ring,
                          ),
                        ),
                      ),
                    ),
                    if (!frame.done && (frame.beams > 0 || frame.lamps > 0))
                      Positioned(
                        left: (diameter - lightWidth) / 2,
                        top: lightTop,
                        width: lightWidth,
                        height: lightWidth,
                        child: RepaintBoundary(
                          child: IgnitionLights(
                            intensity: frame.beams,
                            lamps: frame.glow,
                            reflection:
                                frame.wordmark * (1 - frame.wordmarkTravel),
                          ),
                        ),
                      ),
                    Positioned(
                      top: carTop,
                      left: (diameter - carWidth) / 2,
                      width: carWidth,
                      child: RepaintBoundary(
                        child: SignatureCar(
                          key: const Key('signature-car'),
                          body: frame.body,
                          left: frame.lamps,
                          right: frame.lamps,
                          glow: frame.glow,
                        ),
                      ),
                    ),
                    if (!separate)
                      Positioned(
                        top: diameter * .40,
                        left: diameter * .16,
                        right: diameter * .16,
                        child: _reveal(frame.details, label),
                      ),
                  ],
                ),
              ),
              if (separate) _reveal(frame.details, label),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResourceLabel extends StatelessWidget {
  const _ResourceLabel({
    required this.resource,
    required this.hasVehicle,
    this.choice,
  });
  final ResourceView resource;
  final bool hasVehicle;
  final ResourceChoice? choice;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        resource.status,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, color: BubkaDesign.text),
      ),
      Text(
        resource.metric,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 36,
          height: 1.1,
          fontWeight: FontWeight.w700,
          color: resource.color,
          fontFeatures: const [ui.FontFeature.tabularFigures()],
        ),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Divider(height: 1, color: BubkaDesign.border),
      ),
      Text(
        hasVehicle
            ? (choice?.label ?? 'Избери показател')
            : 'Няма избран автомобил',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ],
  );
}

class _QuickCards extends StatelessWidget {
  const _QuickCards({required this.actions});
  final CockpitActions actions;
  static const labels = ['Гориво', 'Сервиз', 'Документи', 'Срокове'];
  static const paths = ['/fuel', '/service', '/documents', '/deadlines'];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final scaler = MediaQuery.textScalerOf(context);
      double textWidth(String value) {
        final painter = painting.TextPainter(
          text: painting.TextSpan(
            text: value,
            style: DefaultTextStyle.of(context).style.merge(
              const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
          textDirection: Directionality.of(context),
          textScaler: scaler,
          maxLines: 1,
        )..layout();
        final width = painter.width;
        painter.dispose();
        return width;
      }

      final needed = labels.map(textWidth).reduce((a, b) => a > b ? a : b) + 4;
      final four = (c.maxWidth - 21) / 4;
      final two = (c.maxWidth - 7) / 2;
      final columns =
          c.maxWidth >= 340 && scaler.scale(1) <= 1.15 && four >= needed
          ? 4
          : two >= needed
          ? 2
          : 1;
      final width = (c.maxWidth - (columns - 1) * 7) / columns;
      return Wrap(
        spacing: 7,
        runSpacing: 7,
        children: [
          for (var i = 0; i < labels.length; i++)
            SizedBox(
              key: ValueKey('v4-tile-$i'),
              width: width,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 88),
                child: PremiumCard(
                  radius: 16,
                  onTap: () => actions.navigate(paths[i]),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 2,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CockpitAsset(
                            'icons/${['fuel', 'service', 'documents', 'deadlines'][i]}.png',
                            tint: BubkaDesign.accent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          labels[i],
                          softWrap: false,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _Summary extends StatelessWidget {
  const _Summary();
  @override
  Widget build(BuildContext context) => PremiumCard(
    key: const Key('v4-metrics'),
    radius: 19,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    child: LayoutBuilder(
      builder: (context, c) {
        const widgets = [
          _Metric(
            title: 'Разходи този месец',
            value: '—',
            icon: Icons.payments_outlined,
          ),
          _Metric(
            title: 'Среден разход',
            value: '—',
            icon: Icons.local_gas_station_outlined,
          ),
        ];
        if (c.maxWidth < 250 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.3) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [widgets.first, const Divider(), widgets.last],
          );
        }
        return Stack(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 53),
              child: Row(
                children: [
                  Expanded(child: widgets.first),
                  const SizedBox(width: 12),
                  Expanded(child: widgets.last),
                ],
              ),
            ),
            const Positioned(
              top: 6,
              bottom: 6,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: SizedBox(
                    key: Key('v5-summary-divider'),
                    width: 1,
                    height: double.infinity,
                    child: ColoredBox(color: BubkaDesign.border),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.title, required this.value, required this.icon});
  final String title, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      CockpitAsset(
        icon == Icons.payments_outlined ? 'icons/coins.png' : 'icons/fuel.png',
        width: 27,
        height: 27,
        tint: BubkaDesign.accent,
      ),
      const SizedBox(width: 9),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                height: 1.3,
                color: BubkaDesign.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ],
  );
}

Future<void> showRingSelector(
  BuildContext context,
  CockpitFixtureModel model,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Какво да следи Cockpit?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text('Тестов визуален преглед · не се записва в базата.'),
          for (final option in ResourceChoice.values)
            ListTile(
              title: Text(option.label),
              selected: option == model.choice,
              trailing: option == model.choice
                  ? const Icon(Icons.check_circle, color: BubkaDesign.accent)
                  : null,
              onTap: () {
                model.selectChoice(option);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    ),
  ),
);

class _CockpitArcPainter extends CustomPainter {
  const _CockpitArcPainter(this.opacity);
  final double opacity;
  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) {
      return;
    }
    final w = size.width;
    final y = 114 + 104 * w / 390;
    final edge = Path()
      ..moveTo(0, y)
      ..quadraticBezierTo(w / 2, 114 - 92 * w / 390, w, y);
    final area = Path.from(edge)
      ..lineTo(w, size.height)
      ..lineTo(0, size.height)
      ..close();
    final rect = Rect.fromLTWH(0, y * .5, w, size.height - y * .5);
    if (rect.height <= 0) {
      return;
    }
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF101114).withValues(alpha: .35 * opacity),
            const Color(0xFF101114).withValues(alpha: .15 * opacity),
            Colors.transparent,
          ],
          stops: const [0, .55, 1],
        ).createShader(rect),
    );
    canvas.drawPath(
      edge,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .7
        ..color = Colors.white.withValues(alpha: .055 * opacity),
    );
  }

  @override
  bool shouldRepaint(_CockpitArcPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}
