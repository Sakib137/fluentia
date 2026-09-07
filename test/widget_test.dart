import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluentia/app/app.dart';
import 'package:fluentia/core/constants/app_constants.dart';
import 'package:fluentia/core/constants/app_strings.dart';
import 'package:fluentia/core/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('FluentiaApp bootstraps and displays splash screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const FluentiaApp(),
      ),
    );

    // Initial frame shows the Splash Screen
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppStrings.splashTagline), findsOneWidget);

    // Advance time past the splash delay to trigger navigation to Onboarding
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verifies Onboarding is presented
    expect(find.text(AppStrings.onboardingTitle), findsOneWidget);
    expect(find.text(AppStrings.getStarted), findsOneWidget);
  });
}
