import '../../core/database/database.dart';
import 'data/local_fuel_repository.dart';
import 'domain/fuel_models.dart';

FuelRepository createFuelRepository(AppDatabase database) =>
    LocalFuelRepository(database);
