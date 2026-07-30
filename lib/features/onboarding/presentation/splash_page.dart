import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mikozi_mobile/app/theme/app_theme.dart';
import 'package:mikozi_mobile/features/auth/application/auth_controller.dart';
import 'package:mikozi_mobile/features/onboarding/application/onboarding_controller.dart';
import 'package:mikozi_mobile/shared/design_system/mikozi_brand.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingControllerProvider);
    final auth = ref.watch(authControllerProvider);
    final hasError = onboarding.hasError || auth.hasError;

    return AdaptiveScaffold(
      body: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              const Center(child: MikoziBrand(logoSize: 112, showName: false)),
              Positioned(
                left: 40,
                right: 40,
                bottom: 42,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: hasError
                      ? _SplashRetry(
                          onRetry: () {
                            ref.invalidate(onboardingControllerProvider);
                            ref.invalidate(authControllerProvider);
                          },
                        )
                      : const _LoadingRule(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingRule extends StatelessWidget {
  const _LoadingRule();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Opening Mikozi',
      child: Center(
        child: Container(
          height: 3,
          width: 48,
          decoration: BoxDecoration(
            color: AppTheme.brandRed,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _SplashRetry extends StatelessWidget {
  const _SplashRetry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(onPressed: onRetry, child: const Text('Try again')),
    );
  }
}
