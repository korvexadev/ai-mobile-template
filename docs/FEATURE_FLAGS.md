# Mobile Feature Flags

The backend returns an effective REST snapshot containing enabled codes, revision, fetched/expiry timestamps, and client compatibility metadata. Mobile does not evaluate protected targeting rules.

Riverpod exposes:

- A cached-then-refreshed `FeatureFlagSnapshot`.
- A typed flag catalog.
- `isFeatureEnabledProvider(code)` for presentation and router decisions.

Unknown, expired, or malformed flags default to disabled. A disabled feature must not render navigation, accept a direct route/deep link, prefetch data, or subscribe to socket rooms. Backend authorization still governs every endpoint and socket action.

Test enabled, disabled, preview, stale cache, offline refresh, unknown flag, direct navigation, and live disable behavior.
