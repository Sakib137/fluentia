import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/preferences_service.dart';
import '../../data/datasources/listening_content.dart';
import '../../data/services/audioplayer_audio_service.dart';
import '../../domain/models/audio_player_state.dart';
import '../../domain/models/listening_activity.dart';
import '../../domain/models/listening_mode.dart';
import '../../domain/services/audio_player_service.dart';
import '../../domain/services/daily_listening_selector.dart';

/// Provider supplying the [AudioPlayerService] instance.
final audioPlayerServiceProvider = Provider.autoDispose<AudioPlayerService>((
  ref,
) {
  final service = AudioplayerAudioService();
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Reactive stream provider for real-time audio playback status and progress.
final audioPlayerStateStreamProvider =
    StreamProvider.autoDispose<AudioPlayerSnapshot>((ref) {
      final player = ref.watch(audioPlayerServiceProvider);
      return player.stateStream;
    });

/// Provider for all bundled listening activities across CEFR levels.
final allListeningActivitiesProvider = Provider<List<ListeningActivity>>((ref) {
  return ListeningContent.activities;
});

/// Family provider filtering activities by [ListeningMode].
final listeningActivitiesByModeProvider =
    Provider.family<List<ListeningActivity>, ListeningMode>((ref, mode) {
      final all = ref.watch(allListeningActivitiesProvider);
      return all.where((a) => a.mode == mode).toList();
    });

/// Family provider filtering activities by CEFR level.
final listeningActivitiesByLevelProvider =
    Provider.family<List<ListeningActivity>, String>((ref, level) {
      final all = ref.watch(allListeningActivitiesProvider);
      return all
          .where((a) => a.level.toUpperCase() == level.toUpperCase())
          .toList();
    });

/// Provider for today's deterministic Daily Listening Challenge.
final dailyListeningChallengeProvider = Provider<ListeningActivity>((ref) {
  final all = ref.watch(allListeningActivitiesProvider);
  return DailyListeningSelector.select(activities: all, date: DateTime.now());
});

/// Key for storing unfinished continue-listening state in local preferences.
const String kContinueListeningActivityIdKey =
    'fluentia_continue_listening_activity_id';
const String kContinueListeningProgressKey =
    'fluentia_continue_listening_progress';

/// Provider for retrieving unfinished listening activity draft.
final continueListeningProvider = Provider<ListeningActivity?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final savedId = prefs.getString(kContinueListeningActivityIdKey);
  if (savedId == null || savedId.isEmpty) return null;

  final all = ref.watch(allListeningActivitiesProvider);
  return all.cast<ListeningActivity?>().firstWhere(
    (a) => a?.id == savedId,
    orElse: () => null,
  );
});
