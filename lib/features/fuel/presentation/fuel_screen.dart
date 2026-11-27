import 'package:material_ui/material_ui.dart';

import '../../../design_system/cockpit_components.dart';
import '../../../design_system/theme.dart';
import '../../cockpit/cockpit.dart';
import '../../garage/garage.dart';
import '../domain/fuel_models.dart';
import 'fuel_form.dart';
import 'fuel_view_model.dart';

class FuelScreen extends StatelessWidget {
  const FuelScreen({
    super.key,
    required this.actions,
    this.garage,
    this.repository,
    this.initialEntry,
  });
  final CockpitActions actions;
  final GarageViewModel? garage;
  final FuelRepository? repository;
  final String? initialEntry;
  @override
  Widget build(BuildContext context) => CockpitShell(
    active: '/fuel',
    actions: actions,
    body: garage == null
        ? _content(context)
        : ListenableBuilder(
            listenable: garage!,
            builder: (context, _) => _content(context),
          ),
  );
  Widget _content(BuildContext context) {
    final car = garage?.active;
    if (car != null && repository != null) {
      return _Ledger(
        key: ValueKey('${car.id}:$initialEntry'),
        car: car,
        repository: repository!,
        initialEntry: initialEntry,
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Гориво и километраж',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        if (garage != null && garage!.snapshot == null) ...[
          if (garage!.busy)
            const Center(child: CircularProgressIndicator())
          else ...[
            Text(garage!.error ?? 'Данните не са заредени'),
            TextButton(
              onPressed: garage!.load,
              child: const Text('Опитай отново'),
            ),
          ],
        ] else if (car == null) ...[
          const EmptyPanel(
            title: 'Няма добавен автомобил',
            detail: 'Добави автомобил в гаража, за да записваш зареждания и километраж.',
          ),
          GoldButton(
            onPressed: () => actions.navigate('/garage'),
            label: 'Към гаража',
          ),
        ] else
          const Text('Дневникът не е достъпен.'),
      ],
    );
  }
}

class _Ledger extends StatefulWidget {
  const _Ledger({
    super.key,
    required this.car,
    required this.repository,
    this.initialEntry,
  });
  final GarageVehicle car;
  final FuelRepository repository;
  final String? initialEntry;
  @override
  State<_Ledger> createState() => _LedgerState();
}

class _LedgerState extends State<_Ledger> {
  late final FuelViewModel model;
  @override
  void initState() {
    super.initState();
    model = FuelViewModel(widget.repository, widget.car.id);
    _load();
  }

  Future<void> _load() async {
    final ok = await model.load();
    if (!mounted || !ok) return;
    if (widget.initialEntry == 'fuel' || widget.initialEntry == 'odometer') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _edit(widget.initialEntry == 'fuel');
      });
    }
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  Future<void> _edit(bool fuel, [FuelRecord? record]) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => FuelForm(
          model: model,
          vehicleName: '${widget.car.name} · ${widget.car.registration}',
          isFuel: fuel,
          record: record,
        ),
      ),
    );
  }

  Future<void> _delete(FuelRecord record) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изтриване на запис'),
        content: Text(
          '${widget.car.name}\n${displayCalendarDate(record.draft.date)} · ${record.draft.odometerKm} км\nЗаписът ще бъде изтрит окончателно.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отказ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Изтрий окончателно'),
          ),
        ],
      ),
    );
    if (mounted && yes == true) await model.remove(record.id);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: model,
    builder: (context, _) {
      final history = model.history;
      final average = history?.estimatedConsumption;
      return ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          Text(
            'Гориво и километраж',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(widget.car.name, style: Theme.of(context).textTheme.titleLarge),
          Text(
            widget.car.registration,
            style: const TextStyle(color: BubkaDesign.muted),
          ),
          const SizedBox(height: 16),
          if (history == null) ...[
            if (model.busy)
              const Center(child: CircularProgressIndicator())
            else ...[
              Text(model.error ?? 'Данните не са заредени'),
              TextButton(
                onPressed: model.load,
                child: const Text('Опитай отново'),
              ),
            ],
          ] else ...[
            PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Текущ километраж'),
                  Text(
                    history.latestKm == null
                        ? 'Няма показание'
                        : '${history.latestKm} км',
                    key: const Key('fuel-current-km'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Divider(),
                  const Text('Среден разход · оценка'),
                  Text(
                    average == null
                        ? 'Недостатъчно данни'
                        : '${average.toStringAsFixed(2)} л/100 км',
                    key: const Key('fuel-average'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Text(
                    'Оценка по интервал между зареждания, не точен разход на едно зареждане.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GoldButton(
              key: const Key('fuel-add'),
              onPressed: model.busy ? null : () => _edit(true),
              label: 'Добави зареждане',
            ),
            OutlinedButton(
              key: const Key('odometer-add'),
              onPressed: model.busy ? null : () => _edit(false),
              child: const Text('Добави километраж'),
            ),
            const SizedBox(height: 16),
            Text('История', style: Theme.of(context).textTheme.titleLarge),
            if (model.error != null)
              Text(
                model.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (history.entries.isEmpty) const Text('Все още няма записи.'),
            for (final row in history.entries.reversed) ...[
              const SizedBox(height: 10),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.draft.fuelMl == null ? 'Километраж' : 'Зареждане',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${displayCalendarDate(row.draft.date)} · ${row.draft.odometerKm} км',
                    ),
                    if (row.draft.fuelMl != null)
                      Text('${quantityText(row.draft.fuelMl!, 3)} л'),
                    if (row.draft.priceCents != null)
                      Text('${quantityText(row.draft.priceCents!, 2)} EUR'),
                    Wrap(
                      children: [
                        TextButton(
                          onPressed: model.busy
                              ? null
                              : () => _edit(row.draft.fuelMl != null, row),
                          child: const Text('Редактирай'),
                        ),
                        TextButton(
                          onPressed: model.busy ? null : () => _delete(row),
                          child: const Text('Изтрий'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      );
    },
  );
}
