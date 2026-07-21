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
- Represent async UI with `AsyncValue` or an explicit immutable state when multiple concurrent states exist.
- Keep side effects in notifiers/use cases, never widget `build` methods.
- Use `ref.watch` for rendering, `ref.read` for commands, and `ref.listen` for one-off UI effects.
- Scope mutable state to the shortest useful lifetime; use `autoDispose` unless persistence is intentional.
- Repositories and external clients are providers and are overridden in tests.
- Persist only deliberate state; credentials use secure storage.

## UI rules

- Business features consume app-level adaptive wrappers, not direct iOS-version checks.
- Use `AdaptiveScaffold`, `AdaptiveAppBar`, `AdaptiveBottomNavigationBar`, adaptive controls, and semantic design tokens.
- Enable native toolbar/bottom bar only where their navigation behavior is tested.
- Keep platform-specific code inside the adaptive package or a narrowly named adapter.
- Every screen supports text scaling, safe areas, keyboard navigation where applicable, semantics, dark mode, loading, empty, error, and retry states.

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
