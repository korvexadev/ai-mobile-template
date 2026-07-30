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
    final selectedMoreTab = moreTabs
        .where((tab) => tab.id == selectedId)
        .firstOrNull;
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
            if (selectedMoreTab != null)
              _CategoryPill(
                label: selectedMoreTab.name,
                selected: true,
                onPressed: () => onSelected(selectedMoreTab.id),
              ),
            for (final tab in topTabs)
              _CategoryPill(
                label: tab.name,
                selected: tab.id == selectedId,
                onPressed: () => onSelected(tab.id),
              ),
            if (moreTabs.isNotEmpty)
              _CategoryPill(
                label: 'More',
                selected: false,
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
      barrierColor: Colors.black.withValues(alpha: 0.42),
      semanticsDismissible: true,
      builder: (context) {
        return _MoreCategoriesSheet(tabs: moreTabs, selectedId: selectedId);
      },
    );
    if (selected != null) {
      onSelected(selected);
    }
  }
}

class _MoreCategoriesSheet extends StatelessWidget {
  const _MoreCategoriesSheet({required this.tabs, required this.selectedId});

  final List<HomeTab> tabs;
  final String selectedId;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.sizeOf(context).height * 0.72,
        ),
        child: DecoratedBox(
          key: const ValueKey('more-categories-sheet'),
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLarge),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 38,
                height: AppSpacing.xxs,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(AppSpacing.xxs),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Categories',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Close categories',
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: AppTheme.softSurface,
                          shape: BoxShape.circle,
                        ),
                        child: CupertinoButton(
                          key: const ValueKey('close-more-categories'),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size.square(40),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const HugeIcon(
                            icon: HugeIconsStrokeRounded.cancel01,
                            color: AppTheme.ink,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppTheme.border),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.sm + bottomInset,
                  ),
                  itemCount: tabs.length,
                  separatorBuilder: (context, index) {
                    return const Divider(
                      height: 1,
                      indent: AppSpacing.sm,
                      endIndent: AppSpacing.sm,
                      color: AppTheme.border,
                    );
                  },
                  itemBuilder: (context, index) {
                    final tab = tabs[index];
                    return _MoreCategoryRow(
                      tab: tab,
                      selected: tab.id == selectedId,
                      onPressed: () => Navigator.of(context).pop(tab.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreCategoryRow extends StatelessWidget {
  const _MoreCategoryRow({
    required this.tab,
    required this.selected,
    required this.onPressed,
  });

  final HomeTab tab;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppTheme.brandRed : AppTheme.ink;
    return Semantics(
      button: true,
      selected: selected,
      label: tab.name,
      child: DecoratedBox(
        key: ValueKey('more-category-${tab.id}'),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.brandRed.withValues(alpha: 0.07)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(HomeLayout.controlRadius),
        ),
        child: CupertinoButton(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          minimumSize: const Size.fromHeight(58),
          onPressed: onPressed,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  tab.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: foreground,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
              if (selected)
                const HugeIcon(
                  icon: HugeIconsStrokeRounded.checkmarkCircle02,
                  color: AppTheme.brandRed,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
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
