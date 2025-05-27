// theme_provider.dart
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart'; // Keep for platform adaptive colors

// Your existing list
final List<MaterialColor> seedColorList = [
  Colors.deepPurple,
  Colors.deepOrange,
  Colors.teal,
  Colors.cyan,
  Colors.indigo,
  Colors.green
];

enum ThemePreference {
  dynamic,
  custom,
}


class ThemeProvider with ChangeNotifier {
  ThemePreference _themePreference = ThemePreference
      .dynamic; // Default to dynamic
  MaterialColor _customSeedColor = seedColorList[0]; // Default custom color

  ThemePreference get themePreference => _themePreference;

  MaterialColor get customSeedColor => _customSeedColor;

  // These will now be used by NextBusApp to get the final schemes
  ColorScheme? _lightDynamicScheme;
  ColorScheme? _darkDynamicScheme;

  // Call this from NextBusApp after DynamicColorBuilder gives you the schemes
  void setDynamicSchemes(ColorScheme? light, ColorScheme? dark) {
    _lightDynamicScheme = light;
    _darkDynamicScheme = dark;
    // Notify if the preference is dynamic, as the theme might change
    if (_themePreference == ThemePreference.dynamic) {
      notifyListeners();
    }
  }

  ColorScheme get lightColorScheme {
    if (_themePreference == ThemePreference.dynamic &&
        _lightDynamicScheme != null) {
      return _lightDynamicScheme!;
    }
    // Fallback to custom or if dynamic is not available
    return ColorScheme.fromSeed(seedColor: _customSeedColor);
  }

  ColorScheme get darkColorScheme {
    if (_themePreference == ThemePreference.dynamic &&
        _darkDynamicScheme != null) {
      return _darkDynamicScheme!;
    }
    // Fallback to custom or if dynamic is not available
    return ColorScheme.fromSeed(
      seedColor: _customSeedColor,
      brightness: Brightness.dark,
    );
  }

  void setThemePreference(ThemePreference preference) {
    if (_themePreference != preference) {
      _themePreference = preference;
      notifyListeners();
    }
  }

  void setCustomSeedColor(MaterialColor newColor) {
    if (_customSeedColor != newColor) {
      _customSeedColor = newColor;
      if (_themePreference == ThemePreference.custom) {
        // Only notify if custom is active, otherwise the change will apply when they switch
        notifyListeners();
      }
    }
  }
}
