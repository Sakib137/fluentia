import '../../domain/models/practice_models.dart';

/// Bundled local offline content dataset for Fluentia practice activities.
class BundledPracticeContent {
  BundledPracticeContent._();

  static final List<PracticeActivity> allActivities = [
    // ==========================================
    // SPEAKING ACTIVITIES
    // ==========================================
    const PracticeActivity(
      id: 'spk_a1_01',
      skill: PracticeSkill.speaking,
      type: PracticeActivityType.speakingPrompt,
      title: 'Daily Routine Overview',
      instruction:
          'Speak for 30 seconds describing what you usually do in the morning.',
      level: 'A1',
      estimatedDurationMinutes: 2,
      difficulty: 'Beginner',
      content: {
        'prompt': 'Describe your typical morning routine.',
        'starter': 'Every morning, I wake up at...',
        'keyPhrases': [
          'wake up',
          'have breakfast',
          'get ready',
          'leave for work',
        ],
      },
      metadata: {'tag': 'Everyday Life', 'minSeconds': 20},
    ),
    const PracticeActivity(
      id: 'spk_b1_01',
      skill: PracticeSkill.speaking,
      type: PracticeActivityType.speakingPrompt,
      title: 'Workplace Project Update',
      instruction:
          'Deliver a concise 1-minute verbal update on an ongoing project at work.',
      level: 'B1',
      estimatedDurationMinutes: 2,
      difficulty: 'Intermediate',
      content: {
        'prompt':
            'Explain the current status, key milestone achieved, and the next steps.',
        'starter': 'In our current sprint, we successfully finalized...',
        'keyPhrases': [
          'milestone achieved',
          'next priority',
          'on schedule',
          'collaborating with',
        ],
      },
      metadata: {'tag': 'Career & Business', 'minSeconds': 45},
    ),
    const PracticeActivity(
      id: 'spk_b2_01',
      skill: PracticeSkill.speaking,
      type: PracticeActivityType.speakingPrompt,
      title: 'Debating Remote Collaboration',
      instruction:
          'State your perspective on remote vs. in-person work, defending your viewpoint.',
      level: 'B2',
      estimatedDurationMinutes: 3,
      difficulty: 'Upper Intermediate',
      content: {
        'prompt':
            'Discuss the trade-offs between remote flexibility and spontaneous in-office collaboration.',
        'starter':
            'While remote setups boost individual autonomy, one drawback is...',
        'keyPhrases': [
          'on the one hand',
          'conversely',
          'durable advantage',
          'foster cohesion',
        ],
      },
      metadata: {'tag': 'Opinion & Debate', 'minSeconds': 60},
    ),

    // ==========================================
    // LISTENING ACTIVITIES
    // ==========================================
    const PracticeActivity(
      id: 'lis_a1_01',
      skill: PracticeSkill.listening,
      type: PracticeActivityType.listenAndChoose,
      title: 'Coffee Shop Order',
      instruction:
          'Listen to the customer ordering drinks and select the correct option.',
      level: 'A1',
      estimatedDurationMinutes: 2,
      difficulty: 'Beginner',
      content: {
        'audioScript':
            'Hello! Can I please get one iced oat latte and two blueberry muffins to go?',
        'options': [
          '1 latte and 2 muffins',
          '2 lattes and 1 muffin',
          '1 black coffee and 2 bagels',
        ],
        'correctIndex': 0,
      },
      metadata: {'tag': 'Everyday Conversation'},
    ),
    const PracticeActivity(
      id: 'lis_b1_01',
      skill: PracticeSkill.listening,
      type: PracticeActivityType.dictation,
      title: 'Airport Gate Announcement',
      instruction:
          'Listen carefully to the gate change announcement and note down the flight details.',
      level: 'B1',
      estimatedDurationMinutes: 2,
      difficulty: 'Intermediate',
      content: {
        'audioScript':
            'Attention passengers on Flight 412 to Chicago. The departure gate has changed to B18.',
        'targetText': 'Flight 412 to Chicago gate B18',
      },
      metadata: {'tag': 'Travel & Transit'},
    ),
    const PracticeActivity(
      id: 'lis_b2_01',
      skill: PracticeSkill.listening,
      type: PracticeActivityType.listenAndChoose,
      title: 'Quarterly Executive Summary',
      instruction:
          'Listen to the company briefing and identify the primary growth driver.',
      level: 'B2',
      estimatedDurationMinutes: 3,
      difficulty: 'Upper Intermediate',
      content: {
        'audioScript':
            'Our expansion into European regional logistics drove an eighteen percent revenue uplift despite broader market headwinds.',
        'options': [
          'Domestic consumer discounts',
          'European regional logistics expansion',
          'Manufacturing downsizing',
        ],
        'correctIndex': 1,
      },
      metadata: {'tag': 'Business Analysis'},
    ),

    // ==========================================
    // READING ACTIVITIES
    // ==========================================
    const PracticeActivity(
      id: 'read_a1_01',
      skill: PracticeSkill.reading,
      type: PracticeActivityType.readingComprehension,
      title: 'Weekend Farmers Market',
      instruction:
          'Read the short event notice and answer the schedule question.',
      level: 'A1',
      estimatedDurationMinutes: 2,
      difficulty: 'Beginner',
      content: {
        'passage':
            'The City Farmers Market is open every Saturday from 8:00 AM to 1:00 PM in Central Park. Fresh vegetables, handmade cheese, and warm bakery goods are available.',
        'question': 'When does the market close?',
        'options': ['12:00 PM', '1:00 PM', '5:00 PM'],
        'correctIndex': 1,
      },
      metadata: {'tag': 'Community'},
    ),
    const PracticeActivity(
      id: 'read_b1_01',
      skill: PracticeSkill.reading,
      type: PracticeActivityType.readingComprehension,
      title: 'Sustainable Urban Transit',
      instruction:
          'Read the editorial passage on bicycle transit infrastructure.',
      level: 'B1',
      estimatedDurationMinutes: 2,
      difficulty: 'Intermediate',
      content: {
        'passage':
            'Protected bicycle lanes not only decrease municipal carbon emissions but also significantly reduce pedestrian collision rates by separating distinct transit velocities.',
        'question':
            'What secondary benefit does the passage mention besides lower emissions?',
        'options': [
          'Lower bike manufacturing costs',
          'Fewer pedestrian collisions due to separated transit speeds',
          'Faster subway trains',
        ],
        'correctIndex': 1,
      },
      metadata: {'tag': 'Urban Planning'},
    ),
    const PracticeActivity(
      id: 'read_b2_01',
      skill: PracticeSkill.reading,
      type: PracticeActivityType.readingComprehension,
      title: 'Cognitive Science of Habits',
      instruction:
          'Read the scientific summary and deduce the primary role of contextual cues.',
      level: 'B2',
      estimatedDurationMinutes: 3,
      difficulty: 'Upper Intermediate',
      content: {
        'passage':
            'Automatic behavioural routines are fundamentally reinforced through stable situational anchors rather than sheer willpower. When environmental cues shift, habit loops rapidly dissipate.',
        'question':
            'According to the passage, what primarily sustains habit loops?',
        'options': [
          'Sheer conscious willpower',
          'Stable environmental situational anchors',
          'High reward frequency alone',
        ],
        'correctIndex': 1,
      },
      metadata: {'tag': 'Psychology'},
    ),

    // ==========================================
    // WRITING ACTIVITIES
    // ==========================================
    const PracticeActivity(
      id: 'wrt_a1_01',
      skill: PracticeSkill.writing,
      type: PracticeActivityType.sentenceWriting,
      title: 'Inviting a Friend to Lunch',
      instruction:
          'Write a simple 2-sentence invitation to a friend for lunch this weekend.',
      level: 'A1',
      estimatedDurationMinutes: 2,
      difficulty: 'Beginner',
      content: {
        'prompt': 'Invite Sarah to eat pizza on Saturday afternoon at 1 PM.',
        'targetWords': ['lunch', 'Saturday', 'pizza', 'free'],
      },
      metadata: {'tag': 'Social Writing'},
    ),
    const PracticeActivity(
      id: 'wrt_b1_01',
      skill: PracticeSkill.writing,
      type: PracticeActivityType.sentenceWriting,
      title: 'Meeting Reschedule Request',
      instruction:
          'Write a polite, professional message requesting to postpone a 2 PM sync.',
      level: 'B1',
      estimatedDurationMinutes: 2,
      difficulty: 'Intermediate',
      content: {
        'prompt':
            'Apologize for an urgent conflict and propose moving tomorrow’s 2 PM sync to 4:30 PM.',
        'keyPhrases': [
          'unforeseen conflict',
          'apologies for the short notice',
          'reschedule to',
          'does that time suit you',
        ],
      },
      metadata: {'tag': 'Professional Correspondence'},
    ),
    const PracticeActivity(
      id: 'wrt_b2_01',
      skill: PracticeSkill.writing,
      type: PracticeActivityType.shortWriting,
      title: 'Constructive Feature Feedback',
      instruction:
          'Draft a short 3-4 sentence appraisal of a mobile app, balancing praise with a suggestion.',
      level: 'B2',
      estimatedDurationMinutes: 3,
      difficulty: 'Upper Intermediate',
      content: {
        'prompt':
            'Praise the clean interface and suggest adding offline export functionality.',
        'keyPhrases': [
          'particularly appreciate',
          'one constructive suggestion',
          'enhance the experience',
          'in future releases',
        ],
      },
      metadata: {'tag': 'Review & Critique'},
    ),
  ];
}
