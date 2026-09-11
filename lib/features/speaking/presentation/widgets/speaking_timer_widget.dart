import 'package:flutter/material.dart';
import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';

/// Clean timer widget showing elapsed speaking duration and remaining seconds for timed drills.
class SpeakingTimerWidget extends StatelessWidget {
  const SpeakingTimerWidget({
    super.key,
    required this.elapsedSeconds,
    required this.maxSeconds,
    this.isListening = false,
  });

  final int elapsedSeconds;
  final int maxSeconds;
  final bool isListening;

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final remainingSeconds = (maxSeconds - elapsedSeconds).clamp(0, maxSeconds);
    final progress = maxSeconds > 0
        ? (elapsedSeconds / maxSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Semantics(
      label:
          'Speaking timer: ${_formatTime(elapsedSeconds)} elapsed, ${_formatTime(remainingSeconds)} remaining',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isListening
                          ? (isDark ? AppColors.error400 : AppColors.error600)
                          : AppColors.slate400,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _formatTime(elapsedSeconds),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: AppFontSizes.titleMedium,
                      fontWeight: AppFontWeights.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '${_formatTime(remainingSeconds)} remaining',
                style: TextStyle(
                  fontSize: AppFontSizes.labelSmall,
                  fontWeight: AppFontWeights.medium,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: AppRadii.roundedFull,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: isDark ? AppColors.slate800 : AppColors.slate200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isListening
                    ? (isDark ? AppColors.error400 : AppColors.error500)
                    : (isDark ? AppColors.primary400 : AppColors.primary600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
