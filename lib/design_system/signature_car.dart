import 'package:material_ui/material_ui.dart';

import 'cockpit_assets.dart';

/// Shared 137 x 72 design geometry. All alpha layers retain exact anchors.
class SignatureCar extends StatelessWidget {
  const SignatureCar({
    super.key,
    this.body = 1,
    this.left = 1,
    this.right = 1,
    this.glow = 0,
  });
  final double body, left, right, glow;
  Widget layer(String name, double opacity) => Opacity(
    opacity: opacity.clamp(0.0, 1.0).toDouble(),
    child: CockpitAsset('car/$name.png', fit: BoxFit.fill),
  );
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AspectRatio(
      aspectRatio: 137 / 72,
      child: Stack(
        fit: StackFit.expand,
        children: [
          layer('shadow', body),
          layer('body', body),
          layer('contours', body),
          layer('highlights', body),
          layer('glow_left', left * glow),
          layer('glow_right', right * glow),
          layer('lamp_left', left),
          layer('lamp_right', right),
        ],
      ),
    ),
  );
}
