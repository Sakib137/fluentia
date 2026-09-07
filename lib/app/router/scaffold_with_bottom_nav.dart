import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/design_system.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/extensions/context_extensions.dart';

/// Persistent shell layout with Material 3 NavigationBar for parallel tab navigation.
class ScaffoldWithBottomNav extends StatelessWidget {
  const ScaffoldWithBottomNav({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1.0,
              ),
            ),
          ),
          child: NavigationBar(
            height: 68,
            elevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            indicatorColor: isDark ? AppColors.slate800 : AppColors.primary100,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, size: 22),
                selectedIcon: Icon(Icons.home_rounded, size: 22),
                label: AppStrings.navHome,
                tooltip: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.psychology_outlined, size: 22),
                selectedIcon: Icon(Icons.psychology_rounded, size: 22),
                label: AppStrings.navPractice,
                tooltip: 'Practice',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined, size: 22),
                selectedIcon: Icon(Icons.menu_book_rounded, size: 22),
                label: AppStrings.navLearn,
                tooltip: 'Learn',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined, size: 22),
                selectedIcon: Icon(Icons.insights_rounded, size: 22),
                label: AppStrings.navProgress,
                tooltip: 'Progress',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded, size: 22),
                selectedIcon: Icon(Icons.person_rounded, size: 22),
                label: AppStrings.navProfile,
                tooltip: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
