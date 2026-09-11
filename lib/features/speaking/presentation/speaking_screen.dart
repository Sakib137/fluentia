import 'package:flutter/material.dart';
import 'screens/speaking_hub_screen.dart';

export 'screens/speaking_hub_screen.dart';
export 'screens/speaking_practice_screen.dart';
export 'screens/speaking_result_screen.dart';

/// Legacy alias for [SpeakingHubScreen].
class SpeakingScreen extends StatelessWidget {
  const SpeakingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SpeakingHubScreen();
  }
}
