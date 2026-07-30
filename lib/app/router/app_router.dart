import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mikozi_mobile/app/adaptive/mikozi_page_boundary.dart';
import 'package:mikozi_mobile/features/auth/application/auth_controller.dart';
import 'package:mikozi_mobile/features/auth/application/auth_flow_state.dart';
import 'package:mikozi_mobile/features/auth/presentation/complete_profile_page.dart';
import 'package:mikozi_mobile/features/auth/presentation/login_page.dart';
import 'package:mikozi_mobile/features/auth/presentation/otp_page.dart';
import 'package:mikozi_mobile/features/home/presentation/reader_shell_page.dart';
import 'package:mikozi_mobile/features/onboarding/application/onboarding_controller.dart';
import 'package:mikozi_mobile/features/onboarding/domain/onboarding_status.dart';
import 'package:mikozi_mobile/features/onboarding/presentation/onboarding_page.dart';
import 'package:mikozi_mobile/features/onboarding/presentation/splash_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = _RouterRefresh();
  ref
    ..listen(onboardingControllerProvider, (_, _) => refresh.notify())
    ..listen(authControllerProvider, (_, _) => refresh.notify())
    ..onDispose(refresh.dispose);
  return GoRouter(
    initialLocation: const SplashRoute().location,
    routes: $appRoutes,
    refreshListenable: refresh,
    redirect: (context, state) => _redirect(ref, state),
  );
}

String? _redirect(Ref ref, GoRouterState state) {
  final location = state.matchedLocation;
  final onboarding = ref.read(onboardingControllerProvider);
  final auth = ref.read(authControllerProvider);
  if (onboarding.isLoading || auth.isLoading) {
    return location == const SplashRoute().location
        ? null
        : const SplashRoute().location;
  }
  if (onboarding.hasError || auth.hasError) {
    return location == const SplashRoute().location
        ? null
        : const SplashRoute().location;
  }
  if (onboarding.value == OnboardingStatus.pending) {
    return location == const OnboardingRoute().location
        ? null
        : const OnboardingRoute().location;
  }
  final flow = auth.value ?? const AuthFlowState.signedOut();
  final target = switch (flow.stage) {
    AuthStage.signedOut ||
    AuthStage.requestingOtp => const LoginRoute().location,
    AuthStage.awaitingOtp ||
    AuthStage.verifyingOtp => const OtpRoute().location,
    AuthStage.completingProfile ||
    AuthStage.savingProfile => const CompleteProfileRoute().location,
    AuthStage.authenticated => const HomeRoute().location,
  };
  return location == target ? null : target;
}

class _RouterRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}

@TypedGoRoute<SplashRoute>(path: '/splash')
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _selectable(const SplashPage());
  }
}

@TypedGoRoute<OnboardingRoute>(path: '/onboarding')
class OnboardingRoute extends GoRouteData with $OnboardingRoute {
  const OnboardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _selectable(const OnboardingPage());
  }
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _selectable(const LoginPage());
  }
}

@TypedGoRoute<OtpRoute>(path: '/verify')
class OtpRoute extends GoRouteData with $OtpRoute {
  const OtpRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _selectable(const OtpPage());
  }
}

@TypedGoRoute<CompleteProfileRoute>(path: '/complete-profile')
class CompleteProfileRoute extends GoRouteData with $CompleteProfileRoute {
  const CompleteProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _selectable(const CompleteProfilePage());
  }
}

@TypedGoRoute<HomeRoute>(path: '/home')
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _selectable(const ReaderShellPage());
  }
}

Widget _selectable(Widget child) => MikoziPageBoundary(child: child);
