import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/design_system/app_spacing.dart';
import '../../../../shared/design_system/mikozi_brand.dart';

import '../home_layout.dart';

class HomeFloatingHeader extends StatelessWidget {
  const HomeFloatingHeader({
    required this.onSearch,
    required this.onNotifications,
    required this.surfaceOpacity,
    super.key,
  });

  final VoidCallback onSearch;
  final VoidCallback onNotifications;
  final double surfaceOpacity;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: [
        //     AppTheme.paperOf(context).withValues(alpha: surfaceOpacity),
        //     AppTheme.paperOf(context).withValues(alpha: surfaceOpacity * 0.92),
        //   ],
        // ),
      ),
      child: SafeArea(
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
                  showBadge: false,
                  onPressed: onNotifications,
                ),
              ],
            ),
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
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context).withValues(alpha: 0.92),
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.borderOf(context)),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
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
      ),
    );
  }
}
