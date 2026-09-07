import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/challenge/presentation/challenge_screen.dart';
import '../../features/grammar/presentation/grammar_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/learn/presentation/learn_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/placement_test_screen.dart';
import '../../features/practice/presentation/practice_screen.dart';
import '../../features/practice/presentation/screens/practice_intro_screen.dart';
import '../../features/practice/presentation/screens/practice_result_screen.dart';
import '../../features/practice/presentation/screens/practice_session_screen.dart';
import '../../features/profile/presentation/notifications_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/progress/presentation/achievements_screen.dart';
import '../../features/progress/presentation/progress_screen.dart';
import '../../features/progress/presentation/statistics_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/vocabulary/presentation/screens/word_detail_screen.dart';
import '../../features/vocabulary/presentation/vocabulary_screen.dart';
import 'app_routes.dart';
import 'error_route_screen.dart';
import 'scaffold_with_bottom_nav.dart';

/// Global root navigator key for full-screen dialogs and shell-bypassing routes.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Central GoRouter configuration providing nested shell navigation and full-screen subroutes.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    errorBuilder: (context, state) => ErrorRouteScreen(error: state.error),
    routes: [
      // Top-level standalone routes (outside bottom navigation)
      GoRoute(
        path: AppRoutes.splash,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.placementTest,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const PlacementTestScreen(),
      ),
      GoRoute(
        path: AppRoutes.challenge,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ChallengeScreen(),
      ),

      // Persistent bottom navigation shell (StatefulShellRoute)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithBottomNav(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Branch 1: Practice + Full-Screen Subroutes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.practice,
                builder: (context, state) => const PracticeScreen(),
                routes: [
                  GoRoute(
                    path: 'speaking',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const PracticeIntroScreen(skillId: 'speaking'),
                  ),
                  GoRoute(
                    path: 'listening',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const PracticeIntroScreen(skillId: 'listening'),
                  ),
                  GoRoute(
                    path: 'reading',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const PracticeIntroScreen(skillId: 'reading'),
                  ),
                  GoRoute(
                    path: 'writing',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const PracticeIntroScreen(skillId: 'writing'),
                  ),
                  GoRoute(
                    path: ':skill/intro',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => PracticeIntroScreen(
                      skillId: state.pathParameters['skill'] ?? 'speaking',
                    ),
                  ),
                  GoRoute(
                    path: ':skill/session',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => PracticeSessionScreen(
                      skillId: state.pathParameters['skill'] ?? 'speaking',
                    ),
                  ),
                  GoRoute(
                    path: ':skill/result',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => PracticeResultScreen(
                      skillId: state.pathParameters['skill'] ?? 'speaking',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Branch 2: Learn + Full-Screen Subroutes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.learn,
                builder: (context, state) => const LearnScreen(),
                routes: [
                  GoRoute(
                    path: 'vocabulary',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const VocabularyScreen(),
                    routes: [
                      GoRoute(
                        path: 'word/:id',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => WordDetailScreen(
                          wordId: state.pathParameters['id'] ?? '',
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'grammar',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const GrammarScreen(),
                  ),
                ],
              ),
            ],
          ),

          // Branch 3: Progress + Full-Screen Subroutes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.progress,
                builder: (context, state) => const ProgressScreen(),
                routes: [
                  GoRoute(
                    path: 'statistics',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const StatisticsScreen(),
                  ),
                  GoRoute(
                    path: 'achievements',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const AchievementsScreen(),
                  ),
                ],
              ),
            ],
          ),

          // Branch 4: Profile + Full-Screen Subroutes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const NotificationsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
