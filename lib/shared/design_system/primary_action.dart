import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mikozi_mobile/app/theme/app_theme.dart';
import 'package:mikozi_mobile/shared/design_system/app_spacing.dart';

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
    final action = loading
        ? AdaptiveButton.child(
            onPressed: null,
            enabled: false,
            color: AppTheme.brandRed,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            minSize: const Size.fromHeight(AppSpacing.actionHeight),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _ActionProgress(),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  loadingLabel ?? label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
              ],
            ),
          )
        : AdaptiveButton(
            label: label,
            onPressed: onPressed,
            enabled: enabled,
            color: AppTheme.brandRed,
            textColor: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            minSize: const Size.fromHeight(AppSpacing.actionHeight),
          );
    return SizedBox(
      height: AppSpacing.actionHeight,
      width: double.infinity,
      child: Semantics(
        liveRegion: loading,
        label: loading ? loadingLabel ?? '$label in progress' : null,
        child: action,
      ),
    );
  }
}

class _ActionProgress extends StatelessWidget {
  const _ActionProgress();

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isIOS) {
      return const CupertinoActivityIndicator(
        key: ValueKey('primary-action-progress'),
        color: Colors.white,
        radius: 9,
      );
    }
    return const SizedBox.square(
      key: ValueKey('primary-action-progress'),
      dimension: 18,
      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
    );
  }
}
