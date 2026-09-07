import '../data/models/home_models.dart';

/// Pure domain engine that prioritizes and arranges quick practice recommendations
/// based on the user's selected learning goals from onboarding.
class PracticeRecommendationEngine {
  const PracticeRecommendationEngine._();

  static const List<QuickPracticeItem> _basePracticeItems = [
    QuickPracticeItem(
      skillType: 'Speaking',
      title: 'Conversational Fluency',
      description: 'Practice pronunciation, sentence stress, and speaking confidence.',
      estimatedMinutes: 5,
      route: '/practice/speaking',
      isPrimaryGoal: false,
    ),
    QuickPracticeItem(
      skillType: 'Listening',
      title: 'Comprehension & Accents',
      description: 'Train your ear with real-world dialogues and native intonations.',
      estimatedMinutes: 5,
      route: '/practice/listening',
      isPrimaryGoal: false,
    ),
    QuickPracticeItem(
      skillType: 'Reading',
      title: 'Speed & Vocabulary in Context',
      description: 'Read engaging short articles and expand lexical range.',
      estimatedMinutes: 5,
      route: '/practice/reading',
      isPrimaryGoal: false,
    ),
    QuickPracticeItem(
      skillType: 'Writing',
      title: 'Structure & Coherence',
      description: 'Formulate accurate sentences and express ideas logically.',
      estimatedMinutes: 5,
      route: '/practice/writing',
      isPrimaryGoal: false,
    ),
  ];

  /// Prioritizes the base practice items according to [selectedGoals].
  ///
  /// Matching skills receive higher rank and `isPrimaryGoal = true`.
  static List<QuickPracticeItem> rankRecommendations(List<String> selectedGoals) {
    if (selectedGoals.isEmpty) {
      // Default balanced order
      return _basePracticeItems;
    }

    final prioritizedSkills = <String>{};

    for (final goal in selectedGoals) {
      switch (goal) {
        case 'career_business':
          prioritizedSkills.add('Speaking');
          prioritizedSkills.add('Writing');
          break;
        case 'casual_conversation':
          prioritizedSkills.add('Speaking');
          prioritizedSkills.add('Listening');
          break;
        case 'travel_daily':
          prioritizedSkills.add('Speaking');
          prioritizedSkills.add('Listening');
          break;
        case 'exams_tests':
          prioritizedSkills.add('Reading');
          prioritizedSkills.add('Writing');
          break;
        case 'media_culture':
          prioritizedSkills.add('Listening');
          prioritizedSkills.add('Reading');
          break;
        default:
          prioritizedSkills.add('Speaking');
      }
    }

    // Sort items so prioritized skills appear first
    final ranked = List<QuickPracticeItem>.from(_basePracticeItems);
    ranked.sort((a, b) {
      final aPriority = prioritizedSkills.contains(a.skillType) ? 1 : 0;
      final bPriority = prioritizedSkills.contains(b.skillType) ? 1 : 0;
      return bPriority.compareTo(aPriority); // Higher priority first
    });

    return ranked.map((item) {
      final isPrimary = prioritizedSkills.contains(item.skillType);
      return QuickPracticeItem(
        skillType: item.skillType,
        title: item.title,
        description: item.description,
        estimatedMinutes: item.estimatedMinutes,
        route: item.route,
        isPrimaryGoal: isPrimary,
      );
    }).toList();
  }
}
