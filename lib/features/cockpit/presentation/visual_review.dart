import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../design_system/cockpit_components.dart';
import '../../../design_system/resource_ring.dart';
import '../../../design_system/theme.dart';
import 'cockpit_models.dart';
import 'cockpit_shell.dart';
import 'garage_screen.dart';
import 'home_screen.dart';

/// The default production build has no preview route. Explicit test-only flag.
const visualPreviewEnabled = bool.fromEnvironment('BUBKA_VISUAL_PREVIEW');

class VisualReview extends StatelessWidget {
  const VisualReview({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => CockpitFixtureModel(),
    child: const _ReviewMenu(),
  );
}

class _ReviewMenu extends StatelessWidget {
  const _ReviewMenu();
  @override
  Widget build(BuildContext context) {
    final model = context.watch<CockpitFixtureModel>();
    final scenarios = <String, ResourceView>{
      '100%': const ResourceView(
        state: ResourceState.active,
        fraction: 1,
        remaining: 365,
      ),
      '50%': const ResourceView(
        state: ResourceState.active,
        fraction: .5,
        remaining: 182,
      ),
      '25%': const ResourceView(
        state: ResourceState.active,
        fraction: .25,
        remaining: 91,
      ),
      '5%': const ResourceView(
        state: ResourceState.active,
        fraction: .05,
        remaining: 18,
      ),
      '0%': const ResourceView(
        state: ResourceState.due,
        fraction: 0,
        remaining: 0,
      ),
      'Просрочено': const ResourceView(
        state: ResourceState.overdue,
        fraction: 0,
        remaining: -3,
      ),
      'Неизвестен': const ResourceView(),
      'Дни без процент': const ResourceView(
        state: ResourceState.daysOnly,
        remaining: 14,
      ),
    };
    void open(Widget child) => Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => _PreviewBanner(child: child)),
    );
    final actions = CockpitActions(
      navigate: (path) {
        if (path == '/garage') {
          open(GarageScreen(actions: _noActions(context), fixture: model));
        } else if (path == '/fuel') {
          open(const FuelFormPreview());
        } else {
          _future(context, 'Демонстрационен маршрут $path');
        }
      },
      quick: () => showQuickSheet(context, (title) => _future(context, title)),
      future: (title) => _future(context, title),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Визуален тест · BUBA')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const EmptyPanel(
            title: 'САМО ПРИМЕРНИ ДАННИ',
            detail: 'Този преглед не чете и не променя реалния гараж или SQLite. Няма запис на формуляри.',
          ),
          const SizedBox(height: 16),
          GoldButton(
            label: 'Cockpit · избран автомобил',
            onPressed: () =>
                open(CockpitHome(actions: actions, fixture: model)),
          ),
          GoldButton(
            label: 'Cockpit · празен гараж',
            onPressed: () => open(CockpitHome(actions: actions)),
          ),
          GoldButton(
            label: 'Cinematic Ignition · 3400 ms',
            onPressed: () => open(
              CockpitHome(actions: actions, fixture: model, playIntro: true),
            ),
          ),
          GoldButton(
            label: 'Гараж · примерни карти',
            onPressed: () =>
                open(GarageScreen(actions: actions, fixture: model)),
          ),
          GoldButton(
            label: 'Гараж · празен',
            onPressed: () => open(GarageScreen(actions: actions)),
          ),
          GoldButton(
            label: 'Зареждане · формуляр',
            onPressed: () => open(const FuelFormPreview()),
          ),
          GoldButton(
            label: 'Други формуляри и статуси',
            onPressed: () => open(const FormStatusPreview()),
          ),
          const SizedBox(height: 12),
          const Text(
            'Ресурс за текущия тестов автомобил',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in scenarios.entries)
                OutlinedButton(
                  onPressed: () {
                    model.showResource(entry.value);
                    open(CockpitHome(actions: actions, fixture: model));
                  },
                  child: Text(entry.key),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewBanner extends StatelessWidget {
  const _PreviewBanner({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Назад към тестовия преглед',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
              const Expanded(
                child: Text(
                  'ТЕСТОВ ВИЗУАЛЕН ПРЕГЛЕД · без запис',
                  style: TextStyle(fontSize: 12, color: BubkaDesign.accent),
                ),
              ),
            ],
          ),
          Expanded(child: child),
        ],
      ),
    ),
  );
}

void _future(BuildContext context, String title) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text('$title · само визуален преглед')));
CockpitActions _noActions(BuildContext context) => CockpitActions(
  navigate: (path) => _future(context, path),
  quick: () => showQuickSheet(context, (title) => _future(context, title)),
  future: (title) => _future(context, title),
);

