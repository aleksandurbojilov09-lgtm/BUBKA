import '../../../core/odometer/odometer_reader.dart';

class FuelValidation implements Exception {
  const FuelValidation(this.message);
  final String message;
}

String calendarDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String displayCalendarDate(String iso) =>
    '${iso.substring(8, 10)}.${iso.substring(5, 7)}.${iso.substring(0, 4)}';

String calendarDateInput(String input) {
  final value = input.trim();
  final match = RegExp(r'^(\d{2})\.(\d{2})\.(\d{4})$').firstMatch(value);
  return match == null
      ? value
      : '${match.group(3)}-${match.group(2)}-${match.group(1)}';
}

int? parseQuantity(String input, int digits) {
  final text = input.trim().replaceAll(',', '.');
  final pattern = digits == 0 ? r'^\d+$' : '^\\d+(?:\\.\\d{1,$digits})?\$';
  if (!RegExp(pattern).hasMatch(text)) return null;
  final parts = text.split('.');
  final scaled =
      '${parts.first}${(parts.length == 2 ? parts.last : '').padRight(digits, '0')}';
  return int.tryParse(scaled);
}

String quantityText(int value, int digits) {
  final text = value.toString().padLeft(digits + 1, '0');
  if (digits == 0) return text;
  return '${text.substring(0, text.length - digits)}.${text.substring(text.length - digits)}';
}

class FuelDraft {
  const FuelDraft({
    required this.date,
    required this.odometerKm,
    this.fuelMl,
    this.priceCents,
  });
  final String date;
  final int odometerKm;
  final int? fuelMl, priceCents;

  void validate() {
    final parsed = DateTime.tryParse(date);
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date) ||
        parsed == null ||
        parsed.year < 1 ||
        calendarDate(parsed) != date ||
        date.compareTo(calendarDate(DateTime.now())) > 0) {
      throw const FuelValidation(
        'Въведи валидна дата, не по-късна от днес (ДД.ММ.ГГГГ).',
      );
    }
    if (odometerKm < 0) {
      throw const FuelValidation(
        'Километражът трябва да е цяло неотрицателно число.',
      );
    }
    if (fuelMl != null && fuelMl! <= 0) {
      throw const FuelValidation('Литрите трябва да са повече от нула.');
    }
    if (priceCents != null && (priceCents! < 0 || fuelMl == null)) {
      throw const FuelValidation('Невалидна цена.');
    }
  }
}

class FuelRecord {
  const FuelRecord(this.id, this.vehicleId, this.draft);
  final int id, vehicleId;
  final FuelDraft draft;
}

class FuelHistory {
  FuelHistory(List<FuelRecord> entries)
    : entries = List.unmodifiable(
        [...entries]..sort((a, b) {
          final date = a.draft.date.compareTo(b.draft.date);
          if (date != 0) return date;
          final km = a.draft.odometerKm.compareTo(b.draft.odometerKm);
          return km == 0 ? a.id.compareTo(b.id) : km;
        }),
      );
  final List<FuelRecord> entries;
  int? get latestKm => entries.isEmpty ? null : entries.last.draft.odometerKm;
  double? get estimatedConsumption {
    final fuel = entries.where((e) => e.draft.fuelMl != null).toList();
    if (fuel.length < 2) return null;
    final distance = fuel.last.draft.odometerKm - fuel.first.draft.odometerKm;
    if (distance <= 0) return null;
    final ml = fuel.skip(1).fold<double>(0, (sum, e) => sum + e.draft.fuelMl!);
    return ml / 10 / distance;
  }
}

abstract interface class FuelRepository implements OdometerReader {
  Future<FuelHistory> read(int vehicleId);
  Future<FuelHistory> save(int vehicleId, FuelDraft draft, {int? id});
  Future<FuelHistory> remove(int vehicleId, int id);
}
