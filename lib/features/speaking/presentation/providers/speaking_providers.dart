import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/speaking_content.dart';
import '../../data/services/device_speech_recognition_service.dart';
import '../../data/services/device_tts_service.dart';
import '../../domain/models/speaking_activity.dart';
import '../../domain/models/speaking_mode.dart';
import '../../domain/services/daily_speaking_selector.dart';
import '../../domain/services/speaking_analysis_service.dart';
import '../../domain/services/speech_recognition_service.dart';
import '../../domain/services/text_comparison_service.dart';
import '../../domain/services/tts_service.dart';
import 'speaking_session_controller.dart';

/// Provider for the abstract speech recognition service.
final speechRecognitionServiceProvider = Provider<SpeechRecognitionService>((
  ref,
) {
  final service = DeviceSpeechRecognitionService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for text-to-speech audio pronunciation.
final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = DeviceTtsService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for the text comparison service.
final textComparisonServiceProvider = Provider<TextComparisonService>((ref) {
  return const TextComparisonService();
});

/// Provider for the speaking analysis service (currently local, future AI ready).
final speakingAnalysisServiceProvider = Provider<SpeakingAnalysisService>((
  ref,
) {
  final comparisonService = ref.watch(textComparisonServiceProvider);
  return LocalSpeakingAnalysisService(comparisonService);
});

/// Provider for all bundled speaking activities.
final allSpeakingActivitiesProvider = Provider<List<SpeakingActivity>>((ref) {
  return SpeakingContent.activities;
});

/// Provider family for activities filtered by [SpeakingMode].
final speakingActivitiesByModeProvider =
    Provider.family<List<SpeakingActivity>, SpeakingMode>((ref, mode) {
      final all = ref.watch(allSpeakingActivitiesProvider);
      return all.where((a) => a.mode == mode).toList();
    });

/// Provider for today's deterministic speaking challenge.
final dailySpeakingChallengeProvider = Provider<SpeakingActivity>((ref) {
  final all = ref.watch(allSpeakingActivitiesProvider);
  return DailySpeakingSelector.select(activities: all, date: DateTime.now());
});

/// State controller managing active speaking practice drill lifecycle.
final speakingSessionControllerProvider =
    NotifierProvider<SpeakingSessionController, SpeakingSessionState>(
      SpeakingSessionController.new,
    );
