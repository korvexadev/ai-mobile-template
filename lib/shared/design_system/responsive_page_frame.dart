import 'package:flutter/material.dart';
import 'package:mikozi_mobile/shared/design_system/app_spacing.dart';

class ResponsivePageFrame extends StatelessWidget {
  const ResponsivePageFrame({
    required this.child,
    this.alignment = Alignment.center,
    this.padding,
    super.key,
  });

  final AlignmentGeometry alignment;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 700
            ? AppSpacing.pageWide
            : AppSpacing.page;
        return SafeArea(
          child: Align(
            alignment: alignment,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.contentMaxWidth,
              ),
              child: Padding(
                padding:
                    padding ??
                    EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 20,
                    ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
