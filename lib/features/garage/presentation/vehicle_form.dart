import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/garage_models.dart';
import '../domain/vehicle_catalog.dart';
import '../domain/vehicle_rules.dart';
import 'garage_view_model.dart';

Future<void> showVehicleForm(
  BuildContext context,
  GarageViewModel vm, {
  GarageVehicle? car,
}) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (_) => _VehicleForm(vm: vm, car: car),
);

class _VehicleForm extends StatefulWidget {
  const _VehicleForm({required this.vm, this.car});
  final GarageViewModel vm;
  final GarageVehicle? car;
  @override
  State<_VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<_VehicleForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController brand, model, registration, year, fuel;
  late RegistrationMode mode;
  String? selectedFuel;
  bool saving = false, manualModel = false;
  String? error;
  VehicleDraft? get previous => widget.car?.details;

  @override
  void initState() {
    super.initState();
    final old = previous;
    brand = TextEditingController(text: old?.brand);
    model = TextEditingController(text: old?.model);
    registration = TextEditingController(text: old?.registration);
    year = TextEditingController(text: old?.year?.toString());
    fuel = TextEditingController(text: old?.fuel);
    selectedFuel = old?.fuel;
    mode =
        inferRegistrationMode(registration.text) ?? RegistrationMode.bulgarian;
  }

  @override
  void dispose() {
    for (final c in [brand, model, registration, year, fuel]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<String?> _search(
    String label,
    List<String> Function(String) search, {
    bool allowManual = false,
  }) => showDialog<String>(
    context: context,
    builder: (_) =>
        _CatalogDialog(label: label, search: search, allowManual: allowManual),
  );
  Future<void> _chooseBrand() async {
    final result = await _search('Марка', searchBrands);
    if (!mounted || result == null) return;
    setState(() {
      if (brand.text != result) {
        model.clear();
        manualModel = false;
      }
      brand.text = result;
    });
  }

  Future<void> _chooseModel() async {
    if (!vehicleCatalog.containsKey(brand.text) &&
        brand.text != previous?.brand) {
      return;
    }
    final result = await _search(
      'Модел',
      (query) => searchModels(brand.text, query),
      allowManual: true,
    );
    if (!mounted || result == null) return;
    if (result == _manualChoice) {
      final value = await showDialog<String>(
        context: context,
        builder: (_) => const _ManualModelDialog(),
      );
      if (!mounted || value == null) return;
      setState(() {
        model.text = value;
        manualModel = true;
      });
    } else {
      setState(() {
        model.text = result;
        manualModel = false;
      });
    }
  }

  Future<void> _chooseFuel() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Гориво'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('Без избор'),
          ),
          for (final item in fuelOptions)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, item),
              child: Text(item),
            ),
        ],
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      selectedFuel = result.isEmpty ? null : result;
      fuel.text = result;
    });
  }

  Widget _selector(
    TextEditingController controller,
    String label,
    VoidCallback choose, {
    String? warning,
    bool mandatory = false,
    bool available = true,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      key: ValueKey(label),
      controller: controller,
      readOnly: true,
      enabled: !saving && available,
      onTap: choose,
      decoration: InputDecoration(
        labelText: label,
        helperText: warning,
        helperMaxLines: 5,
        suffixIcon: IconButton(
          tooltip: 'Избери $label от списък',
          onPressed: saving || !available ? null : choose,
          icon: const Icon(Icons.arrow_drop_down),
        ),
      ),
      validator: (value) => mandatory && (value == null || value.trim().isEmpty)
          ? 'Задължително поле'
          : null,
    ),
  );
  Future<void> _chooseMode() async {
    final result = await showDialog<RegistrationMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Вид регистрационен номер'),
        children: [
          for (final item in RegistrationMode.values)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, item),
              child: Text(_modeLabel(item)),
            ),
        ],
      ),
    );
    if (!mounted || result == null) return;
    setState(() => mode = result);
  }

  String _modeLabel(RegistrationMode value) => switch (value) {
    RegistrationMode.bulgarian => 'Български стандартен',
    RegistrationMode.foreign => 'Чуждестранен',
    RegistrationMode.personalized => 'Български по желание (6 знака)',
  };
  String? _registrationError(String? value) {
    if (value == previous?.registration && previous != null) return null;
    if (value == null || value.trim().isEmpty) return 'Задължително поле';
    return normalizedRegistration(value, mode) == null
        ? 'Невалиден или неподдържан формат'
        : null;
  }

  String? _yearError(String? value) {
    if (value == (previous?.year?.toString() ?? '')) return null;
    return validYearText(value ?? '')
        ? null
        : 'Година от 1886 до ${DateTime.now().year}';
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final draft = VehicleDraft(
      brand: brand.text,
      model: model.text,
      registration: registration.text,
      year: int.tryParse(year.text),
      fuel: selectedFuel,
      registrationMode: mode,
      manualModel: manualModel,
    );
    try {
      draft.validated(previous: previous);
    } on GarageValidation catch (e) {
      setState(() => error = e.message);
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    final success = await widget.vm.save(draft, id: widget.car?.id);
    if (!mounted) return;
    if (success) {
      setState(() => saving = false);
      Navigator.pop(context);
    } else {
      setState(() {
        saving = false;
        error = widget.vm.error ?? 'Опитай отново.';
      });
    }
  }

  static const _legacy = 'Стара стойност — може да остане непроменена.';
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !saving,
    child: AlertDialog(
      title: Text(
        widget.car == null ? 'Добави автомобил' : 'Редактирай автомобил',
      ),
      scrollable: true,
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _selector(
              brand,
              'Марка',
              _chooseBrand,
              mandatory: true,
              warning:
                  previous != null &&
                      brand.text == previous!.brand &&
                      !vehicleCatalog.containsKey(brand.text)
                  ? _legacy
                  : null,
            ),
            _selector(
              model,
              'Модел',
              _chooseModel,
              mandatory: true,
              available: brand.text.isNotEmpty,
              warning:
                  previous != null &&
                      model.text == previous!.model &&
                      !modelsForBrand(brand.text).contains(model.text)
                  ? 'Модел извън каталога — може да остане непроменен.'
                  : null,
            ),
            OutlinedButton(
              key: const ValueKey('registration-mode'),
              onPressed: saving ? null : _chooseMode,
              child: Text(_modeLabel(mode)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                key: const ValueKey('Регистрационен номер'),
                controller: registration,
                enabled: !saving,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Регистрационен номер',
                  helperText:
                      previous != null &&
                          inferRegistrationMode(previous!.registration) == null
                      ? _legacy
                      : 'Проверка на формат, не на регистрация',
                  helperMaxLines: 5,
                ),
                validator: _registrationError,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                key: const ValueKey('Година (по желание)'),
                controller: year,
                enabled: !saving,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: InputDecoration(
                  labelText: 'Година (по желание)',
                  helperText: previous != null && !validYear(previous!.year)
                      ? _legacy
                      : null,
                  helperMaxLines: 5,
                ),
                validator: _yearError,
              ),
            ),
            _selector(
              fuel,
              'Гориво (по желание)',
              _chooseFuel,
              warning:
                  previous?.fuel != null &&
                      selectedFuel == previous!.fuel &&
                      !fuelOptions.contains(selectedFuel)
                  ? _legacy
                  : null,
            ),
            if (error != null)
              Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Отказ'),
        ),
        FilledButton(
          onPressed: saving ? null : _save,
          child: Text(saving ? 'Записване…' : 'Запази'),
        ),
      ],
    ),
  );
}

