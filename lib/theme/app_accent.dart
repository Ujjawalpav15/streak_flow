import 'package:flutter/material.dart';

class AppAccent extends ThemeExtension<AppAccent> {
  final String name;
  final Color primary;
  final Color primaryContainer;
  final Color glow;
  final Color gradientStart;
  final Color gradientEnd;

  const AppAccent({
    required this.name,
    required this.primary,
    required this.primaryContainer,
    required this.glow,
    required this.gradientStart,
    required this.gradientEnd,
  });

  @override
  AppAccent copyWith({
    String? name,
    Color? primary,
    Color? primaryContainer,
    Color? glow,
    Color? gradientStart,
    Color? gradientEnd,
  }) {
    return AppAccent(
      name: name ?? this.name,
      primary: primary ?? this.primary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      glow: glow ?? this.glow,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
    );
  }

  @override
  ThemeExtension<AppAccent> lerp(ThemeExtension<AppAccent>? other, double t) {
    if (other is! AppAccent) {
      return this;
    }
    return AppAccent(
      name: t < 0.5 ? name : other.name,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
    );
  }

  static const cyberViolet = AppAccent(
    name: 'Cyber Violet',
    primary: Color(0xFF8B5CF6),
    primaryContainer: Color(0x338B5CF6), // 20% alpha of 8B5CF6
    glow: Color(0xFFA78BFA),
    gradientStart: Color(0xFF7C3AED),
    gradientEnd: Color(0xFFC084FC),
  );

  static const neonEmerald = AppAccent(
    name: 'Neon Emerald',
    primary: Color(0xFF10B981),
    primaryContainer: Color(0x3310B981), // 20% alpha of 10B981
    glow: Color(0xFF34D399),
    gradientStart: Color(0xFF059669),
    gradientEnd: Color(0xFF6EE7B7),
  );

  static const solarAmber = AppAccent(
    name: 'Solar Amber',
    primary: Color(0xFFF59E0B),
    primaryContainer: Color(0x33F59E0B), // 20% alpha of F59E0B
    glow: Color(0xFFFBBF24),
    gradientStart: Color(0xFFD97706),
    gradientEnd: Color(0xFFFCD34D),
  );

  static const midnightRuby = AppAccent(
    name: 'Midnight Ruby',
    primary: Color(0xFFEF4444),
    primaryContainer: Color(0x33EF4444), // 20% alpha of EF4444
    glow: Color(0xFFF87171),
    gradientStart: Color(0xFFB91C1C),
    gradientEnd: Color(0xFFFCA5A5),
  );

  static const List<AppAccent> all = [
    cyberViolet,
    neonEmerald,
    solarAmber,
    midnightRuby,
  ];

  static final Map<String, AppAccent> byName = {
    for (var accent in all) accent.name: accent,
  };
}
