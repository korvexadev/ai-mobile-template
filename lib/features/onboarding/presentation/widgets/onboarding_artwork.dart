import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../shared/design_system/app_spacing.dart';
import '../onboarding_slide.dart';

class OnboardingArtworkView extends StatelessWidget {
  const OnboardingArtworkView({required this.artwork, super.key});

  final OnboardingArtwork artwork;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 1.06,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 360,
              height: 440,
              child: switch (artwork) {
                OnboardingArtwork.frontPage => const _FrontPageArtwork(),
                OnboardingArtwork.reading => const _ReadingArtwork(),
                OnboardingArtwork.collection => const _CollectionArtwork(),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FrontPageArtwork extends StatelessWidget {
  const _FrontPageArtwork();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Masthead(label: 'This week'),
        const SizedBox(height: 16),
        Expanded(
          flex: 6,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppTheme.ink,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _EditorialImagePainter()),
                ),
                const Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Text(
                    'Ichi chatentha kwambiri,\nAnthu akuchipopa',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Newsreader',
                      fontSize: 31,
                      fontWeight: FontWeight.w600,
                      height: 0.98,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(child: _StoryLine(widthFactor: 0.82)),
            SizedBox(width: 16),
            Expanded(child: _StoryLine(widthFactor: 0.62)),
          ],
        ),
      ],
    );
  }
}

class _ReadingArtwork extends StatelessWidget {
  const _ReadingArtwork();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Masthead(label: 'READING  /  06 MIN'),
            const Spacer(),
            Text(
              'Eni mudzi anyinyirika..',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 20),
            const _ReadingLine(widthFactor: 1),
            const _ReadingLine(widthFactor: 0.92),
            const _ReadingLine(widthFactor: 0.96),
            const _ReadingLine(widthFactor: 0.68),
            const Spacer(),
            Container(
              height: 4,
              width: 64,
              decoration: BoxDecoration(
                color: AppTheme.brandRed,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionArtwork extends StatelessWidget {
  const _CollectionArtwork();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Masthead(label: ''),
        const SizedBox(height: 18),
        Expanded(
          child: Row(
            children: [
              const Expanded(
                child: _CollectionCard(
                  index: '',
                  title: 'Events today',
                  active: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(
                      child: Center(
                        child: _CollectionCard(
                          index: '',
                          title: 'Ladies night out party',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add_rounded,
                            color: AppTheme.brandRed,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Masthead extends StatelessWidget {
  const _Masthead({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.8,
      ),
    );
  }
}

class _StoryLine extends StatelessWidget {
  const _StoryLine({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FractionallySizedBox(
          widthFactor: widthFactor,
          child: Container(
            height: 7,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 7),
        FractionallySizedBox(
          widthFactor: 0.7,
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadingLine extends StatelessWidget {
  const _ReadingLine({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: 7,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.index,
    required this.title,
    this.active = false,
  });

  final bool active;
  final String index;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: active ? AppTheme.brandRed : colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: active ? null : Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              index,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: active ? Colors.white70 : AppTheme.brandRed,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: active ? Colors.white : colors.onSurface,
                fontFamily: 'Newsreader',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorialImagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final red = Paint()..color = AppTheme.brandRed;
    final softRed = Paint()..color = const Color(0xFF7F1D27);
    final paper = Paint()..color = const Color(0xFFF2EDE5);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.58, 0, size.width * 0.42, size.height),
      softRed,
    );
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.28),
      size.shortestSide * 0.23,
      red,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.18,
        size.width * 0.22,
        size.height * 0.48,
      ),
      paper,
    );
  }

  @override
  bool shouldRepaint(_EditorialImagePainter oldDelegate) => false;
}
