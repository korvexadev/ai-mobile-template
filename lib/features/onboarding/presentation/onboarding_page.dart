import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mikozi_mobile/app/theme/app_theme.dart';
import 'package:mikozi_mobile/features/onboarding/application/onboarding_controller.dart';
import 'package:mikozi_mobile/features/onboarding/presentation/onboarding_slide.dart';
import 'package:mikozi_mobile/features/onboarding/presentation/widgets/onboarding_artwork.dart';
import 'package:mikozi_mobile/shared/design_system/mikozi_brand.dart';
import 'package:mikozi_mobile/shared/design_system/primary_action.dart';
import 'package:mikozi_mobile/shared/design_system/responsive_page_frame.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late final PageController _pageController;
  int _selectedIndex = 0;

  bool get _isLast => _selectedIndex == onboardingSlides.length - 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_isLast) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    await ref.read(onboardingControllerProvider.notifier).complete();
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(onboardingControllerProvider).isLoading;
    return AdaptiveScaffold(
      body: ResponsivePageFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MikoziBrand(logoSize: 38),
            const SizedBox(height: 20),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingSlides.length,
                onPageChanged: (index) {
                  setState(() => _selectedIndex = index);
                },
                itemBuilder: (context, index) {
                  return _OnboardingSlideView(slide: onboardingSlides[index]);
                },
              ),
            ),
            const SizedBox(height: 18),
            _ProgressIndicator(
              count: onboardingSlides.length,
              selectedIndex: _selectedIndex,
            ),
            const SizedBox(height: 22),
            PrimaryAction(
              label: _isLast ? 'Start reading' : 'Continue',
              enabled: !saving,
              onPressed: saving ? null : () => _continue(),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlideView extends StatelessWidget {
  const _OnboardingSlideView({required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 620;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: compact ? 280 : 360,
                    maxWidth: 390,
                  ),
                  child: OnboardingArtworkView(artwork: slide.artwork),
                ),
              ),
            ),
            SizedBox(height: compact ? 18 : 28),
            Semantics(
              header: true,
              child: Text(
                slide.title,
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            const SizedBox(height: 11),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                slide.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.count, required this.selectedIndex});

  final int count;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Page ${selectedIndex + 1} of $count',
      child: Row(
        children: List.generate(count, (index) {
          final selected = selectedIndex == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: 5,
            width: selected ? 38 : 12,
            margin: const EdgeInsets.only(right: 7),
            decoration: BoxDecoration(
              color: selected
                  ? AppTheme.brandRed
                  : Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}
