# Mikozi Mobile Plan

Status values are `pending`, `in_progress`, `blocked`, and `done`. Work follows
the shared contract-first loop in `../backend/docs/DELIVERY_WORKFLOW.md`.

## 0. Platform foundation and contract tooling

- [ ] `in_progress` Scaffold Flutter with Riverpod, `go_router`, strict
      analysis, environment validation, secure storage, observability, and tests.
- [ ] `pending` Pin `adaptive_platform_ui`; build semantic publication tokens
      and adaptive app, scaffold, navigation, typography, media, and feedback
      primitives.
- [ ] `pending` Generate the REST client from backend OpenAPI and implement
      common auth, error, caching, deep-link, and connectivity boundaries.

## 1. Phone identity and admin access

- [ ] `in_progress` Build guest state, phone OTP request/verification, onboarding,
      JWT refresh/logout, secure session restore, and expired/revoked recovery.
- [x] `done` Ship phone entry, six-cell OTP verification, first-time
      display-name completion, secure restoration, auth-aware routing, and the
      adaptive four-tab reader shell.
- [x] `done` Translate the login reference into the shared phone-auth visual
      system, enable selectable app copy, and document host/emulator/physical
      device local-backend addressing.
- [x] `done` Make route-level text selection safe under both MaterialApp and
      CupertinoApp with cross-platform localization coverage and regression
      tests.
- [x] `done` Add a shared route boundary and adaptive authentication inputs so
      Material and Cupertino hosts satisfy the same behavior contracts while
      retaining native platform controls.
- [x] `done` Make local physical-device auth use the ignored tunnel
      configuration, add adaptive action progress, and guarantee recovery from
      every OTP/profile busy state.
- [x] `done` Ship the first-run splash, three-page onboarding, persisted
      completion state, typed routing, and the initial Login destination.
- [ ] `pending` Add pending-link capture, TTL, and post-auth continuation.
- [ ] `pending` Pass the shared reader identity journey with backend.

### First-run experience acceptance criteria

- Splash uses the existing Mikozi mark, resolves first-run state outside the
  widget tree, and routes without a visible blank frame.
- Onboarding contains exactly three concise, responsive pages with one heading,
  one short supporting line, original code-native editorial artwork, clear
  progress, and generous white space.
- Completing onboarding persists only a boolean preference and opens Login;
  later launches bypass onboarding and open Login after splash.
- Login is intentionally limited to the Mikozi identity, a short welcome, and
  one accessible Login action until the OTP workflow is implemented.
- Routing is typed with `go_router`; mutable state and persistence use generated
  Riverpod providers and remain replaceable in tests.
- All first-run screens support the complete light theme, text scaling, safe
  areas, narrow phones, tablets, keyboard focus, and screen-reader semantics.
  Dark mode is deliberately deferred until its full token set is designed.

### Phone authentication acceptance criteria

- A valid Malawi number calls `POST /api/v1/auth/request-otp`; the UI never
  invents a challenge or treats request success as authentication.
- Six digits call `POST /api/v1/auth/verify-otp` with the challenge ID.
  Stable backend errors remain safe and actionable.
- Verification persists tokens only through OS secure storage. An access-token
  expiry uses the rotating refresh endpoint when the refresh token remains
  valid; invalid or expired sessions fail closed to Login.
- A null or blank server `displayName` opens one concise name screen and
  `PATCH /api/v1/auth/me`; returning readers open the authenticated shell.
- iOS 26+ uses the native adaptive Liquid Glass bottom bar. The cross-platform
  fallback uses the same four destinations and HugeIcons, with tab state kept
  alive and no unnecessary animation.
- Auth pages use the light publication theme, semantic spacing scale, safe
  areas, keyboard-aware scrolling, autofill, text scaling, and test-overridable
  repositories.

## 2. Taxonomy and media

- [ ] `pending` Build section/topic discovery and accessible article media,
      captions, credits, renditions, and degraded/offline states.
- [ ] `pending` Register canonical section, topic, and article deep-link targets.
- [ ] `pending` Pass the shared taxonomy/media acceptance journey.

## 3. Newsroom publishing

- [ ] `in_progress` Build the configurable category homepage and authenticated
      article reader from REST; top/latest feeds, correction, and sponsorship
      metadata remain pending.
- [x] `done` Wire the real homepage into the reader shell and translate
      `home.png` into pinned actions, immersive banners, compact story rows,
      category pills, carousels, adverts, and floating navigation without
      changing dashboard-resolved order.
- [x] `done` Add visible manual and pull-to-refresh REST reconciliation for
      dashboard changes, centralize homepage geometry at 8-point gutters and
      12/8-point radii, and standardize relative project imports.
