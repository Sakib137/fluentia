import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/features/listening/domain/models/comprehension_question.dart';
import 'package:fluentia/features/listening/domain/models/listening_activity.dart';
import 'package:fluentia/features/listening/domain/models/listening_mode.dart';
import 'package:fluentia/features/practice/domain/models/practice_models.dart';

void main() {
  group('ListeningActivity domain tests', () {
    test('Can convert ListeningActivity to and from PracticeActivity', () {
      const activity = ListeningActivity(
        id: 'test_lac_01',
        title: 'Morning Alarm',
        instruction: 'Listen carefully to the time mentioned.',
        level: 'A1',
        mode: ListeningMode.listenAndChoose,
        audioAsset: 'assets/audio/listening/a1/a1_daily_routine.wav',
        transcript: 'I wake up at seven.',
        question: 'What time does the speaker wake up?',
        options: ['At 6', 'At 7', 'At 8'],
        correctAnswer: 'At 7',
        acceptedAnswers: ['7', 'At seven'],
        estimatedDurationMinutes: 2,
        category: 'Routines',
        tags: ['A1', 'Time'],
      );

      final practiceActivity = activity.toPracticeActivity();
      expect(practiceActivity.id, equals('test_lac_01'));
      expect(practiceActivity.skill, equals(PracticeSkill.listening));
      expect(
        practiceActivity.type,
        equals(PracticeActivityType.listenAndChoose),
      );
      expect(practiceActivity.difficulty, equals('Beginner'));

      final reconstructed = ListeningActivity.fromPracticeActivity(
        practiceActivity,
      );
      expect(reconstructed.id, equals(activity.id));
      expect(reconstructed.title, equals(activity.title));
      expect(reconstructed.mode, equals(ListeningMode.listenAndChoose));
      expect(reconstructed.audioAsset, equals(activity.audioAsset));
      expect(reconstructed.transcript, equals(activity.transcript));
      expect(reconstructed.question, equals(activity.question));
      expect(reconstructed.options, equals(activity.options));
      expect(reconstructed.correctAnswer, equals(activity.correctAnswer));
    });

    test('Translates all ListeningModes to correct PracticeActivityType', () {
      for (final mode in ListeningMode.values) {
        final act = ListeningActivity(
          id: 'test_${mode.id}',
          title: 'Test',
          instruction: 'Instruction',
          level: 'B1',
          mode: mode,
          audioAsset: 'test.wav',
          transcript: 'test',
        );

        final pAct = act.toPracticeActivity();
        expect(pAct.skill, equals(PracticeSkill.listening));
        expect(pAct.type, equals(act.practiceActivityType));
      }
    });

    test('Serializes ComprehensionQuestion to and from JSON', () {
      const q = ComprehensionQuestion(
        id: 'q1',
        question: 'Why did the gate change?',
        options: ['Maintenance', 'Weather', 'Staff'],
        correctAnswer: 'Maintenance',
        explanation: 'The announcer mentioned technical tarmac maintenance.',
      );

      final json = q.toJson();
      final fromJson = ComprehensionQuestion.fromJson(json);

      expect(fromJson.id, equals('q1'));
      expect(fromJson.question, equals('Why did the gate change?'));
      expect(fromJson.options.length, equals(3));
      expect(fromJson.correctAnswer, equals('Maintenance'));
      expect(
        fromJson.explanation,
        equals('The announcer mentioned technical tarmac maintenance.'),
      );
    });
  });
}
