import 'package:flutter/material.dart';

/// Returns whether the app should be considered in dark mode.
/// Accepts an optional [themeMode] (e.g. from a provider). If null,
/// it falls back to Theme.of(context) and then MediaQuery.platformBrightness.
bool isDarkMode(BuildContext context, ThemeMode? themeMode) {
  final platform = MediaQuery.of(context).platformBrightness;
  final material = Theme.of(context).brightness;

  if (themeMode == null) {
    // No explicit mode -> use material theme or platform as fallback.
    return material == Brightness.dark || platform == Brightness.dark;
  }

  switch (themeMode) {
    case ThemeMode.dark:
      return true;
    case ThemeMode.light:
      return false;
    case ThemeMode.system:
    default:
      return platform == Brightness.dark;
  }
}

/// Convenient extension so callers can write `context.isDarkMode(...)`.
extension ThemeUtilsX on BuildContext {
  bool isDarkModeFrom(ThemeMode? themeMode) => isDarkMode(this, themeMode);
}
