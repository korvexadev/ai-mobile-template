# Mikozi Mobile

Flutter customer client with feature-first clean boundaries, Riverpod state management, `go_router` navigation, dynamic deep linking, and adaptive native UI.

The first Flutter vertical slice renders the backend-configured news homepage
on iOS and Android. The REST response owns category placement, section order,
automatic population, publication eligibility, and duplicate removal.

Intentional packages:

- `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`
- `go_router`
- `dio`
- `flutter_secure_storage`
- `adaptive_platform_ui`
- `hugeicons`
- `flutter_markdown_plus`
- `youtube_player_iframe`
- `url_launcher`
- `cached_network_image`, `flutter_cache_manager`
- `share_plus`

Packages are not the default solution. Flutter/Dart owns validation,
formatting, spacing, theme components, animation, and the six-cell OTP input.
Secure storage remains for the Keychain/Keystore boundary; HugeIcons is the
reviewed cross-platform icon set; the vendored adaptive package owns native
iOS 26 Liquid Glass components.
The maintained Markdown parser renders the newsroom's GFM contract without
allowing raw HTML; the iframe player owns YouTube's native platform-view and
fullscreen integration; URL Launcher safely hands article links to the
platform.

Reader images use one bounded, 240-object disk cache with a 14-day stale
window. Article sharing reads from that same cache without issuing a new image
request; uncached images fall back to title-and-summary sharing. `share_plus`
is retained only for the native Android/iOS share-sheet boundary.

Saved articles currently persist stable slugs in shared preferences. This is a
temporary local bookmark index, never a store for article bodies or session
material.
The Saved tab resolves those slugs through the authoritative article endpoint,
so publication changes remain current. Homepage category selection is
session-only Riverpod state: it survives tab and page reconstruction until the
process ends, but is never written to local storage.

## Current reader journey

`Splash -> Onboarding -> Phone -> OTP -> Name (new readers only) -> Reader`

- Phone and OTP use the backend `/api/v1/auth` REST contract.
- A null or blank profile `displayName` is the server-owned first-time signal.
- Access and rotating refresh tokens are stored only in OS secure storage.
- iOS 26+ uses the native adaptive tab bar; other platforms use the matching
  HugeIcons fallback.
- Shared feature behavior is platform-neutral. Route boundaries provide common
  theme and selection contracts, while adaptive controls render Material on
  Android and Cupertino on iOS.
- The shell contains the backend-configured editorial homepage, authenticated
  slug-based article reading, a local Saved feed, and the reader profile and
  settings destination. Latest remains a placeholder until a backend feed exists.
- Appearance follows the device by default. Profile → Appearance can persist
  a Light or Dark choice locally.

## API address

Every REST feature uses `ApiConstants.baseUrl`, currently:

```sh
https://breach-vegas-cinema-endorsed.trycloudflare.com/api/v1
```

When the tunnel changes, edit only `origin` in
`lib/core/constants/api_constants.dart`, keep the `/api/v1` version path
unchanged, and fully restart the app. No environment variable or launch
argument is required. Because the device connects to public HTTPS, it does not
need to share a LAN with the development Mac.

Local cleartext traffic is enabled only for Android debug/profile builds.
iOS allows local-network development traffic and shows the standard local
network permission prompt. Production API traffic must use HTTPS.

Quality gates:

```sh
/Volumes/Dev/Flutter/flutter/bin/dart format --output=none --set-exit-if-changed .
/Volumes/Dev/Flutter/flutter/bin/flutter analyze
/Volumes/Dev/Flutter/flutter/bin/flutter test
```

All product data uses versioned REST endpoints. There is currently no deployed
reader socket endpoint or event catalog. Pending payments reconcile through
REST while visible, and an article read refreshes the REST-owned allowance.
Reader notification delivery and preferences are awaiting backend contracts;
the available notification endpoints are administrator drafts only.

Most visible copy is selectable through route-level selection regions. The
adaptive app supplies both Cupertino and Material localization delegates so
selection controls work on iOS as well as Material platforms.
Editorial bodies should still use explicit selectable reader components when
article detail is introduced.

## Payments

Subscription payments use the authenticated REST API; the app never contains a
PayChangu credential or talks to PayChangu directly. Mobile money resolves
Airtel Money for `9…` numbers and TNM Mpamba for `8…` numbers. The signed-in
number is the default, with an explicit alternate-number flow. Bank-transfer
details are large, selectable, copyable, and confirm successful copying while
the backend continues verification after the sheet is closed.

Only one pending charge is allowed at a time. A small edge status control and
the Transactions page reconcile that charge through the backend. During an
effective administrator-scheduled free-reading window, the entitlement hides
subscription and transaction actions and the article paywall is suppressed.
