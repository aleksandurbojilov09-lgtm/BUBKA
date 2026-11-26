import 'package:flutter/widgets.dart';

class AppModule {
  const AppModule({
    required this.id,
    required this.name,
    required this.icon,
    required this.path,
    required this.builder,
  });
  final String id;
  final String name;
  final IconData icon;
  final String path;
  final WidgetBuilder builder;
}

class ModuleRegistry {
  ModuleRegistry(Iterable<AppModule> entries)
    : modules = List.unmodifiable(entries) {
    final ids = <String>{};
    final paths = <String>{'/'};
    for (final m in modules) {
      if (m.id.isEmpty ||
          !m.path.startsWith('/') ||
          !ids.add(m.id) ||
          !paths.add(m.path)) {
        throw ArgumentError('Invalid or duplicate module: ${m.id} ${m.path}');
      }
    }
  }
  final List<AppModule> modules;
}
