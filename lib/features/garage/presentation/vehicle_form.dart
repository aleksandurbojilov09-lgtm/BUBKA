import 'package:material_ui/material_ui.dart';

import '../domain/garage_models.dart';
import '../domain/vehicle_catalog.dart';
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
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final value = widget.car?.details;
    brand = TextEditingController(text: value?.brand);
    model = TextEditingController(text: value?.model);
    registration = TextEditingController(text: value?.registration);
    year = TextEditingController(text: value?.year?.toString());
    fuel = TextEditingController(text: value?.fuel);
  }

  @override
  void dispose() {
    for (final controller in [brand, model, registration, year, fuel]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _choose(
    TextEditingController controller,
    String label,
    List<String> choices,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(label),
        children: [
          for (final item in choices)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, item),
              child: Text(item),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ръчно въвеждане'),
          ),
        ],
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      if (controller == brand && brand.text != result) model.clear();
      controller.text = result;
    });
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    List<String>? choices,
    bool mandatory = false,
    bool numeric = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      key: ValueKey(label),
      controller: controller,
      enabled: !saving,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: choices == null || choices.isEmpty
            ? null
            : IconButton(
                tooltip: 'Избери $label от списък',
                onPressed: saving
                    ? null
                    : () => _choose(controller, label, choices),
                icon: const Icon(Icons.arrow_drop_down),
              ),
      ),
      onChanged: controller == brand ? (_) => setState(model.clear) : null,
      validator: (value) {
        if (mandatory && (value == null || value.trim().isEmpty)) {
          return 'Задължително поле';
        }
        if (numeric && value != null && value.trim().isNotEmpty) {
          final parsed = int.tryParse(value.trim());
          if (parsed == null || parsed < 1 || parsed > 9999) {
            return 'Невалидна година';
          }
        }
        return null;
      },
    ),
  );

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      saving = true;
      error = null;
    });
    final success = await widget.vm.save(
      VehicleDraft(
        brand: brand.text,
        model: model.text,
        registration: registration.text,
        year: int.tryParse(year.text.trim()),
        fuel: fuel.text,
      ),
      id: widget.car?.id,
    );
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
            _field(
              brand,
              'Марка',
              mandatory: true,
              choices: vehicleCatalog.keys.toList(),
            ),
            _field(
              model,
              'Модел',
              mandatory: true,
              choices: modelsForBrand(brand.text),
            ),
            _field(registration, 'Регистрационен номер', mandatory: true),
            _field(year, 'Година (по желание)', numeric: true),
            _field(
              fuel,
              'Гориво (по желание)',
              choices: const [
                'Бензин',
                'Дизел',
                'Газ',
                'Метан',
                'Хибрид',
                'Електричество',
                'Друго',
              ],
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
