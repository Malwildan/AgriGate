// Typography tokens matching Montserrat (display/headings) and Source Sans Pro (body).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'agri_colors.dart';

abstract final class AgriTypography {
  static TextTheme get textTheme => TextTheme(
        // Display / hero headings — Montserrat
        displayLarge: _montserrat(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
          color: AgriColors.ink,
          height: 1.0,
        ),
        displayMedium: _montserrat(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
          color: AgriColors.ink,
          height: 1.1,
        ),
        displaySmall: _montserrat(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          color: AgriColors.ink,
          height: 1.1,
        ),

        // Page titles — Montserrat
        headlineLarge: _montserrat(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          color: AgriColors.ink,
          height: 1.15,
        ),
        headlineMedium: _montserrat(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: AgriColors.ink,
          height: 1.2,
        ),
        headlineSmall: _montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: AgriColors.ink,
          height: 1.25,
        ),

        // Section labels / card titles — Source Sans Pro
        titleLarge: _sourceSans(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: AgriColors.ink,
        ),
        titleMedium: _sourceSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: AgriColors.ink,
        ),
        titleSmall: _sourceSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: AgriColors.inkSoft,
        ),

        // Body — Source Sans Pro
        bodyLarge: _sourceSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AgriColors.ink,
          height: 1.5,
        ),
        bodyMedium: _sourceSans(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AgriColors.ink,
          height: 1.47,
        ),
        bodySmall: _sourceSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AgriColors.inkSoft,
          height: 1.4,
        ),

        // Labels / captions — Source Sans Pro
        labelLarge: _sourceSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: AgriColors.ink,
        ),
        labelMedium: _sourceSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: AgriColors.inkSoft,
        ),
        labelSmall: _sourceSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: AgriColors.inkSoft,
        ),
      );

  static TextStyle _montserrat({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    double letterSpacing = 0,
    Color color = AgriColors.ink,
    double? height,
  }) =>
      GoogleFonts.montserrat(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        color: color,
        height: height,
      );

  static TextStyle _sourceSans({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    double letterSpacing = 0,
    Color color = AgriColors.ink,
    double? height,
  }) =>
      GoogleFonts.sourceSans3(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        color: color,
        height: height,
      );

  // Convenience getters for direct use
  static TextStyle get sectionLabel => _sourceSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: AgriColors.inkSoft,
      );

  static TextStyle get metricValue => _montserrat(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        color: AgriColors.ink,
        height: 1.0,
      );

  static TextStyle get badgeText => _sourceSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      );

  static TextStyle get ctaButton => _sourceSans(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: AgriColors.forest,
      );

  static TextStyle get liveIndicator => _sourceSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AgriColors.ink,
      );
}
