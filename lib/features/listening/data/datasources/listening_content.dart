import '../../domain/models/comprehension_question.dart';
import '../../domain/models/listening_activity.dart';
import '../../domain/models/listening_mode.dart';

/// Bundled, structured repository of production-quality listening drills
/// mapped across CEFR levels A1, A2, B1, B2, and C1.
class ListeningContent {
  ListeningContent._();

  static const List<ListeningActivity> activities = [
    // ==========================================
    // A1 - BEGINNER (Short everyday phrases & slow sentence structures)
    // ==========================================
    ListeningActivity(
      id: 'listening_a1_lac_01',
      title: 'Morning Alarm & Breakfast',
      instruction:
          'Listen carefully and identify what time the speaker wakes up.',
      level: 'A1',
      mode: ListeningMode.listenAndChoose,
      audioAsset: 'assets/audio/listening/a1/a1_daily_routine.wav',
      transcript:
          'Good morning. I usually wake up at seven o\'clock in the morning. Then I drink a warm cup of black tea and eat some toast.',
      question: 'What time does the speaker wake up?',
      options: [
        'At six o\'clock',
        'At seven o\'clock',
        'At eight o\'clock',
        'At nine o\'clock',
      ],
      correctAnswer: 'At seven o\'clock',
      explanation:
          'The speaker clearly states: "I usually wake up at seven o\'clock in the morning."',
      estimatedDurationMinutes: 2,
      category: 'Daily Routine',
      tags: ['A1', 'Time', 'Morning', 'Routine'],
    ),
    ListeningActivity(
      id: 'listening_a1_tf_01',
      title: 'Weekend Meeting',
      instruction:
          'Listen to the message and decide whether the statement is True or False.',
      level: 'A1',
      mode: ListeningMode.trueFalse,
      audioAsset: 'assets/audio/listening/a1/a1_meeting_friend.wav',
      transcript:
          'Hello David! Let us meet tomorrow afternoon at the central cafe near the library. Please bring your English textbook with you.',
      question: 'Statement: The speaker wants to meet at the cinema.',
      options: ['True', 'False'],
      correctAnswer: 'False',
      explanation:
          'The speaker specifically suggests meeting "at the central cafe near the library", not at the cinema.',
      estimatedDurationMinutes: 2,
      category: 'Social Plans',
      tags: ['A1', 'Plans', 'Locations'],
    ),
    ListeningActivity(
      id: 'listening_a1_fill_01',
      title: 'Daily Habits',
      instruction:
          'Listen to the sentence and fill in the missing word in the blank.',
      level: 'A1',
      mode: ListeningMode.fillMissingWords,
      audioAsset: 'assets/audio/listening/a1/a1_daily_routine.wav',
      transcript:
          'I drink a warm cup of black tea and eat toast every morning.',
      question: 'I drink a warm cup of black ___ and eat toast every morning.',
      missingWords: ['tea'],
      acceptedAnswers: ['tea'],
      correctAnswer: 'tea',
      explanation:
          'The speaker explicitly mentions drinking "a warm cup of black tea".',
      estimatedDurationMinutes: 2,
      category: 'Food & Drink',
      tags: ['A1', 'Vocabulary', 'Drink'],
    ),

    // ==========================================
    // A2 - ELEMENTARY (Daily activities & short natural dialogues)
    // ==========================================
    ListeningActivity(
      id: 'listening_a2_dict_01',
      title: 'Library Study Session',
      instruction:
          'Listen to the audio and type exactly what you hear. Punctuation is optional.',
      level: 'A2',
      mode: ListeningMode.dictation,
      audioAsset: 'assets/audio/listening/a2/a2_weekend_plans.wav',
      transcript: 'I usually go to the library after class.',
      question: 'Type the exact sentence you heard:',
      correctAnswer: 'I usually go to the library after class.',
      acceptedAnswers: [
        'i usually go to the library after class',
        'I usually go to the library after class.',
      ],
      explanation:
          'Expected sentence: "I usually go to the library after class."',
      estimatedDurationMinutes: 3,
      category: 'Campus Life',
      tags: ['A2', 'Dictation', 'Routine', 'School'],
    ),
    ListeningActivity(
      id: 'listening_a2_lac_01',
      title: 'Grocery Store Dilemma',
      instruction:
          'Listen to the supermarket inquiry and choose what item the customer needs.',
      level: 'A2',
      mode: ListeningMode.listenAndChoose,
      audioAsset: 'assets/audio/listening/a2/a2_grocery_shopping.wav',
      transcript:
          'Excuse me, where can I find organic olive oil? I looked in aisle four next to the pasta sauces, but the shelf was empty.',
      question: 'What product is the customer looking for?',
      options: [
        'Pasta sauce',
        'Organic olive oil',
        'Fresh vegetables',
        'Whole wheat bread',
      ],
      correctAnswer: 'Organic olive oil',
      explanation:
          'The customer asks directly: "Excuse me, where can I find organic olive oil?"',
      estimatedDurationMinutes: 3,
      category: 'Shopping',
      tags: ['A2', 'Groceries', 'Questions'],
    ),
    ListeningActivity(
      id: 'listening_a2_fill_01',
      title: 'Supermarket Aisle',
      instruction:
          'Listen to the customer request and fill in the missing word.',
      level: 'A2',
      mode: ListeningMode.fillMissingWords,
      audioAsset: 'assets/audio/listening/a2/a2_grocery_shopping.wav',
      transcript:
          'I looked in aisle four next to the pasta sauces, but the shelf was empty.',
      question:
          'I looked in aisle four next to the pasta sauces, but the ___ was empty.',
      missingWords: ['shelf'],
      acceptedAnswers: ['shelf'],
      correctAnswer: 'shelf',
      explanation: 'The customer remarks that "the shelf was empty".',
      estimatedDurationMinutes: 2,
      category: 'Shopping',
      tags: ['A2', 'Vocabulary', 'Retail'],
    ),

    // ==========================================
    // B1 - INTERMEDIATE (Conversations, workplace & travel explanations)
    // ==========================================
    ListeningActivity(
      id: 'listening_b1_lac_01',
      title: 'Airport Gate Announcement',
      instruction:
          'Listen to the public gate announcement and determine the passenger action.',
      level: 'B1',
      mode: ListeningMode.listenAndChoose,
      audioAsset: 'assets/audio/listening/b1/b1_airport_announcement.wav',
      transcript:
          'Attention all passengers traveling on flight BA 249 to Amsterdam. Due to technical maintenance on the tarmac, boarding will now commence at Gate B12 instead of Gate B4. Please have your boarding passes and passports ready for priority boarding.',
      question: 'What change has occurred according to the announcement?',
      options: [
        'The flight has been canceled completely',
        'Boarding has moved to Gate B12',
        'Passengers must rebook their tickets at check-in',
        'The destination has changed to Brussels',
      ],
      correctAnswer: 'Boarding has moved to Gate B12',
      explanation:
          'The announcement notes: "boarding will now commence at Gate B12 instead of Gate B4."',
      estimatedDurationMinutes: 3,
      category: 'Travel & Transit',
      tags: ['B1', 'Airport', 'Announcements'],
    ),
    ListeningActivity(
      id: 'listening_b1_tf_01',
      title: 'Job Interview Follow-Up',
      instruction:
          'Listen to the hiring manager and determine if the statement is True or False.',
      level: 'B1',
      mode: ListeningMode.trueFalse,
      audioAsset: 'assets/audio/listening/b1/b1_job_interview.wav',
      transcript:
          'Thank you for coming in today, Sarah. We were very impressed by your practical design portfolio and team leadership experience. Our human resources department will send a formal offer letter by Friday afternoon.',
      question:
          'Statement: The company decided not to move forward with the candidate.',
      options: ['True', 'False'],
      correctAnswer: 'False',
      explanation:
          'The statement is False. The speaker says "Our human resources department will send a formal offer letter by Friday afternoon."',
      estimatedDurationMinutes: 3,
      category: 'Professional Careers',
      tags: ['B1', 'Workplace', 'Interview'],
    ),
    ListeningActivity(
      id: 'listening_b1_comp_01',
      title: 'Airport Operations & Travel Details',
      instruction:
          'Listen to the full transit announcement and answer the comprehension questions.',
      level: 'B1',
      mode: ListeningMode.comprehension,
      audioAsset: 'assets/audio/listening/b1/b1_airport_announcement.wav',
      transcript:
          'Attention all passengers traveling on flight BA 249 to Amsterdam. Due to technical maintenance on the tarmac, boarding will now commence at Gate B12 instead of Gate B4. Please have your boarding passes and passports ready for priority boarding. First class and business travelers may proceed first.',
      comprehensionQuestions: [
        ComprehensionQuestion(
          id: 'b1_comp_q1',
          question: 'What caused the gate change?',
          options: [
            'Severe weather thunderstorm',
            'Technical maintenance on the tarmac',
            'Pilot scheduling conflict',
            'Missing security documents',
          ],
          correctAnswer: 'Technical maintenance on the tarmac',
          explanation:
              'The announcer explicitly says: "Due to technical maintenance on the tarmac..."',
        ),
        ComprehensionQuestion(
          id: 'b1_comp_q2',
          question: 'Which passengers are invited to board first?',
          options: [
            'Passengers traveling with small pets',
            'First class and business travelers',
            'Economy window seat passengers',
            'Passengers who checked more than two bags',
          ],
          correctAnswer: 'First class and business travelers',
          explanation:
              'The broadcast states: "First class and business travelers may proceed first."',
        ),
      ],
      estimatedDurationMinutes: 4,
      category: 'Travel & Transit',
      tags: ['B1', 'Comprehension', 'Transit'],
    ),

    // ==========================================
    // B2 - UPPER INTERMEDIATE (Complex workplace dialogues & opinions)
    // ==========================================
    ListeningActivity(
      id: 'listening_b2_dict_01',
      title: 'Product Roadmap Alignment',
      instruction:
          'Transcribe the project manager\'s directive verbatim into the text field.',
      level: 'B2',
      mode: ListeningMode.dictation,
      audioAsset: 'assets/audio/listening/b2/b2_team_meeting.wav',
      transcript:
          'We need to prioritize customer feedback before finalizing the quarterly release.',
      question: 'Type the exact statement you heard:',
      correctAnswer:
          'We need to prioritize customer feedback before finalizing the quarterly release.',
      acceptedAnswers: [
        'we need to prioritize customer feedback before finalizing the quarterly release',
        'We need to prioritize customer feedback before finalizing the quarterly release.',
      ],
      explanation:
          'Sentence: "We need to prioritize customer feedback before finalizing the quarterly release."',
      estimatedDurationMinutes: 4,
      category: 'Product Strategy',
      tags: ['B2', 'Dictation', 'Business', 'Strategy'],
    ),
    ListeningActivity(
      id: 'listening_b2_tf_01',
      title: 'Tech Architecture Review',
      instruction:
          'Listen to the technical architect\'s remarks and evaluate the statement.',
      level: 'B2',
      mode: ListeningMode.trueFalse,
      audioAsset: 'assets/audio/listening/b2/b2_tech_presentation.wav',
      transcript:
          'Although migrating directly to microservices offers granular scalability, our current infrastructure will experience significant operational overhead. Therefore, I strongly advocate for a modular monolith during this transitional fiscal year.',
      question:
          'Statement: The architect recommends an immediate total transition to microservices.',
      options: ['True', 'False'],
      correctAnswer: 'False',
      explanation:
          'The statement is False. The speaker advocates for "a modular monolith during this transitional fiscal year" to prevent operational overhead.',
      estimatedDurationMinutes: 3,
      category: 'Software Engineering',
      tags: ['B2', 'Architecture', 'Engineering'],
    ),
    ListeningActivity(
      id: 'listening_b2_lac_01',
      title: 'Quarterly Strategic Decisions',
      instruction:
          'Listen to the engineering director and identify the strategic recommendation.',
      level: 'B2',
      mode: ListeningMode.listenAndChoose,
      audioAsset: 'assets/audio/listening/b2/b2_tech_presentation.wav',
      transcript:
          'Although migrating directly to microservices offers granular scalability, our current infrastructure will experience significant operational overhead. Therefore, I strongly advocate for a modular monolith during this transitional fiscal year.',
      question: 'What architectural approach is strongly advocated?',
      options: [
        'Immediate distributed microservices',
        'A modular monolith for the transitional year',
        'Outsourcing legacy database operations',
        'Freezing all software releases indefinitely',
      ],
      correctAnswer: 'A modular monolith for the transitional year',
      explanation:
          'The speaker concludes: "Therefore, I strongly advocate for a modular monolith during this transitional fiscal year."',
      estimatedDurationMinutes: 3,
      category: 'Technology',
      tags: ['B2', 'Architecture', 'Decision'],
    ),

    // ==========================================
    // C1 - ADVANCED (Nuanced academic discourse & abstract topics)
    // ==========================================
    ListeningActivity(
      id: 'listening_c1_comp_01',
      title: 'Renewable Transition & Economic Decentralization',
      instruction:
          'Listen to the academic lecture excerpt and answer the analytical questions.',
      level: 'C1',
      mode: ListeningMode.comprehension,
      audioAsset: 'assets/audio/listening/c1/c1_climate_lecture.wav',
      transcript:
          'The transition toward renewable energy cannot merely be viewed through the narrow prism of technological substitution. Rather, it necessitates a fundamental restructuring of geopolitical relations and localized economic empowerment. As decentralized microgrids proliferated across rural provinces, municipal governance experienced unprecedented autonomy from centralized energy conglomerates.',
      comprehensionQuestions: [
        ComprehensionQuestion(
          id: 'c1_comp_q1',
          question:
              'According to the lecturer, what fundamental error occurs in standard energy discussions?',
          options: [
            'Underestimating the cost of photovoltaic materials',
            'Viewing the transition merely as technological substitution',
            'Ignoring the role of fossil fuel subsidies',
            'Overstating the efficiency of wind turbine generators',
          ],
          correctAnswer:
              'Viewing the transition merely as technological substitution',
          explanation:
              'The lecturer emphasizes that the transition "cannot merely be viewed through the narrow prism of technological substitution."',
        ),
        ComprehensionQuestion(
          id: 'c1_comp_q2',
          question:
              'What consequence followed the proliferation of decentralized microgrids?',
          options: [
            'Municipalities achieved greater autonomy from centralized energy conglomerates',
            'Industrial output dropped across agricultural regions',
            'Consumer electricity costs surged uncontrollably',
            'Centralized power grids consolidated monopoly pricing',
          ],
          correctAnswer:
              'Municipalities achieved greater autonomy from centralized energy conglomerates',
          explanation:
              'The lecturer states that municipal governance experienced "unprecedented autonomy from centralized energy conglomerates."',
        ),
      ],
      estimatedDurationMinutes: 5,
      category: 'Economics & Ecology',
      tags: ['C1', 'Lecture', 'Economics', 'Autonomy'],
    ),
    ListeningActivity(
      id: 'listening_c1_dict_01',
      title: 'Geopolitical Restructuring',
      instruction:
          'Transcribe this complex academic assertion with high typographical accuracy.',
      level: 'C1',
      mode: ListeningMode.dictation,
      audioAsset: 'assets/audio/listening/c1/c1_economic_analysis.wav',
      transcript:
          'Decentralized microgrids provide unprecedented autonomy to regional communities.',
      question: 'Type the exact statement you heard:',
      correctAnswer:
          'Decentralized microgrids provide unprecedented autonomy to regional communities.',
      acceptedAnswers: [
        'decentralized microgrids provide unprecedented autonomy to regional communities',
        'Decentralized microgrids provide unprecedented autonomy to regional communities.',
      ],
      explanation:
          'Sentence: "Decentralized microgrids provide unprecedented autonomy to regional communities."',
      estimatedDurationMinutes: 4,
      category: 'Socioeconomics',
      tags: ['C1', 'Dictation', 'Academic', 'Vocabulary'],
    ),
    ListeningActivity(
      id: 'listening_c1_lac_01',
      title: 'Fiscal Policy Nuances',
      instruction:
          'Listen to the macroeconomic analysis and identify the underlying perspective.',
      level: 'C1',
      mode: ListeningMode.listenAndChoose,
      audioAsset: 'assets/audio/listening/c1/c1_economic_analysis.wav',
      transcript:
          'Decentralized microgrids provide unprecedented autonomy to regional communities, fundamentally altering fiscal bargaining power against traditional utility monopolies.',
      question:
          'What fundamental shift does the speaker highlight regarding regional communities?',
      options: [
        'An increase in reliance on public welfare packages',
        'Altered fiscal bargaining power against traditional monopolies',
        'Compulsory relocation to urban business districts',
        'A total abandonment of commercial grid connectivity',
      ],
      correctAnswer:
          'Altered fiscal bargaining power against traditional monopolies',
      explanation:
          'The speaker explicitly highlights "fundamentally altering fiscal bargaining power against traditional utility monopolies."',
      estimatedDurationMinutes: 3,
      category: 'Macroeconomics',
      tags: ['C1', 'Analysis', 'Finance'],
    ),
  ];
}
