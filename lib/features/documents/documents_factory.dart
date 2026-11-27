import '../../core/database/database.dart';
import '../../core/notifications/notification_service.dart';
import 'data/local_documents_repository.dart';
import 'presentation/documents_view_model.dart';

DocumentsViewModel createDocuments(
  AppDatabase db,
  NotificationService? notifications,
) => DocumentsViewModel(LocalDocumentsRepository(db), notifications);
