# Mobile Agent Rules

This file is the complete agent contract for `mobile/`. Read `README.md`, `ARCHITECTURE.md`, `PLAN.md`, and relevant `docs/` before changing files.

## Operating rules

- Work from explicit acceptance criteria and keep `PLAN.md` current for non-trivial work.
- Preserve unrelated changes and never commit secrets, private keys, production credentials, personal data, build output, or dependency caches.
- Keep changes inside `mobile/` unless a cross-application task explicitly assigns another folder.
- Never silently change a REST endpoint, socket event, feature flag, or deep-link contract. Coordinate backend/dashboard consumers and tests.
- Feature flags are rollout controls, not authorization.
- Finish with formatting, analysis, tests, a changed-file summary, decisions, and remaining risks.

## Mandatory foundations

- Prefer Dart and Flutter SDK capabilities before adding a package. Add a
  dependency only when it provides a security boundary, native platform
  integration, a backend contract primitive, or substantial maintained
  behavior that would be unsafe or wasteful to reproduce. Record why it is
  needed and never add a package for spacing, theming, simple animation,
  formatting, validation, or a small reusable widget.
- State management and dependency injection use Riverpod. Do not introduce GetX, Provider, Bloc, global service locators, or mutable singletons.
- Navigation uses `go_router` with typed route definitions and Riverpod-aware redirects.
- New UI uses `adaptive_platform_ui` primitives where an equivalent exists.
- iOS 26+ Liquid Glass is provided by native adaptive components; older iOS uses Cupertino and Android uses Material 3.
- Deep-link infrastructure is part of bootstrap and must work before the first feature ships.
- Domain and application layers do not import Flutter UI libraries.
- Product APIs use versioned REST through generated OpenAPI clients. Do not introduce another product API style.
- Live state uses the central authenticated socket client. Do not create feature-specific socket connections.

## Feature structure

Create `lib/features/<feature>/` with only the layers needed:

- `domain/`: immutable entities, value objects, repository contracts, domain failures.
- `application/`: use cases and Riverpod notifiers/providers.
- `data/`: DTOs, mappers, remote/local sources, repository implementation.
- `presentation/`: routes, pages, widgets, view state rendering.

Cross-feature imports go through public domain/application interfaces. Promote code to `lib/shared/` only after at least two real consumers exist.

## Riverpod rules

- Prefer generated, typed providers.
- New providers use `riverpod_annotation` and generated `.g.dart` output unless
  a framework integration cannot be expressed safely through code generation.
- Represent async UI with `AsyncValue` or an explicit immutable state when multiple concurrent states exist.
- Every user-triggered network command shows immediate, accessible progress,
  prevents duplicate submission, and exits its busy state on success, expected
  failure, timeout, cancellation, and unexpected exceptions. Test progress and
  recovery; a disabled control without visible activity is not a loading state.
- Keep side effects in notifiers/use cases, never widget `build` methods.
- Use `ref.watch` for rendering, `ref.read` for commands, and `ref.listen` for one-off UI effects.
- Scope mutable state to the shortest useful lifetime; use `autoDispose` unless persistence is intentional.
- Repositories and external clients are providers and are overridden in tests.
- Persist only deliberate state; credentials use secure storage.

## UI rules

- Treat `ThemeData` and `CupertinoThemeData` as complete product systems.
  Define typography, color, surfaces, inputs, actions, navigation, cards,
  sheets, feedback, selection, progress, and transitions centrally before
  styling a feature locally. The current release is light-theme only.
- Use the semantic spacing scale in `AppSpacing`; do not scatter arbitrary
  padding values. Screen gutters, vertical rhythm, readable widths, safe areas,
  and keyboard insets are part of every layout review.
- Import project libraries through relative paths. Do not use
  `package:mikozi_mobile/...` imports inside `lib/`.
- Routed pages use the centralized `MikoziFadePage` transition. Keep navigation
  motion fast, preserve reduced-motion behavior, and do not define ad hoc page
  transitions inside features.
- Business features consume app-level adaptive wrappers, not direct iOS-version checks.
- Shared behavior and feature widgets remain platform-neutral. Put unavoidable
  Material/Cupertino branching in `adaptive_ui`, the vendored adaptive package,
  or another narrowly named platform boundary, and test both target branches
  whenever that boundary or one of its consumers changes.
- Every routed page uses `MikoziPageBoundary` so selection, Mikozi's Material
  theme, and the transparent Material interaction surface exist below the
  Navigator under both MaterialApp and CupertinoApp.
- Use `AdaptiveScaffold`, `AdaptiveAppBar`, `AdaptiveBottomNavigationBar`, adaptive controls, and semantic design tokens.
- Enable native toolbar/bottom bar only where their navigation behavior is tested.
- Keep platform-specific code inside the adaptive package or a narrowly named adapter.
- Every screen supports text scaling, safe areas, keyboard navigation where applicable, semantics, dark mode, loading, empty, error, and retry states.

## Mikozi reader implementation standard

