import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/app/theme/design_system.dart';
import 'package:fluentia/shared/widgets/widgets.dart';

Widget _wrapWithTheme({required Widget child, ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? AppTheme.light,
    home: Scaffold(
      body: SingleChildScrollView(child: Center(child: child)),
    ),
  );
}

void main() {
  group('Design System Tokens', () {
    test('Color tokens are non-null and correctly initialized', () {
      expect(AppColors.primary, equals(AppColors.primary600));
      expect(AppColors.primaryLight, equals(AppColors.primary500));
      expect(AppColors.primaryDark, equals(AppColors.primary700));
      expect(AppColors.lightBackground, isA<Color>());
      expect(AppColors.darkBackground, isA<Color>());
      expect(AppColors.sage500, isA<Color>());
      expect(AppColors.amber500, isA<Color>());
      expect(AppColors.coral500, isA<Color>());
      expect(AppColors.sky500, isA<Color>());
    });

    test('Spacing tokens adhere to scale', () {
      expect(AppSpacing.xxs, equals(2.0));
      expect(AppSpacing.xs, equals(4.0));
      expect(AppSpacing.sm, equals(8.0));
      expect(AppSpacing.md, equals(12.0));
      expect(AppSpacing.lg, equals(16.0));
      expect(AppSpacing.xl, equals(20.0));
      expect(AppSpacing.xxl, equals(24.0));
      expect(AppSpacing.xxxl, equals(32.0));
      expect(AppSpacing.section, equals(48.0));
    });

    test('Radii and BorderRadii match scale', () {
      expect(AppRadii.sm, equals(8.0));
      expect(AppRadii.md, equals(12.0));
      expect(AppRadii.lg, equals(16.0));
      expect(AppRadii.roundedMd, equals(BorderRadius.circular(12.0)));
      expect(AppRadii.roundedFull, equals(BorderRadius.circular(999.0)));
    });

    test('Shadows are defined for light and dark', () {
      expect(AppShadows.subtle.length, greaterThan(0));
      expect(AppShadows.card.length, greaterThan(0));
      expect(AppShadows.darkSubtle.length, greaterThan(0));
    });

    test('Icon sizes follow scale', () {
      expect(AppIconSizes.xs, equals(12.0));
      expect(AppIconSizes.sm, equals(16.0));
      expect(AppIconSizes.md, equals(20.0));
      expect(AppIconSizes.lg, equals(24.0));
      expect(AppIconSizes.xl, equals(32.0));
      expect(AppIconSizes.hero, equals(48.0));
    });
  });

  group('Theme Data Configuration', () {
    test('Light theme has correct brightness and surfaces', () {
      final theme = AppTheme.light;
      expect(theme.brightness, equals(Brightness.light));
      expect(theme.scaffoldBackgroundColor, equals(AppColors.lightBackground));
      expect(theme.colorScheme.primary, equals(AppColors.primary600));
      expect(theme.colorScheme.surface, equals(AppColors.lightSurface));
      expect(theme.useMaterial3, isTrue);
    });

    test('Dark theme has correct brightness and surfaces', () {
      final theme = AppTheme.dark;
      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.scaffoldBackgroundColor, equals(AppColors.darkBackground));
      expect(theme.colorScheme.primary, equals(AppColors.primary400));
      expect(theme.colorScheme.surface, equals(AppColors.darkSurface));
      expect(theme.useMaterial3, isTrue);
    });
  });

  group('Reusable UI Components', () {
    testWidgets('PrimaryButton renders and responds to tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrapWithTheme(
          child: PrimaryButton(
            label: 'Start Practice',
            icon: const Icon(Icons.play_arrow_rounded),
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Start Practice'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      await tester.tap(find.text('Start Practice'));
      expect(tapped, isTrue);
    });

    testWidgets(
      'PrimaryButton renders loading indicator when isLoading is true',
      (tester) async {
        await tester.pumpWidget(
          _wrapWithTheme(
            child: const PrimaryButton(
              label: 'Saving',
              isLoading: true,
              onPressed: null,
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Saving'), findsNothing);
      },
    );

    testWidgets('SecondaryButton renders with outline and responds to tap', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrapWithTheme(
          child: SecondaryButton(
            label: 'Review Later',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Review Later'), findsOneWidget);
      await tester.tap(find.text('Review Later'));
      expect(tapped, isTrue);
    });

    testWidgets(
      'AppCard renders child with subtle border and responds to tap',
      (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          _wrapWithTheme(
            child: AppCard(
              onTap: () => tapped = true,
              child: const Text('Card Content'),
            ),
          ),
        );

        expect(find.text('Card Content'), findsOneWidget);
        await tester.tap(find.text('Card Content'));
        expect(tapped, isTrue);
      },
    );

    testWidgets('ProgressBar renders with expected progress', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          child: const ProgressBar(
            value: 0.65,
            height: 8.0,
            color: AppColors.primary500,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final progressIndicatorFinder = find.byType(LinearProgressIndicator);
      expect(progressIndicatorFinder, findsOneWidget);

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        progressIndicatorFinder,
      );
      expect(progressIndicator.value, equals(0.65));
      expect(progressIndicator.minHeight, equals(8.0));
    });

    testWidgets('SkillCard displays title, subtitle, level, and progress', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrapWithTheme(
          child: SkillCard(
            icon: Icons.mic_rounded,
            title: 'Speaking',
            subtitle: 'Voice clarity & accent drills',
            level: 'B2',
            progress: 0.45,
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Speaking'), findsOneWidget);
      expect(find.text('Voice clarity & accent drills'), findsOneWidget);
      expect(find.text('B2'), findsOneWidget);
      expect(find.byType(ProgressBar), findsOneWidget);

      await tester.tap(find.text('Speaking'));
      expect(tapped, isTrue);
    });

    testWidgets('PracticeCard displays duration, badge, and handles tap', (
      tester,
    ) async {
      var started = false;
      await tester.pumpWidget(
        _wrapWithTheme(
          child: PracticeCard(
            title: 'Speed Pronunciation',
            description: 'Speak 10 rapid sentences with AI phonetic checks',
            durationMinutes: 7,
            badge: 'Daily Drill',
            onStart: () => started = true,
          ),
        ),
      );

      expect(find.text('Speed Pronunciation'), findsOneWidget);
      expect(find.text('7 min'), findsOneWidget);
      expect(find.text('Daily Drill'), findsOneWidget);
      expect(find.text('Start Practice'), findsOneWidget);

      await tester.tap(find.text('Start Practice'));
      expect(started, isTrue);
    });

    testWidgets('StatCard displays value, label, and subtitle in Dark theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          theme: AppTheme.dark,
          child: const StatCard(
            label: 'Study Time',
            value: '45m',
            icon: Icons.timer_outlined,
            subtitle: '+15m vs yesterday',
          ),
        ),
      );

      expect(find.text('Study Time'), findsOneWidget);
      expect(find.text('45m'), findsOneWidget);
      expect(find.text('+15m vs yesterday'), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });

    testWidgets('LevelBadge renders CEFR level', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          child: const Row(
            children: [
              LevelBadge(level: 'A1'),
              LevelBadge(level: 'B1'),
              LevelBadge(level: 'C2'),
            ],
          ),
        ),
      );

      expect(find.text('A1'), findsOneWidget);
      expect(find.text('B1'), findsOneWidget);
      expect(find.text('C2'), findsOneWidget);
    });

    testWidgets('StreakBadge displays count in regular and compact modes', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          child: const Row(
            children: [
              StreakBadge(count: 7),
              StreakBadge(count: 14, compact: true),
            ],
          ),
        ),
      );

      expect(find.text('7 Day Streak'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
    });

    testWidgets('AppTextField renders label, hint, and errorText', (
      tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        _wrapWithTheme(
          child: AppTextField(
            label: 'Target Vocabulary',
            hint: 'Enter a word to search',
            controller: controller,
            errorText: 'Word not found',
            prefixIcon: const Icon(Icons.search_rounded),
          ),
        ),
      );

      expect(find.text('Target Vocabulary'), findsOneWidget);
      expect(find.text('Enter a word to search'), findsOneWidget);
      expect(find.text('Word not found'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('EmptyState displays title, description, and action button', (
      tester,
    ) async {
      var actionTriggered = false;
      await tester.pumpWidget(
        _wrapWithTheme(
          child: EmptyState(
            icon: Icons.auto_stories_outlined,
            title: 'No Reading Lessons Yet',
            description: 'Download offline packages to start reading articles.',
            actionLabel: 'Browse Library',
            onAction: () => actionTriggered = true,
          ),
        ),
      );

      expect(find.text('No Reading Lessons Yet'), findsOneWidget);
      expect(
        find.text('Download offline packages to start reading articles.'),
        findsOneWidget,
      );
      expect(find.text('Browse Library'), findsOneWidget);

      await tester.tap(find.text('Browse Library'));
      expect(actionTriggered, isTrue);
    });

    testWidgets('LoadingState renders message and progress spinner', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          child: const LoadingState(
            message: 'Preparing your daily exercise...',
          ),
        ),
      );

      expect(find.text('Preparing your daily exercise...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('SectionHeader displays title, subtitle, and action', (
      tester,
    ) async {
      var seeAllTapped = false;
      await tester.pumpWidget(
        _wrapWithTheme(
          child: SectionHeader(
            title: 'Grammar Modules',
            subtitle: 'Master essential tenses and structures',
            actionLabel: 'See All',
            onAction: () => seeAllTapped = true,
          ),
        ),
      );

      expect(find.text('Grammar Modules'), findsOneWidget);
      expect(
        find.text('Master essential tenses and structures'),
        findsOneWidget,
      );
      expect(find.text('See All'), findsOneWidget);

      await tester.tap(find.text('See All'));
      expect(seeAllTapped, isTrue);
    });
  });
}
