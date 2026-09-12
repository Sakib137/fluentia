import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../domain/models/audio_player_state.dart';
import '../../domain/services/audio_player_service.dart';
import '../providers/listening_providers.dart';

/// Reusable, compact audio player card with play/pause, replay, scrubbing, and speed selection.
class AudioPlayerCard extends ConsumerWidget {
  const AudioPlayerCard({
    super.key,
    required this.audioAsset,
    this.title = 'Listen to the Audio',
  });

  final String audioAsset;
  final String title;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString();
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    final audioService = ref.watch(audioPlayerServiceProvider);
    final audioSnapshotAsync = ref.watch(audioPlayerStateStreamProvider);

    // Default to the service's synchronous snapshot if stream hasn't emitted yet
    final snapshot = audioSnapshotAsync.asData?.value ?? audioService.snapshot;

    final primaryColor = isDark ? AppColors.primary400 : AppColors.primary600;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: AppRadii.roundedXl,
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Title & Status Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.graphic_eq_rounded,
                    size: AppIconSizes.sm,
                    color: primaryColor,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppFontSizes.labelLarge,
                      fontWeight: AppFontWeights.semiBold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs + 2,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate800 : AppColors.slate100,
                  borderRadius: AppRadii.roundedFull,
                ),
                child: Text(
                  snapshot.status.displayName,
                  style: TextStyle(
                    fontSize: AppFontSizes.caption,
                    fontWeight: AppFontWeights.medium,
                    color: snapshot.isError
                        ? (isDark ? AppColors.danger400 : AppColors.danger600)
                        : (isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextSecondary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Error State or Active Audio Controls
          if (snapshot.isError)
            _buildErrorState(context, ref, snapshot, isDark)
          else ...[
            // Progress Bar / Slider
            Row(
              children: [
                Text(
                  _formatDuration(snapshot.position),
                  style: TextStyle(
                    fontSize: AppFontSizes.caption,
                    fontFamily: 'monospace',
                    fontWeight: AppFontWeights.medium,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextSecondary,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: primaryColor,
                      inactiveTrackColor: isDark
                          ? AppColors.slate700
                          : AppColors.slate200,
                      thumbColor: primaryColor,
                      trackHeight: 3.5,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6.0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14.0,
                      ),
                    ),
                    child: Slider(
                      value: snapshot.duration.inMilliseconds > 0
                          ? snapshot.position.inMilliseconds.toDouble().clamp(
                              0.0,
                              snapshot.duration.inMilliseconds.toDouble(),
                            )
                          : 0.0,
                      max: snapshot.duration.inMilliseconds > 0
                          ? snapshot.duration.inMilliseconds.toDouble()
                          : 1.0,
                      onChanged: snapshot.duration.inMilliseconds > 0
                          ? (value) {
                              audioService.seek(
                                Duration(milliseconds: value.toInt()),
                              );
                            }
                          : null,
                    ),
                  ),
                ),
                Text(
                  _formatDuration(snapshot.duration),
                  style: TextStyle(
                    fontSize: AppFontSizes.caption,
                    fontFamily: 'monospace',
                    fontWeight: AppFontWeights.medium,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            // Main Playback Controls: Replay, Play/Pause, Speed Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Replay Button
                IconButton(
                  tooltip: 'Replay from start',
                  icon: const Icon(Icons.replay_rounded),
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  onPressed: () => audioService.replay(),
                ),

                // Central Play/Pause Toggle
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      if (snapshot.isLoading) return;
                      if (snapshot.isPlaying) {
                        audioService.pause();
                      } else {
                        audioService.play();
                      }
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: snapshot.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Icon(
                                snapshot.isPlaying
                                    ? Icons.pause_rounded
                                    : (snapshot.isCompleted
                                          ? Icons.replay_rounded
                                          : Icons.play_arrow_rounded),
                                color: Colors.white,
                                size: AppIconSizes.lg,
                              ),
                      ),
                    ),
                  ),
                ),

                // Playback Speed Chips Menu
                _buildSpeedSelector(context, audioService, snapshot, isDark),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpeedSelector(
    BuildContext context,
    AudioPlayerService service,
    AudioPlayerSnapshot snapshot,
    bool isDark,
  ) {
    const speeds = [0.75, 1.0, 1.25, 1.5];

    return PopupMenuButton<double>(
      initialValue: snapshot.speed,
      tooltip: 'Playback speed',
      shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
      onSelected: (speed) => service.setSpeed(speed),
      itemBuilder: (context) {
        return speeds.map((speed) {
          final isSelected = (snapshot.speed - speed).abs() < 0.01;
          return PopupMenuItem<double>(
            value: speed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${speed}x',
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? (isDark ? AppColors.primary300 : AppColors.primary700)
                        : null,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: isDark ? AppColors.primary300 : AppColors.primary700,
                  ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate800 : AppColors.slate100,
          borderRadius: AppRadii.roundedFull,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${snapshot.speed}x',
              style: TextStyle(
                fontSize: AppFontSizes.bodySmall,
                fontWeight: AppFontWeights.semiBold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 18,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    AudioPlayerSnapshot snapshot,
    bool isDark,
  ) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.danger900.withValues(alpha: 0.25)
            : AppColors.danger50,
        borderRadius: AppRadii.roundedMd,
        border: Border.all(
          color: isDark ? AppColors.danger800 : AppColors.danger200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: isDark ? AppColors.danger400 : AppColors.danger600,
            size: AppIconSizes.md,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audio Unavailable',
                  style: TextStyle(
                    fontSize: AppFontSizes.bodyMedium,
                    fontWeight: AppFontWeights.semiBold,
                    color: isDark ? AppColors.danger300 : AppColors.danger700,
                  ),
                ),
                Text(
                  snapshot.errorMessage ??
                      'Could not play local audio asset. Please retry.',
                  style: TextStyle(
                    fontSize: AppFontSizes.caption,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {
              ref.read(audioPlayerServiceProvider).loadAsset(audioAsset);
            },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: TextButton.styleFrom(
              foregroundColor: isDark
                  ? AppColors.primary300
                  : AppColors.primary700,
            ),
          ),
        ],
      ),
    );
  }
}
