# Mobile Dynamic Deep Linking

Use canonical HTTPS links such as `https://[DOMAIN]/l/<type>/<slug>`. Configure iOS Universal Links and Android App Links for every environment.

The startup pipeline is:

1. Capture initial and streamed links with `app_links`.
2. Validate scheme, host, path, and query limits.
3. Deduplicate OS replays in memory and with a short persisted TTL.
4. Resolve dynamic/alias links through `GET /api/v1/links/resolve`.
5. Check minimum app version and the effective feature flag.
6. Store one typed pending target while authentication/onboarding completes.
7. Navigate through the Riverpod-provided `go_router`.
8. Record safe received/resolved/rejected/navigated telemetry.

The backend returns a fixed target type, canonical ID/slug, safe arguments, required flag, authentication requirement, version requirement, expiry, and web/store fallback. The app maps only compiled target types; the server cannot execute arbitrary routes.

Test cold/warm/foreground delivery, auth deferral, duplicates, malformed/foreign links, disabled flags, outdated apps, offline resolution, and already-open targets.
