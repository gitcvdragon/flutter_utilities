// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends StatefulWidget {
  final Widget Function(ThemeMode themeMode) builder;
  static late final SharedPreferences? _themeDB;
  static bool? initialized;

  ThemeManager({
    Key? key,
    required this.builder,
  })  : assert(
          initialized != null,
          "You must call ThemeManager.initialize() before using it",
        ),
        super(key: key);

  static Future<void> initialize([
    ThemeMode initialThemeMode = ThemeMode.system,
  ]) async {
    if (initialized != null) {
      return;
    }
    _themeDB = await SharedPreferences.getInstance();
    if (!_themeDB!.containsKey('last')) {
      await _saveTheme(initialThemeMode);
    }
    initialized = true;
  }

  static Future<void> _deleteCache() async {
    if (_themeDB == null) {
      return;
    }
    _themeDB!.remove('last');
  }

  static Future<void> _saveTheme(ThemeMode themeMode) async {
    if (_themeDB == null) {
      return;
    }
    ThemeManager._themeDB?.setInt('last', themeMode.index);
  }

  @override
  ThemeManagerState createState() => ThemeManagerState();
}

class ThemeManagerState extends State<ThemeManager> {
  late final ValueNotifier<ThemeMode> _themeMode;

  ThemeMode get themeMode => _themeMode.value;

  ValueNotifier<ThemeMode> get listenable => _themeMode;

  set themeMode(ThemeMode themeMode) {
    _themeMode.value = themeMode;
  }

  void toLightTheme() {
    _themeMode.value = ThemeMode.light;
  }

  void toDarkTheme() {
    _themeMode.value = ThemeMode.dark;
  }

  void toSystemTheme() {
    _themeMode.value = ThemeMode.system;
  }

  Future<void> saveTheme() async {
    await ThemeManager._saveTheme(_themeMode.value);
  }

  Future<void> deleteSavedTheme() async {
    await ThemeManager._deleteCache();
  }

  @override
  void initState() {
    super.initState();
    _themeMode = ValueNotifier<ThemeMode>(
      ThemeMode.values[ThemeManager._themeDB?.getInt('last') ?? 0],
    );
    _themeMode.addListener(() async {
      await saveTheme();
    });
  }

  @override
  void dispose() {
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, themeMode, child) {
        return widget.builder(themeMode);
      },
    );
  }
}
