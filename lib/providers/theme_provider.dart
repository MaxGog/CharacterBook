import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemePaletteStyle {
  tonalSpot,
  vibrant,
  expressive,
  fidelity,
  monochrome,
  neutral,
  rainbow,
  fruitSalad,
  content,
}

enum ThemeColorSpec {
  spec2021,
  spec2025,
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = Colors.blue;
  bool _useDynamicColor = false;
  ThemePaletteStyle _paletteStyle = ThemePaletteStyle.tonalSpot;
  ThemeColorSpec _colorSpec = ThemeColorSpec.spec2025;
  bool _useAmoledBlack = false;
  ColorScheme? _dynamicLightColorScheme;
  ColorScheme? _dynamicDarkColorScheme;

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;
  bool get useDynamicColor => _useDynamicColor;
  ThemePaletteStyle get paletteStyle => _paletteStyle;
  ThemeColorSpec get colorSpec => _colorSpec;
  bool get useAmoledBlack => _useAmoledBlack;
  bool get supportsDynamicColor =>
      _dynamicLightColorScheme != null && _dynamicDarkColorScheme != null;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    final colorValue = prefs.getInt('seedColor') ?? Colors.blue.value;
    final useDynamicColor = prefs.getBool('useDynamicColor') ?? false;
    final paletteStyleIndex = prefs.getInt('paletteStyle') ?? 0;
    final colorSpecIndex = prefs.getInt('colorSpec') ?? 1;
    final useAmoledBlack = prefs.getBool('useAmoledBlack') ?? false;

    _themeMode = ThemeMode.values[themeIndex];
    _seedColor = Color(colorValue);
    _useDynamicColor = useDynamicColor;
    final clampedPaletteStyleIndex = paletteStyleIndex
        .clamp(0, ThemePaletteStyle.values.length - 1) as int;
    _paletteStyle = ThemePaletteStyle.values[clampedPaletteStyleIndex];
    final clampedColorSpecIndex = colorSpecIndex
        .clamp(0, ThemeColorSpec.values.length - 1) as int;
    _colorSpec = ThemeColorSpec.values[clampedColorSpecIndex];
    _useAmoledBlack = useAmoledBlack;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  void setSeedColor(Color color) async {
    _seedColor = color;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seedColor', color.value);
  }

  void setUseDynamicColor(bool value) async {
    if (_useDynamicColor == value) return;
    _useDynamicColor = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useDynamicColor', value);
  }

  void setPaletteStyle(ThemePaletteStyle value) async {
    if (_paletteStyle == value) return;
    _paletteStyle = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('paletteStyle', value.index);
  }

  void setColorSpec(ThemeColorSpec value) async {
    if (_colorSpec == value) return;
    _colorSpec = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('colorSpec', value.index);
  }

  void setUseAmoledBlack(bool value) async {
    if (_useAmoledBlack == value) return;
    _useAmoledBlack = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useAmoledBlack', value);
  }

  void updateDynamicColorSchemes({
    required ColorScheme? light,
    required ColorScheme? dark,
  }) {
    _dynamicLightColorScheme = light;
    _dynamicDarkColorScheme = dark;
  }

  DynamicScheme _dynamicSchemeForSeed({
    required Color seed,
    required Brightness brightness,
    required ThemePaletteStyle style,
  }) {
    final isDark = brightness == Brightness.dark;
    final sourceColorHct = Hct.fromInt(seed.value);
    return switch (style) {
      ThemePaletteStyle.tonalSpot => SchemeTonalSpot(
          sourceColorHct: sourceColorHct,
          isDark: isDark,
          contrastLevel: 0.0,
        ),
      ThemePaletteStyle.vibrant => SchemeVibrant(
          sourceColorHct: sourceColorHct,
          isDark: isDark,
          contrastLevel: 0.0,
        ),
      ThemePaletteStyle.expressive => SchemeExpressive(
          sourceColorHct: sourceColorHct,
          isDark: isDark,
          contrastLevel: 0.0,
        ),
      ThemePaletteStyle.fidelity => SchemeFidelity(
          sourceColorHct: sourceColorHct,
          isDark: isDark,
          contrastLevel: 0.0,
        ),
      ThemePaletteStyle.monochrome => SchemeMonochrome(
          sourceColorHct: sourceColorHct,
          isDark: isDark,
          contrastLevel: 0.0,
        ),
      ThemePaletteStyle.neutral => SchemeNeutral(
          sourceColorHct: sourceColorHct,
          isDark: isDark,
          contrastLevel: 0.0,
        ),
      ThemePaletteStyle.rainbow => SchemeRainbow(
          sourceColorHct: sourceColorHct,
          isDark: isDark,
          contrastLevel: 0.0,
        ),
      ThemePaletteStyle.fruitSalad => SchemeFruitSalad(
          sourceColorHct: sourceColorHct,
          isDark: isDark,
          contrastLevel: 0.0,
        ),
      ThemePaletteStyle.content => SchemeContent(
          sourceColorHct: sourceColorHct,
          isDark: isDark,
          contrastLevel: 0.0,
        ),
    };
  }

