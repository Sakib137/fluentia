import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/features/practice/domain/models/practice_models.dart';
import 'package:fluentia/features/writing/domain/models/writing_activity.dart';
import 'package:fluentia/features/writing/domain/models/writing_mode.dart';

void main() {
  group('WritingActivity Model Tests', () {
    test('Correctly identifies objective activities', () {
      const sb = WritingActivity(
        id: 'w1',
        title: 'Sentence Builder Drill',
        instruction: 'Assemble the sentence',
        level: 'A1',
        mode: WritingMode.sentenceBuilder,
        prompt: 'Arrange the words',
        expectedAnswer: 'I drink water.',
        category: 'Basics',
      );
      expect(sb.isObjective, isTrue);

      const cs = WritingActivity(
        id: 'w2',
        title: 'Complete Sentence Drill',
        instruction: 'Fill in blank',
        level: 'A2',
        mode: WritingMode.completeSentence,
        prompt: 'I want to ___ home.',
        expectedAnswer: 'go',
        category: 'Basics',
      );
      expect(cs.isObjective, isTrue);

      const qr = WritingActivity(
        id: 'w3',
        title: 'Quick Response Drill',
        instruction: 'Write 2 sentences',
        level: 'B1',
        mode: WritingMode.quickResponse,
        prompt: 'What did you eat?',
        minimumWords: 10,
        maximumWords: 30,
        category: 'Food',
      );
      expect(qr.isObjective, isFalse);
    });

    test('Converts to core PracticeActivity accurately', () {
      const activity = WritingActivity(
        id: 'wr-test-01',
        title: 'Proposal Exercise',
        instruction: 'Write proposal',
        level: 'B2',
        mode: WritingMode.guidedWriting,
        prompt: 'Draft an email proposal',
        minimumWords: 40,
        maximumWords: 80,
        checklist: ['Point 1', 'Point 2'],
        category: 'Work',
        tags: ['work', 'email'],
      );

      final practice = activity.toPracticeActivity();

      expect(practice.id, 'wr-test-01');
      expect(practice.skill, PracticeSkill.writing);
      expect(practice.type, PracticeActivityType.guidedWriting);
      expect(practice.title, 'Proposal Exercise');
      expect(practice.level, 'B2');
      expect(practice.content['minimumWords'], 40);
      expect(practice.content['checklist'], ['Point 1', 'Point 2']);
      expect(practice.metadata['category'], 'Work');
      expect(practice.metadata['mode'], 'guidedWriting');
    });

    test('Serializes to and deserializes from JSON properly', () {
      const original = WritingActivity(
        id: 'json-1',
        title: 'Test Prompt',
        instruction: 'Follow rules',
        level: 'C1',
        mode: WritingMode.shortWriting,
        prompt: 'Analyze implications',
        minimumWords: 50,
        maximumWords: 100,
        category: 'Analysis',
        tags: ['academic'],
        sampleAnswer: 'This is a sample.',
      );

      final json = original.toJson();
      final restored = WritingActivity.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.mode, original.mode);
      expect(restored.minimumWords, original.minimumWords);
      expect(restored.maximumWords, original.maximumWords);
      expect(restored.sampleAnswer, original.sampleAnswer);
      expect(restored.tags, original.tags);
    });
  });
}
