import 'package:flutter/material.dart';
import 'package:mikozi_mobile/app/theme/app_theme.dart';

/// Supplies the shared Flutter contracts used by every routed page.
///
/// [AdaptiveApp] uses CupertinoApp on iOS and MaterialApp elsewhere. Mikozi
/// pages still share typography, selection, and some Material-backed controls,
/// so those contracts must exist below the Navigator on both app hosts.
class MikoziPageBoundary extends StatelessWidget {
  const MikoziPageBoundary({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: Material(
        type: MaterialType.transparency,
        child: SelectionArea(child: child),
      ),
    );
  }
}
