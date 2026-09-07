/// Centralized route paths and route names for GoRouter.
class AppRoutes {
  AppRoutes._();

  // Root & Standalone Routes
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  // Shell Tabs
  static const String home = '/home';
  static const String practice = '/practice';
  static const String learn = '/learn';
  static const String progress = '/progress';
  static const String profile = '/profile';

  // Nested Practice Routes
  static const String practiceSpeaking = '/practice/speaking';
  static const String practiceListening = '/practice/listening';
  static const String practiceReading = '/practice/reading';
  static const String practiceWriting = '/practice/writing';

  // Nested Learn Routes
  static const String learnVocabulary = '/learn/vocabulary';
  static const String learnGrammar = '/learn/grammar';

  // Nested Progress Routes
  static const String progressStatistics = '/progress/statistics';
  static const String progressAchievements = '/progress/achievements';

  // Nested Profile Routes
  static const String profileSettings = '/profile/settings';
  static const String profileNotifications = '/profile/notifications';

  // Challenge Route
  static const String challenge = '/challenge';
}
