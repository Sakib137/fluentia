import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/design_system.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/widgets.dart';

/// Practice hub screen organizing active skill training modes.
class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FluentAppBar(
        title: AppStrings.practiceTitle,
        subtitle: AppStrings.practiceSubtitle,
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            const SectionHeader(
              title: 'Core Skills',
              subtitle: 'Select an active competency drill to practice',
            ),
            const SizedBox(height: AppSpacing.xs),
            SkillCard(
              icon: Icons.mic_rounded,
              title: AppStrings.speakingTitle,
              subtitle: AppStrings.speakingDesc,
              badgeText: 'Oral Fluency',
              level: 'B1',
              onTap: () => context.push(AppRoutes.practiceSpeaking),
            ),
            const SizedBox(height: AppSpacing.sm),
            SkillCard(
              icon: Icons.headphones_rounded,
              title: AppStrings.listeningTitle,
              subtitle: AppStrings.listeningDesc,
              badgeText: 'Comprehension',
              level: 'B1',
              onTap: () => context.push(AppRoutes.practiceListening),
            ),
            const SizedBox(height: AppSpacing.sm),
            SkillCard(
              icon: Icons.menu_book_rounded,
              title: AppStrings.readingTitle,
              subtitle: AppStrings.readingDesc,
              badgeText: 'Articles & Drills',
              level: 'B1',
              onTap: () => context.push(AppRoutes.practiceReading),
            ),
            const SizedBox(height: AppSpacing.sm),
            SkillCard(
              icon: Icons.edit_note_rounded,
              title: AppStrings.writingTitle,
              subtitle: AppStrings.writingDesc,
              badgeText: 'Composition',
              level: 'B1',
              onTap: () => context.push(AppRoutes.practiceWriting),
            ),
          ],
        ),
      ),
    );
  }
}
