import 'package:material_ui/material_ui.dart';

import '../../../design_system/cockpit_assets.dart';

/// Motion reference uses 3400 ms with discrete anchor times. Only opacity and
/// the wordmark move; the signature car stays in the final cockpit geometry.
@immutable
class IgnitionFrame {
  const IgnitionFrame({required this.ms});
  static const duration = Duration(milliseconds: 3400);
  final double ms;
  static const complete = IgnitionFrame(ms: 3400);
  double _ramp(double start, double end) =>
      ((ms - start) / (end - start)).clamp(0.0, 1.0).toDouble();
  double get lamps =>
      ms < 890 ? _ramp(300, 410) * (1 - _ramp(720, 890)) : _ramp(1150, 1320);
  double get body => _ramp(1280, 2350);
  double get beams => _ramp(1150, 1430) * (1 - _ramp(1830, 2550));
  double get glow => (ms < 890 ? lamps : beams * .8);
  double get background => _ramp(1830, 2650);
  double get wordmark => _ramp(1430, 1680);
  double get wordmarkTravel => Curves.easeInOut.transform(_ramp(1830, 2550));
  double get ring => _ramp(2550, 3400);
  double get details => _ramp(2550, 3000);
  double get quick => _ramp(2550, 3210);
  double get summary => _ramp(2700, 3300);
  double get navigation => _ramp(2800, 3400);
  bool get done => ms >= 3400;
}

/// Local square light canvas, width anchored to the shared 137x72 car.
class IgnitionLights extends StatelessWidget {
  const IgnitionLights({
    super.key,
    required this.intensity,
    required this.lamps,
    required this.reflection,
  });
  final double intensity, lamps, reflection;
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: LayoutBuilder(
      builder: (context, c) => Stack(
        fit: StackFit.expand,
        children: [
          for (final name in [
            'asphalt',
            'road_pool',
            'beam_left',
            'beam_right',
          ])
            Opacity(
              opacity: intensity,
              child: CockpitAsset('ignition/$name.png', fit: BoxFit.fill),
            ),
          for (final name in ['halo_left', 'halo_right'])
            Opacity(
              opacity: lamps,
              child: CockpitAsset('ignition/$name.png', fit: BoxFit.fill),
            ),
          Positioned(
            top: c.maxWidth * 170 / 390,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: reflection * .18,
              child: Center(
                child: CockpitAsset(
                  'ignition/wordmark_reflection.png',
                  width: c.maxWidth * 198 / 390,
                  height: c.maxWidth * 38 / 390,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
