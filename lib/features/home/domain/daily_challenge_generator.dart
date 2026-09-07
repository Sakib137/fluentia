import '../data/models/home_models.dart';

/// Pure domain generator for the deterministic 5-activity Daily Challenge.
///
/// Uses the calendar date key (e.g. 2026-09-07) to derive a deterministic pseudo-random
/// seed, selecting varied activities that do not change across app re-renders.
class DailyChallengeGenerator {
  const DailyChallengeGenerator._();

  static const List<List<DailyChallengeItem>> _challengePools = [
    [
      DailyChallengeItem(
        id: 'c1_vocab',
        title: 'Master 5 Advanced Phrasal Verbs',
        skillType: 'Vocabulary',
        isCompleted: false,
        durationMinutes: 3,
      ),
      DailyChallengeItem(
        id: 'c2_speaking',
        title: 'Shadow a Native Speaker Dialogue',
        skillType: 'Speaking',
        isCompleted: false,
        durationMinutes: 4,
      ),
      DailyChallengeItem(
        id: 'c3_listening',
        title: 'Quick Listening Comprehension Check',
        skillType: 'Listening',
        isCompleted: false,
        durationMinutes: 3,
      ),
      DailyChallengeItem(
        id: 'c4_grammar',
        title: 'Conditional Sentences Workout',
        skillType: 'Grammar',
        isCompleted: false,
        durationMinutes: 3,
      ),
      DailyChallengeItem(
        id: 'c5_reading',
        title: 'Short Tech Article Speed Reading',
        skillType: 'Reading',
        isCompleted: false,
        durationMinutes: 2,
      ),
    ],
    [
      DailyChallengeItem(
        id: 'c1_vocab_b',
        title: 'Explore Collocations for Business',
        skillType: 'Vocabulary',
        isCompleted: false,
        durationMinutes: 3,
      ),
      DailyChallengeItem(
        id: 'c2_speaking_b',
        title: 'Read Aloud with Intonation Marks',
        skillType: 'Speaking',
        isCompleted: false,
        durationMinutes: 3,
      ),
      DailyChallengeItem(
        id: 'c3_listening_b',
        title: 'Catch Connected Speech Reductions',
        skillType: 'Listening',
        isCompleted: false,
        durationMinutes: 4,
      ),
      DailyChallengeItem(
        id: 'c4_grammar_b',
        title: 'Past Perfect vs Simple Past Drill',
        skillType: 'Grammar',
        isCompleted: false,
        durationMinutes: 3,
      ),
      DailyChallengeItem(
        id: 'c5_writing_b',
        title: 'Draft a 3-Sentence Argument',
        skillType: 'Writing',
        isCompleted: false,
        durationMinutes: 2,
      ),
    ],
    [
      DailyChallengeItem(
        id: 'c1_vocab_c',
        title: '5 Synonyms to Replace "Important"',
        skillType: 'Vocabulary',
        isCompleted: false,
        durationMinutes: 2,
      ),
      DailyChallengeItem(
        id: 'c2_speaking_c',
        title: 'Vowel Length & Stress Contrast',
        skillType: 'Speaking',
        isCompleted: false,
        durationMinutes: 4,
      ),
      DailyChallengeItem(
        id: 'c3_listening_c',
        title: 'News Snippet Main Idea Extraction',
        skillType: 'Listening',
        isCompleted: false,
        durationMinutes: 3,
      ),
      DailyChallengeItem(
        id: 'c4_grammar_c',
        title: 'Identify & Fix 5 Common Mistakes',
        skillType: 'Grammar',
        isCompleted: false,
        durationMinutes: 3,
      ),
      DailyChallengeItem(
        id: 'c5_reading_c',
        title: 'Short Story Inferences & Context',
        skillType: 'Reading',
        isCompleted: false,
        durationMinutes: 3,
      ),
    ],
    [
      DailyChallengeItem(
        id: 'c1_vocab_d',
        title: 'Prepositional Phrases in Context',
        skillType: 'Vocabulary',
        isCompleted: false,
        durationMinutes: 3,
      ),
      DailyChallengeItem(
        id: 'c2_speaking_d',
        title: 'Describe an Everyday Object in 60s',
        skillType: 'Speaking',
        isCompleted: false,
        durationMinutes: 3,
      ),
      DailyChallengeItem(
        id: 'c3_listening_d',
        title: 'Fast Dialogue Numbers & Details',
        skillType: 'Listening',
        isCompleted: false,
        durationMinutes: 4,
      ),
      DailyChallengeItem(
        id: 'c4_grammar_d',
        title: 'Articles (a, an, the) Precision Drill',
        skillType: 'Grammar',
        isCompleted: false,
        durationMinutes: 2,
      ),
      DailyChallengeItem(
        id: 'c5_writing_d',
        title: 'Summarize a Short Scenario in 2 Lines',
        skillType: 'Writing',
        isCompleted: false,
        durationMinutes: 3,
      ),
    ],
  ];

  /// Generates the daily challenge for the given [date], merging any
  /// [completedItemIds] stored previously.
  static DailyChallengeState generate({
    required DateTime date,
    Set<String> completedItemIds = const {},
  }) {
    final dateKey = _formatDateKey(date);
    // Deterministic pool index based on calendar date
    final dateSeed = (date.year * 10000 + date.month * 100 + date.day);
    final poolIndex = dateSeed % _challengePools.length;
    final templateItems = _challengePools[poolIndex];

    final items = templateItems.map((item) {
      // Append dateKey to ensure unique ID per day
      final uniqueId = '${dateKey}_${item.id}';
      final isCompleted = completedItemIds.contains(uniqueId) || completedItemIds.contains(item.id);
      return item.copyWith(
        id: uniqueId,
        isCompleted: isCompleted,
      );
    }).toList();

    return DailyChallengeState(
      dateKey: dateKey,
      items: items,
    );
  }

  static String _formatDateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
