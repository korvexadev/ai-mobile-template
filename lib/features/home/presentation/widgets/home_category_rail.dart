import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/design_system/app_spacing.dart';
import '../../domain/homepage.dart';
import '../home_layout.dart';

class HomeCategoryRail extends StatelessWidget {
  const HomeCategoryRail({
    required this.topTabs,
    required this.moreTabs,
    required this.selectedId,
    required this.onSelected,
    super.key,
  });

  final List<HomeTab> topTabs;
  final List<HomeTab> moreTabs;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final moreSelected = moreTabs.any((tab) => tab.id == selectedId);
    return Semantics(
      label: 'News categories',
      child: SizedBox(
        height: 58,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: HomeLayout.horizontalPadding,
            vertical: AppSpacing.xs,
          ),
          children: [
            for (final tab in topTabs)
              _CategoryPill(
                label: tab.name,
                selected: tab.id == selectedId,
                onPressed: () => onSelected(tab.id),
              ),
            if (moreTabs.isNotEmpty)
              _CategoryPill(
                label: moreSelected
                    ? moreTabs.firstWhere((tab) => tab.id == selectedId).name
                    : 'More',
                selected: moreSelected,
                trailing: HugeIconsStrokeRounded.arrowDown01,
                onPressed: () => _showMoreCategories(context),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMoreCategories(BuildContext context) async {
    final selected = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('Categories'),
          actions: [
            for (final tab in moreTabs)
              CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop(tab.id),
                child: Text(tab.name),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        );
      },
    );
    if (selected != null) {
      onSelected(selected);
    }
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.selected,
    required this.onPressed,
    this.trailing,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final List<List<dynamic>>? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: _CategoryPillContent(
            label: label,
            selected: selected,
            trailing: trailing,
          ),
        ),
      ),
    );
  }
}

class _CategoryPillContent extends StatelessWidget {
  const _CategoryPillContent({
    required this.label,
    required this.selected,
    this.trailing,
  });

  final String label;
  final bool selected;
  final List<List<dynamic>>? trailing;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppTheme.white : AppTheme.muted;
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: selected ? AppTheme.brandRed : AppTheme.softSurface,
        borderRadius: BorderRadius.circular(HomeLayout.controlRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foreground,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.xs),
            HugeIcon(icon: trailing!, color: foreground, size: 15),
          ],
        ],
      ),
    );
  }
}
