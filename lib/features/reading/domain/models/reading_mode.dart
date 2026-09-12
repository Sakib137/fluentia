import 'package:flutter/material.dart';

/// Available reading practice modes in Fluentia Reading Lab.
enum ReadingMode {
  readAndAnswer(
    'readAndAnswer',
    'Read & Answer',
    'Answer focused comprehension questions based on the passage.',
    Icons.menu_book_rounded,
  ),
  mainIdea(
    'mainIdea',
    'Main Idea',
    'Identify the primary theme and central message of the text.',
    Icons.center_focus_strong_rounded,
  ),
  vocabularyInContext(
    'vocabularyInContext',
    'Vocabulary in Context',
    'Infer the meanings of advanced words from contextual cues.',
    Icons.spellcheck_rounded,
  ),
  trueFalse(
    'trueFalse',
    'True or False',
    'Evaluate factual statements directly against passage evidence.',
    Icons.fact_check_rounded,
  ),
  comprehension(
    'comprehension',
    'Reading Comprehension',
    'Master in-depth, multi-question reading passage analysis.',
    Icons.auto_stories_rounded,
  );

  const ReadingMode(this.id, this.title, this.description, this.icon);

  final String id;
  final String title;
  final String description;
  final IconData icon;

  String get displayName => title;

  static ReadingMode fromId(String id) {
    return ReadingMode.values.firstWhere(
      (m) => m.id.toLowerCase() == id.toLowerCase(),
      orElse: () => ReadingMode.readAndAnswer,
    );
  }
}
