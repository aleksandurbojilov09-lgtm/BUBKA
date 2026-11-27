enum DocumentKind {
  liability('Гражданска отговорност'),
  casco('Каско'),
  inspection('ГТП'),
  vignette('Винетка'),
  tax('Данък МПС');

  const DocumentKind(this.label);
  final String label;
  bool get permitsPayments => this == liability || this == casco || this == tax;
}

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
DateTime? parseDate(String input) {
  final s = input.trim();
  final bg = RegExp(r'^(\d{2})\.(\d{2})\.(\d{4})$').firstMatch(s);
  final value = bg == null ? s : '${bg[3]}-${bg[2]}-${bg[1]}';
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return null;
  final d = DateTime.tryParse(value);
  if (d == null || d.year < 1900 || dateKey(d) != value) return null;
  return d;
}

String displayDate(String s) =>
    '${s.substring(8, 10)}.${s.substring(5, 7)}.${s.substring(0, 4)}';
int? parseCents(String input) {
  final m = RegExp(r'^(\d{1,9})(?:[.,](\d{1,2}))?$').firstMatch(input.trim());
  if (m == null) return null;
  return int.parse(m[1]!) * 100 + int.parse((m[2] ?? '').padRight(2, '0'));
}

String money(int cents) =>
    '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')} €';
String dueStatus(String due, DateTime now) {
  final c = due.compareTo(dateKey(now));
  return c < 0
      ? 'Просрочено'
      : c == 0
      ? 'Днес'
      : 'Предстоящо';
}

class DocumentValidation implements Exception {
  const DocumentValidation(this.message);
  final String message;
}

class PaymentDraft {
  const PaymentDraft({
    this.id,
    required this.due,
    required this.cents,
    this.paid = false,
  });
  final int? id;
  final String due;
  final int cents;
  final bool paid;
}

class DocumentDraft {
  const DocumentDraft({
    required this.kind,
    this.start,
    this.end,
    this.payments = const [],
  });
  final DocumentKind kind;
  final String? start, end;
  final List<PaymentDraft> payments;
  void validate() {
    bool valid(String? s) =>
        s != null && parseDate(s) != null && dateKey(parseDate(s)!) == s;
    if (kind == DocumentKind.tax) {
      if (start != null || end != null || payments.isEmpty) {
        throw const DocumentValidation(
          'Въведи поне един падеж и сума за данъка.',
        );
      }
    } else if (!valid(end) ||
        (start != null && (!valid(start) || start!.compareTo(end!) > 0))) {
      throw const DocumentValidation('Въведи валиден срок на документа.');
    }
    if (!kind.permitsPayments && payments.isNotEmpty) {
      throw const DocumentValidation('Този документ няма вноски.');
    }
    final ids = <int>{};
    for (final p in payments) {
      if (!valid(p.due) ||
          p.cents < 0 ||
          p.cents > 99999999999 ||
          (p.id != null && !ids.add(p.id!))) {
        throw const DocumentValidation('Невалиден падеж или сума на вноска.');
      }
    }
  }
}

class DocumentRecord {
  const DocumentRecord(
    this.id,
    this.vehicleId,
    this.vehicleName,
    this.active,
    this.draft,
  );
  final int id, vehicleId;
  final String vehicleName;
  final bool active;
  final DocumentDraft draft;
}

class DocumentDeadline {
  const DocumentDeadline({
    required this.id,
    required this.payment,
    required this.date,
    required this.label,
    required this.vehicleName,
    this.cents,
  });
  final int id;
  final bool payment;
  final String date, label, vehicleName;
  final int? cents;
  int reminderId(int offset) {
    if (id < 1 || id > 200000000) throw StateError('Reminder ID out of range');
    return (payment ? 1500000000 : 1000000000) + id * 2 + (offset == 7 ? 0 : 1);
  }
}

List<DocumentDeadline> deadlinesFor(List<DocumentRecord> records) {
  final result = <DocumentDeadline>[];
  for (final r in records) {
    final d = r.draft;
    if (r.active && d.end != null) {
      result.add(
        DocumentDeadline(
          id: r.id,
          payment: false,
          date: d.end!,
          label: '${d.kind.label} · валидност',
          vehicleName: r.vehicleName,
        ),
      );
    }
    for (final p in d.payments.where((p) => !p.paid)) {
      result.add(
        DocumentDeadline(
          id: p.id!,
          payment: true,
          date: p.due,
          label: '${d.kind.label} · плащане',
          vehicleName: r.vehicleName,
          cents: p.cents,
        ),
      );
    }
  }
  result.sort((a, b) => a.date.compareTo(b.date));
  return result;
}

abstract interface class DocumentsRepository {
  Stream<List<DocumentRecord>> watch();
  Future<void> save(
    int vehicleId,
    DocumentDraft draft, {
    int? id,
    int? renewId,
  });
  Future<void> remove(int vehicleId, int id);
  Future<void> setPaid(int vehicleId, int documentId, int paymentId, bool paid);
}
