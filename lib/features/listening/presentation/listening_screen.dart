import 'package:flutter/material.dart';
import 'screens/listening_hub_screen.dart';

/// Legacy entry point aliasing [ListeningHubScreen] (/practice/listening).
class ListeningScreen extends StatelessWidget {
  const ListeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListeningHubScreen();
  }
}
