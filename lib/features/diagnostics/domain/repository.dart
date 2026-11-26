class DiagnosticItem {
  const DiagnosticItem(this.id, this.value);
  final int id;
  final String value;
}

abstract interface class DiagnosticsRepository {
  Future<List<DiagnosticItem>> read();
  Future<void> add();
  Future<void> edit(int id);
  Future<void> remove(int id);
}