Future<void> showQuickSheet(
  BuildContext context,
  ValueChanged<String> onAction,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (ctx) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Бързи действия',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Функциите ще се активират в съответните фази.',
            style: TextStyle(color: BubkaDesign.muted),
          ),
          for (final item in const <(String, IconData)>[
            ('Зареждане', Icons.local_gas_station_outlined),
            ('Километраж', Icons.speed_outlined),
            ('Сервиз', Icons.build_outlined),
            ('Документ', Icons.description_outlined),
            ('Напомняне', Icons.notifications_none_outlined),
            ('Автомобил', Icons.directions_car_outlined),
          ])
            ListTile(
              leading: Icon(item.$2, color: BubkaDesign.accent),
              title: Text(item.$1),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                onAction(item.$1);
              },
            ),
        ],
      ),
    ),
  ),
);

/// The fuel fields are the approved owner contract. No full-tank selector or
/// historical checkbox, no write, no actual consumption calculation.
class FuelFormPreview extends StatefulWidget {
  const FuelFormPreview({super.key});
  @override
  State<FuelFormPreview> createState() => _FuelFormPreviewState();
}

class _FuelFormPreviewState extends State<FuelFormPreview> {
  final _liters = TextEditingController(),
      _km = TextEditingController(),
      _price = TextEditingController();
  late final TextEditingController _date;
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date = TextEditingController(
      text:
          '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}',
    );
  }

  double? _number(String text) => double.tryParse(text.replaceAll(',', '.'));
  @override
  void dispose() {
    for (final c in [_liters, _km, _price, _date]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liters = _number(_liters.text), price = _number(_price.text);
    final km = int.tryParse(_km.text);
    final validPrice = price != null && price.isFinite && price >= 0;
    final validLiters = liters != null && liters.isFinite && liters > 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Зареждане')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Визуален формуляр · не записва данни',
            style: TextStyle(color: BubkaDesign.accent),
          ),
          const SizedBox(height: 16),
          PremiumField(
            label: 'Литри гориво *',
            controller: _liters,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            error: _liters.text.isNotEmpty && !validLiters
                ? 'Въведи повече от 0 литра'
                : null,
          ),
          PremiumField(
            label: 'Общ километраж *',
            controller: _km,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            error: _km.text.isNotEmpty && (km == null || km < 0)
                ? 'Въведи цяло число ≥ 0'
                : null,
          ),
          PremiumField(
            label: 'Обща цена (EUR) · по желание',
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            error: _price.text.isNotEmpty && !validPrice
                ? 'Въведи валидна сума'
                : null,
          ),
          PremiumField(
            label: 'Дата',
            controller: _date,
            keyboardType: TextInputType.datetime,
            hint: 'ДД.ММ.ГГГГ',
          ),
          PremiumCard(
            child: Text(
              'Цена/литър: ${price != null && liters != null && validLiters && validPrice ? '${(price / liters).toStringAsFixed(2)} EUR' : '—'}',
            ),
          ),
          const SizedBox(height: 16),
          const GoldButton(
            label: 'Запази · недостъпно в теста',
            onPressed: null,
          ),
        ],
      ),
    );
  }
}

class FormStatusPreview extends StatelessWidget {
  const FormStatusPreview({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Формуляри и статуси')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Визуални образци · без запис',
          style: TextStyle(color: BubkaDesign.accent),
        ),
        const SizedBox(height: 16),
        const Text(
          'Автомобил',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        const PremiumField(label: 'Марка и модел'),
        const PremiumField(label: 'Регистрационен номер · по желание'),
        const PremiumField(label: 'VIN · по желание'),
        const PremiumField(label: 'Година', keyboardType: TextInputType.number),
        const PremiumField(label: 'Гориво'),
        const PremiumField(
          label: 'Километраж',
          keyboardType: TextInputType.number,
        ),
        const Divider(),
        const Text(
          'Сервиз',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        const PremiumField(label: 'Наименование'),
        const PremiumField(
          label: 'Километраж',
          keyboardType: TextInputType.number,
        ),
        const PremiumField(label: 'Дата'),
        const PremiumField(label: 'Цена · по желание'),
        const PremiumField(label: 'Бележка'),
        const PremiumField(label: 'Интервал км'),
        const Divider(),
        const Text(
          'Документ',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        const PremiumField(label: 'Начало'),
        const PremiumField(label: 'Край'),
        const PremiumField(label: 'Цена · по желание'),
        const PremiumField(label: 'Последна ръчна проверка'),
        const Divider(),
        const EmptyPanel(
          title: 'Няма данни',
          detail: 'Неизвестните стойности не се заместват с нула.',
        ),
        const SizedBox(height: 8),
        const PremiumCard(child: Text('Частични данни · сумата е непълна')),
        const SizedBox(height: 8),
        const PremiumCard(
          child: Text(
            'Грешка · провери въведените данни',
            style: TextStyle(color: BubkaDesign.error),
          ),
        ),
        const SizedBox(height: 8),
        const PremiumCard(selected: true, child: Text('Избрано')),
        const SizedBox(height: 8),
        const PremiumCard(child: LinearProgressIndicator(value: .4)),
        const SizedBox(height: 8),
        const GoldButton(label: 'Запази · деактивирано', onPressed: null),
      ],
    ),
  );
}
