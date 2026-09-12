import 'package:flutter/material.dart';

import '../../../../app/theme/design_system.dart';
import '../../../../shared/extensions/context_extensions.dart';

/// Interactive guided checklist widget for Guided Writing exercises.
class GuidedChecklistWidget extends StatefulWidget {
  const GuidedChecklistWidget({
    super.key,
    required this.checklist,
    required this.checkedIndices,
    required this.onToggleItem,
  });

  final List<String> checklist;
  final Set<int> checkedIndices;
  final ValueChanged<int> onToggleItem;

  @override
  State<GuidedChecklistWidget> createState() => _GuidedChecklistWidgetState();
}

class _GuidedChecklistWidgetState extends State<GuidedChecklistWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    if (widget.checklist.isEmpty) return const SizedBox.shrink();

    final isDark = context.isDarkMode;
    final total = widget.checklist.length;
    final completed = widget.checkedIndices.length;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppRadii.roundedLg,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row with toggle arrow
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: _isExpanded
                ? const BorderRadius.vertical(top: Radius.circular(12))
                : AppRadii.roundedLg,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(
                    Icons.checklist_rtl_rounded,
                    size: 20,
                    color: isDark ? AppColors.teal300 : AppColors.teal700,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Guided Writing Checklist',
                          style: TextStyle(
                            fontSize: AppFontSizes.bodyMedium,
                            fontWeight: AppFontWeights.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$completed of $total points addressed',
                          style: TextStyle(
                            fontSize: AppFontSizes.caption,
                            color: completed == total
                                ? AppColors.success
                                : (isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Expanded checklist items
          if (_isExpanded) ...[
            Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Column(
                children: List.generate(widget.checklist.length, (index) {
                  final item = widget.checklist[index];
                  final isChecked = widget.checkedIndices.contains(index);

                  return InkWell(
                    onTap: () => widget.onToggleItem(index),
                    borderRadius: AppRadii.roundedMd,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              isChecked
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              size: 18,
                              color: isChecked
                                  ? AppColors.teal500
                                  : (isDark
                                        ? AppColors.slate600
                                        : AppColors.slate400),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: AppFontSizes.bodySmall,
                                height: 1.4,
                                decoration: isChecked
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isChecked
                                    ? (isDark
                                          ? AppColors.darkTextMuted
                                          : AppColors.lightTextSecondary)
                                    : (isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