  ColorScheme _colorSchemeFromDynamicScheme({
    required DynamicScheme scheme,
    required Brightness brightness,
  }) {
    return ColorScheme(
      brightness: brightness,
      primary: Color(scheme.primary),
      onPrimary: Color(scheme.onPrimary),
      primaryContainer: Color(scheme.primaryContainer),
      onPrimaryContainer: Color(scheme.onPrimaryContainer),
      secondary: Color(scheme.secondary),
      onSecondary: Color(scheme.onSecondary),
      secondaryContainer: Color(scheme.secondaryContainer),
      onSecondaryContainer: Color(scheme.onSecondaryContainer),
      tertiary: Color(scheme.tertiary),
      onTertiary: Color(scheme.onTertiary),
      tertiaryContainer: Color(scheme.tertiaryContainer),
      onTertiaryContainer: Color(scheme.onTertiaryContainer),
      error: Color(scheme.error),
      onError: Color(scheme.onError),
      errorContainer: Color(scheme.errorContainer),
      onErrorContainer: Color(scheme.onErrorContainer),
      surface: Color(scheme.surface),
      onSurface: Color(scheme.onSurface),
      surfaceDim: Color(scheme.surfaceDim),
      surfaceBright: Color(scheme.surfaceBright),
      surfaceContainerLowest: Color(scheme.surfaceContainerLowest),
      surfaceContainerLow: Color(scheme.surfaceContainerLow),
      surfaceContainer: Color(scheme.surfaceContainer),
      surfaceContainerHigh: Color(scheme.surfaceContainerHigh),
      surfaceContainerHighest: Color(scheme.surfaceContainerHighest),
      onSurfaceVariant: Color(scheme.onSurfaceVariant),
      surfaceVariant: Color(scheme.surfaceVariant),
      outline: Color(scheme.outline),
      outlineVariant: Color(scheme.outlineVariant),
      shadow: Color(scheme.shadow),
      scrim: Color(scheme.scrim),
      inverseSurface: Color(scheme.inverseSurface),
      onInverseSurface: Color(scheme.inverseOnSurface),
      inversePrimary: Color(scheme.inversePrimary),
      surfaceTint: Color(scheme.surfaceTint),
    );
  }

  ColorScheme generateMaterialYouColorSchemeFromSeed({
    required Color seed,
    required Brightness brightness,
    ThemePaletteStyle? style,
  }) {
    final s = style ?? _paletteStyle;
    final scheme = _dynamicSchemeForSeed(
      seed: seed,
      brightness: brightness,
      style: s,
    );
    return _colorSchemeFromDynamicScheme(scheme: scheme, brightness: brightness);
  }

  ColorScheme _applyAmoledIfNeeded(ColorScheme scheme, Brightness brightness) {
    if (!_useAmoledBlack || brightness != Brightness.dark) return scheme;

    const surface = Color(0xFF000000);
    const container = Color(0xFF0A0A0A);
    const containerHigh = Color(0xFF101010);
    const containerHighest = Color(0xFF161616);
    const surfaceVariant = Color(0xFF141414);

    return scheme.copyWith(
      surface: surface,
      background: surface,
      surfaceDim: surface,
      surfaceBright: containerHigh,
      surfaceContainerLowest: surface,
      surfaceContainerLow: container,
      surfaceContainer: containerHigh,
      surfaceContainerHigh: containerHighest,
      surfaceContainerHighest: const Color(0xFF1C1C1C),
      surfaceVariant: surfaceVariant,
    );
  }

  ColorScheme _colorScheme(Brightness brightness) {
    if (_useDynamicColor) {
      final maybeDynamic = brightness == Brightness.light
          ? _dynamicLightColorScheme
          : _dynamicDarkColorScheme;

      if (_colorSpec == ThemeColorSpec.spec2021) {
        if (maybeDynamic != null && _paletteStyle == ThemePaletteStyle.tonalSpot) {
          return _applyAmoledIfNeeded(maybeDynamic, brightness);
        }
        final fromSeed = ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: brightness,
        );
        return _applyAmoledIfNeeded(fromSeed, brightness);
      }

      if (_colorSpec == ThemeColorSpec.spec2025 &&
          maybeDynamic != null &&
          _paletteStyle == ThemePaletteStyle.tonalSpot) {
        return _applyAmoledIfNeeded(maybeDynamic, brightness);
      }

      final seed =
          maybeDynamic != null ? Color(maybeDynamic.primary.value) : _seedColor;
      return _applyAmoledIfNeeded(
        generateMaterialYouColorSchemeFromSeed(
          seed: seed,
          brightness: brightness,
        ),
        brightness,
      );
    }

    if (_colorSpec == ThemeColorSpec.spec2021) {
      return _applyAmoledIfNeeded(
        ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: brightness,
        ),
        brightness,
      );
    }

    return _applyAmoledIfNeeded(
      generateMaterialYouColorSchemeFromSeed(
        seed: _seedColor,
        brightness: brightness,
      ),
      brightness,
    );
  }

  ThemeData get lightTheme {
    final colorScheme = _colorScheme(Brightness.light);
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      ),
    );
  }


  ThemeData get darkTheme {
    final colorScheme = _colorScheme(Brightness.dark);
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      ),
    );
  }
}
