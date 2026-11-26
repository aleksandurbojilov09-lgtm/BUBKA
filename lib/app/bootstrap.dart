import 'package:flutter/widgets.dart';

import 'app.dart';
import 'providers/composition.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(BubkaApp(database: createDatabase()));
}
