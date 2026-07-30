import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:mikozi_mobile/app/theme/app_theme.dart';
import 'package:mikozi_mobile/shared/design_system/app_spacing.dart';
import 'package:mikozi_mobile/shared/design_system/mikozi_brand.dart';

class AuthPageFrame extends StatelessWidget {
  const AuthPageFrame({
    required this.title,
    required this.subtitle,
    required this.child,
    this.onBack,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      body: ColoredBox(
        color: AppTheme.ink,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 700;
            final headerHeight = compact ? 280.0 : 330.0;
            final remainingHeight = constraints.maxHeight - headerHeight;
            final sheetMinHeight = remainingHeight > 360
                ? remainingHeight
                : 360.0;
            return SingleChildScrollView(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    children: [
                      _AuthHeader(
                        height: headerHeight,
                        title: title,
                        subtitle: subtitle,
                        onBack: onBack,
                      ),
                      Container(
                        constraints: BoxConstraints(minHeight: sheetMinHeight),
                        decoration: const BoxDecoration(
                          color: AppTheme.paper,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(36),
                          ),
                        ),
                        child: SafeArea(
                          top: false,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: AppSpacing.contentMaxWidth,
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  AppSpacing.page,
                                  AppSpacing.xl,
                                  AppSpacing.page,
                                  AppSpacing.xl,
                                ),
                                child: child,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({
    required this.height,
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final double height;
  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: CustomPaint(
        painter: const _AuthBackdropPainter(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.page,
            topInset + AppSpacing.md,
            AppSpacing.page,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (onBack == null)
                const MikoziBrand(logoSize: 38, foregroundColor: Colors.white)
              else
                _BackButton(onPressed: onBack!),
              SizedBox(height: height < 300 ? AppSpacing.xxl : AppSpacing.xxxl),
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w700,
                    height: 1.04,
                    letterSpacing: -1.4,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: IconButton(
        tooltip: 'Back',
        onPressed: onPressed,
        color: Colors.white,
        icon: const HugeIcon(
          icon: HugeIconsStrokeRounded.arrowLeft01,
          size: 21,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _AuthBackdropPainter extends CustomPainter {
  const _AuthBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.035);
    const cell = 46.0;
    for (var row = 0; row < 5; row++) {
      for (var column = 0; column < 5; column++) {
        if ((row + column).isOdd) {
          final left = size.width - ((column + 1) * cell);
          final top = 18.0 + (row * cell);
          canvas.drawRect(Rect.fromLTWH(left, top, cell - 2, cell - 2), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
