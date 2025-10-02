import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

// Simple theme provider
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);