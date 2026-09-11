import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/features/speaking/domain/models/speaking_activity.dart';
import 'package:fluentia/features/speaking/domain/models/speaking_mode.dart';
import 'package:fluentia/features/speaking/domain/services/speaking_analysis_service.dart';
import 'package:fluentia/features/speaking/domain/services/text_comparison_service.dart';

void main() {
  late LocalSpeakingAnalysisService service;

  setUp(() {
    service = const LocalSpeakingAnalysisService(TextComparisonService());
  });

  group('SpeakingMetrics and LocalSpeakingAnalysisService Tests', () {
    test(
      'Read Aloud exact match derives 100% match and positive recommendation',
      () async {
        const activity = SpeakingActivity(
          id: 'ra_test_1',
          title: 'Morning Routine',
          instruction: 'Read this sentence aloud clearly.',
          mode: SpeakingMode.readAloud,
          level: 'A1',
          prompt: 'Read this aloud',
          expectedText: 'I always drink coffee in the morning.',
          speakingSeconds: 15,
          preparationSeconds: 5,
        );

        final metrics = await service.analyze(
          activity: activity,
          recognizedText: 'I always drink coffee in the morning',
          speakingDuration: const Duration(seconds: 5),
        );

        expect(metrics.matchPercentage, 100.0);
        expect(metrics.wordCount, 7);
        expect(metrics.wordsPerMinute, greaterThan(0));
        expect(metrics.hasExpectedText, isTrue);
        expect(metrics.hasSpeechRecognized, isTrue);
        expect(metrics.missingWords, isEmpty);
        expect(metrics.nextRecommendation, contains('Challenge yourself'));
      },
    );

    test(
      'Read Aloud partial match derives lower match percentage and highlights missing words',
      () async {
        const activity = SpeakingActivity(
          id: 'ra_test_2',
          title: 'Travel Plans',
          instruction: 'Read the sentence accurately.',
          mode: SpeakingMode.readAloud,
          level: 'B1',
          prompt: 'Read this aloud',
          expectedText: 'We booked our flight tickets two months in advance.',
          speakingSeconds: 20,
          preparationSeconds: 5,
        );

        final metrics = await service.analyze(
          activity: activity,
          recognizedText: 'We booked our tickets',
          speakingDuration: const Duration(seconds: 4),
        );

        expect(metrics.matchPercentage, lessThan(100.0));
        expect(
          metrics.missingWords,
          containsAll(['flight', 'two', 'months', 'in', 'advance']),
        );
        expect(
          metrics.nextRecommendation,
          contains('silently before speaking'),
        );
      },
    );

    test(
      'Speak About It with sufficient duration and good pace yields positive pacing feedback',
      () async {
        const activity = SpeakingActivity(
          id: 'sai_test_1',
          title: 'Favorite Season',
          instruction: 'Share your thoughts.',
          mode: SpeakingMode.speakAboutIt,
          level: 'A2',
          prompt: 'Tell me about your favorite season and why you like it.',
          speakingSeconds: 30,
          preparationSeconds: 5,
        );

        // 40 words in 20 seconds = 120 WPM (conversational sweet spot)
        const transcript =
            'My favorite season is autumn because the weather is cool and pleasant. '
            'I really love walking in the park and watching the colorful leaves fall from the trees. '
            'It feels so calm and relaxing.';

        final metrics = await service.analyze(
          activity: activity,
          recognizedText: transcript,
          speakingDuration: const Duration(seconds: 20),
        );

        expect(
          metrics.matchPercentage,
          isNull,
        ); // Free speaking does not have text match
        expect(metrics.durationSeconds, 20);
        expect(metrics.wordCount, greaterThan(20));
        expect(metrics.wordsPerMinute, inInclusiveRange(80, 180));
        expect(
          metrics.feedbackMessage,
          contains('Good job keeping your answer going'),
        );
      },
    );

    test(
      'Speak About It with too short duration gives encouraging extension advice',
      () async {
        const activity = SpeakingActivity(
          id: 'sai_test_2',
          title: 'Weekend Plans',
          instruction: 'Describe your weekend.',
          mode: SpeakingMode.speakAboutIt,
          level: 'B1',
          prompt: 'What are your plans for the weekend?',
          speakingSeconds: 45,
          preparationSeconds: 5,
        );

        final metrics = await service.analyze(
          activity: activity,
          recognizedText: 'I will stay home and sleep.',
          speakingDuration: const Duration(seconds: 5), // short duration
        );

        expect(metrics.durationSeconds, 5);
        expect(
          metrics.feedbackMessage,
          contains('speaking for a little longer'),
        );
      },
    );

    test(
      'Zero speech detected yields helpful prompt to retry and 0 WPM',
      () async {
        const activity = SpeakingActivity(
          id: 'qr_test_1',
          title: 'Quick Response',
          instruction: 'Answer promptly.',
          mode: SpeakingMode.quickResponse,
          level: 'B2',
          prompt: 'Do you prefer tea or coffee?',
          speakingSeconds: 20,
          preparationSeconds: 3,
        );

        final metrics = await service.analyze(
          activity: activity,
          recognizedText: '',
          speakingDuration: const Duration(seconds: 10),
        );

        expect(metrics.wordCount, 0);
        expect(metrics.wordsPerMinute, 0);
        expect(metrics.hasSpeechRecognized, isFalse);
        expect(metrics.feedbackMessage, contains('No speech was recognized'));
      },
    );

    test('WPM is clamped and handles 0 duration safely', () async {
      const activity = SpeakingActivity(
        id: 'test_clamp',
        title: 'Pacing test',
        instruction: 'Test instruction',
        mode: SpeakingMode.speakAboutIt,
        level: 'B1',
        prompt: 'Test prompt',
        speakingSeconds: 10,
      );

      // Duration 0 seconds
      final zeroDurationMetrics = await service.analyze(
        activity: activity,
        recognizedText: 'one two three',
        speakingDuration: Duration.zero,
      );
      expect(zeroDurationMetrics.wordsPerMinute, 0);

      // Extreme words count clamped to 300 max
      final extremeWords = List.generate(500, (i) => 'word').join(' ');
      final extremeMetrics = await service.analyze(
        activity: activity,
        recognizedText: extremeWords,
        speakingDuration: const Duration(seconds: 10),
      );
      expect(extremeMetrics.wordsPerMinute, 300);
    });
  });
}
