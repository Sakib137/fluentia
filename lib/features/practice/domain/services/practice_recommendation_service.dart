import '../models/practice_models.dart';

/// Pure domain service that orders skills and selects recommendations deterministically.
class PracticeRecommendationService {
  const PracticeRecommendationService();

  /// Orders the 4 core practice skills based on user's onboarding goals.
  List<PracticeSkill> orderSkills(List<String> userGoals) {
    if (userGoals.isEmpty) {
      return const [
        PracticeSkill.speaking,
        PracticeSkill.listening,
        PracticeSkill.reading,
        PracticeSkill.writing,
      ];
    }

    final lowerGoals = userGoals.map((g) => g.toLowerCase()).toSet();

    // Priority checks based on user's stated goals
    final isCareer = lowerGoals.any((g) => g.contains('career') || g.contains('interview'));
    final isExam = lowerGoals.any((g) => g.contains('exam') || g.contains('test') || g.contains('academic'));
    final isSpeaking = lowerGoals.any((g) => g.contains('speaking') || g.contains('conversation') || g.contains('pronunciation'));
    final isWritingFirst = lowerGoals.any((g) => g.contains('writing')) && !isSpeaking;
    final isListeningFirst = lowerGoals.any((g) => g.contains('listening')) && !isSpeaking;
    final isReadingFirst = lowerGoals.any((g) => g.contains('reading')) && !isSpeaking;

    List<PracticeSkill> baseOrder;
    if (isExam) {
      baseOrder = const [
        PracticeSkill.reading,
        PracticeSkill.writing,
        PracticeSkill.listening,
        PracticeSkill.speaking,
      ];
    } else if (isCareer) {
      baseOrder = const [
        PracticeSkill.speaking,
        PracticeSkill.writing,
        PracticeSkill.listening,
        PracticeSkill.reading,
      ];
    } else if (isWritingFirst) {
      baseOrder = const [
        PracticeSkill.writing,
        PracticeSkill.reading,
        PracticeSkill.listening,
        PracticeSkill.speaking,
      ];
    } else if (isListeningFirst) {
      baseOrder = const [
        PracticeSkill.listening,
        PracticeSkill.speaking,
        PracticeSkill.reading,
        PracticeSkill.writing,
      ];
    } else if (isReadingFirst) {
      baseOrder = const [
        PracticeSkill.reading,
        PracticeSkill.listening,
        PracticeSkill.speaking,
        PracticeSkill.writing,
      ];
    } else {
      // Default: Speaking first (core Fluentia philosophy)
      baseOrder = const [
        PracticeSkill.speaking,
        PracticeSkill.listening,
        PracticeSkill.reading,
        PracticeSkill.writing,
      ];
    }

    return baseOrder;
  }

  /// Deterministically selects the Quick Practice skill based on user goals and calendar date.
  PracticeSkill selectQuickPracticeSkill({
    required List<String> userGoals,
    required DateTime date,
  }) {
    final ordered = orderSkills(userGoals);
    // Cycle between top 2 goals across days so learners get balanced practice without randomness on rebuild
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final index = (dayOfYear % 2 == 0) ? 0 : 1.clamp(0, ordered.length - 1);
    return ordered[index];
  }
}
