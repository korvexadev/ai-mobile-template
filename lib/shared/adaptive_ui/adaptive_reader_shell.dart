import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../app/theme/app_theme.dart';

class ReaderNavigationItem {
  const ReaderNavigationItem({
    required this.label,
    required this.icon,
    required this.symbol,
    required this.selectedSymbol,
  });

  final String label;
  final List<List<dynamic>> icon;
  final String symbol;
  final String selectedSymbol;
}

class AdaptiveReaderShell extends StatelessWidget {
  const AdaptiveReaderShell({
    required this.body,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final Widget body;
  final List<ReaderNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isIOS26OrHigher()) {
      return AdaptiveScaffold(
        minimizeBehavior: TabBarMinimizeBehavior.never,
        body: body,
        bottomNavigationBar: AdaptiveBottomNavigationBar(
          useNativeBottomBar: true,
          selectedIndex: selectedIndex,
          onTap: onSelected,
          selectedItemColor: AppTheme.brandRed,
          items: items
              .map(
                (item) => AdaptiveNavigationDestination(
                  icon: item.symbol,
                  selectedIcon: item.selectedSymbol,
                  label: item.label,
                ),
              )
              .toList(growable: false),
        ),
      );
    }
    return Scaffold(
      extendBody: true,
      body: body,
      bottomNavigationBar: _FallbackBottomBar(
        items: items,
        selectedIndex: selectedIndex,
        onSelected: onSelected,
      ),
    );
  }
}

class _FallbackBottomBar extends StatelessWidget {
  const _FallbackBottomBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<ReaderNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.ink,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SizedBox(
          height: 66,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = selectedIndex == index;
              final color = selected ? AppTheme.white : const Color(0xFFB8B9BD);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Semantics(
                    selected: selected,
                    button: true,
                    label: item.label,
                    onTap: () => onSelected(index),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelected(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.brandRed
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HugeIcon(icon: item.icon, size: 23, color: color),
                            const SizedBox(height: 2),
                            Text(
                              item.label,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: color,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
