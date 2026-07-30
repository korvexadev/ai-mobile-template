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

Run against the local backend:

```sh
/Volumes/Dev/Flutter/flutter/bin/flutter run \
  --dart-define=MIKOZI_API_URL=http://localhost:9289/api/v1
```

Local addressing depends on where Flutter is running:

- Flutter web and the iOS simulator use
  `http://localhost:9289/api/v1`.
- The Android emulator uses `http://10.0.2.2:9289/api/v1`.
- A physical phone cannot use `localhost`, because that points back to the
  phone. Use the development Mac's reachable `.local` hostname or LAN address,
  keep both devices on the same network, and make sure the backend listens on
  a LAN-reachable interface.

For a physical iPhone:

```sh
/Volumes/Dev/Flutter/flutter/bin/flutter run \
  --dart-define=MIKOZI_API_URL=http://YOUR_MAC.local:9289/api/v1
```

An HTTPS Cloudflare Quick Tunnel is usually simpler for a physical device:

```sh
cloudflared tunnel --url http://localhost:9289

/Volumes/Dev/Flutter/flutter/bin/flutter run \
  --dart-define=MIKOZI_API_URL=https://YOUR_TUNNEL.trycloudflare.com/api/v1
```

For repeat local launches, copy `config/local.example.json` to the ignored
`config/local.json`, set the current tunnel URL, and run:

```sh
/Volumes/Dev/Flutter/flutter/bin/flutter run \
  --dart-define-from-file=config/local.json
```

The checked-in VS Code Flutter launch profiles use this local configuration.
Keep the tunnel process running while using the app. Quick Tunnel hostnames are
temporary and must not become the committed default API URL. Restart the
Flutter process—not only hot reload—after changing a `--dart-define` value.
Because the device connects to public HTTPS, this path does not require the
iPhone and Mac to share a LAN or use iOS local-network permission.

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