const _manualChoice = '__manual_model__';

class _CatalogDialog extends StatefulWidget {
  const _CatalogDialog({
    required this.label,
    required this.search,
    required this.allowManual,
  });
  final String label;
  final List<String> Function(String) search;
  final bool allowManual;
  @override
  State<_CatalogDialog> createState() => _CatalogDialogState();
}

class _CatalogDialogState extends State<_CatalogDialog> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final choices = widget.search(query);
    return AlertDialog(
      title: Text('Избери ${widget.label.toLowerCase()}'),
      scrollable: true,
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: ValueKey('search-${widget.label}'),
              decoration: const InputDecoration(labelText: 'Търси'),
              onChanged: (v) => setState(() => query = v),
            ),
            if (choices.isEmpty)
              Text(
                widget.allowManual
                    ? 'Няма намерен модел.'
                    : 'Марката не е в локалния каталог.',
              ),
            for (final item in choices)
              ListTile(
                title: Text(item),
                onTap: () => Navigator.pop(context, item),
              ),
          ],
        ),
      ),
      actions: [
        if (widget.allowManual)
          TextButton(
            onPressed: () => Navigator.pop(context, _manualChoice),
            child: const Text('Моят модел липсва'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отказ'),
        ),
      ],
    );
  }
}

class _ManualModelDialog extends StatefulWidget {
  const _ManualModelDialog();
  @override
  State<_ManualModelDialog> createState() => _ManualModelDialogState();
}

class _ManualModelDialogState extends State<_ManualModelDialog> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Моят модел липсва'),
    scrollable: true,
    content: TextField(
      key: const ValueKey('manual-model'),
      controller: controller,
      decoration: const InputDecoration(labelText: 'Въведи модел'),
      onChanged: (_) => setState(() {}),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Отказ'),
      ),
      FilledButton(
        onPressed: controller.text.trim().isEmpty
            ? null
            : () => Navigator.pop(context, controller.text.trim()),
        child: const Text('Избери модел'),
      ),
    ],
  );
}
