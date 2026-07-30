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

Packages are not the default solution. Flutter/Dart owns validation,
formatting, spacing, theme components, animation, and the six-cell OTP input.
Secure storage remains for the Keychain/Keystore boundary; HugeIcons is the
reviewed cross-platform icon set; the vendored adaptive package owns native
iOS 26 Liquid Glass components.

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
- The shell currently contains a dummy editorial homepage plus Latest, Saved,
  and Profile destinations.

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

All product data uses versioned REST endpoints. Real-time updates use the
central authenticated socket client when a feature requires them.

Most visible copy is selectable through route-level selection regions. The
adaptive app supplies both Cupertino and Material localization delegates so
selection controls work on iOS as well as Material platforms.
Editorial bodies should still use explicit selectable reader components when
article detail is introduced.