- Treat reading comfort and white space as product behavior, not decoration.
- Use the references in `assets/design/` as a design library; translate their
  editorial hierarchy into original Mikozi UI and never ship reference
  screenshots as product artwork.
- Use bundled Manrope across interface and editorial display type to preserve
  the homepage reference's clean grotesk character. Do not fetch fonts at
  runtime.
- Keep source lines within the configured 80-character formatter width.
- Apply SOLID boundaries at real behavior seams. Prefer small focused types,
  but do not create pass-through abstractions without a second responsibility
  or a test boundary.
- Cache story metadata and decoded images with explicit size, age, and
  invalidation limits. Never grow an unbounded cache or duplicate the
  authoritative REST state.
- Homepage presentation maps one isolated renderer to each backend section
  type and preserves the resolved tab, section, and article order exactly.
  Never promote, merge, refill, or reorder dashboard-configured content in the
  widget tree.
- Keep homepage card geometry in `HomeLayout`: the horizontal content inset is
  8, large card radius is 12, and nested image radius is 8 unless a native
  control shape has stronger platform semantics.
- The homepage header is a transparent overlay with the logo only and visible
  contained actions. Fade its paper surface in as content scrolls beneath it.
  Refresh is pull-only: use `RefreshIndicator.adaptive`, prevent duplicate
  requests, and reconcile the full authoritative REST snapshot.
- Large story cards draw copy over a continuous image gradient, never a solid
  text panel. Multi-story banners and horizontal sections keep the next card
  visibly peeking into the viewport and take their heights from `HomeLayout`.
- Horizontal-list cards are compact 16:9 media with category/publication
  metadata and the title below. They never reuse banner geometry. A populated
  section exposes More only when it contains more than five resolved stories,
  and that action reads the backend category feed by stable slug.
- Shared controls avoid Material ink and elevation effects. Prefer restrained
  Cupertino press behavior and common HugeIcons so Android and iOS retain one
  calm, iOS-leaning visual language.
- Widgets render state and send commands. Persistence, routing decisions,
  timers, networking, caching, and authentication rules live outside widgets.
- Authentication tokens and session material use OS secure storage. Never put
  credentials in shared preferences, logs, analytics, widget state, route
  arguments, or error messages.
- Keep reader and editorial copy selectable by default. The route-level
  `SelectionArea` covers general copy, and `AdaptiveApp` must provide Material
  localizations when it creates a `CupertinoApp`; long-form article components
  must make selection an explicit, tested part of their reader behavior.
  Exclude control labels only when selection interferes with the control
  gesture.
- Article detail reads the authenticated reader endpoint by stable slug and
  renders the returned section array exactly in server order. Markdown remains
  selectable; images retain captions and alternative text; YouTube plays
  inline through the privacy-enhanced player; advert placement codes remain
  labelled slots until an ad-decision contract supplies creative content.
- Render backend-ranked similar stories with their normalized score and
  category; never recompute recommendation order in the client.

## Local development topology

- The backend, dashboard, and Flutter web app may all run on the development
  Mac. Flutter web and the iOS simulator can use `localhost`; the Android
  emulator uses `10.0.2.2`.
- Mobile REST addressing is centralized in
  `lib/core/constants/api_constants.dart`. Change `ApiConstants.origin` when
  the active development or production host changes; do not introduce a
  second base URL in a feature, widget, launch argument, or environment value.
- Physical devices use the configured HTTPS origin directly. Quick Tunnel
  hostnames are temporary, so update the single constant and fully restart the
  application whenever the tunnel changes.
- Keep local cleartext exceptions scoped to development or local-network
  traffic. Production endpoints use HTTPS, and platform security must not be
  broadly disabled to make local testing convenient.
- Backend URLs stay in networking configuration and repositories. Widgets
  never branch on emulator, simulator, device, or host addresses.

## Flags and links

- Access flags through the central `FeatureFlagSnapshot` Riverpod provider.
- A disabled feature must not appear, prefetch, subscribe, or accept direct navigation.
- Every linkable feature registers a typed target with the central deep-link registry.
- Never parse incoming URLs inside a page/widget.
- Test cold/warm starts, authentication deferral, replay suppression, invalid links, and disabled features.

## REST and sockets

- Features call repository interfaces; repositories call generated REST clients and map DTOs to domain models.
- Widgets and notifiers never construct URLs or parse transport payloads.
- Use idempotency keys for retried commands where supported and map stable backend error codes to domain failures.
- The socket manager owns authentication, connection state, reconnect/backoff, resubscription, and post-reconnect REST reconciliation.
- Feature handlers subscribe through typed event adapters and always unsubscribe through Riverpod disposal.
- Socket events are hints/live deltas; fetch an authoritative REST snapshot after reconnect or sequence gaps.

## Verification

Run `dart format`, `flutter analyze`, targeted tests, and the complete mobile test suite before handoff. Native adaptive changes require at least one iOS and one Android smoke path; Liquid Glass changes require iOS 26+ and legacy-iOS fallback verification.
