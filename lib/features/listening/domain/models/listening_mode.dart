import 'package:flutter/material.dart';

/// Supported listening practice modes in Fluentia Listening Lab.
enum ListeningMode {
  listenAndChoose(
    'listen_and_choose',
    'Listen & Choose',
    'Listen to spoken audio and select the accurate answer.',
    Icons.tune_rounded,
    'Multiple Choice',
    'A1 - C1',
    3,
  ),
  trueFalse(
    'true_false',
    'True or False',
    'Evaluate whether spoken statements reflect the passage truth.',
    Icons.rule_rounded,
    'Speed Comprehension',
    'A1 - B2',
    2,
  ),
  dictation(
    'dictation',
    'Dictation',
    'Type verbatim what you hear to test real phonological decoding.',
    Icons.keyboard_outlined,
    'Precision',
    'A2 - C1',
    4,
  ),
  fillMissingWords(
    'fill_missing_words',
    'Fill in the Missing Words',
    'Complete the blanks in the transcript by listening attentively.',
    Icons.space_bar_rounded,
    'Contextual Gap',
    'A1 - B2',
    3,
  ),
  comprehension(
    'comprehension',
    'Listening Comprehension',
    'Engage with extended passages followed by comprehension questions.',
    Icons.auto_stories_outlined,
    'In-Depth Drill',
    'B1 - C1',
    5,
  );

  const ListeningMode(
    this.id,
    this.title,
    this.description,
    this.icon,
    this.badgeText,
    this.recommendedLevel,
    this.defaultDurationMinutes,
  );

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String badgeText;
  final String recommendedLevel;
  final int defaultDurationMinutes;

  static ListeningMode fromId(String id) {
    return ListeningMode.values.firstWhere(
      (m) =>
          m.id.toLowerCase() == id.toLowerCase() ||
          m.name.toLowerCase() == id.toLowerCase(),
      orElse: () => ListeningMode.listenAndChoose,
    );
  }
}
