import '../../domain/models/writing_activity.dart';
import '../../domain/models/writing_mode.dart';

/// Preloaded offline library of authentic writing practice activities across A1–C1.
class WritingContent {
  WritingContent._();

  static const List<WritingActivity> activities = [
    // =========================================================================
    // LEVEL A1 - BEGINNER
    // =========================================================================
    WritingActivity(
      id: 'wr-a1-sb-01',
      title: 'Daily Morning Habit',
      instruction:
          'Tap words to arrange them into a correct, natural sentence.',
      level: 'A1',
      mode: WritingMode.sentenceBuilder,
      prompt: 'Arrange the words to say what someone drinks in the morning.',
      context: 'Talking about daily breakfast habits.',
      expectedAnswer: 'I usually drink coffee in the morning.',
      acceptedAnswers: [
        'In the morning I usually drink coffee.',
        'I drink coffee in the morning usually.',
      ],
      sentenceParts: [
        'morning.',
        'drink',
        'in',
        'usually',
        'I',
        'coffee',
        'the',
      ],
      hints: [
        'Start with the subject pronoun "I".',
        'Place the frequency adverb before the main verb.',
      ],
      estimatedDurationMinutes: 2,
      category: 'Daily Life',
      tags: ['habits', 'grammar', 'sentence-order'],
      difficulty: 'Beginner',
      sampleAnswer: 'I usually drink coffee in the morning.',
    ),
    WritingActivity(
      id: 'wr-a1-cs-01',
      title: 'Greeting at the Hotel',
      instruction: 'Fill in the blank with the appropriate word.',
      level: 'A1',
      mode: WritingMode.completeSentence,
      prompt:
          'Good evening! I have a ___ for a single room under the name Smith.',
      context: 'Checking in at a hotel reception desk.',
      expectedAnswer: 'reservation',
      acceptedAnswers: ['booking', 'reservation'],
      hints: ['Think of the noun used when you book a room in advance.'],
      estimatedDurationMinutes: 2,
      category: 'Travel & Hospitality',
      tags: ['travel', 'hotel', 'vocabulary'],
      difficulty: 'Beginner',
      sampleAnswer:
          'Good evening! I have a reservation for a single room under the name Smith.',
    ),
    WritingActivity(
      id: 'wr-a1-qr-01',
      title: 'Your Favorite Season',
      instruction:
          'Write 1–2 simple sentences describing the season you like best.',
      level: 'A1',
      mode: WritingMode.quickResponse,
      prompt: 'Which season do you like most, and what is one reason why?',
      minimumWords: 8,
      maximumWords: 25,
      hints: [
        'Name the season (spring, summer, autumn, winter).',
        'Mention the weather or an activity you enjoy.',
      ],
      estimatedDurationMinutes: 3,
      category: 'Personal Interests',
      tags: ['weather', 'preferences', 'daily-life'],
      difficulty: 'Beginner',
      sampleAnswer:
          'I love autumn because the weather is cool. I enjoy walking in the park.',
    ),
    WritingActivity(
      id: 'wr-a1-sw-01',
      title: 'My Typical Weekend',
      instruction:
          'Write a short paragraph describing how you spend your weekend.',
      level: 'A1',
      mode: WritingMode.shortWriting,
      prompt: 'Describe your typical Saturday and Sunday routines.',
      minimumWords: 20,
      maximumWords: 55,
      hints: [
        'Mention when you wake up.',
        'State who you spend time with or what meals you eat.',
      ],
      estimatedDurationMinutes: 4,
      category: 'Daily Life',
      tags: ['routine', 'weekend', 'paragraph'],
      difficulty: 'Beginner',
      sampleAnswer:
          'On Saturdays, I wake up late and eat breakfast with my family. In the afternoon, I clean my apartment and read books. On Sundays, I visit friends or watch movies.',
    ),

    // =========================================================================
    // LEVEL A2 - ELEMENTARY
    // =========================================================================
    WritingActivity(
      id: 'wr-a2-sb-01',
      title: 'Catching the Train',
      instruction:
          'Tap words to arrange them into a grammatically correct sentence.',
      level: 'A2',
      mode: WritingMode.sentenceBuilder,
      prompt: 'Assemble the sentence explaining why someone was late for work.',
      context: 'Explaining a commute delay to a colleague.',
      expectedAnswer:
          'Because my train was delayed, I arrived late at the office.',
      acceptedAnswers: [
        'I arrived late at the office because my train was delayed.',
        'Because my train was delayed I arrived late at the office.',
      ],
      sentenceParts: [
        'delayed,',
        'office.',
        'Because',
        'I',
        'arrived',
        'train',
        'my',
        'at',
        'was',
        'late',
        'the',
      ],
      hints: [
        'Begin with "Because" or start directly with the main clause "I arrived".',
      ],
      estimatedDurationMinutes: 2,
      category: 'Work & Commute',
      tags: ['connectors', 'past-tense', 'commute'],
      difficulty: 'Elementary',
      sampleAnswer:
          'Because my train was delayed, I arrived late at the office.',
    ),
    WritingActivity(
      id: 'wr-a2-cs-01',
      title: 'Restaurant Request',
      instruction:
          'Type the missing phrase or verb to complete the polite request.',
      level: 'A2',
      mode: WritingMode.completeSentence,
      prompt: 'Excuse me, could we please ___ the bill when you have a moment?',
      context: 'Finishing lunch at a local cafe.',
      expectedAnswer: 'have',
      acceptedAnswers: ['have', 'get', 'see'],
      hints: ['Use the standard verb for requesting a check or bill politely.'],
      estimatedDurationMinutes: 2,
      category: 'Dining & Social',
      tags: ['politeness', 'cafe', 'requests'],
      difficulty: 'Elementary',
      sampleAnswer:
          'Excuse me, could we please have the bill when you have a moment?',
    ),
    WritingActivity(
      id: 'wr-a2-qr-01',
      title: 'A Hobby You Enjoy',
      instruction:
          'Write 2–3 sentences about an activity you do in your free time.',
      level: 'A2',
      mode: WritingMode.quickResponse,
      prompt:
          'What is a hobby you enjoy, how often do you practice it, and why?',
      minimumWords: 15,
      maximumWords: 35,
      hints: [
        'Use adverbs of frequency like "twice a week" or "every evening".',
        'Express your feelings with verbs like "helps me relax".',
      ],
      estimatedDurationMinutes: 3,
      category: 'Leisure',
      tags: ['hobbies', 'free-time', 'habits'],
      difficulty: 'Elementary',
      sampleAnswer:
          'I enjoy playing the acoustic guitar. I practice three times a week after dinner. It helps me relax after a long day at work.',
    ),
    WritingActivity(
      id: 'wr-a2-gw-01',
      title: 'Rescheduling Dinner Plans',
      instruction:
          'Write a brief message to a friend rescheduling tonight’s dinner. Follow all checklist items.',
      level: 'A2',
      mode: WritingMode.guidedWriting,
      prompt:
          'You cannot meet your friend for dinner tonight. Write a polite message explaining the situation and suggesting another time.',
      minimumWords: 25,
      maximumWords: 60,
      checklist: [
        'Greet your friend warmly',
        'Apologize and state you cannot make it tonight',
        'Give a brief reason (overtime work or feeling unwell)',
        'Suggest a specific alternative day next week',
        'End with a friendly closing remark',
      ],
      hints: [
        'Keep the tone friendly and casual.',
        'Use phrases like "I am so sorry" and "How about...?"',
      ],
      estimatedDurationMinutes: 5,
      category: 'Social Messages',
      tags: ['message', 'apology', 'rescheduling'],
      difficulty: 'Elementary',
      sampleAnswer:
          'Hi Sarah, I am so sorry, but I won’t be able to make dinner tonight. I have to work late on an urgent report. How about meeting next Tuesday instead? Let me know if that works for you!',
    ),

    // =========================================================================
    // LEVEL B1 - INTERMEDIATE
    // =========================================================================
    WritingActivity(
      id: 'wr-b1-sb-01',
      title: 'Problem-Solving Strategy',
      instruction:
          'Construct a coherent, natural English sentence by ordering the phrases.',
      level: 'B1',
      mode: WritingMode.sentenceBuilder,
      prompt:
          'Arrange the segments into a logical sentence describing effective teamwork.',
      context: 'Team meeting discussion on project roadblocks.',
      expectedAnswer:
          'If we identify the problem early, we can prevent major delays in the project.',
      acceptedAnswers: [
        'We can prevent major delays in the project if we identify the problem early.',
      ],
      sentenceParts: [
        'the',
        'identify',
        'early,',
        'can',
        'If',
        'problem',
        'in',
        'we',
        'delays',
        'prevent',
        'we',
        'project.',
        'major',
      ],
      hints: [
        'Use the conditional pattern: "If + present simple, can/will + base verb".',
      ],
      estimatedDurationMinutes: 3,
      category: 'Workplace & Business',
      tags: ['conditionals', 'workplace', 'syntax'],
      difficulty: 'Intermediate',
      sampleAnswer:
          'If we identify the problem early, we can prevent major delays in the project.',
    ),
    WritingActivity(
      id: 'wr-b1-cs-01',
      title: 'Formal Email Inquiries',
      instruction:
          'Type the formal transition or collocation that fits the blank.',
      level: 'B1',
      mode: WritingMode.completeSentence,
      prompt:
          'If you have any further questions, please do not ___ to contact our team.',
      context: 'Closing paragraph of a customer support email.',
      expectedAnswer: 'hesitate',
      acceptedAnswers: ['hesitate', 'hesitate to'],
      hints: ['A standard formal idiom: "do not [verb] to contact...".'],
      estimatedDurationMinutes: 2,
      category: 'Business English',
      tags: ['formal', 'email', 'collocations'],
      difficulty: 'Intermediate',
      sampleAnswer:
          'If you have any further questions, please do not hesitate to contact our team.',
    ),
    WritingActivity(
      id: 'wr-b1-qr-01',
      title: 'Healthy Digital Habits',
      instruction:
          'Give your opinion with supporting reasoning in 2–3 clear sentences.',
      level: 'B1',
      mode: WritingMode.quickResponse,
      prompt:
          'How can people reduce their daily screen time without feeling disconnected from friends?',
      minimumWords: 25,
      maximumWords: 55,
      hints: [
        'Use linking words like "for instance", "furthermore", or "instead of".',
      ],
      estimatedDurationMinutes: 4,
      category: 'Modern Living',
      tags: ['technology', 'well-being', 'advice'],
      difficulty: 'Intermediate',
      sampleAnswer:
          'People can set specific screen-free hours during meals and before bedtime. Instead of browsing social media passively, calling a close friend for ten minutes provides much stronger personal connection with far less screen time.',
    ),
    WritingActivity(
      id: 'wr-b1-sw-01',
      title: 'The Value of Continuous Learning',
      instruction:
          'Write a well-structured paragraph developing your main idea with examples.',
      level: 'B1',
      mode: WritingMode.shortWriting,
      prompt:
          'Why is it beneficial for adults to continue acquiring new skills throughout their careers?',
      minimumWords: 45,
      maximumWords: 95,
      hints: [
        'Begin with a clear topic sentence.',
        'Provide a practical professional example, then summarize.',
      ],
      estimatedDurationMinutes: 5,
      category: 'Career & Growth',
      tags: ['career', 'education', 'paragraph-structure'],
      difficulty: 'Intermediate',
      sampleAnswer:
          'Continuous learning keeps professionals adaptable in a fast-changing job market. When employees learn new tools or languages, they become more resilient to industry disruptions and discover unexpected career opportunities. Furthermore, mastering new challenges boosts daily confidence and keeps work intellectually engaging.',
    ),
    WritingActivity(
      id: 'wr-b1-gw-01',
      title: 'Inquiry on Delayed Shipment',
      instruction:
          'Draft a polite but firm customer inquiry email following the structured checklist.',
      level: 'B1',
      mode: WritingMode.guidedWriting,
      prompt:
          'Your online order was expected three days ago, but the tracking status has not updated. Write an inquiry to customer service.',
      minimumWords: 35,
      maximumWords: 80,
      checklist: [
        'Include a formal greeting and your order reference number',
        'Explain when the package was originally promised',
        'State the current issue with the tracking information',
        'Politely request an updated delivery estimate or resolution',
        'Include a professional closing sign-off',
      ],
      hints: [
        'Maintain a professional, constructive tone.',
        'Use phrases like "I am writing to inquire regarding..."',
      ],
      estimatedDurationMinutes: 6,
      category: 'Customer Communication',
      tags: ['email', 'customer-service', 'formal'],
      difficulty: 'Intermediate',
      sampleAnswer:
          'Dear Support Team,\n\nI am writing regarding order #FL-8429, which was scheduled for delivery on September 9th. The online tracking page has not updated for three days and still shows the package as processing. Could you please provide an updated delivery timeline or investigate this shipment? Thank you for your assistance.\n\nBest regards,\nAlex Taylor',
    ),

    // =========================================================================
    // LEVEL B2 - UPPER INTERMEDIATE
    // =========================================================================
    WritingActivity(
      id: 'wr-b2-sb-01',
      title: 'Strategic Resource Allocation',
      instruction:
          'Order the clauses into a nuanced, syntactically complex sentence.',
      level: 'B2',
      mode: WritingMode.sentenceBuilder,
      prompt:
          'Assemble a sentence discussing the long-term balance between short-term profits and sustainability.',
      context: 'Corporate sustainability annual review meeting.',
      expectedAnswer:
          'Although short-term gains are appealing, investing in sustainable practices yields superior value.',
      acceptedAnswers: [
        'Investing in sustainable practices yields superior value although short-term gains are appealing.',
        'Although short-term gains are appealing investing in sustainable practices yields superior value.',
      ],
      sentenceParts: [
        'are',
        'yields',
        'practices',
        'appealing,',
        'sustainable',
        'short-term',
        'value.',
        'in',
        'superior',
        'gains',
        'investing',
        'Although',
      ],
      hints: [
        'Subordinate the concession with "Although", then present the main assertion.',
      ],
      estimatedDurationMinutes: 3,
      category: 'Business & Economics',
      tags: ['concession', 'business', 'complex-syntax'],
      difficulty: 'Upper Intermediate',
      sampleAnswer:
          'Although short-term gains are appealing, investing in sustainable practices yields superior value.',
    ),
    WritingActivity(
      id: 'wr-b2-cs-01',
      title: 'Risk Assessment Caveat',
      instruction:
          'Complete the sentence with the appropriate prepositional phrase or idiom.',
      level: 'B2',
      mode: WritingMode.completeSentence,
      prompt:
          'We must proceed with caution, taking ___ account the fluctuating market conditions.',
      context: 'Financial strategy evaluation briefing.',
      expectedAnswer: 'into',
      acceptedAnswers: ['into'],
      hints: [
        'Part of the common collocation "to take [preposition] account".',
      ],
      estimatedDurationMinutes: 2,
      category: 'Finance & Strategy',
      tags: ['collocations', 'idioms', 'prepositions'],
      difficulty: 'Upper Intermediate',
      sampleAnswer:
          'We must proceed with caution, taking into account the fluctuating market conditions.',
    ),
    WritingActivity(
      id: 'wr-b2-qr-01',
      title: 'Remote Work and Team Cohesion',
      instruction:
          'Write a balanced, focused response analyzing an organizational trade-off.',
      level: 'B2',
      mode: WritingMode.quickResponse,
      prompt:
          'What is one major advantage and one notable challenge of fully distributed remote teams?',
      minimumWords: 35,
      maximumWords: 75,
      hints: [
        'Use contrastive transitions such as "While", "Conversely", or "On the other hand".',
      ],
      estimatedDurationMinutes: 4,
      category: 'Workplace Trends',
      tags: ['remote-work', 'analysis', 'contrast'],
      difficulty: 'Upper Intermediate',
      sampleAnswer:
          'Fully distributed teams gain access to diverse international talent without geographical restrictions, significantly boosting productivity and cultural perspective. Conversely, maintaining spontaneous collaboration and team cohesion requires deliberate scheduling, which can sometimes lead to communication fatigue across disparate time zones.',
    ),
    WritingActivity(
      id: 'wr-b2-sw-01',
      title: 'Urban Density vs. Quality of Life',
      instruction:
          'Develop a persuasive perspective supporting sustainable urban planning.',
      level: 'B2',
      mode: WritingMode.shortWriting,
      prompt:
          'Does higher urban density improve or diminish overall well-being in modern metropolitan cities?',
      minimumWords: 60,
      maximumWords: 130,
      hints: [
        'Address infrastructure, public transit, and community spaces.',
        'Conclude with a synthesis rather than a simplistic either/or.',
      ],
      estimatedDurationMinutes: 6,
      category: 'Society & Urbanism',
      tags: ['urbanism', 'argumentative', 'society'],
      difficulty: 'Upper Intermediate',
      sampleAnswer:
          'Higher urban density often provokes concerns regarding overcrowding and noise pollution. However, when paired with thoughtful public infrastructure, compact neighborhoods dramatically enhance quality of life. Walkable communities with accessible mass transit diminish vehicular emissions and foster active social interaction. Rather than density itself degrading well-being, the decisive factor is whether urban planners prioritize green public spaces and equitable access to essential amenities.',
    ),
    WritingActivity(
      id: 'wr-b2-gw-01',
      title: 'Proposal for Workplace Flexibility',
      instruction:
          'Draft a concise internal proposal to your department head advocating for flexible hours.',
      level: 'B2',
      mode: WritingMode.guidedWriting,
      prompt:
          'Write a proposal recommending core working hours and flexible start times for your team.',
      minimumWords: 50,
      maximumWords: 110,
      checklist: [
        'State the objective of the proposal clearly in the opening',
        'Identify two tangible benefits for productivity or morale',
        'Address how client coverage and cross-team communication will be preserved',
        'Propose a concrete 60-day trial period with review milestones',
        'Maintain a formal, professional tone throughout',
      ],
      hints: [
        'Use objective, data-oriented terminology such as "core collaboration hours" and "measurable deliverables".',
      ],
      estimatedDurationMinutes: 7,
      category: 'Internal Proposals',
      tags: ['proposal', 'workplace', 'persuasion'],
      difficulty: 'Upper Intermediate',
      sampleAnswer:
          'Subject: Proposal: Core Collaboration Hours and Flexible Scheduling\n\nDear Marcus,\n\nI would like to propose introducing core working hours (10:00 AM to 3:00 PM) with flexible start and finish times for our department. This adjustment would accommodate varying peak productivity windows while easing commute-related stress. Seamless cross-team collaboration will remain intact, as all team meetings and client handoffs will continue inside the designated core period. To evaluate effectiveness, I suggest implementing a 60-day trial focused on sprint velocity and team feedback. I welcome your thoughts on piloting this initiative.\n\nSincerely,\nElena Rostova',
    ),

    // =========================================================================
    // LEVEL C1 - ADVANCED
    // =========================================================================
    WritingActivity(
      id: 'wr-c1-sb-01',
      title: 'Epistemic Uncertainty in Policy',
      instruction:
          'Reconstruct the sophisticated analytical statement with exact rhetorical balance.',
      level: 'C1',
      mode: WritingMode.sentenceBuilder,
      prompt:
          'Assemble the academic statement regarding the interpretation of empirical climate metrics.',
      context: 'Academic symposium on environmental modeling.',
      expectedAnswer:
          'Only by scrutinizing the underlying methodology can researchers discern meaningful correlations from statistical anomalies.',
      acceptedAnswers: [
        'Researchers can discern meaningful correlations from statistical anomalies only by scrutinizing the underlying methodology.',
      ],
      sentenceParts: [
        'the',
        'scrutinizing',
        'researchers',
        'correlations',
        'anomalies.',
        'methodology',
        'from',
        'statistical',
        'can',
        'Only',
        'discern',
        'meaningful',
        'by',
        'underlying',
      ],
      hints: [
        'Apply negative/limiting inversion following the introductory "Only by...".',
      ],
      estimatedDurationMinutes: 3,
      category: 'Academic & Analysis',
      tags: ['inversion', 'advanced-syntax', 'academic'],
      difficulty: 'Advanced',
      sampleAnswer:
          'Only by scrutinizing the underlying methodology can researchers discern meaningful correlations from statistical anomalies.',
    ),
    WritingActivity(
      id: 'wr-c1-cs-01',
      title: 'Nuanced Qualification',
      instruction:
          'Insert the precise formal verb or idiom that establishes critical qualification.',
      level: 'C1',
      mode: WritingMode.completeSentence,
      prompt:
          'While the initial findings appear promising, they should be taken with a ___ of salt until peer-reviewed.',
      context: 'Editorial commentary on preliminary pharmacological trials.',
      expectedAnswer: 'grain',
      acceptedAnswers: ['grain', 'pinch'],
      hints: ['A ubiquitous idiomatic expression denoting healthy skepticism.'],
      estimatedDurationMinutes: 2,
      category: 'Critical Thinking',
      tags: ['idioms', 'advanced', 'academic'],
      difficulty: 'Advanced',
      sampleAnswer:
          'While the initial findings appear promising, they should be taken with a grain of salt until peer-reviewed.',
    ),
    WritingActivity(
      id: 'wr-c1-qr-01',
      title: 'Automation and Cognitive Labor',
      instruction:
          'Articulate an incisive analytical synthesis in 2–3 sentences with precise diction.',
      level: 'C1',
      mode: WritingMode.quickResponse,
      prompt:
          'As algorithmic tools automate cognitive tasks, what uniquely human faculty will become most indispensable in leadership?',
      minimumWords: 40,
      maximumWords: 85,
      hints: [
        'Incorporate concepts like contextual discernment, ethical arbitration, or empathetic synthesis.',
      ],
      estimatedDurationMinutes: 5,
      category: 'Technology & Philosophy',
      tags: ['automation', 'leadership', 'advanced-writing'],
      difficulty: 'Advanced',
      sampleAnswer:
          'As artificial intelligence streamlines quantitative computation and synthesized data retrieval, nuanced contextual judgment and ethical stewardship become the preeminent leadership faculties. Algorithms can optimize within established parameters, but framing ambiguous dilemmas and aligning diverse human motivations require deep empathy and moral deliberation that remain fundamentally irreducible to predictive models.',
    ),
    WritingActivity(
      id: 'wr-c1-sw-01',
      title: 'The Paradox of Ubiquitous Connectivity',
      instruction:
          'Craft a tightly argued expository paragraph with elevated vocabulary and cohesive cohesion.',
      level: 'C1',
      mode: WritingMode.shortWriting,
      prompt:
          'Analyze how hyper-connected communication ecosystems simultaneously broaden access and attenuate deep contemplation.',
      minimumWords: 75,
      maximumWords: 160,
      hints: [
        'Explore cognitive fragmentation, the tension between breadth and depth, and deliberate boundary-setting.',
      ],
      estimatedDurationMinutes: 7,
      category: 'Cultural Commentary',
      tags: ['critical-analysis', 'technology', 'essay-style'],
      difficulty: 'Advanced',
      sampleAnswer:
          'The democratization of real-time communication has undeniably dissolved geographic barriers, granting unprecedented access to global discourse. Yet this pervasive connectivity fosters a cognitive fragmentation that imperils sustained contemplative thought. When the mind is perpetually primed for intermittent interruptions and algorithmically curated stimuli, the capacity for deliberate synthesis and nuanced appraisal deteriorates. Consequently, the contemporary intellectual challenge is not merely acquiring knowledge, but fiercely defending the psychological margins necessary to distill substantive wisdom from relentless digital static.',
    ),
    WritingActivity(
      id: 'wr-c1-gw-01',
      title: 'Executive Briefing: Organizational Restructuring',
      instruction:
          'Author a high-stakes executive memo synthesizing strategic reallocation with stakeholder sensitivity.',
      level: 'C1',
      mode: WritingMode.guidedWriting,
      prompt:
          'Draft an executive briefing outlining a strategic transition toward cross-functional agile units.',
      minimumWords: 70,
      maximumWords: 150,
      checklist: [
        'State the strategic imperative and intended commercial objective succinctly',
        'Outline two structural adjustments to operational workflows',
        'Articulate proactive risk mitigations regarding team morale or workflow friction',
        'Delineate immediate next steps with explicit accountability',
        'Employ sophisticated executive diction and authoritative clarity',
      ],
      hints: [
        'Use succinct headings or bulleted structures if appropriate.',
        'Emphasize strategic alignment and governance.',
      ],
      estimatedDurationMinutes: 8,
      category: 'Executive Communications',
      tags: ['executive-memo', 'strategy', 'leadership'],
      difficulty: 'Advanced',
      sampleAnswer:
          'MEMORANDUM: Strategic Operational Alignment\n\nContext: To accelerate product delivery and dismantle functional silos, our engineering and commercial divisions will transition into cross-functional agile pods effective Q4.\n\nStructural Realignment:\n1. Autonomous Pod Architecture: Each unit will embed dedicated product design, engineering, and quality assurance personnel, eliminating bureaucratic handoff bottlenecks.\n2. Decentralized Governance: Team leads will hold localized decision-making authority for feature roadmaps within calibrated budgetary constraints.\n\nRisk Mitigation: To alleviate initial operational friction, dedicated transition coaches will facilitate bi-weekly retrospectives during the maiden sprint cycle.\n\nNext Steps: Division leaders must submit their proposed roster compositions to the steering committee by Friday, September 19th.',
    ),
  ];
}
