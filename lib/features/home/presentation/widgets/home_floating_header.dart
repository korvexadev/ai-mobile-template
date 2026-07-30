import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../../../shared/design_system/app_spacing.dart';
import '../../../../shared/design_system/mikozi_brand.dart';

import '../home_layout.dart';

class HomeFloatingHeader extends StatelessWidget {
  const HomeFloatingHeader({
    required this.onSearch,
    required this.onNotifications,
    super.key,
  });

  final VoidCallback onSearch;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 76,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HomeLayout.horizontalPadding,
          ),
          child: Row(
            children: [
              const Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: MikoziBrand(logoSize: 42, showName: false),
                ),
              ),
              _FloatingHeaderAction(
                label: 'Search',
                icon: HugeIconsStrokeRounded.search01,
                onPressed: onSearch,
              ),
              const SizedBox(width: AppSpacing.xs),
              _FloatingHeaderAction(
                label: 'Notifications',
                icon: HugeIconsStrokeRounded.notification02,
                showBadge: true,
                onPressed: onNotifications,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingHeaderAction extends StatelessWidget {
  const _FloatingHeaderAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.showBadge = false,
  });

  final String label;
  final List<List<dynamic>> icon;
  final VoidCallback onPressed;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size.square(44),
        pressedOpacity: 0.58,
        onPressed: onPressed,
        child: SizedBox.square(
          dimension: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              HugeIcon(icon: icon, color: CupertinoColors.label, size: 21),
              if (showBadge)
                const Positioned(
                  right: 9,
                  top: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemRed,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(dimension: 7),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
