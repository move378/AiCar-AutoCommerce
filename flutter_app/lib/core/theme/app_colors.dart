import 'package:flutter/material.dart';

/// AiCar 디자인 시스템 컬러 토큰
/// Tailwind CSS v4 기반 — Slate + Emerald 팔레트
abstract final class AppColors {
  // ── Semantic ──────────────────────────────────────
  static const Color primary = Color(0xFF1E293B); // slate-800
  static const Color secondary = Color(0xFF10B981); // emerald-500
  static const Color secondaryHover = Color(0xFF059669); // emerald-600

  // ── Background ────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF); // white
  static const Color surface = Color(0xFFF8FAFC); // slate-50
  static const Color cardBackground = Color(0xFF64748B); // slate-500

  // ── Text ──────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A); // slate-900
  static const Color textSecondary = Color(0xFF64748B); // slate-500
  static const Color textTertiary = Color(0xFF94A3B8); // slate-400
  static const Color textDisabled = Color(0xFFCBD5E1); // slate-300
  static const Color textOnDark = Color(0xFFFFFFFF); // white
  static const Color textAccent = Color(0xFF059669); // emerald-600

  // ── State ─────────────────────────────────────────
  static const Color success = Color(0xFF10B981); // emerald-500
  static const Color error = Color(0xFFEF4444); // red-500
  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color info = Color(0xFF3B82F6); // blue-500

  // ── GNB ───────────────────────────────────────────
  static const Color gnbBackground = Color(0xFFFFFFFF); // white
  static const Color gnbActive = Color(0xFF0F172A); // slate-900
  static const Color gnbInactive = Color(0xFF94A3B8); // slate-400

  // ── Component ─────────────────────────────────────
  static const Color buttonSolidDefault = Color(0xFF1E293B); // slate-800
  static const Color buttonSolidDisabled = Color(0xFFF1F5F9); // slate-100
  static const Color buttonOutlineDefault = Color(0xFFFFFFFF); // white
  static const Color chipSelected = Color(0xFF334155); // slate-700
  static const Color chipUnselected = Color(0xFFFFFFFF); // white
}
