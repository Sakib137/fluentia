import 'package:flutter/material.dart';

/// Supported speaking practice modes in Fluentia Speaking Lab.
enum SpeakingMode {
  readAloud(
    'read_aloud',
    'Read Aloud',
    'Read sentences aloud to practice oral clarity and sentence flow.',
    Icons.record_voice_over_rounded,
    'Pronunciation & Flow',
  ),
  speakAboutIt(
    'speak_about_it',
    'Speak About It',
    'Express your thoughts freely on practical topics for about 60 seconds.',
    Icons.forum_rounded,
    'Sustained Fluency',
  ),
  quickResponse(
    'quick_response',
    'Quick Response',
    'Fast-paced prompts with 10s preparation and 30s speaking time.',
    Icons.bolt_rounded,
    'Spontaneous Speech',
  ),
  dailySpeaking(
    'daily_speaking',
    'Daily Speaking',
    'Today’s speaking challenge to build consistency and keep your streak alive.',
    Icons.today_rounded,
    'Daily Habit',
  );

  const SpeakingMode(
    this.id,
    this.title,
    this.description,
    this.icon,
    this.badgeText,
  );

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String badgeText;

  static SpeakingMode fromId(String id) {
    return SpeakingMode.values.firstWhere(
      (m) => m.id.toLowerCase() == id.toLowerCase(),
      orElse: () => SpeakingMode.readAloud,
    );
  }
}
