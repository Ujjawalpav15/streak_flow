import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF161B26);
  static const Color surfaceVariant = Color(0xFF1C2230);
  
  static const Color onSurface = Colors.white;
  static const Color onSurfaceMuted = Colors.white54;
  static const Color onSurfaceDim = Colors.white24;

  static const Color warningGradientStart = Color(0xFFE65100); // orange.shade900
  static const Color warningGradientEnd = Color(0xFFB71C1C); // red.shade900
}

class AppColorScheme extends ThemeExtension<AppColorScheme> {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color onSurfaceDim;
  final Color outline;

  const AppColorScheme({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.onSurfaceDim,
    required this.outline,
  });

  static const AppColorScheme dark = AppColorScheme(
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceVariant: AppColors.surfaceVariant,
    onSurface: AppColors.onSurface,
    onSurfaceMuted: AppColors.onSurfaceMuted,
    onSurfaceDim: AppColors.onSurfaceDim,
    outline: Colors.white12,
  );

  static const AppColorScheme light = AppColorScheme(
    background: Color(0xFFFFF9F2),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFFFF3E6),
    onSurface: Color(0xFF2B2118),
    onSurfaceMuted: Color(0xFF8A7B6C),
    onSurfaceDim: Color(0xFFB5A899),
    outline: Color(0xFFF0E4D4),
  );

  @override
  AppColorScheme copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? onSurface,
    Color? onSurfaceMuted,
    Color? onSurfaceDim,
    Color? outline,
  }) {
    return AppColorScheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      onSurfaceDim: onSurfaceDim ?? this.onSurfaceDim,
      outline: outline ?? this.outline,
    );
  }

  @override
  ThemeExtension<AppColorScheme> lerp(ThemeExtension<AppColorScheme>? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      onSurfaceDim: Color.lerp(onSurfaceDim, other.onSurfaceDim, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
    );
  }

  static AppColorScheme of(BuildContext context) {
    return Theme.of(context).extension<AppColorScheme>() ?? dark;
  }
}
