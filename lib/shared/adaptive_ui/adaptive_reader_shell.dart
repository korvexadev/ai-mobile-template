import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mikozi_mobile/app/theme/app_theme.dart';

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
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = selectedIndex == index;
              final color = selected ? AppTheme.brandRed : AppTheme.muted;
              return Expanded(
                child: InkResponse(
                  onTap: () => onSelected(index),
                  radius: 32,
                  child: Semantics(
                    selected: selected,
                    button: true,
                    label: item.label,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(icon: item.icon, size: 25, color: color),
                        const SizedBox(height: 3),
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
              );
            }),
          ),
        ),
      ),
    );
  }
}
