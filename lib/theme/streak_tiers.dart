import 'package:flutter/material.dart';

class StreakTiers {
  static Color getTierColor(int streak) {
    if (streak >= 100) return const Color(0xFFDC2626); // Mythic Ruby
    if (streak >= 50) return const Color(0xFF06B6D4); // Diamond
    if (streak >= 30) return const Color(0xFFEAB308); // Golden Crown
    if (streak >= 7) return const Color(0xFFA855F7); // Plasma
    if (streak >= 1) return const Color(0xFFF97316); // Ember
    return Colors.grey; // Inactive
  }

  static Color getTierGlow(int streak) {
    if (streak >= 100) return const Color(0xFFF87171);
    if (streak >= 50) return const Color(0xFF22D3EE);
    if (streak >= 30) return const Color(0xFFFACC15);
    if (streak >= 7) return const Color(0xFFC084FC);
    if (streak >= 1) return const Color(0xFFFB923C);
    return Colors.grey;
  }

  static String getTierEmoji(int streak) {
    if (streak >= 100) return '👑🔥'; // Mythic Ruby
    if (streak >= 50) return '💎🔥'; // Diamond
    if (streak >= 30) return '🔱🔥'; // Golden Crown
    if (streak >= 7) return '💜🔥'; // Plasma
    if (streak >= 1) return '🔥'; // Ember
    return '❄️'; // Inactive
  }

  static String getTierTitle(int streak) {
    if (streak >= 100) return 'Mythic Ruby';
    if (streak >= 50) return 'Diamond';
    if (streak >= 30) return 'Golden Crown';
    if (streak >= 7) return 'Plasma';
    if (streak >= 1) return 'Ember';
    return 'Inactive';
  }
}
