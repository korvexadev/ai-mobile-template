# Mobile Architecture

## Directory target

```text
mobile/
  lib/
    app/
      bootstrap/
      router/
      theme/
      feature_flags/
      deep_links/
    core/
      config/
      errors/
      networking/
      sockets/
      observability/
      persistence/
    features/
      <feature>/
        domain/
        application/
        data/
        presentation/
    shared/
      adaptive_ui/
      design_system/
      widgets/
  packages/
    adaptive_platform_ui/
  test/
  integration_test/
```

## Dependency direction

```text
presentation -> application -> domain
       |              ^           ^
       +---------- data adapters --+
```

Domain defines repository contracts. Data implements them. Application coordinates use cases and immutable state. Presentation observes Riverpod providers and sends commands.

## App bootstrap

Bootstrap initializes only prerequisites needed to render safely:

1. Environment/config validation.
2. Error reporting boundary.
3. Secure session restoration.
4. Cached feature-flag snapshot.
5. Deep-link capture.
6. REST client and socket-manager providers.
7. `ProviderScope` overrides.
8. `MaterialApp.router` or `AdaptiveApp.router` using the central `go_router` provider.

Network refresh, push tokens, permissions, and non-critical preload happen after first frame and expose state through providers.

## Riverpod model

- `Provider`: immutable dependencies/configuration.
- `FutureProvider`: read-only async data.
- `Notifier`/`AsyncNotifier`: user-driven mutable workflows.
- Provider families: parameterized entity/detail state.
- Overrides: environment composition and tests.

Providers are named by the capability they expose, not their implementation. Avoid a single global app controller.

## Adaptive UI and Liquid Glass

The project vendors or pins `adaptive_platform_ui` as a local package:

```yaml
dependencies:
  adaptive_platform_ui:
    path: packages/adaptive_platform_ui
```

The package is the platform boundary:

- iOS 26+: native UIKit toolbar, tab bar, buttons, segmented controls, switches, sliders, alerts, blur, spring animations, SF Symbols, haptics, and Liquid Glass effects.
- Older iOS: traditional Cupertino equivalents.
- Android: Material 3 equivalents.

Use `AdaptiveApp.router` at the root. Use `AdaptiveScaffold` and adaptive navigation components on screens. Set `useNativeToolbar: true` and `useNativeBottomBar: true` only in the design-system wrappers so feature code cannot accidentally produce inconsistent navigation.

Native iOS platform-view and method-channel code remains inside the package. Pin the package to a reviewed commit or maintain an internal fork; upgrades require native smoke tests and a short ADR/release note.

## Routing and dynamic links

`go_router` is exposed by a Riverpod provider so authentication, onboarding, flags, and pending links participate in redirect decisions without global state.

Components:

- `IncomingLinkSource`: wraps `app_links` initial link and stream.
- `DeepLinkParser`: validates the public URL envelope.
- `DeepLinkResolver`: resolves aliases/dynamic targets through local patterns or the backend.
- `DeepLinkRegistry`: maps a safe target enum to feature-owned typed route builders.
- `PendingDeepLinkStore`: holds one auth/onboarding-deferred target with TTL.
- `DeepLinkCoordinator`: deduplicates, checks flags/version/auth, navigates, and records telemetry.

Routes use stable slugs/opaque IDs. Pages receive typed route data and fetch their own current entity state. See `docs/DEEP_LINKING.md`.

## Feature flags

`featureFlagSnapshotProvider` exposes effective flag codes, revision, fetch time, and expiry. A repository loads the bounded cached snapshot immediately and refreshes it after session resolution. `isFeatureEnabledProvider(code)` is the only presentation-facing check.

Router redirects, navigation items, background subscriptions, and commands all consult the same snapshot. Backend permission checks remain authoritative.

## REST data access

The backend OpenAPI document generates typed DTOs and API clients. Generated code lives in a clearly marked directory and is never hand-edited. Feature data sources wrap generated clients, apply authentication/idempotency headers, map transport errors, and convert DTOs to domain models.

Reads use cache semantics defined by the endpoint. Mutations return the authoritative changed resource or an accepted-operation identifier. Pagination, sorting, and filtering use the shared REST conventions documented by the backend.

## Real-time sockets

One Riverpod-managed socket connection is shared by the authenticated application. It performs versioned handshake, token refresh, exponential reconnect with jitter, room/topic subscriptions, and connection-state reporting. Feature adapters decode versioned event envelopes into typed domain events.

REST remains authoritative: bootstrap and reconnect fetch snapshots, while sockets carry live deltas such as status, chat, presence, location, and operation progress. Sequence gaps, unknown event versions, or failed decoding trigger bounded REST reconciliation rather than silent state corruption.

## Testing

- Domain/use-case unit tests without Flutter bindings.
- Provider tests with repository/client overrides.
- DTO/mapper and OpenAPI contract fixture tests.
- Socket event decoding, reconnect, resubscribe, and reconciliation tests.
- Widget/golden tests for adaptive states.
- Router/deep-link table tests.
- Integration tests for the first critical journey on iOS and Android.
