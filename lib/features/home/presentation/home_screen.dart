import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/design_system.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/fluent_app_bar.dart';
import 'providers/home_providers.dart';
import 'widgets/daily_challenge_card.dart';
import 'widgets/daily_goal_card.dart';
import 'widgets/home_header.dart';
import 'widgets/progress_snapshot_section.dart';
import 'widgets/quick_practice_section.dart';
import 'widgets/word_of_the_day_card.dart';

/// Production Home Dashboard screen for Fluentia.
///
/// Combines time-aware personalized greetings, real-time daily practice goals,
/// deterministic daily challenges, goal-prioritized quick practice drills,
/// lexical Word of the Day, and cumulative offline progress metrics.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const FluentAppBar(
        title: AppConstants.appName,
        subtitle: 'Daily English Practice',
        showDivider: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dailyProgressProvider);
          ref.invalidate(streakProvider);
          ref.invalidate(dailyChallengeProvider);
          ref.invalidate(wordOfTheDayProvider);
          ref.invalidate(progressSnapshotProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          children: const [
            HomeHeader(),
            SizedBox(height: AppSpacing.sm),
            DailyGoalCard(),
            SizedBox(height: AppSpacing.lg),
            DailyChallengeCard(),
            SizedBox(height: AppSpacing.lg),
            QuickPracticeSection(),
            SizedBox(height: AppSpacing.lg),
            WordOfTheDayCard(),
            SizedBox(height: AppSpacing.lg),
            ProgressSnapshotSection(),
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
