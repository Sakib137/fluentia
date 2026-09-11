import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/placement_questions_data.dart';
import '../../data/models/placement_question_model.dart';
import '../../domain/scoring/placement_test_evaluator.dart';

/// State of the interactive placement test.
class PlacementTestState {
  const PlacementTestState({
    this.questions = kBundledPlacementQuestions,
    this.currentIndex = 0,
    this.selectedAnswers = const {},
    this.isSubmitted = false,
    this.result,
  });

  final List<PlacementQuestionModel> questions;
  final int currentIndex;
  final Map<int, int> selectedAnswers;
  final bool isSubmitted;
  final PlacementResultModel? result;

  PlacementQuestionModel get currentQuestion => questions[currentIndex];
  bool get hasAnsweredCurrent => selectedAnswers.containsKey(currentIndex);
  bool get isLastQuestion => currentIndex == questions.length - 1;
  int? get currentSelectedOption => selectedAnswers[currentIndex];
  int get answeredCount => selectedAnswers.length;
  double get progress =>
      questions.isNotEmpty ? (currentIndex + 1) / questions.length : 0.0;

  PlacementTestState copyWith({
    List<PlacementQuestionModel>? questions,
    int? currentIndex,
    Map<int, int>? selectedAnswers,
    bool? isSubmitted,
    PlacementResultModel? result,
  }) {
    return PlacementTestState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      result: result ?? this.result,
    );
  }
}

/// Notifier handling question traversal, answer choices, and scoring.
class PlacementTestNotifier extends Notifier<PlacementTestState> {
  @override
  PlacementTestState build() {
    return const PlacementTestState();
  }

  /// Selects an option for the active question.
  void selectOption(int optionIndex) {
    final updated = Map<int, int>.from(state.selectedAnswers);
    updated[state.currentIndex] = optionIndex;
    state = state.copyWith(selectedAnswers: updated);
  }

  /// Navigates to the next question or submits if on the last question.
  void nextQuestion() {
    if (!state.isLastQuestion) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    } else {
      submitTest();
    }
  }

  /// Navigates to the previous question.
  void previousQuestion() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  /// Submits answers and calculates the estimated level and qualitative feedback.
  void submitTest() {
    final evalResult = PlacementTestEvaluator.evaluate(
      questions: state.questions,
      selectedAnswers: state.selectedAnswers,
    );

    state = state.copyWith(isSubmitted: true, result: evalResult);
  }

  /// Resets test state for retaking the assessment.
  void reset() {
    state = PlacementTestState(questions: state.questions);
  }
}

/// Riverpod provider for the active placement test.
final placementTestProvider =
    NotifierProvider.autoDispose<PlacementTestNotifier, PlacementTestState>(
      PlacementTestNotifier.new,
    );
