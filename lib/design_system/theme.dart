import 'package:material_ui/material_ui.dart';

abstract final class BubkaDesign {
  static const background = Color(0xFF111318);
  static const accent = Color(0xFF9EB8F0);
  static const spacing = 16.0;
  static const radius = 12.0;
  static const motion = Duration(milliseconds: 180);
  static ThemeData get dark => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: background,
    useMaterial3: true,
    textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 16)),
    cardTheme: const CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
    ),
  );
}
