import 'package:material_ui/material_ui.dart';

abstract final class BubkaDesign {
  static const background = Color(0xFF141518);
  static const graphite = Color(0xFF1C1D21);
  static const surface = Color(0xFF25262A);
  static const surfaceDark = Color(0xFF1B1C20);
  static const surfaceLight = Color(0xFF303136);
  static const accent = Color(0xFFE6BD7E);
  static const goldHighlight = Color(0xFFF6D29A);
  static const goldDark = Color(0xFFC19A67);
  static const goldShadow = Color(0xFF685740);
  static const text = Color(0xFFF5F4F3);
  static const muted = Color(0xFFB5B6BE);
  static const border = Color(0xFF42434A);
  static const error = Color(0xFFFF9B9D);
  static const spacing = 16.0;
  static const radius = 16.0;
  static const motion = Duration(milliseconds: 320);
  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF303136), Color(0xFF222327), Color(0xFF1C1D20)],
    stops: [0, .52, 1],
  );
  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5D3A0), Color(0xFFC59B63)],
  );
  static ThemeData get dark => ThemeData(
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
        ).copyWith(
          primary: accent,
          onPrimary: background,
          surface: surface,
          onSurface: text,
          error: error,
          outline: border,
        ),
    scaffoldBackgroundColor: background,
    canvasColor: background,
    useMaterial3: true,
    visualDensity: VisualDensity.standard,
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      bodyMedium: TextStyle(fontSize: 16, color: text),
      bodySmall: TextStyle(fontSize: 14, color: muted),
    ),
    appBarTheme: const AppBarThemeData(
      backgroundColor: background,
      foregroundColor: text,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
    ),
  );
}
