/// Deterministic practice plan generator based on daily minutes and selected goals.
class PlanGenerator {
  const PlanGenerator._();

  static const List<String> kCoreSkills = [
    'Speaking',
    'Listening',
    'Vocabulary',
    'Grammar',
    'Reading',
  ];

  /// Generates a skill-to-minutes distribution that sums strictly to [dailyMinutes].
  static Map<String, int> generatePlan({
    required int dailyMinutes,
    required List<String> selectedGoals,
  }) {
    if (dailyMinutes <= 0) return {};

    final weights = <String, double>{
      for (final skill in kCoreSkills) skill: 1.0,
    };

    for (final goal in selectedGoals) {
      final normalized = goal.trim().toLowerCase();

      if (normalized.contains('speaking') ||
          normalized.contains('pronunciation')) {
        weights['Speaking'] = (weights['Speaking'] ?? 1.0) + 2.5;
      }
      if (normalized.contains('listening')) {
        weights['Listening'] = (weights['Listening'] ?? 1.0) + 2.0;
      }
      if (normalized.contains('vocabulary')) {
        weights['Vocabulary'] = (weights['Vocabulary'] ?? 1.0) + 2.0;
      }
      if (normalized.contains('grammar')) {
        weights['Grammar'] = (weights['Grammar'] ?? 1.0) + 2.0;
      }
      if (normalized.contains('reading')) {
        weights['Reading'] = (weights['Reading'] ?? 1.0) + 2.0;
      }
      if (normalized.contains('everyday conversation')) {
        weights['Speaking'] = (weights['Speaking'] ?? 1.0) + 1.5;
        weights['Listening'] = (weights['Listening'] ?? 1.0) + 1.0;
      }
      if (normalized.contains('interview')) {
        weights['Speaking'] = (weights['Speaking'] ?? 1.0) + 2.0;
        weights['Vocabulary'] = (weights['Vocabulary'] ?? 1.0) + 1.0;
      }
      if (normalized.contains('academic')) {
        weights['Reading'] = (weights['Reading'] ?? 1.0) + 1.5;
        weights['Vocabulary'] = (weights['Vocabulary'] ?? 1.0) + 1.5;
      }
    }

    final totalWeight = weights.values.fold<double>(0.0, (sum, w) => sum + w);

    // Initial allocation using Largest Remainder Method (Hamilton-Hare method)
    final allocations = <String, int>{};
    final remainders = <String, double>{};
    int allocatedSum = 0;

    for (final skill in kCoreSkills) {
      final exactShare = (weights[skill]! / totalWeight) * dailyMinutes;
      final integerPart = exactShare.floor();
      allocations[skill] = integerPart;
      remainders[skill] = exactShare - integerPart;
      allocatedSum += integerPart;
    }

    int remainingMinutes = dailyMinutes - allocatedSum;

    // Distribute remaining minutes according to largest fractional remainders
    final sortedByRemainder = kCoreSkills.toList()
      ..sort((a, b) => remainders[b]!.compareTo(remainders[a]!));

    for (int i = 0; i < remainingMinutes; i++) {
      final targetSkill = sortedByRemainder[i % sortedByRemainder.length];
      allocations[targetSkill] = allocations[targetSkill]! + 1;
    }

    // Ensure all displayed skills have at least 1 minute if dailyMinutes >= coreSkills.length
    if (dailyMinutes >= kCoreSkills.length) {
      for (final skill in kCoreSkills) {
        if (allocations[skill]! == 0) {
          // Borrow 1 minute from the highest allocated skill
          String highestSkill = kCoreSkills.first;
          for (final s in kCoreSkills) {
            if (allocations[s]! > allocations[highestSkill]!) {
              highestSkill = s;
            }
          }
          if (allocations[highestSkill]! > 1) {
            allocations[highestSkill] = allocations[highestSkill]! - 1;
            allocations[skill] = 1;
          }
        }
      }
    }

    return allocations;
  }
}
