import 'package:flutter/material.dart';

/// Available writing practice modes in Fluentia Writing Lab.
enum WritingMode {
  quickResponse(
    'quickResponse',
    'Quick Response',
    'Answer focused real-world prompts in 1–3 clear sentences.',
    Icons.bolt_rounded,
  ),
  sentenceBuilder(
    'sentenceBuilder',
    'Sentence Builder',
    'Assemble shuffled words into natural, grammatically sound sentences.',
    Icons.view_week_rounded,
  ),
  completeSentence(
    'completeSentence',
    'Complete the Sentence',
    'Supply missing words or phrases to complete authentic expressions.',
    Icons.edit_note_rounded,
  ),
  shortWriting(
    'shortWriting',
    'Short Writing',
    'Compose cohesive paragraph responses with structured reasoning.',
    Icons.article_rounded,
  ),
  guidedWriting(
    'guidedWriting',
    'Guided Writing',
    'Follow a multi-point checklist to draft organized, purposeful texts.',
    Icons.checklist_rtl_rounded,
  );

  const WritingMode(this.id, this.title, this.description, this.icon);

  final String id;
  final String title;
  final String description;
  final IconData icon;

  String get displayName => title;

  static WritingMode fromId(String id) {
    return WritingMode.values.firstWhere(
      (m) => m.id.toLowerCase() == id.toLowerCase(),
      orElse: () => WritingMode.quickResponse,
    );
  }
}
