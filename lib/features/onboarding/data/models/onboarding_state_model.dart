import 'dart:convert';

/// Representation of a single scheduled reminder time slot.
class ReminderTimeSlot {
  const ReminderTimeSlot({
    required this.hour,
    required this.minute,
    this.label,
  });

  final int hour;
  final int minute;
  final String? label;

  Map<String, dynamic> toMap() {
    return {'hour': hour, 'minute': minute, if (label != null) 'label': label};
  }

  factory ReminderTimeSlot.fromMap(Map<String, dynamic> map) {
    return ReminderTimeSlot(
      hour: map['hour'] as int? ?? 20,
      minute: map['minute'] as int? ?? 0,
      label: map['label'] as String?,
    );
  }

  ReminderTimeSlot copyWith({int? hour, int? minute, String? label}) {
    return ReminderTimeSlot(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      label: label ?? this.label,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderTimeSlot &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute &&
          label == other.label;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode ^ (label?.hashCode ?? 0);
}

/// Persistent onboarding state capturing all user preferences and assessment results.
class OnboardingStateModel {
  const OnboardingStateModel({
    this.onboardingCompleted = false,
    this.selectedGoals = const [],
    this.currentLevel,
    this.estimatedLevel,
    this.dailyPracticeMinutes = 15,
    this.remindersEnabled = true,
    this.reminderCount = 1,
    this.reminderTimes = const [
      ReminderTimeSlot(hour: 20, minute: 0, label: 'Evening Practice'),
    ],
    this.placementTestCompleted = false,
    this.placementTestScore = 0,
    this.personalizedPlan = const {},
  });

  final bool onboardingCompleted;
  final List<String> selectedGoals;
  final String? currentLevel;
  final String? estimatedLevel;
  final int dailyPracticeMinutes;
  final bool remindersEnabled;
  final int reminderCount;
  final List<ReminderTimeSlot> reminderTimes;
  final bool placementTestCompleted;
  final int placementTestScore;
  final Map<String, int> personalizedPlan;

  OnboardingStateModel copyWith({
    bool? onboardingCompleted,
    List<String>? selectedGoals,
    String? currentLevel,
    String? estimatedLevel,
    int? dailyPracticeMinutes,
    bool? remindersEnabled,
    int? reminderCount,
    List<ReminderTimeSlot>? reminderTimes,
    bool? placementTestCompleted,
    int? placementTestScore,
    Map<String, int>? personalizedPlan,
  }) {
    return OnboardingStateModel(
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      selectedGoals: selectedGoals ?? this.selectedGoals,
      currentLevel: currentLevel ?? this.currentLevel,
      estimatedLevel: estimatedLevel ?? this.estimatedLevel,
      dailyPracticeMinutes: dailyPracticeMinutes ?? this.dailyPracticeMinutes,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderCount: reminderCount ?? this.reminderCount,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      placementTestCompleted:
          placementTestCompleted ?? this.placementTestCompleted,
      placementTestScore: placementTestScore ?? this.placementTestScore,
      personalizedPlan: personalizedPlan ?? this.personalizedPlan,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'onboardingCompleted': onboardingCompleted,
      'selectedGoals': selectedGoals,
      'currentLevel': currentLevel,
      'estimatedLevel': estimatedLevel,
      'dailyPracticeMinutes': dailyPracticeMinutes,
      'remindersEnabled': remindersEnabled,
      'reminderCount': reminderCount,
      'reminderTimes': reminderTimes.map((r) => r.toMap()).toList(),
      'placementTestCompleted': placementTestCompleted,
      'placementTestScore': placementTestScore,
      'personalizedPlan': personalizedPlan,
    };
  }

  factory OnboardingStateModel.fromMap(Map<String, dynamic> map) {
    return OnboardingStateModel(
      onboardingCompleted: map['onboardingCompleted'] as bool? ?? false,
      selectedGoals:
          (map['selectedGoals'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      currentLevel: map['currentLevel'] as String?,
      estimatedLevel: map['estimatedLevel'] as String?,
      dailyPracticeMinutes: map['dailyPracticeMinutes'] as int? ?? 15,
      remindersEnabled: map['remindersEnabled'] as bool? ?? true,
      reminderCount: map['reminderCount'] as int? ?? 1,
      reminderTimes:
          (map['reminderTimes'] as List<dynamic>?)
              ?.map(
                (item) =>
                    ReminderTimeSlot.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          const [
            ReminderTimeSlot(hour: 20, minute: 0, label: 'Evening Practice'),
          ],
      placementTestCompleted: map['placementTestCompleted'] as bool? ?? false,
      placementTestScore: map['placementTestScore'] as int? ?? 0,
      personalizedPlan:
          (map['personalizedPlan'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          ) ??
          const {},
    );
  }

  String toJson() => jsonEncode(toMap());

  factory OnboardingStateModel.fromJson(String source) =>
      OnboardingStateModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
