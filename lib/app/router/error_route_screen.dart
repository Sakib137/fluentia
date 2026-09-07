import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/widgets/fluent_app_bar.dart';
import '../../shared/widgets/fluent_empty_state.dart';
import 'app_routes.dart';

/// Screen displayed when an unknown or invalid route path is navigated to.
class ErrorRouteScreen extends StatelessWidget {
  const ErrorRouteScreen({super.key, this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FluentAppBar(title: AppStrings.errorPageTitle),
      body: FluentEmptyState(
        icon: Icons.explore_off_rounded,
        title: AppStrings.errorPageTitle,
        description: error?.toString() ?? AppStrings.errorPageMessage,
        actionLabel: AppStrings.goHome,
        onAction: () => context.go(AppRoutes.home),
      ),
    );
  }
}
