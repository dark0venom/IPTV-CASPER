import 'package:flutter/material.dart';

/// Custom app theme model
class AppTheme {
  final String id;
  final String name;
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final bool isCustom;

  AppTheme({
    required this.id,
    required this.name,
    required this.lightTheme,
    required this.darkTheme,
    this.isCustom = false,
  });

  /// Create from JSON
  factory AppTheme.fromJson(Map<String, dynamic> json) {
    return AppTheme(
      id: json['id'] as String,
      name: json['name'] as String,
      lightTheme: _themeFromJson(json['light_theme'] as Map<String, dynamic>),
      darkTheme: _themeFromJson(json['dark_theme'] as Map<String, dynamic>),
      isCustom: json['is_custom'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'light_theme': _themeToJson(lightTheme),
      'dark_theme': _themeToJson(darkTheme),
      'is_custom': isCustom,
    };
  }

  /// Create theme from JSON map
  static ThemeData _themeFromJson(Map<String, dynamic> json) {
    return ThemeData(
      brightness: json['brightness'] == 'dark' ? Brightness.dark : Brightness.light,
      primaryColor: Color(json['primary_color'] as int),
      scaffoldBackgroundColor: Color(json['background_color'] as int),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(json['app_bar_color'] as int),
        foregroundColor: Color(json['app_bar_text_color'] as int),
      ),
      colorScheme: ColorScheme(
        brightness: json['brightness'] == 'dark' ? Brightness.dark : Brightness.light,
        primary: Color(json['primary_color'] as int),
        onPrimary: Color(json['on_primary_color'] as int),
        secondary: Color(json['secondary_color'] as int),
        onSecondary: Color(json['on_secondary_color'] as int),
        error: Color(json['error_color'] as int),
        onError: Color(json['on_error_color'] as int),
        surface: Color(json['surface_color'] as int),
        onSurface: Color(json['on_surface_color'] as int),
      ),
    );
  }

  /// Convert theme to JSON map
  static Map<String, dynamic> _themeToJson(ThemeData theme) {
    return {
      'brightness': theme.brightness == Brightness.dark ? 'dark' : 'light',
      'primary_color': theme.primaryColor.value,
      'background_color': theme.scaffoldBackgroundColor.value,
      'app_bar_color': theme.appBarTheme.backgroundColor?.value ?? theme.primaryColor.value,
      'app_bar_text_color': theme.appBarTheme.foregroundColor?.value ?? Colors.white.value,
      'on_primary_color': theme.colorScheme.onPrimary.value,
      'secondary_color': theme.colorScheme.secondary.value,
      'on_secondary_color': theme.colorScheme.onSecondary.value,
      'error_color': theme.colorScheme.error.value,
      'on_error_color': theme.colorScheme.onError.value,
      'surface_color': theme.colorScheme.surface.value,
      'on_surface_color': theme.colorScheme.onSurface.value,
    };
  }
}

/// Predefined app themes
class AppThemes {
  /// Default dark theme (Blue-Purple gradient)
  static AppTheme get defaultTheme => AppTheme(
        id: 'default',
        name: 'IPTV Casper (Default)',
        lightTheme: _defaultLightTheme,
        darkTheme: _defaultDarkTheme,
      );

  /// Modern dark theme
  static AppTheme get modernDark => AppTheme(
        id: 'modern_dark',
        name: 'Modern Dark',
        lightTheme: _modernLightTheme,
        darkTheme: _modernDarkTheme,
      );

  /// Ocean theme
  static AppTheme get ocean => AppTheme(
        id: 'ocean',
        name: 'Ocean Blue',
        lightTheme: _oceanLightTheme,
        darkTheme: _oceanDarkTheme,
      );

  /// Forest theme
  static AppTheme get forest => AppTheme(
        id: 'forest',
        name: 'Forest Green',
        lightTheme: _forestLightTheme,
        darkTheme: _forestDarkTheme,
      );

