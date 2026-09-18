import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import 'app_spacing.dart';

/// A common platform-neutral action with restrained Cupertino interaction.
class PrimaryAction extends StatelessWidget {
  const PrimaryAction({
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.loading = false,
    this.loadingLabel,
    super.key,
  });

  final bool enabled;
  final bool loading;
  final String label;
  final String? loadingLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final canPress = enabled && onPressed != null;
    final visuallyActive = canPress || loading;
    final foreground = visuallyActive
        ? AppTheme.white
        : AppTheme.mutedOf(context);

    return SizedBox(
      height: AppSpacing.actionHeight,
      width: double.infinity,
      child: Semantics(
        liveRegion: loading,
        label: loading ? loadingLabel ?? '$label in progress' : null,
        child: IgnorePointer(
          ignoring: loading,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            color: AppTheme.brandRed,
            disabledColor: AppTheme.borderOf(context),
            borderRadius: BorderRadius.circular(14),
            pressedOpacity: 0.72,
            onPressed: visuallyActive ? onPressed ?? _ignorePress : null,
            child: loading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoActivityIndicator(
                        key: ValueKey('primary-action-progress'),
                        color: AppTheme.white,
                        radius: 9,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        loadingLabel ?? label,
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: AppTheme.white),
                      ),
                    ],
                  )
                : Text(
                    label,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: foreground),
                  ),
          ),
        ),
      ),
    );
  }

  static void _ignorePress() {}
}
