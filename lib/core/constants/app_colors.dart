import 'package:flutter/material.dart';

class AdminColors {
  AdminColors._();

  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF54A0FF);
  static const Color background = Color(0xFFF0F2F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color sidebar = Color(0xFF1E1E2E);
  static const Color sidebarText = Color(0xFFB0B3C1);
  static const Color sidebarActive = Color(0xFF6C63FF);

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFADB5BD);

  static const Color success = Color(0xFF43D854);
  static const Color warning = Color(0xFFFFBE0B);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF54A0FF);

  static const Color divider = Color(0xFFEEEFF5);
  static const Color shadow = Color(0x1A6C63FF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF54A0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Stat card colours
  static const Color statStudents = Color(0xFF6C63FF);
  static const Color statActive = Color(0xFF43D854);
  static const Color statExams = Color(0xFF54A0FF);
  static const Color statCompletion = Color(0xFFFFBE0B);
}
