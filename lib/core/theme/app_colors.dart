import 'package:flutter/material.dart';

/// Centralized Design System Color Tokens
class AppColors {
  // Brand Primary (Royal Blue)
  static const Color primary50 = Color(0xFFEFF6FF);
  static const Color primary100 = Color(0xFFDBEAFE);
  static const Color primary200 = Color(0xFFBFDBFE);
  static const Color primary300 = Color(0xFF93C5FD);
  static const Color primary400 = Color(0xFF60A5FA);
  static const Color primary500 = Color(0xFF3B82F6);
  static const Color primary = Color(0xFF2563EB); // Main Brand Color
  static const Color primary700 = Color(0xFF1D4ED8);
  static const Color primary800 = Color(0xFF1E40AF);
  static const Color primary900 = Color(0xFF1E3A8A);

  // Secondary (Indigo / Violet)
  static const Color secondary = Color(0xFF6366F1);
  static const Color secondaryDark = Color(0xFF4F46E5);
  static const Color secondaryLight = Color(0xFFEEF2FF);

  // Neutrals / Slate & Zinc
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // Semantic Feedback Colors
  // Success (Emerald)
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color successBorder = Color(0xFFA7F3D0);
  static const Color successDark = Color(0xFF065F46);

  // Warning (Amber / Orange)
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFFDE68A);
  static const Color warningDark = Color(0xFF92400E);

  // Error / Danger (Crimson / Rose)
  static const Color error = Color(0xFFE11D48);
  static const Color errorLight = Color(0xFFFFF1F2);
  static const Color errorBorder = Color(0xFFFECDD3);
  static const Color errorDark = Color(0xFF9F1239);

  // Information (Sky)
  static const Color info = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFFF0F9FF);
  static const Color infoBorder = Color(0xFFBAE6FD);
  static const Color infoDark = Color(0xFF075985);

  // Surface & Canvas (Light Mode)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceElevated = Colors.white;
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Modern SaaS Elevations & Shadows
  static const Color cardShadowColor = Color(0x0A0F172A); // Soft 4% slate shadow
  static const Color cardHoverShadowColor = Color(0x140F172A); // Elevated 8% slate shadow
  static const Color accentGlow = Color(0x1F2563EB); // Subtle brand glow

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> cardHoverShadow = [
    BoxShadow(
      color: Color(0x140F172A),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // Modern Micro-Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroSurfaceGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardAccentGradient = LinearGradient(
    colors: [Color(0xFFEFF6FF), Colors.white],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Surface & Canvas (Dark Mode)
  static const Color darkBackground = Color(0xFF090D16);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceElevated = Color(0xFF1F2937);
  static const Color darkBorder = Color(0xFF374151);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFFD1D5DB);
  static const Color darkTextMuted = Color(0xFF9CA3AF);
}
