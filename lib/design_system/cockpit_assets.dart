import 'package:material_ui/material_ui.dart';

/// DESIGN-003 PNGs with the approved BUBA name change, local only.
/// ImageCache owns decoded images.
abstract final class CockpitAssets {
  static const prefix = 'assets/design/cockpit/';
  static const names = <String>[
    'car/body.png',
    'car/contours.png',
    'car/glow_left.png',
    'car/glow_right.png',
    'car/highlights.png',
    'car/lamp_left.png',
    'car/lamp_right.png',
    'car/shadow.png',
    'icons/bell.png',
    'icons/coins.png',
    'icons/deadlines.png',
    'icons/documents.png',
    'icons/fuel.png',
    'icons/garage.png',
    'icons/home.png',
    'icons/plus.png',
    'icons/service.png',
    'icons/settings.png',
    'icons/stats.png',
    'ignition/asphalt.png',
    'ignition/beam_left.png',
    'ignition/beam_right.png',
    'ignition/halo_left.png',
    'ignition/halo_right.png',
    'ignition/road_pool.png',
    'ignition/wordmark_reflection.png',
    'surfaces/grain_tile.png',
    'surfaces/selected_inner_glow.png',
    'surfaces/soft_light.png',
    'wordmark/bubka.png',
  ];
  static ImageProvider<Object> provider(String name) =>
      ResizeImage.resizeIfNeeded(
        name.startsWith('ignition/') &&
                name != 'ignition/wordmark_reflection.png'
            ? 780
            : null,
        null,
        AssetImage('$prefix$name'),
      );
  static Future<void> warm(BuildContext context) async {
    await Future.wait<void>([
      for (final name in names) precacheImage(provider(name), context),
    ]);
  }
}

class CockpitAsset extends StatelessWidget {
  const CockpitAsset(
    this.name, {
    super.key,
    this.tint,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = ImageRepeat.noRepeat,
  });
  final String name;
  final Color? tint;
  final double? width, height;
  final BoxFit fit;
  final ImageRepeat repeat;
  @override
  Widget build(BuildContext context) => Image(
    image: CockpitAssets.provider(name),
    width: width,
    height: height,
    fit: fit,
    repeat: repeat,
    color: tint,
    colorBlendMode: BlendMode.srcIn,
    excludeFromSemantics: true,
    filterQuality: FilterQuality.medium,
    errorBuilder: (context, error, stack) =>
        const Center(child: Icon(Icons.broken_image_outlined, size: 20)),
  );
}

class CockpitWordmark extends StatelessWidget {
  const CockpitWordmark({super.key, this.tint});
  final Color? tint;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'BUBA',
    image: true,
    child: CockpitAsset(
      'wordmark/bubka.png',
      width: 152,
      height: 152 * 34 / 180,
      tint: tint,
    ),
  );
}
