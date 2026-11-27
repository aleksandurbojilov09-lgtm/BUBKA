import 'package:material_ui/material_ui.dart';

import '../../../design_system/cockpit_components.dart';
import '../../cockpit/cockpit.dart';
import '../../garage/garage.dart';
import '../domain/document_models.dart';
import 'document_form.dart';
import 'documents_view_model.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({
    super.key,
    required this.actions,
    required this.garage,
    required this.model,
    required this.deadlines,
  });
  final CockpitActions actions;
  final GarageViewModel garage;
  final DocumentsViewModel model;
  final bool deadlines;
  Future<void> edit(
    BuildContext context,
    GarageVehicle car, [
    DocumentRecord? record,
    bool renew = false,
  ]) => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => DocumentForm(
        model: model,
        vehicleId: car.id,
        vehicleName: '${car.name} · ${car.registration}',
        record: record,
        renew: renew,
      ),
    ),
  );
  Future<void> remove(BuildContext context, DocumentRecord record) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Изтриване на документ'),
        content: Text(
          '${record.draft.kind.label}\nЗаписът и вноските ще бъдат изтрити окончателно.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Отказ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Изтрий'),
          ),
        ],
      ),
    );
    if (yes == true) {
      await model.run(
        () => model.repository.remove(record.vehicleId, record.id),
      );
    }
  }

  Widget recordCard(BuildContext context, GarageVehicle car, DocumentRecord r) {
    final d = r.draft;
    final unpaid = d.payments.where((p) => !p.paid).toList();
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(d.kind.label, style: Theme.of(context).textTheme.titleLarge),
          if (!r.active)
            const Text('История · неплатените вноски остават активни'),
          if (d.start != null) Text('Валидна от: ${displayDate(d.start!)}'),
          if (d.end != null)
            Text(
              'Валидна до: ${displayDate(d.end!)}${r.active ? ' · ${dueStatus(d.end!, DateTime.now())}' : ''}',
            ),
          if (d.payments.isNotEmpty) ...[
            const Divider(),
            Text(
              unpaid.isEmpty
                  ? 'Всички вноски са платени'
                  : 'Следващо плащане: ${displayDate(unpaid.first.due)}',
            ),
            for (final p in d.payments)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${displayDate(p.due)} · ${money(p.cents)}'),
                subtitle: Text(
                  p.paid ? 'Платена' : dueStatus(p.due, DateTime.now()),
                ),
                value: p.paid,
                onChanged: model.busy
                    ? null
                    : (value) => model.run(
                        () => model.repository.setPaid(
                          car.id,
                          r.id,
                          p.id!,
                          value ?? false,
                        ),
                      ),
              ),
          ],
          Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: model.busy ? null : () => edit(context, car, r),
                child: const Text('Редактирай'),
              ),
              if (r.active)
                TextButton(
                  onPressed: model.busy
                      ? null
                      : () => edit(context, car, r, true),
                  child: const Text('Поднови'),
                ),
              TextButton(
                onPressed: model.busy ? null : () => remove(context, r),
                child: const Text('Изтрий'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => CockpitShell(
    active: deadlines ? '/deadlines' : '/documents',
    actions: actions,
    body: ListenableBuilder(
      listenable: Listenable.merge([garage, model]),
      builder: (context, _) {
        final car = garage.active;
        final rows = model.records;
        final list = rows?.where((r) => r.vehicleId == car?.id).toList() ?? [];
        final due = deadlinesFor(rows ?? []);
        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          children: [
            Text(
              deadlines ? 'Срокове' : 'Документи',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            if (model.error != null) Text(model.error!),
            if (model.notificationError != null) Text(model.notificationError!),
            if (garage.snapshot == null) ...[
              if (garage.busy)
                const Center(child: CircularProgressIndicator())
              else
                TextButton(
                  onPressed: garage.load,
                  child: const Text('Опитай отново'),
                ),
            ] else if (garage.snapshot!.vehicles.isEmpty) ...[
              const EmptyPanel(
                title: 'Няма добавен автомобил',
                detail: 'Добави автомобил в гаража.',
              ),
              GoldButton(
                onPressed: () => actions.navigate('/garage'),
                label: 'Към гаража',
              ),
            ] else if (rows == null) ...[
              if (model.error == null)
                const Center(child: CircularProgressIndicator()),
            ] else if (deadlines) ...[
              const Text('Всички автомобили'),
              OutlinedButton(
                onPressed: model.notifications == null
                    ? null
                    : model.permission,
                child: const Text('Разреши напомняния'),
              ),
              if (due.isEmpty)
                const EmptyPanel(
                  title: 'Няма активни срокове',
                  detail: 'Добави документ или неплатена вноска.',
                ),
              for (final d in due) ...[
                const SizedBox(height: 8),
                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(d.vehicleName),
                      Text(
                        '${displayDate(d.date)} · ${dueStatus(d.date, DateTime.now())}',
                      ),
                      if (d.cents != null) Text(money(d.cents!)),
                    ],
                  ),
                ),
              ],
            ] else if (car != null) ...[
              Text('${car.name} · ${car.registration}'),
              const SizedBox(height: 12),
              GoldButton(
                key: const Key('document-add'),
                onPressed: model.busy ? null : () => edit(context, car),
                label: 'Добави документ',
              ),
              const SizedBox(height: 12),
              if (list.isEmpty)
                const EmptyPanel(
                  title: 'Няма документи',
                  detail: 'Добави първия документ на автомобила.',
                ),
              for (final r in list.where((r) => r.active)) ...[
                recordCard(context, car, r),
                const SizedBox(height: 8),
              ],
              if (list.any((r) => !r.active)) ...[
                ExpansionTile(
                  title: const Text('История'),
                  children: [
                    for (final r in list.where((r) => !r.active))
                      recordCard(context, car, r),
                  ],
                ),
              ],
            ],
          ],
        );
      },
    ),
  );
}
