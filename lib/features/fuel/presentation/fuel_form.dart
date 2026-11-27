import 'package:material_ui/material_ui.dart';

import '../../../design_system/cockpit_components.dart';
import '../domain/fuel_models.dart';
import 'fuel_view_model.dart';

class FuelForm extends StatefulWidget {
  const FuelForm({
    super.key,
    required this.model,
    required this.vehicleName,
    required this.isFuel,
    this.record,
  });
  final FuelViewModel model;
  final String vehicleName;
  final bool isFuel;
  final FuelRecord? record;
  @override
  State<FuelForm> createState() => _FuelFormState();
}

class _FuelFormState extends State<FuelForm> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _km, _litres, _price, _date;
  bool saving = false;
  String? error;
  @override
  void initState() {
    super.initState();
    final old = widget.record?.draft;
    _km = TextEditingController(text: old?.odometerKm.toString() ?? '');
    _litres = TextEditingController(
      text: old?.fuelMl == null ? '' : quantityText(old!.fuelMl!, 3),
    );
    _price = TextEditingController(
      text: old?.priceCents == null ? '' : quantityText(old!.priceCents!, 2),
    );
    _date = TextEditingController(
      text: displayCalendarDate(old?.date ?? calendarDate(DateTime.now())),
    );
  }

  @override
  void dispose() {
    for (final controller in [_km, _litres, _price, _date]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (saving) return;
    final validFields = _key.currentState!.validate();
    final km = parseQuantity(_km.text, 0);
    final ml = widget.isFuel ? parseQuantity(_litres.text, 3) : null;
    final hasPrice = widget.isFuel && _price.text.trim().isNotEmpty;
    final cents = hasPrice ? parseQuantity(_price.text, 2) : null;
    // ListView may unmount off-screen form fields; validate every controller, not only mounted fields.
    if (km == null ||
        (widget.isFuel && (ml == null || ml <= 0)) ||
        (hasPrice && cents == null)) {
      setState(() => error = 'Провери километража, литрите и въведената цена.');
      return;
    }
    final draft = FuelDraft(
      date: calendarDateInput(_date.text),
      odometerKm: km,
      fuelMl: ml,
      priceCents: cents,
    );
    if (!validFields) {
      setState(() => error = 'Провери въведените данни.');
      return;
    }
    try {
      draft.validate();
    } on FuelValidation catch (e) {
      setState(() => error = e.message);
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    final ok = await widget.model.save(draft, id: widget.record?.id);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        saving = false;
        error = widget.model.error ?? 'Записът не е запазен.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !saving,
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.isFuel ? 'Зареждане' : 'Километраж'),
        automaticallyImplyLeading: !saving,
      ),
      body: SafeArea(
        child: Form(
          key: _key,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                widget.vehicleName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (widget.isFuel) ...[
                TextFormField(
                  key: const Key('fuel-litres'),
                  controller: _litres,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Литри гориво *',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (s) => (parseQuantity(s ?? '', 3) ?? 0) <= 0
                      ? 'Въведи положителни литри (до 3 знака).'
                      : null,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                key: const Key('fuel-km'),
                controller: _km,
                enabled: !saving,
                decoration: const InputDecoration(
                  labelText: 'Общ километраж *',
                ),
                keyboardType: TextInputType.number,
                validator: (s) => parseQuantity(s ?? '', 0) == null
                    ? 'Въведи цяло неотрицателно число.'
                    : null,
              ),
              const SizedBox(height: 12),
              if (widget.isFuel) ...[
                TextFormField(
                  key: const Key('fuel-price'),
                  controller: _price,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Обща цена (EUR) · по желание',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (s) =>
                      (s ?? '').trim().isNotEmpty &&
                          parseQuantity(s!, 2) == null
                      ? 'Въведи цена с до 2 десетични знака.'
                      : null,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                key: const Key('fuel-date'),
                controller: _date,
                enabled: !saving,
                decoration: const InputDecoration(
                  labelText: 'Дата (ДД.ММ.ГГГГ) *',
                ),
                keyboardType: TextInputType.datetime,
                validator: (s) {
                  try {
                    FuelDraft(
                      date: calendarDateInput(s ?? ''),
                      odometerKm: 0,
                    ).validate();
                    return null;
                  } on FuelValidation catch (e) {
                    return e.message;
                  }
                },
              ),
              const SizedBox(height: 16),
              if (error != null)
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              GoldButton(
                key: const Key('fuel-save'),
                onPressed: saving ? null : save,
                label: saving ? 'Записване…' : 'Запази',
              ),
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(context),
                child: const Text('Отказ'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