  /// Sunset theme
  static AppTheme get sunset => AppTheme(
        id: 'sunset',
        name: 'Sunset Orange',
        lightTheme: _sunsetLightTheme,
        darkTheme: _sunsetDarkTheme,
      );

  /// Midnight theme
  static AppTheme get midnight => AppTheme(
        id: 'midnight',
        name: 'Midnight Purple',
        lightTheme: _midnightLightTheme,
        darkTheme: _midnightDarkTheme,
      );

  /// Get all predefined themes
  static List<AppTheme> get all => [
        defaultTheme,
        modernDark,
        ocean,
        forest,
        sunset,
        midnight,
      ];

  // Default Theme Data
  static final _defaultLightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF6200EE),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF6200EE),
      foregroundColor: Colors.white,
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6200EE),
      secondary: Color(0xFF03DAC6),
    ),
  );

  static final _defaultDarkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF6200EE),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6200EE),
      secondary: Color(0xFF03DAC6),
      surface: Color(0xFF1E1E1E),
    ),
  );

  // Modern Theme Data
  static final _modernLightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.indigo,
    scaffoldBackgroundColor: Colors.grey[50],
    colorScheme: const ColorScheme.light(
      primary: Colors.indigo,
      secondary: Colors.teal,
      surface: Colors.white,
    ),
  );

  static final _modernDarkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.indigo,
    scaffoldBackgroundColor: const Color(0xFF0A0A0A),
    colorScheme: const ColorScheme.dark(
      primary: Colors.indigo,
      secondary: Colors.tealAccent,
      surface: Color(0xFF1A1A1A),
    ),
  );

  // Ocean Theme Data
  static final _oceanLightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue[700],
    scaffoldBackgroundColor: Colors.blue[50],
    colorScheme: ColorScheme.light(
      primary: Colors.blue[700]!,
      secondary: Colors.cyan,
    ),
  );

  static final _oceanDarkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blue[700],
    scaffoldBackgroundColor: const Color(0xFF0D1B2A),
    colorScheme: ColorScheme.dark(
      primary: Colors.blue[400]!,
      secondary: Colors.cyan[300]!,
      surface: const Color(0xFF1B263B),
    ),
  );

  // Forest Theme Data
  static final _forestLightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.green[700],
    scaffoldBackgroundColor: Colors.green[50],
    colorScheme: ColorScheme.light(
      primary: Colors.green[700]!,
      secondary: Colors.lightGreen,
    ),
  );

  static final _forestDarkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.green[700],
    scaffoldBackgroundColor: const Color(0xFF0F1A0F),
    colorScheme: ColorScheme.dark(
      primary: Colors.green[400]!,
      secondary: Colors.lightGreen[300]!,
      surface: const Color(0xFF1A2A1A),
    ),
  );

  // Sunset Theme Data
  static final _sunsetLightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.deepOrange[700],
    scaffoldBackgroundColor: Colors.orange[50],
    colorScheme: ColorScheme.light(
      primary: Colors.deepOrange[700]!,
      secondary: Colors.amber,
    ),
  );

  static final _sunsetDarkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.deepOrange[700],
    scaffoldBackgroundColor: const Color(0xFF1A0F0A),
    colorScheme: ColorScheme.dark(
      primary: Colors.deepOrange[400]!,
      secondary: Colors.amber[300]!,
      surface: const Color(0xFF2A1A1A),
    ),
  );

  // Midnight Theme Data
  static final _midnightLightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.deepPurple[700],
    scaffoldBackgroundColor: Colors.purple[50],
    colorScheme: ColorScheme.light(
      primary: Colors.deepPurple[700]!,
      secondary: Colors.purpleAccent,
    ),
  );

  static final _midnightDarkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.deepPurple[700],
    scaffoldBackgroundColor: const Color(0xFF0A0A1A),
    colorScheme: ColorScheme.dark(
      primary: Colors.deepPurple[400]!,
      secondary: Colors.purpleAccent[100]!,
      surface: const Color(0xFF1A1A2A),
    ),
  );
}
