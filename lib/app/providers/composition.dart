import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/database/connection.dart';
import '../../core/database/database.dart';
import '../../features/diagnostics/diagnostics.dart';
import '../../features/garage/garage.dart';
import '../../features/fuel/fuel.dart';
import '../../features/fuel/fuel_factory.dart';
import '../../features/garage/garage_factory.dart';
import '../modules/module_registry.dart';
import '../version.dart';

AppDatabase createDatabase() => AppDatabase(localExecutor());

GarageViewModel createGarage(AppDatabase database) =>
    createGarageViewModel(database);

FuelRepository createFuel(AppDatabase database) =>
    createFuelRepository(database);

ModuleRegistry createRegistry() => ModuleRegistry([
  AppModule(
    id: 'diagnostics',
    name: 'Диагностика',
    icon: Icons.health_and_safety_outlined,
    path: '/diagnostics',
    builder: (context) => ChangeNotifierProvider(
      create: (_) =>
          DiagnosticsViewModel(context.read<DiagnosticsRepository>())..load(),
      child: const DiagnosticsScreen(version: '$appVersion+$appBuild'),
    ),
  ),
]);
