import 'package:flutter/material.dart';

class AppColors {
  final bool isDark;
  const AppColors._(this.isDark);

  static AppColors of(BuildContext context) =>
      AppColors._(MediaQuery.of(context).platformBrightness == Brightness.dark);

  static const accent = Color(0xFF6C63FF);
  static const accentGreen = Color(0xFF00D9A3);

  // ── Backgrounds ──────────────────────────────────────────────────────────────
  Color get background => isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF2F2F7);
  Color get surface    => isDark ? const Color(0xFF1C1C2E) : Colors.white;
  Color get appBarBg   => isDark ? const Color(0xFF1A1A2E) : Colors.white;
  Color get inputBg    => isDark ? const Color(0xFF0F0F1A) : const Color(0xFFEEEEF5);
  Color get popupBg    => isDark ? const Color(0xFF252540) : const Color(0xFFF5F5FF);

  // ── Text ─────────────────────────────────────────────────────────────────────
  Color get textPrimary   => isDark ? Colors.white : const Color(0xFF11111A);
  Color get textSecondary => isDark ? Colors.white.withValues(alpha: 0.65) : const Color(0xFF55556E);
  Color get textTertiary  => isDark ? Colors.white.withValues(alpha: 0.45) : const Color(0xFF8A8AAA);
  Color get textDim       => isDark ? Colors.white.withValues(alpha: 0.30) : const Color(0xFFA8A8C4);
  Color get textHint      => isDark ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFAAAAAA);
  Color get textFaint     => isDark ? Colors.white.withValues(alpha: 0.20) : const Color(0xFFBBBBCC);

  // ── Icons ─────────────────────────────────────────────────────────────────────
  Color get iconMid  => isDark ? Colors.white54 : const Color(0xFF7878A0);
  Color get iconDim  => isDark ? Colors.white.withValues(alpha: 0.35) : const Color(0xFF9898B8);
  Color get iconFaint => isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFCCCCDD);

  // ── Surface overlays & borders ────────────────────────────────────────────────
  Color get chipBg     => isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFEEEEF8);
  Color get border     => isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE4E4EE);
  Color get divider    => isDark ? Colors.white12 : const Color(0xFFE0E0EC);
  Color get dragHandle => isDark ? Colors.white24 : const Color(0xFFD4D4E4);

  // ── Navigation glass bar ──────────────────────────────────────────────────────
  Color get glassColor => isDark
      ? const Color(0xFF0F0F1A).withValues(alpha: 0.5)
      : Colors.white.withValues(alpha: 0.9);

  // ── Shadow (used in floating cards) ──────────────────────────────────────────
  Color get shadowColor => isDark
      ? Colors.black.withValues(alpha: 0.45)
      : Colors.black.withValues(alpha: 0.12);

  // ── Calendar (TableCalendar) ──────────────────────────────────────────────────
  Color get calendarBg           => isDark ? const Color(0xFF1A1A2E) : Colors.white;
  Color get calendarDayText      => isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF33334A);
  Color get calendarWeekdayText  => isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF888899);
  Color get calendarDisabledText => isDark ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFBBBBCC);
  Color get calendarChevron      => isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF8888A8);
  Color get calendarTitleText    => isDark ? Colors.white : const Color(0xFF11111A);
}
