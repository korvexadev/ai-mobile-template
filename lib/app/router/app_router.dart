import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/articles/presentation/article_detail_page.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/application/auth_flow_state.dart';
import '../../features/auth/presentation/complete_profile_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/otp_page.dart';
import '../../features/home/presentation/category_articles_page.dart';
import '../../features/home/presentation/reader_shell_page.dart';
import '../../features/onboarding/application/onboarding_controller.dart';
import '../../features/onboarding/domain/onboarding_status.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/onboarding/presentation/splash_page.dart';
import '../adaptive/mikozi_page_boundary.dart';
import 'mikozi_fade_page.dart';

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
  if (flow.stage == AuthStage.authenticated &&
      (location == const HomeRoute().location ||
          location == const LatestRoute().location ||
          location == const SavedRoute().location ||
          location == const ProfileRoute().location ||
          location.startsWith('/articles/') ||
          location.startsWith('/categories/'))) {
    return null;
  }
  return location == target ? null : target;
}

class _RouterRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}

@TypedGoRoute<SplashRoute>(path: '/splash')
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return _page(state, const SplashPage());
  }
}

@TypedGoRoute<OnboardingRoute>(path: '/onboarding')
class OnboardingRoute extends GoRouteData with $OnboardingRoute {
  const OnboardingRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return _page(state, const OnboardingPage());
  }
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return _page(state, const LoginPage());
  }
}

@TypedGoRoute<OtpRoute>(path: '/verify')
class OtpRoute extends GoRouteData with $OtpRoute {
  const OtpRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return _page(state, const OtpPage());
  }
}

@TypedGoRoute<CompleteProfileRoute>(path: '/complete-profile')
class CompleteProfileRoute extends GoRouteData with $CompleteProfileRoute {
  const CompleteProfileRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return _page(state, const CompleteProfilePage());
  }
}

@TypedGoRoute<HomeRoute>(path: '/home')
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return _page(
      state,
      const ReaderShellPage(destination: ReaderDestination.home),
    );
  }
}

@TypedGoRoute<LatestRoute>(path: '/latest')
class LatestRoute extends GoRouteData with $LatestRoute {
  const LatestRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return _page(
      state,
      const ReaderShellPage(destination: ReaderDestination.latest),
    );
  }
}

@TypedGoRoute<SavedRoute>(path: '/saved')
class SavedRoute extends GoRouteData with $SavedRoute {
  const SavedRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return _page(
      state,
      const ReaderShellPage(destination: ReaderDestination.saved),
    );
  }
}

@TypedGoRoute<ProfileRoute>(path: '/profile')
class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return _page(
      state,
      const ReaderShellPage(destination: ReaderDestination.profile),
    );
  }
}

@TypedGoRoute<ArticleRoute>(path: '/articles/:slug')
class ArticleRoute extends GoRouteData with $ArticleRoute {
  const ArticleRoute({required this.slug});

  final String slug;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return _page(state, ArticleDetailPage(slug: slug));
  }
}

@TypedGoRoute<CategoryArticlesRoute>(path: '/categories/:categorySlug/articles')
class CategoryArticlesRoute extends GoRouteData with $CategoryArticlesRoute {
  const CategoryArticlesRoute({required this.categorySlug});

  final String categorySlug;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return _page(state, CategoryArticlesPage(categorySlug: categorySlug));
  }
}

Page<void> _page(GoRouterState state, Widget child) {
  return MikoziFadePage<void>(
    key: state.pageKey,
    child: MikoziPageBoundary(child: child),
  );
}
