import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle displayLarge({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.onSurface,
    );
  }

  static TextStyle headlineMedium({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.onSurface,
    );
  }

  static TextStyle headlineSmall({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.onSurface,
    );
  }

  static TextStyle titleLarge({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.onSurface,
    );
  }

  static TextStyle titleMedium({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.onSurface,
    );
  }

  static TextStyle streakCount({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 26,
      fontWeight: FontWeight.w800,
      color: color ?? AppColors.onSurface,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle bodyLarge({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.onSurface,
    );
  }

  static TextStyle bodyMedium({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.onSurface,
    );
  }

  static TextStyle bodySmall({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.onSurfaceMuted,
    );
  }

  static TextStyle labelLarge({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.onSurface,
    );
  }

  static TextStyle labelMedium({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.onSurfaceMuted,
    );
  }

  static TextStyle labelSmall({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.onSurfaceMuted,
    );
  }
}