- [x] `done` Centralize the physical-device HTTPS API origin and `/api/v1`
      prefix in one constants file used by the shared Dio provider.
- [x] `done` Apply the fast, reduced-motion-aware fade transition to every
      typed application route.
- [x] `done` Make the reader header transparent and logo-only, move refresh to
      adaptive pull gestures, introduce taller gradient-overlay story cards
      with trailing carousel peeks, and remove Material ink effects from
      shared controls.
- [x] `done` Distinguish the More-category sheet, fade the floating header as
      content scrolls beneath it, and standardize pull refresh on
      `RefreshIndicator.adaptive`.
- [x] `done` Add authenticated slug-based article reading with ordered
      selectable Markdown, responsive images and captions, inline
      privacy-enhanced YouTube playback, summaries, bylines, advert slots,
      stable errors, and refresh.
- [x] `done` Render horizontal lists as compact 16:9 cards with metadata below,
      expose section More for more than five resolved stories, page the
      backend-owned category feed, and render server-scored similar stories.
- [x] `done` Keep article navigation fully transparent, add cache-only native
      image sharing and local article bookmarks, use one bounded image cache
      throughout the reader, and redesign More categories as an anchored,
      spacious action sheet.
- [x] `done` Keep More-category selection for the in-memory application
      session, harden cached image requests for CDN and relative media URLs,
      auto-advance multi-story banners through an infinite carousel, expose
      the Saved feed, and translate the profile reference into reader settings.
- [x] `done` Make the light launch experience deterministic in OS dark mode,
      route every reader-tab destination, keep a selected More category at the
      front of the rail, and prevent Saved-feed rendering from consuming
      backend article reads.
- [x] `done` Group local bookmarks by their actual save date, retain concise
      article snapshots with hero/inline-image fallback, and mirror the proven
      ChanguFood iOS 26 in-place native tab shell with Mikozi HugeIcon assets.
- [ ] `pending` Handle publication updates as hints and reconcile through REST
      when sockets or push are introduced.
- [ ] `pending` Pass the shared publish-and-read journey with backend/dashboard.

### Configurable homepage acceptance criteria

- Mobile reads `GET /api/v1/reader/homepage` through its repository and
  generated-contract boundary. Widgets never construct endpoint URLs.
- The category rail renders explicit top-navigation categories in order and
  exposes backend-resolved More categories without recomputing placement.
- Banner, list, horizontal list, advert, and categories sections render from
  the ordered REST document. Mobile never auto-fills or deduplicates articles.
- Loading skeleton, refresh, empty category, network failure, image failure,
  dark mode, text scaling, and semantic advertisement labels are supported.
- Category and article navigation use stable slugs when their detail routes are
  introduced; database IDs remain opaque transport identity.
- Article detail consumes `GET /api/v1/reader/articles/slug/:slug` and renders
  every supported section in the exact array order returned by the backend.

## 4. Reader discovery and audience preferences

- [ ] `pending` Build language, region, topic, notification, consent, history,
      personalization explanation, and reset controls.
- [ ] `pending` Build personalized feeds with opaque cursors, ranking reasons,
      diversity, cache, refresh, offline, and stale-policy states.
- [ ] `pending` Pass the shared discovery/personalization journey.

## 5. Advertising

- [ ] `pending` Build typed ad placements with visible labels, accessibility,
      safe click-through, frequency behavior, and editorial-content separation.
- [ ] `pending` Add idempotent impression/click delivery with offline retry and
      no raw protected audience data.
- [ ] `pending` Pass the shared advertising delivery journey.

## 6. Reader engagement and search

- [ ] `pending` Build search, suggestions, bookmarks, reading-history controls,
      and privacy-safe engagement state.
- [ ] `pending` Add derived-index unavailable, offline, empty, pagination, and
      recovery states.
- [ ] `pending` Pass the shared engagement/search acceptance journey.

## 7. Distribution, deep links, and notifications

- [ ] `pending` Complete canonical sharing/deep links, notification preferences,
      breaking/followed-topic delivery, pending navigation, and delivery feedback.
- [ ] `pending` Add the central authenticated socket client only for justified
      live behavior, with reconnect and REST reconciliation.
- [ ] `pending` Pass the shared distribution acceptance journey.

## 8. Analytics, operations, and hardening

- [ ] `pending` Add consent-aware product quality analytics, diagnostics, crash
      context, release compatibility, and safe support information.
- [ ] `pending` Complete iOS 26+, legacy iOS, Android, accessibility, privacy,
      performance, store, and production-readiness gates.
- [ ] `pending` Pass the final cross-application production-readiness journey.
