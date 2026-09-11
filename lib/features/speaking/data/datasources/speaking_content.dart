import '../../domain/models/speaking_activity.dart';
import '../../domain/models/speaking_mode.dart';

/// Bundled local offline content dataset for Fluentia Speaking Lab.
class SpeakingContent {
  SpeakingContent._();

  static const List<SpeakingActivity> activities = [
    // ==========================================
    // 1. READ ALOUD ACTIVITIES (Pronunciation & Oral Flow)
    // ==========================================
    SpeakingActivity(
      id: 'spk_read_a1_01',
      title: 'Daily Progress',
      prompt: 'Read this sentence aloud clearly:',
      instruction:
          'Read the sentence at a natural pace. Focus on pronouncing each word distinctly.',
      level: 'A1',
      estimatedDurationMinutes: 2,
      preparationSeconds: 8,
      speakingSeconds: 30,
      mode: SpeakingMode.readAloud,
      expectedText: 'Learning a little every day can make a big difference.',
      category: 'Everyday Life',
      tags: ['Daily Habits', 'Foundations'],
    ),
    SpeakingActivity(
      id: 'spk_read_a2_01',
      title: 'Morning Routine',
      prompt: 'Read this sentence aloud clearly:',
      instruction: 'Pay attention to the rhythm and pauses between thoughts.',
      level: 'A2',
      estimatedDurationMinutes: 2,
      preparationSeconds: 8,
      speakingSeconds: 30,
      mode: SpeakingMode.readAloud,
      expectedText:
          'I usually drink coffee in the morning and tea in the afternoon.',
      category: 'Lifestyle',
      tags: ['Routines', 'Food & Drink'],
    ),
    SpeakingActivity(
      id: 'spk_read_b1_01',
      title: 'Speaking Confidence',
      prompt: 'Read this sentence aloud clearly:',
      instruction:
          'Focus on connecting the words smoothly without hesitations.',
      level: 'B1',
      estimatedDurationMinutes: 2,
      preparationSeconds: 10,
      speakingSeconds: 40,
      mode: SpeakingMode.readAloud,
      expectedText:
          'Practicing English regularly helps you speak with more confidence and ease.',
      category: 'Personal Development',
      tags: ['Learning', 'Fluency'],
    ),
    SpeakingActivity(
      id: 'spk_read_b2_01',
      title: 'Team Collaboration',
      prompt: 'Read this sentence aloud clearly:',
      instruction:
          'Emphasize key conceptual words to convey the idea persuasively.',
      level: 'B2',
      estimatedDurationMinutes: 2,
      preparationSeconds: 10,
      speakingSeconds: 45,
      mode: SpeakingMode.readAloud,
      expectedText:
          'Effective collaboration requires active listening as much as clear communication.',
      category: 'Career & Workplace',
      tags: ['Teamwork', 'Communication'],
    ),
    SpeakingActivity(
      id: 'spk_read_c1_01',
      title: 'Workplace Transformation',
      prompt: 'Read this sentence aloud clearly:',
      instruction:
          'Deliver this statement with executive polish and natural cadence.',
      level: 'C1',
      estimatedDurationMinutes: 2,
      preparationSeconds: 12,
      speakingSeconds: 45,
      mode: SpeakingMode.readAloud,
      expectedText:
          'Technological advancements are rapidly reshaping modern industries and traditional workplaces.',
      category: 'Global Trends',
      tags: ['Technology', 'Economy'],
    ),

    // ==========================================
    // 2. SPEAK ABOUT IT ACTIVITIES (Sustained Free Speaking)
    // ==========================================
    SpeakingActivity(
      id: 'spk_about_a1_01',
      title: 'Family & Friends',
      prompt: 'Tell me about your family or people close to you.',
      instruction:
          'Speak for about 45 seconds. Mention who is in your family and what they like to do.',
      level: 'A1',
      estimatedDurationMinutes: 3,
      preparationSeconds: 15,
      speakingSeconds: 45,
      mode: SpeakingMode.speakAboutIt,
      starter: 'In my family, there are...',
      keyPhrases: [
        'family members',
        'we like to',
        'lives in',
        'spends time together',
      ],
      category: 'Social & Personal',
      tags: ['Family', 'Relationships'],
    ),
    SpeakingActivity(
      id: 'spk_about_a2_01',
      title: 'Weekend Routine',
      prompt: 'What do you usually do on weekends?',
      instruction:
          'Speak for about 60 seconds describing your typical Saturday and Sunday activities.',
      level: 'A2',
      estimatedDurationMinutes: 3,
      preparationSeconds: 15,
      speakingSeconds: 60,
      mode: SpeakingMode.speakAboutIt,
      starter: 'On weekends, I usually wake up and...',
      keyPhrases: [
        'on Saturday morning',
        'relax with',
        'go outside',
        'spend time',
      ],
      category: 'Lifestyle',
      tags: ['Weekends', 'Leisure'],
    ),
    SpeakingActivity(
      id: 'spk_about_b1_01',
      title: 'Learning a New Skill',
      prompt: 'Describe a skill you would like to learn in the future.',
      instruction:
          'Speak for about 60 seconds. Explain why you chose it and how you plan to practice.',
      level: 'B1',
      estimatedDurationMinutes: 3,
      preparationSeconds: 15,
      speakingSeconds: 60,
      mode: SpeakingMode.speakAboutIt,
      starter: 'A skill I have always wanted to master is...',
      keyPhrases: [
        'would like to learn',
        'be useful for',
        'practice by',
        'in the future',
      ],
      category: 'Personal Development',
      tags: ['Goals', 'Education'],
    ),
    SpeakingActivity(
      id: 'spk_about_b2_01',
      title: 'Technology & Connection',
      prompt: 'Do you think modern technology has improved communication?',
      instruction:
          'Speak for about 60 seconds defending your viewpoint with concrete examples.',
      level: 'B2',
      estimatedDurationMinutes: 3,
      preparationSeconds: 20,
      speakingSeconds: 60,
      mode: SpeakingMode.speakAboutIt,
      starter:
          'While technology connects us instantly across borders, one drawback is...',
      keyPhrases: [
        'on the one hand',
        'conversely',
        'social dynamics',
        'fosters connection',
      ],
      category: 'Society & Debate',
      tags: ['Technology', 'Communication'],
    ),
    SpeakingActivity(
      id: 'spk_about_c1_01',
      title: 'AI & Future Work',
      prompt: 'How might artificial intelligence change the way people work?',
      instruction:
          'Speak for about 60 seconds outlining both transformative opportunities and workforce challenges.',
      level: 'C1',
      estimatedDurationMinutes: 3,
      preparationSeconds: 20,
      speakingSeconds: 60,
      mode: SpeakingMode.speakAboutIt,
      starter:
          'As automation evolves, intellectual tasks will increasingly shift toward...',
      keyPhrases: [
        'paradigm shift',
        'augment human capabilities',
        'workforce disruption',
        'ethical implications',
      ],
      category: 'Technology & Economy',
      tags: ['Future', 'Innovation'],
    ),

    // ==========================================
    // 3. QUICK RESPONSE ACTIVITIES (Fast-Paced Prompt)
    // ==========================================
    SpeakingActivity(
      id: 'spk_quick_a1_01',
      title: 'Favorite Meal',
      prompt: 'What is your favorite food and why?',
      instruction:
          'You have 10 seconds to prepare, then 30 seconds to speak spontaneously.',
      level: 'A1',
      estimatedDurationMinutes: 2,
      preparationSeconds: 10,
      speakingSeconds: 30,
      mode: SpeakingMode.quickResponse,
      starter: 'My favorite food is...',
      category: 'Everyday',
      tags: ['Food', 'Favorites'],
    ),
    SpeakingActivity(
      id: 'spk_quick_a2_01',
      title: 'Yesterday After Hours',
      prompt: 'What did you do yesterday evening?',
      instruction:
          'Answer spontaneously using past tense verbs. Speak for 30 seconds.',
      level: 'A2',
      estimatedDurationMinutes: 2,
      preparationSeconds: 10,
      speakingSeconds: 30,
      mode: SpeakingMode.quickResponse,
      starter: 'Yesterday after work, I...',
      category: 'Daily Life',
      tags: ['Past Events', 'Grammar'],
    ),
    SpeakingActivity(
      id: 'spk_quick_b1_01',
      title: 'A Good Book or Movie',
      prompt: 'Recommend a movie or book you enjoyed recently.',
      instruction:
          'Summarize the plot in 1-2 sentences and explain why you enjoyed it.',
      level: 'B1',
      estimatedDurationMinutes: 2,
      preparationSeconds: 10,
      speakingSeconds: 30,
      mode: SpeakingMode.quickResponse,
      starter: 'I recently watched/read...',
      category: 'Entertainment',
      tags: ['Media', 'Culture'],
    ),
    SpeakingActivity(
      id: 'spk_quick_b2_01',
      title: 'Qualities of Good Friends',
      prompt: 'What quality matters most to you in a friendship?',
      instruction:
          'State your choice clearly and explain why it is essential to you.',
      level: 'B2',
      estimatedDurationMinutes: 2,
      preparationSeconds: 10,
      speakingSeconds: 30,
      mode: SpeakingMode.quickResponse,
      starter: 'Above all else, I value...',
      category: 'Relationships',
      tags: ['Values', 'Friendship'],
    ),
    SpeakingActivity(
      id: 'spk_quick_c1_01',
      title: 'Quick Decision Making',
      prompt:
          'Do you prefer making fast intuitive decisions or slow analytical ones?',
      instruction:
          'Articulate your rationale concisely within the 30-second window.',
      level: 'C1',
      estimatedDurationMinutes: 2,
      preparationSeconds: 10,
      speakingSeconds: 30,
      mode: SpeakingMode.quickResponse,
      starter: 'In dynamic scenarios, I tend to lean towards...',
      category: 'Psychology',
      tags: ['Decisions', 'Analysis'],
    ),

    // ==========================================
    // 4. DAILY SPEAKING CHALLENGES
    // ==========================================
    SpeakingActivity(
      id: 'spk_daily_01',
      title: 'Recent Discovery',
      prompt: 'Talk about something you learned recently.',
      instruction:
          'Speak for about 60 seconds about a fresh insight, fact, or technique you discovered.',
      level: 'B1',
      estimatedDurationMinutes: 2,
      preparationSeconds: 15,
      speakingSeconds: 60,
      mode: SpeakingMode.dailySpeaking,
      starter: 'Just the other day, I discovered that...',
      category: 'Daily Challenge',
      tags: ['Daily', 'Curiosity'],
    ),
    SpeakingActivity(
      id: 'spk_daily_02',
      title: 'Places That Inspire',
      prompt: 'Describe a place that helps you think clearly or relax.',
      instruction:
          'Speak for 60 seconds describing the setting and how it makes you feel.',
      level: 'B1',
      estimatedDurationMinutes: 2,
      preparationSeconds: 15,
      speakingSeconds: 60,
      mode: SpeakingMode.dailySpeaking,
      starter: 'Whenever I need to recharge, I visit...',
      category: 'Daily Challenge',
      tags: ['Daily', 'Wellbeing'],
    ),
    SpeakingActivity(
      id: 'spk_daily_03',
      title: 'Overcoming a Small Obstacle',
      prompt:
          'Share a small challenge you tackled this week and how you resolved it.',
      instruction:
          'Summarize the situation, action, and result in about 60 seconds.',
      level: 'B2',
      estimatedDurationMinutes: 2,
      preparationSeconds: 15,
      speakingSeconds: 60,
      mode: SpeakingMode.dailySpeaking,
      starter: 'Earlier this week, I faced a minor challenge with...',
      category: 'Daily Challenge',
      tags: ['Daily', 'Problem Solving'],
    ),
    SpeakingActivity(
      id: 'spk_daily_04',
      title: 'Upcoming Ambition',
      prompt:
          'What is one personal goal you want to achieve before the month ends?',
      instruction:
          'Speak for about 60 seconds about your plan and what motivated it.',
      level: 'B1',
      estimatedDurationMinutes: 2,
      preparationSeconds: 15,
      speakingSeconds: 60,
      mode: SpeakingMode.dailySpeaking,
      starter: 'My primary focus for the rest of this month is to...',
      category: 'Daily Challenge',
      tags: ['Daily', 'Goals'],
    ),
    SpeakingActivity(
      id: 'spk_daily_05',
      title: 'Simple Daily Pleasures',
      prompt: 'What simple part of your day brings you the most contentment?',
      instruction:
          'Reflect on a comforting daily ritual or moment for about 60 seconds.',
      level: 'A2',
      estimatedDurationMinutes: 2,
      preparationSeconds: 15,
      speakingSeconds: 60,
      mode: SpeakingMode.dailySpeaking,
      starter: 'One moment I always look forward to every day is...',
      category: 'Daily Challenge',
      tags: ['Daily', 'Mindfulness'],
    ),
  ];
}
