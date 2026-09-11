import '../models/placement_question_model.dart';

/// Bundled, offline placement questions for estimating initial English proficiency.
const List<PlacementQuestionModel> kBundledPlacementQuestions = [
  PlacementQuestionModel(
    id: 'pq_01',
    category: PlacementCategory.grammar,
    difficulty: 'A1',
    question:
        'Sarah usually ______ to work by train, but today she is driving.',
    options: ['goes', 'go', 'is going', 'went'],
    correctAnswerIndex: 0,
    explanation:
        'Use the simple present ("goes") for routine habits and general truths with the third-person singular subject "Sarah".',
  ),
  PlacementQuestionModel(
    id: 'pq_02',
    category: PlacementCategory.vocabulary,
    difficulty: 'A1',
    question: 'Could you please ______ me a favor and close the window?',
    options: ['make', 'do', 'give', 'take'],
    correctAnswerIndex: 1,
    explanation:
        'The natural English collocation is "do someone a favor", not "make a favor".',
  ),
  PlacementQuestionModel(
    id: 'pq_03',
    category: PlacementCategory.sentenceCompletion,
    difficulty: 'A2',
    question: 'While we ______ dinner, the electricity suddenly went out.',
    options: ['have had', 'were having', 'had had', 'are having'],
    correctAnswerIndex: 1,
    explanation:
        'The past continuous ("were having") describes an ongoing action in the past interrupted by another event ("went out").',
  ),
  PlacementQuestionModel(
    id: 'pq_04',
    category: PlacementCategory.conversation,
    difficulty: 'A2',
    question: 'A: "Would you mind helping me move this desk?"\nB: "______."',
    options: [
      'Yes, of course I mind.',
      'Not at all, let\'s lift it together.',
      'No, I am minding.',
      'Yes, please do.',
    ],
    correctAnswerIndex: 1,
    explanation:
        'To agree politely to "Would you mind...?", say "Not at all" or "No problem", indicating that it is not a bother.',
  ),
  PlacementQuestionModel(
    id: 'pq_05',
    category: PlacementCategory.grammar,
    difficulty: 'A2',
    question:
        'They ______ in this neighborhood since 2018, so they know everyone here.',
    options: ['lived', 'are living', 'have lived', 'live'],
    correctAnswerIndex: 2,
    explanation:
        'Use the present perfect ("have lived") with "since" to express an action that started in the past and continues into the present.',
  ),
  PlacementQuestionModel(
    id: 'pq_06',
    category: PlacementCategory.vocabulary,
    difficulty: 'B1',
    question:
        'The team worked diligently to ensure the project was delivered ______ schedule.',
    options: ['ahead of', 'in front of', 'before of', 'prior with'],
    correctAnswerIndex: 0,
    explanation:
        '"Ahead of schedule" is the standard idiomatic expression meaning earlier than expected.',
  ),
  PlacementQuestionModel(
    id: 'pq_07',
    category: PlacementCategory.grammar,
    difficulty: 'B1',
    question:
        'If we ______ more time before the client meeting, we would review the slides once more.',
    options: ['will have', 'have', 'had', 'would have'],
    correctAnswerIndex: 2,
    explanation:
        'In second conditional sentences expressing hypothetical situations, use the simple past ("had") in the if-clause.',
  ),
  PlacementQuestionModel(
    id: 'pq_08',
    category: PlacementCategory.reading,
    difficulty: 'B1',
    context:
        'Micro-learning emphasizes short, focused study sessions rather than prolonged cramming. Cognitive research suggests that absorbing information in 10-to-15 minute daily intervals significantly increases long-term neural retention.',
    question:
        'According to the passage, what is the primary benefit of micro-learning?',
    options: [
      'It completely replaces the need for practical application.',
      'It strengthens long-term memory retention through brief, frequent sessions.',
      'It encourages students to study for several continuous hours.',
      'It eliminates the necessity of periodic revision.',
    ],
    correctAnswerIndex: 1,
    explanation:
        'The passage explicitly notes that absorbing information in 10-to-15 minute daily intervals increases long-term retention.',
  ),
  PlacementQuestionModel(
    id: 'pq_09',
    category: PlacementCategory.sentenceCompletion,
    difficulty: 'B1',
    question:
        'The architect, ______ latest building won an international design award, will speak tonight.',
    options: ['who', 'whom', 'whose', 'which'],
    correctAnswerIndex: 2,
    explanation:
        'Use the relative possessive pronoun "whose" to indicate that the building belongs to or was designed by the architect.',
  ),
  PlacementQuestionModel(
    id: 'pq_10',
    category: PlacementCategory.vocabulary,
    difficulty: 'B2',
    question:
        'Due to unforeseen logistical constraints, the committee decided to ______ the decision until next quarter.',
    options: ['defer', 'deter', 'defy', 'decay'],
    correctAnswerIndex: 0,
    explanation:
        '"Defer" means to put off to a later time or postpone. "Deter" means to discourage.',
  ),
  PlacementQuestionModel(
    id: 'pq_11',
    category: PlacementCategory.grammar,
    difficulty: 'B2',
    question:
        'Rarely ______ such widespread enthusiasm for a grassroots community project.',
    options: [
      'we have witnessed',
      'have we witnessed',
      'did we witnessed',
      'we witnessed',
    ],
    correctAnswerIndex: 1,
    explanation:
        'When a sentence begins with a negative or limiting adverb like "Rarely" or "Seldom", standard subject-auxiliary inversion is required ("have we witnessed").',
  ),
  PlacementQuestionModel(
    id: 'pq_12',
    category: PlacementCategory.reading,
    difficulty: 'B2',
    context:
        'While automated language tools have evolved remarkably, relying exclusively on digital algorithms often strips communication of cultural nuance, subtle irony, and rhetorical elegance that only human discernment can navigate.',
    question:
        'What is the author’s primary perspective on automated language tools?',
    options: [
      'They are wholly inadequate and should not be used in professional contexts.',
      'They are capable, but cannot fully capture complex human cultural nuance and tone.',
      'They have rendered bilingual language education largely unnecessary.',
      'They interpret rhetorical humor and irony better than human translators.',
    ],
    correctAnswerIndex: 1,
    explanation:
        'The text states that automated tools have advanced remarkably but strip communication of nuances that require human discernment.',
  ),
];
