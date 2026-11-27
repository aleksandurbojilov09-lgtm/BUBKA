import '../../core/database/database.dart';
import 'data/local_garage_repository.dart';
import 'presentation/garage_view_model.dart';

GarageViewModel createGarageViewModel(AppDatabase db) =>
    GarageViewModel(LocalGarageRepository(db));
