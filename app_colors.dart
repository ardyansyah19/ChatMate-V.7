import 'package:flutter/material.dart';

/// Palet warna terinspirasi dari WhatsApp (light & dark mode)
class AppColors {
  AppColors._();

  // Warna utama hijau WhatsApp
  static const Color primaryGreen = Color(0xFF25D366);
  static const Color darkGreen = Color(0xFF075E54);
  static const Color tealGreen = Color(0xFF128C7E);
  static const Color lightGreenBg = Color(0xFFDCF8C6);

  // Light mode
  static const Color lightBackground = Color(0xFFF7F7F7);
  static const Color lightAppBar = Color(0xFFFFFFFF);
  static const Color lightBubbleMe = Color(0xFFD9FDD3);
  static const Color lightBubbleOther = Color(0xFFFFFFFF);
  static const Color lightChatBg = Color(0xFFEFEAE2);
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightSubtitle = Color(0xFF667781);

  // Dark mode
  static const Color darkBackground = Color(0xFF111B21);
  static const Color darkAppBar = Color(0xFF1F2C34);
  static const Color darkBubbleMe = Color(0xFF005C4B);
  static const Color darkBubbleOther = Color(0xFF1F2C34);
  static const Color darkChatBg = Color(0xFF0B141A);
  static const Color darkDivider = Color(0xFF2A3942);
  static const Color darkSubtitle = Color(0xFF8696A0);

  static const Color unreadBadge = Color(0xFF25D366);
  static const Color blueTick = Color(0xFF53BDEB);

  static const List<Color> avatarPalette = [
    Color(0xFFEE6C4D),
    Color(0xFF3D5A80),
    Color(0xFF98C1D9),
    Color(0xFFE29578),
    Color(0xFF6A994E),
    Color(0xFF9B5DE5),
    Color(0xFFF15BB5),
    Color(0xFF00BBF9),
  ];
}
