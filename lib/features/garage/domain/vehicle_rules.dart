import 'vehicle_catalog.dart';

enum RegistrationMode { bulgarian, foreign, personalized }

const fuelOptions = <String>[
  'Бензин',
  'Дизел',
  'Бензин + LPG',
  'Бензин + CNG',
  'LPG',
  'CNG',
  'Хибрид',
  'Plug-in хибрид',
  'Електричество',
  'Водород',
  'Друго',
];

const _aliases = <String, String>{
  'Алфа Ромео': 'Alfa Romeo',
  'Ауди': 'Audi',
  'БМВ': 'BMW',
  'Ситроен': 'Citroën',
  'Дачия': 'Dacia',
  'Фиат': 'Fiat',
  'Форд': 'Ford',
  'Хонда': 'Honda',
  'Хюндай': 'Hyundai',
  'Хьондай': 'Hyundai',
  'Джип': 'Jeep',
  'Киа': 'Kia',
  'Ленд Роувър': 'Land Rover',
  'Лексус': 'Lexus',
  'Мазда': 'Mazda',
  'Мерцедес Бенц': 'Mercedes-Benz',
  'Мерседес': 'Mercedes-Benz',
  'Мицубиши': 'Mitsubishi',
  'Нисан': 'Nissan',
  'Опел': 'Opel',
  'Пежо': 'Peugeot',
  'Рено': 'Renault',
  'Сеат': 'SEAT',
  'Шкода': 'Škoda',
  'Субару': 'Subaru',
  'Сузуки': 'Suzuki',
  'Тесла': 'Tesla',
  'Тойота': 'Toyota',
  'Фолксваген': 'Volkswagen',
  'Волво': 'Volvo',
};
String _searchKey(String value) => value
    .toLowerCase()
    .trim()
    .replaceAll('ë', 'e')
    .replaceAll('š', 's')
    .replaceAll(RegExp(r'[\s-]+'), '');
List<String> searchBrands(String query) {
  final q = _searchKey(query);
  return vehicleCatalog.keys
      .where(
        (brand) =>
            _searchKey(brand).contains(q) ||
            _aliases.entries.any(
              (a) => a.value == brand && _searchKey(a.key).contains(q),
            ),
      )
      .toList();
}

List<String> searchModels(String brand, String query) =>
    modelsForBrand(brand)
        .where((m) => _searchKey(m).contains(_searchKey(query)))
        .toList();

const _equivalent = <String, String>{
  'А': 'A',
  'В': 'B',
  'Е': 'E',
  'К': 'K',
  'М': 'M',
  'Н': 'H',
  'О': 'O',
  'Р': 'P',
  'С': 'C',
  'Т': 'T',
  'У': 'Y',
  'Х': 'X',
};
String _latin(String value) =>
    value.toUpperCase().split('').map((c) => _equivalent[c] ?? c).join();
String registrationIdentity(String value) =>
    _latin(value).replaceAll(RegExp(r'[\s-]+', unicode: true), '');
final _standard = RegExp(
  r'^([ABEKMHOPCTYX]{1,2})([0-9]{4})([ABEKMHOPCTYX]{1,2})$',
);
final _personalized = RegExp(r'^([ABEKMHOPCTYX]{1,2})([ABEKMHOPCTYX0-9]{6})$');
final _foreign = RegExp(
  r'^[A-Z0-9А-ЯЁ]+(?:[ -][A-Z0-9А-ЯЁ]+)*$',
  unicode: true,
);
String? normalizedRegistration(String input, RegistrationMode mode) {
  final value = input.trim().toUpperCase().replaceAll(
    RegExp(r'\s+', unicode: true),
    ' ',
  );
  final compact = _latin(value).replaceAll(' ', '');
  switch (mode) {
    case RegistrationMode.bulgarian:
      final match = _standard.firstMatch(compact);
      return match == null ? null : '${match[1]} ${match[2]} ${match[3]}';
    case RegistrationMode.personalized:
      final match = _personalized.firstMatch(compact);
      return match == null ? null : '${match[1]} ${match[2]}';
    case RegistrationMode.foreign:
      final key = registrationIdentity(value);
      if (!_foreign.hasMatch(value) ||
          key.length < 2 ||
          key.length > 12 ||
          !RegExp(r'[0-9]').hasMatch(key)) {
        return null;
      }
      return value;
  }
}

RegistrationMode? inferRegistrationMode(String value) {
  for (final mode in [
    RegistrationMode.bulgarian,
    RegistrationMode.personalized,
    RegistrationMode.foreign,
  ]) {
    if (normalizedRegistration(value, mode) != null) {
      return mode;
    }
  }
  return null;
}

bool validYear(int? value) =>
    value == null || (value >= 1886 && value <= DateTime.now().year);
bool validYearText(String value) =>
    value.isEmpty ||
    (RegExp(r'^[0-9]{4}$').hasMatch(value) && validYear(int.tryParse(value)));
