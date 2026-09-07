import 'package:flutter/material.dart';

import '../../app/theme/design_system.dart';
import '../extensions/context_extensions.dart';

/// Reusable, clean AppBar adhering to Fluentia's minimalist and accessible design system.
class FluentAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FluentAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.showBackButton = false,
    this.automaticallyImplyLeading = true,
    this.onBackPressed,
    this.backgroundColor,
    this.centerTitle = false,
    this.showDivider = true,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool automaticallyImplyLeading;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final bool centerTitle;
  final bool showDivider;

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 64.0 : 56.0);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    Widget? effectiveLeading = leading;
    if (effectiveLeading == null) {
      if (showBackButton ||
          (automaticallyImplyLeading &&
              ModalRoute.of(context)?.canPop == true)) {
        effectiveLeading = IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            size: AppIconSizes.md + 2,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          tooltip: 'Back',
          onPressed: onBackPressed ?? () => Navigator.of(context).maybePop(),
        );
      }
    }

    final effectiveBackgroundColor =
        backgroundColor ??
        (isDark ? AppColors.darkBackground : AppColors.lightBackground);

    return AppBar(
      titleSpacing: effectiveLeading != null ? 0 : AppSpacing.lg,
      leading: effectiveLeading,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      backgroundColor: effectiveBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Column(
        crossAxisAlignment: centerTitle
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppFontSizes.titleMedium,
              fontWeight: AppFontWeights.semiBold,
              letterSpacing: -0.3,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFontSizes.bodySmall,
                fontWeight: AppFontWeights.regular,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ],
      ),
      actions: actions,
      bottom: showDivider
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                height: 1,
              ),
            )
          : null,
    );
  }
}
