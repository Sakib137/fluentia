import '../../domain/models/reading_activity.dart';
import '../../domain/models/reading_mode.dart';
import '../../domain/models/reading_question.dart';

/// Bundled local reading passages across CEFR levels A1, A2, B1, B2, and C1.
class ReadingContent {
  ReadingContent._();

  static const List<ReadingActivity> activities = [
    // -------------------------------------------------------------
    // LEVEL A1 - Beginner
    // -------------------------------------------------------------
    ReadingActivity(
      id: 'read_a1_morning',
      title: 'My Morning Routine',
      level: 'A1',
      mode: ReadingMode.readAndAnswer,
      category: 'Everyday Life',
      estimatedDurationMinutes: 2,
      difficulty: 'Easy',
      passage:
          'Every day, Lucas wakes up at seven o’clock. First, he washes his face and brushes his teeth. Then, he goes to the kitchen to make breakfast. He usually drinks a glass of warm orange juice and eats two eggs with toast.\n\nAt seven forty-five, Lucas leaves his apartment. He walks to the bus station near the park. The bus arrives on time at eight o’clock. Lucas likes listening to calm acoustic music during his twenty-minute ride to work.',
      paragraphs: [
        'Every day, Lucas wakes up at seven o’clock. First, he washes his face and brushes his teeth. Then, he goes to the kitchen to make breakfast. He usually drinks a glass of warm orange juice and eats two eggs with toast.',
        'At seven forty-five, Lucas leaves his apartment. He walks to the bus station near the park. The bus arrives on time at eight o’clock. Lucas likes listening to calm acoustic music during his twenty-minute ride to work.',
      ],
      vocabularyItems: [
        ReadingVocabularyItem(
          word: 'apartment',
          partOfSpeech: 'n.',
          definition:
              'A set of rooms for living in, usually on one floor of a building.',
          contextSentence: 'Lucas leaves his apartment at seven forty-five.',
        ),
        ReadingVocabularyItem(
          word: 'acoustic',
          partOfSpeech: 'adj.',
          definition: 'Music produced without electric amplification.',
          contextSentence: 'Lucas likes listening to calm acoustic music.',
        ),
      ],
      questions: [
        ReadingQuestion(
          id: 'q_a1_1',
          question: 'What time does Lucas wake up?',
          type: ReadingQuestionType.multipleChoice,
          options: ['6:30', '7:00', '7:45', '8:00'],
          correctAnswer: '7:00',
          explanation:
              'The passage explicitly states that Lucas wakes up at seven o’clock every day.',
        ),
        ReadingQuestion(
          id: 'q_a1_2',
          question: 'What does Lucas eat for breakfast?',
          type: ReadingQuestionType.multipleChoice,
          options: [
            'Cereal with milk',
            'Two eggs with toast',
            'Pancakes and fruit',
            'A sandwich',
          ],
          correctAnswer: 'Two eggs with toast',
          explanation:
              'The text explains that he eats two eggs with toast and drinks orange juice.',
        ),
      ],
      tags: ['routine', 'daily-life', 'morning'],
      explanation:
          'A short descriptive text focusing on simple present routines and time expressions.',
    ),

    ReadingActivity(
      id: 'read_a1_cafe',
      title: 'A Cozy Coffee Shop in Madrid',
      level: 'A1',
      mode: ReadingMode.trueFalse,
      category: 'Travel',
      estimatedDurationMinutes: 2,
      difficulty: 'Easy',
      passage:
          'Elena has a small, quiet coffee shop on a sunny street in Madrid. The cafe has five wooden tables inside and three round tables outside on the sidewalk.\n\nEvery morning, fresh pastries arrive from a local bakery. Elena serves hot espresso, tea, and homemade lemonade. Many neighborhood students sit near the window to read books and study Spanish.',
      paragraphs: [
        'Elena has a small, quiet coffee shop on a sunny street in Madrid. The cafe has five wooden tables inside and three round tables outside on the sidewalk.',
        'Every morning, fresh pastries arrive from a local bakery. Elena serves hot espresso, tea, and homemade lemonade. Many neighborhood students sit near the window to read books and study Spanish.',
      ],
      vocabularyItems: [
        ReadingVocabularyItem(
          word: 'pastries',
          partOfSpeech: 'n.',
          definition:
              'Baked goods made of dough containing flour, butter, and sugar.',
          contextSentence:
              'Every morning, fresh pastries arrive from a local bakery.',
        ),
      ],
      questions: [
        ReadingQuestion(
          id: 'q_a1_tf_1',
          question: 'Elena’s coffee shop is located in Barcelona.',
          type: ReadingQuestionType.trueFalse,
          options: ['True', 'False'],
          correctAnswer: 'False',
          explanation:
              'The first sentence states that the coffee shop is located in Madrid, not Barcelona.',
        ),
        ReadingQuestion(
          id: 'q_a1_tf_2',
          question: 'There are tables available outside on the sidewalk.',
          type: ReadingQuestionType.trueFalse,
          options: ['True', 'False'],
          correctAnswer: 'True',
          explanation:
              'The text confirms there are three round tables outside on the sidewalk.',
        ),
      ],
      tags: ['cafe', 'food', 'places'],
      explanation:
          'Fact-checking exercise using basic spatial and descriptive vocabulary.',
    ),

    // -------------------------------------------------------------
    // LEVEL A2 - Elementary
    // -------------------------------------------------------------
    ReadingActivity(
      id: 'read_a2_mountain',
      title: 'Planning a Weekend in the Mountains',
      level: 'A2',
      mode: ReadingMode.mainIdea,
      category: 'Travel',
      estimatedDurationMinutes: 3,
      difficulty: 'Easy-Medium',
      passage:
          'When planning a hiking trip into the mountains, thorough preparation is essential for a safe experience. Before leaving, travelers should always check the updated weather forecast, as temperature and rainfall can change dramatically within an hour.\n\nIn addition to dressing in warm layers, carrying a lightweight waterproof jacket and sturdy hiking boots prevents unnecessary discomfort. Packing sufficient drinking water, high-energy snacks, and a portable battery pack guarantees peace of mind while exploring rugged wilderness trails.',
      paragraphs: [
        'When planning a hiking trip into the mountains, thorough preparation is essential for a safe experience. Before leaving, travelers should always check the updated weather forecast, as temperature and rainfall can change dramatically within an hour.',
        'In addition to dressing in warm layers, carrying a lightweight waterproof jacket and sturdy hiking boots prevents unnecessary discomfort. Packing sufficient drinking water, high-energy snacks, and a portable battery pack guarantees peace of mind while exploring rugged wilderness trails.',
      ],
      vocabularyItems: [
        ReadingVocabularyItem(
          word: 'thorough',
          partOfSpeech: 'adj.',
          definition: 'Complete with regard to every detail; exhaustive.',
          contextSentence:
              'Thorough preparation is essential for a safe experience.',
        ),
        ReadingVocabularyItem(
          word: 'sturdy',
          partOfSpeech: 'adj.',
          definition:
              'Strongly built and capable of withstanding rough conditions.',
          contextSentence:
              'Sturdy hiking boots prevent unnecessary discomfort.',
        ),
      ],
      questions: [
        ReadingQuestion(
          id: 'q_a2_mi_1',
          question: 'What is the main idea of this passage?',
          type: ReadingQuestionType.mainIdea,
          options: [
            'How to choose professional hiking boots',
            'Essential preparation steps for a safe mountain hike',
            'Why mountain weather is completely unpredictable',
            'The best locations for wilderness camping',
          ],
          correctAnswer: 'Essential preparation steps for a safe mountain hike',
          explanation:
              'Both paragraphs focus on the overall preparation necessary for a secure and comfortable mountain trip.',
        ),
      ],
      tags: ['hiking', 'outdoors', 'preparation'],
      explanation:
          'Focuses on extracting the central topic rather than isolated clothing or gear details.',
    ),

    ReadingActivity(
      id: 'read_a2_library',
      title: 'The Digital Community Library',
      level: 'A2',
      mode: ReadingMode.vocabularyInContext,
      category: 'Education',
      estimatedDurationMinutes: 3,
      difficulty: 'Easy-Medium',
      passage:
          'Over the last five years, our town’s public library has experienced a major transformation. Rather than simply keeping rows of paper encyclopedias, the facility now offers modern study spaces, high-speed wireless internet, and digital tablets for visitors.\n\nThe head librarian noticed that student attendance increased significantly after the renovation. Young learners frequently congregate in the downstairs collaboration zone to discuss group projects, exchange research notes, and practice digital presentations together.',
      paragraphs: [
        'Over the last five years, our town’s public library has experienced a major transformation. Rather than simply keeping rows of paper encyclopedias, the facility now offers modern study spaces, high-speed wireless internet, and digital tablets for visitors.',
        'The head librarian noticed that student attendance increased significantly after the renovation. Young learners frequently congregate in the downstairs collaboration zone to discuss group projects, exchange research notes, and practice digital presentations together.',
      ],
      vocabularyItems: [
        ReadingVocabularyItem(
          word: 'congregate',
          partOfSpeech: 'v.',
          definition: 'To gather together in a crowd or group.',
          contextSentence:
              'Young learners frequently congregate in the downstairs zone.',
        ),
        ReadingVocabularyItem(
          word: 'renovation',
          partOfSpeech: 'n.',
          definition:
              'The process of improving or modernizing a building or space.',
          contextSentence:
              'Attendance increased significantly after the renovation.',
        ),
      ],
      questions: [
        ReadingQuestion(
          id: 'q_a2_voc_1',
          question:
              'In the second paragraph, what does "congregate" most nearly mean?',
          type: ReadingQuestionType.vocabularyInContext,
          targetWord: 'congregate',
          options: [
            'Gather together in a group',
            'Complain loudly about rules',
            'Borrow books silently',
            'Clean and organize desks',
          ],
          correctAnswer: 'Gather together in a group',
          explanation:
              'In context, students "congregate in the collaboration zone to discuss group projects", meaning they assemble or gather together.',
        ),
        ReadingQuestion(
          id: 'q_a2_sa_1',
          question: 'Where do students practice their digital presentations?',
          type: ReadingQuestionType.shortAnswer,
          correctAnswer: 'collaboration zone',
          acceptedAnswers: [
            'the collaboration zone',
            'downstairs collaboration zone',
            'the downstairs collaboration zone',
            'collaboration area',
          ],
          explanation:
              'The passage specifies that learners gather in the downstairs collaboration zone.',
        ),
      ],
      tags: ['library', 'community', 'technology'],
      explanation:
          'Tests contextual deduction of verbs and precise short-answer retrieval.',
    ),

    // -------------------------------------------------------------
    // LEVEL B1 - Intermediate
    // -------------------------------------------------------------
    ReadingActivity(
      id: 'read_b1_remote_work',
      title: 'The Rise of Remote Work Habits',
      level: 'B1',
      mode: ReadingMode.comprehension,
      category: 'Work',
      estimatedDurationMinutes: 4,
      difficulty: 'Medium',
      passage:
          'The transition toward remote and hybrid work has fundamentally reshaped how professionals structure their workdays. For decades, the standard office model enforced fixed working hours and long daily commutes. Today, millions of employees conduct meetings, draft proposals, and collaborate with international colleagues from home workspaces.\n\nWhile remote work provides unmatched autonomy, it presents subtle psychological challenges. Without a physical commute to signal the boundary between professional duties and private life, many telecommuters struggle to disconnect in the evening. Constant notifications on mobile phones further erode personal downtime, leading to persistent fatigue.\n\nTo combat this boundary blur, occupational psychologists advise establishing deliberate transition rituals. Closing laptop screens at a consistent time, taking an evening stroll, or creating a dedicated home office room helps train the brain to transition into evening relaxation mode.',
      paragraphs: [
        'The transition toward remote and hybrid work has fundamentally reshaped how professionals structure their workdays. For decades, the standard office model enforced fixed working hours and long daily commutes. Today, millions of employees conduct meetings, draft proposals, and collaborate with international colleagues from home workspaces.',
        'While remote work provides unmatched autonomy, it presents subtle psychological challenges. Without a physical commute to signal the boundary between professional duties and private life, many telecommuters struggle to disconnect in the evening. Constant notifications on mobile phones further erode personal downtime, leading to persistent fatigue.',
        'To combat this boundary blur, occupational psychologists advise establishing deliberate transition rituals. Closing laptop screens at a consistent time, taking an evening stroll, or creating a dedicated home office room helps train the brain to transition into evening relaxation mode.',
      ],
      vocabularyItems: [
        ReadingVocabularyItem(
          word: 'autonomy',
          partOfSpeech: 'n.',
          definition:
              'The freedom to make independent decisions or self-govern.',
          contextSentence:
              'Remote work provides unmatched autonomy for employees.',
        ),
        ReadingVocabularyItem(
          word: 'erode',
          partOfSpeech: 'v.',
          definition: 'Gradually wear away or diminish over time.',
          contextSentence:
              'Constant notifications further erode personal downtime.',
        ),
        ReadingVocabularyItem(
          word: 'rituals',
          partOfSpeech: 'n.',
          definition: 'Established patterns or routines followed consistently.',
          contextSentence:
              'Psychologists advise establishing deliberate transition rituals.',
        ),
      ],
      questions: [
        ReadingQuestion(
          id: 'q_b1_1',
          question:
              'According to the author, what is a key psychological challenge of remote working?',
          type: ReadingQuestionType.multipleChoice,
          options: [
            'Inability to collaborate with global teammates',
            'Difficulty establishing clear boundaries between work and personal life',
            'Higher expenses related to computing equipment',
            'Loss of professional technical skills over time',
          ],
          correctAnswer:
              'Difficulty establishing clear boundaries between work and personal life',
          explanation:
              'The second paragraph points out that without a physical commute, workers struggle to disconnect, blurring work and private life.',
        ),
        ReadingQuestion(
          id: 'q_b1_2',
          question:
              'What do occupational psychologists recommend to prevent work fatigue?',
          type: ReadingQuestionType.multipleChoice,
          options: [
            'Working longer hours on weekends',
            'Creating intentional routines to separate work from evening relaxation',
            'Answering urgent emails late at night to reduce morning stress',
            'Switching careers every few years',
          ],
          correctAnswer:
              'Creating intentional routines to separate work from evening relaxation',
          explanation:
              'The third paragraph recommends deliberate rituals like closing laptops and walking to signal the end of the workday.',
        ),
        ReadingQuestion(
          id: 'q_b1_3',
          question:
              'Notifications on mobile phones contribute to worker fatigue by eroding downtime.',
          type: ReadingQuestionType.trueFalse,
          options: ['True', 'False'],
          correctAnswer: 'True',
          explanation:
              'Paragraph 2 directly highlights that notifications erode personal downtime, causing fatigue.',
        ),
      ],
      tags: ['remote-work', 'psychology', 'productivity'],
      explanation:
          'Examines cause-and-effect relationships and vocabulary inference in workplace contexts.',
    ),

    ReadingActivity(
      id: 'read_b1_urban_cycling',
      title: 'Urban Cycling Culture',
      level: 'B1',
      mode: ReadingMode.mainIdea,
      category: 'Environment',
      estimatedDurationMinutes: 3,
      difficulty: 'Medium',
      passage:
          'Across major European capitals, urban planners are reclaiming street space previously reserved exclusively for private automobiles. Protected cycling lanes separated by concrete curbs now connect residential neighborhoods with business centers. This infrastructure expansion has made commuting by bicycle safer and more appealing to families and elderly citizens.\n\nBeyond environmental benefits like reducing greenhouse gas emissions, widespread cycling alleviates subway overcrowding and encourages daily cardiovascular fitness. Cities that invest in comprehensive cycling networks report cleaner air, fewer traffic fatalities, and noticeably quieter downtown districts.',
      paragraphs: [
        'Across major European capitals, urban planners are reclaiming street space previously reserved exclusively for private automobiles. Protected cycling lanes separated by concrete curbs now connect residential neighborhoods with business centers. This infrastructure expansion has made commuting by bicycle safer and more appealing to families and elderly citizens.',
        'Beyond environmental benefits like reducing greenhouse gas emissions, widespread cycling alleviates subway overcrowding and encourages daily cardiovascular fitness. Cities that invest in comprehensive cycling networks report cleaner air, fewer traffic fatalities, and noticeably quieter downtown districts.',
      ],
      vocabularyItems: [
        ReadingVocabularyItem(
          word: 'alleviate',
          partOfSpeech: 'v.',
          definition: 'To make a problem or suffering less severe.',
          contextSentence: 'Widespread cycling alleviates subway overcrowding.',
        ),
        ReadingVocabularyItem(
          word: 'fatalities',
          partOfSpeech: 'n.',
          definition: 'Deaths resulting from accidents or disasters.',
          contextSentence:
              'Cities report fewer traffic fatalities with protected bike lanes.',
        ),
      ],
      questions: [
        ReadingQuestion(
          id: 'q_b1_cyc_1',
          question: 'What is the central purpose of this passage?',
          type: ReadingQuestionType.mainIdea,
          options: [
            'To criticize car manufacturers for city traffic jams',
            'To explain the multi-faceted benefits of urban cycling infrastructure',
            'To teach people how to ride bicycles in high traffic',
            'To compare the costs of subways versus cycling lanes',
          ],
          correctAnswer:
              'To explain the multi-faceted benefits of urban cycling infrastructure',
          explanation:
              'The text explores the diverse benefits of modern bike networks including safety, environmental quality, and public health.',
        ),
      ],
      tags: ['cities', 'cycling', 'sustainability'],
      explanation:
          'Focuses on synthesis of societal infrastructure improvements.',
    ),

    // -------------------------------------------------------------
    // LEVEL B2 - Upper Intermediate
    // -------------------------------------------------------------
    ReadingActivity(
      id: 'read_b2_fast_fashion',
      title: 'The Hidden Cost of Fast Fashion',
      level: 'B2',
      mode: ReadingMode.comprehension,
      category: 'Environment',
      estimatedDurationMinutes: 4,
      difficulty: 'Upper Intermediate',
      passage:
          'The globalization of garment manufacturing has democratized style, allowing consumers to purchase trendy apparel at remarkably low prices. High-street fashion retailers now produce up to twenty-four distinct micro-collections annually, condensing design cycles from months to mere weeks. Consequently, garments have transitioned from durable investments into virtually disposable goods.\n\nYet this consumer convenience masks severe ecological and socio-economic externalities. The textile sector accounts for nearly ten percent of global carbon emissions and is the second-largest consumer of the world’s freshwater reserves. Cheap synthetic fabrics like polyester shed microscopic plastic fibers during laundering, which subsequently contaminate oceanic ecosystems.\n\nIn response, grassroots sustainable apparel movements advocate for the concept of a circular fashion economy. Emphasizing timeless tailoring, garment repair workshops, and biodegradable organic textiles, these advocates encourage consumers to prioritize quality over fleeting impulse purchases.',
      paragraphs: [
        'The globalization of garment manufacturing has democratized style, allowing consumers to purchase trendy apparel at remarkably low prices. High-street fashion retailers now produce up to twenty-four distinct micro-collections annually, condensing design cycles from months to mere weeks. Consequently, garments have transitioned from durable investments into virtually disposable goods.',
        'Yet this consumer convenience masks severe ecological and socio-economic externalities. The textile sector accounts for nearly ten percent of global carbon emissions and is the second-largest consumer of the world’s freshwater reserves. Cheap synthetic fabrics like polyester shed microscopic plastic fibers during laundering, which subsequently contaminate oceanic ecosystems.',
        'In response, grassroots sustainable apparel movements advocate for the concept of a circular fashion economy. Emphasizing timeless tailoring, garment repair workshops, and biodegradable organic textiles, these advocates encourage consumers to prioritize quality over fleeting impulse purchases.',
      ],
      vocabularyItems: [
        ReadingVocabularyItem(
          word: 'democratized',
          partOfSpeech: 'v.',
          definition: 'Made accessible to everyone, not just a wealthy elite.',
          contextSentence:
              'Globalization has democratized style for average consumers.',
        ),
        ReadingVocabularyItem(
          word: 'externalities',
          partOfSpeech: 'n.',
          definition:
              'Unintended side effects of an industrial or economic activity affecting third parties.',
          contextSentence: 'Convenience masks severe ecological externalities.',
        ),
        ReadingVocabularyItem(
          word: 'fleeting',
          partOfSpeech: 'adj.',
          definition: 'Lasting for a very short duration; brief.',
          contextSentence:
              'Consumers are urged to avoid fleeting impulse purchases.',
        ),
      ],
      questions: [
        ReadingQuestion(
          id: 'q_b2_1',
          question:
              'What does the passage identify as a primary cause of clothing becoming "disposable"?',
          type: ReadingQuestionType.multipleChoice,
          options: [
            'Shortening design cycles and producing frequent low-cost micro-collections',
            'A global scarcity of natural cotton fibers',
            'Rising shipping costs in maritime transportation',
            'Stricter municipal landfill waste regulations',
          ],
          correctAnswer:
              'Shortening design cycles and producing frequent low-cost micro-collections',
          explanation:
              'Paragraph 1 explains that retailers produce up to 24 micro-collections yearly, turning clothes into disposable items.',
        ),
        ReadingQuestion(
          id: 'q_b2_2',
          question:
              'In the second paragraph, the word "externalities" refers to:',
          type: ReadingQuestionType.vocabularyInContext,
          targetWord: 'externalities',
          options: [
            'Unintended negative consequences borne by society and nature',
            'Foreign import tariffs on textiles',
            'Promotional advertising campaigns',
            'International fashion exhibitions',
          ],
          correctAnswer:
              'Unintended negative consequences borne by society and nature',
          explanation:
              'Externalities here refers to environmental degradation like carbon emissions and plastic pollution not paid for in the retail price.',
        ),
        ReadingQuestion(
          id: 'q_b2_3',
          question:
              'What fundamental shift is promoted by the circular fashion economy?',
          type: ReadingQuestionType.multipleChoice,
          options: [
            'Switching entirely to synthetic materials',
            'Prioritizing durable quality, repairability, and biodegradable textiles',
            'Banning clothing sales in physical department stores',
            'Lowering manufacturing safety regulations',
          ],
          correctAnswer:
              'Prioritizing durable quality, repairability, and biodegradable textiles',
          explanation:
              'Paragraph 3 highlights timeless tailoring, repair workshops, and biodegradable organic materials as pillars of circular fashion.',
        ),
      ],
      tags: ['sustainability', 'fashion', 'economy'],
      explanation:
          'Analysis of complex socio-economic and ecological trade-offs.',
    ),

    // -------------------------------------------------------------
    // LEVEL C1 - Advanced
    // -------------------------------------------------------------
    ReadingActivity(
      id: 'read_c1_language_acquisition',
      title: 'The Cognitive Architecture of Language Acquisition',
      level: 'C1',
      mode: ReadingMode.comprehension,
      category: 'Science',
      estimatedDurationMinutes: 5,
      difficulty: 'Advanced',
      passage:
          'For more than half a century, psycholinguists have fiercely debated whether human language proficiency is driven primarily by hardwired innate neurological substrates or by emergent statistical learning mechanisms. Generativists, drawing inspiration from Chomskyan universal grammar, contend that the poverty of the stimulus requires an innate linguistic faculty, without which infants could never master intricate recursive syntax from sparse auditory input.\n\nConversely, connectionist and usage-based cognitive paradigms postulate that the human brain operates as an exceptionally sophisticated probabilistic pattern-recognition engine. Through repeated exposure to ambient phonological patterns, toddlers construct abstract grammatical representations without presupposing specialized genetic blueprints. Neuroimaging studies reveal that multi-system neural plasticity dynamically adapts general memory and auditory circuits to decode semantic nuance.\n\nRather than viewing these schools as irreconcilable dogmas, contemporary cognitive neuroscience increasingly recognizes their complementary nature. Biology undoubtedly provides a predisposed neurological canvas, yet linguistic fluency blossoms only when situated within rich communicative interactions that activate real-time Bayesian predictive processing.',
      paragraphs: [
        'For more than half a century, psycholinguists have fiercely debated whether human language proficiency is driven primarily by hardwired innate neurological substrates or by emergent statistical learning mechanisms. Generativists, drawing inspiration from Chomskyan universal grammar, contend that the poverty of the stimulus requires an innate linguistic faculty, without which infants could never master intricate recursive syntax from sparse auditory input.',
        'Conversely, connectionist and usage-based cognitive paradigms postulate that the human brain operates as an exceptionally sophisticated probabilistic pattern-recognition engine. Through repeated exposure to ambient phonological patterns, toddlers construct abstract grammatical representations without presupposing specialized genetic blueprints. Neuroimaging studies reveal that multi-system neural plasticity dynamically adapts general memory and auditory circuits to decode semantic nuance.',
        'Rather than viewing these schools as irreconcilable dogmas, contemporary cognitive neuroscience increasingly recognizes their complementary nature. Biology undoubtedly provides a predisposed neurological canvas, yet linguistic fluency blossoms only when situated within rich communicative interactions that activate real-time Bayesian predictive processing.',
      ],
      vocabularyItems: [
        ReadingVocabularyItem(
          word: 'innate',
          partOfSpeech: 'adj.',
          definition: 'Inborn; natural rather than acquired through training.',
          contextSentence:
              'Generativists argue for innate neurological substrates.',
        ),
        ReadingVocabularyItem(
          word: 'paradigm',
          partOfSpeech: 'n.',
          definition: 'A typical example, framework, or theoretical model.',
          contextSentence:
              'Connectionist paradigms postulate probabilistic pattern-recognition.',
        ),
        ReadingVocabularyItem(
          word: 'irreconcilable',
          partOfSpeech: 'adj.',
          definition: 'Incapable of being brought into harmony or agreement.',
          contextSentence:
              'Contemporary scholars reject treating these views as irreconcilable dogmas.',
        ),
      ],
      questions: [
        ReadingQuestion(
          id: 'q_c1_1',
          question:
              'According to the generativist framework, why is an innate linguistic faculty necessary?',
          type: ReadingQuestionType.multipleChoice,
          options: [
            'Because children possess limited intellectual pattern recognition',
            'Because the auditory input children receive is too sparse to deduce complex recursive rules alone',
            'Because formal schooling begins too late in childhood',
            'Because neuroimaging cannot observe early brain plasticity',
          ],
          correctAnswer:
              'Because the auditory input children receive is too sparse to deduce complex recursive rules alone',
          explanation:
              'Paragraph 1 notes that generativists argue the "poverty of the stimulus" means input alone is insufficient without innate syntax faculties.',
        ),
        ReadingQuestion(
          id: 'q_c1_2',
          question:
              'In the final paragraph, what consensus is emerging within contemporary cognitive neuroscience?',
          type: ReadingQuestionType.multipleChoice,
          options: [
            'Chomsky’s theoretical hypotheses have been thoroughly disproven',
            'Innate biological predispositions and communicative experiential learning interact harmoniously',
            'Language learning is entirely governed by genetic predetermination',
            'Language acquisition does not utilize Bayesian predictive processing',
          ],
          correctAnswer:
              'Innate biological predispositions and communicative experiential learning interact harmoniously',
          explanation:
              'Paragraph 3 highlights that biology provides a predisposed canvas while situated communicative interaction enables fluent predictive processing.',
        ),
        ReadingQuestion(
          id: 'q_c1_3',
          question: 'What is the primary theme of the entire passage?',
          type: ReadingQuestionType.mainIdea,
          options: [
            'The historical biography of prominent 20th-century linguists',
            'The theoretical evolution and modern synthesis of how humans acquire language',
            'A technical critique of functional MRI brain scanners',
            'Guidelines for teaching second languages to adult immigrants',
          ],
          correctAnswer:
              'The theoretical evolution and modern synthesis of how humans acquire language',
          explanation:
              'The entire passage traces the debate between generativist and connectionist perspectives, concluding with a modern complementary synthesis.',
        ),
      ],
      tags: ['linguistics', 'neuroscience', 'cognition'],
      explanation: 'Rigorous academic analysis of competing cognitive models.',
    ),
  ];
}
