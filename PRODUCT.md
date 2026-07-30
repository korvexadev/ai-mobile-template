# Mikozi Mobile Product

The mobile app is Mikozi's reader experience for iOS and Android. It presents
trusted journalism, reader-controlled personalization, and clearly labelled
advertising through the backend's versioned REST/OpenAPI contract.

## Reader outcomes

- Read top, latest, section, topic, and personalized news with guest access where
  policy permits.
- Sign in by phone OTP and maintain a safe, recoverable session.
- Understand why content is shown and edit or reset preferences.
- Search, bookmark, manage reading history, share, and open canonical links.
- Receive deliberate, consent-aware breaking and followed-topic notifications.
- See advertising without confusing it with editorial content.

## Experience principles

- Editorial hierarchy and typography lead the interface.
- Native adaptive components, restrained motion, strong spacing, and
  publication-quality imagery create a handcrafted result.
- Loading, offline, empty, failure, text scaling, dark mode, and screen-reader
  states are designed with the primary state—not added later.
- No screen evaluates protected targeting, permissions, or publication rules.

## Delivery relationship

Mobile work follows the shared module order in
`../backend/docs/DELIVERY_WORKFLOW.md`. Generated OpenAPI code is updated only
from a reviewed backend artifact. A module is complete only after its applicable
iOS, Android, and cross-application journeys pass.

## Initial journeys

1. Guest reading plus phone OTP authentication and onboarding.
2. Top/latest feeds and public article detail.
3. Sections, topics, media, sharing, and canonical deep links.
4. Reader preferences and explainable personalized feeds.
5. Clearly labelled, frequency-capped advertising placements.
6. Search, bookmarks, history controls, and notifications.

Environment URLs, public link domains, and supported-version policy remain
configuration and release decisions.
