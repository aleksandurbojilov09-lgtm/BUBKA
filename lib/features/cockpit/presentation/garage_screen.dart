import 'package:material_ui/material_ui.dart';

import '../../../design_system/cockpit_components.dart';
import '../../../design_system/cockpit_assets.dart';
import '../../../design_system/signature_car.dart';
import '../../../design_system/theme.dart';
import 'cockpit_models.dart';
import 'cockpit_shell.dart';

class GarageScreen extends StatelessWidget {
  const GarageScreen({super.key, required this.actions, this.fixture});
  final CockpitActions actions;
  final CockpitFixtureModel? fixture;
  @override
  Widget build(BuildContext context) => CockpitShell(
    active: '/garage',
    actions: actions,
    body: fixture == null
        ? _content(context, null)
        : ListenableBuilder(
            listenable: fixture!,
            builder: (context, _) => _content(context, fixture),
          ),
  );
  Widget _content(BuildContext context, CockpitFixtureModel? model) => ListView(
    padding: const EdgeInsets.fromLTRB(12, 11, 12, 24),
    children: [
      const SizedBox(height: 8),
      const Text(
        'Гараж',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 12),
      if (model == null) ...[
        const Center(child: SizedBox(width: 160, child: SignatureCar())),
        const SizedBox(height: 16),
        const EmptyPanel(
          title: 'Гаражът е празен',
          detail: 'Все още няма добавени автомобили. Добавянето и редактирането ще бъдат налични във фаза 05.',
        ),
        const SizedBox(height: 16),
      ] else ...[
        const Text(
          'Визуален тест · примерни автомобили',
          textAlign: TextAlign.center,
          style: TextStyle(color: BubkaDesign.muted, fontSize: 13),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < CockpitFixtureModel.vehicles.length; i++) ...[
          _VehicleCard(
            vehicle: CockpitFixtureModel.vehicles[i],
            selected: model.index == i,
            onTap: () => model.select(i),
          ),
          const SizedBox(height: 19),
        ],
      ],
      CustomPaint(
        key: const Key('v4-add'),
        foregroundPainter: const DashedCardBorder(),
        child: OutlinedButton(
          onPressed: () => actions.future('Добавяне на автомобил · фаза 05'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, 81),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CockpitAsset(
                'icons/plus.png',
                width: 28,
                height: 28,
                tint: BubkaDesign.accent,
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Добави автомобил',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: BubkaDesign.accent, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.selected,
    required this.onTap,
  });
  final VehiclePresentation vehicle;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: PremiumCard(
      key: ValueKey('v4-car-${vehicle.id}'),
      selected: selected,
      radius: 22,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, c) {
          final info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                vehicle.name,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              RegistrationPlate(number: vehicle.registration, compact: true),
              const SizedBox(height: 8),
              Text(
                '${vehicle.fuel} · ${vehicle.year}',
                style: const TextStyle(color: BubkaDesign.muted),
              ),
            ],
          );
          final marker = Icon(
            selected ? Icons.check_circle : Icons.radio_button_unchecked,
            color: selected ? BubkaDesign.accent : BubkaDesign.muted,
            size: 27,
          );
          if (c.maxWidth < 280 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.15) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 78, child: SignatureCar()),
                    const Spacer(),
                    marker,
                  ],
                ),
                const SizedBox(height: 10),
                info,
              ],
            );
          }
          return ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 96),
            child: Row(
              children: [
                const SizedBox(width: 68, child: SignatureCar()),
                const SizedBox(width: 14),
                Container(width: 1, height: 58, color: BubkaDesign.border),
                const SizedBox(width: 18),
                Expanded(child: info),
                const SizedBox(width: 8),
                marker,
              ],
            ),
          );
        },
      ),
    ),
  );
}
