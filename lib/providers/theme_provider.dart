import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_accent.dart';

class AccentThemeNotifier extends StateNotifier<AppAccent> {
  AccentThemeNotifier() : super(AppAccent.cyberViolet) {
    _loadTheme();
  }

  final _box = Hive.box('settings');

  void _loadTheme() {
    final savedName = _box.get('accentTheme') as String?;
    if (savedName != null && AppAccent.byName.containsKey(savedName)) {
      state = AppAccent.byName[savedName]!;
    }
  }

  Future<void> setTheme(String name) async {
    if (AppAccent.byName.containsKey(name)) {
      state = AppAccent.byName[name]!;
      await _box.put('accentTheme', name);
    }
  }
}

final accentThemeProvider = StateNotifierProvider<AccentThemeNotifier, AppAccent>((ref) {
  return AccentThemeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadThemeMode();
  }

  final _box = Hive.box('settings');

  void _loadThemeMode() {
    final savedMode = _box.get('themeMode') as String?;
    if (savedMode == 'light') {
      state = ThemeMode.light;
    } else if (savedMode == 'system') {
      state = ThemeMode.system;
    } else {
      state = ThemeMode.dark;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _box.put('themeMode', mode.name);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
