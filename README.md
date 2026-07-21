# Mobile Template

Flutter customer client with feature-first clean boundaries, Riverpod state management, `go_router` navigation, dynamic deep linking, and adaptive native UI.

This directory intentionally contains architecture and agent guidance rather than generated Flutter boilerplate. Scaffold the application after `PRODUCT.md` and the first feature plan are complete.

Recommended foundational packages:

- `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`
- `go_router`
- `freezed_annotation`, `freezed`, `json_annotation`, `json_serializable`
- `dio` or an ADR-approved REST client
- OpenAPI-generated request/response models and API clients
- `app_links`
- `flutter_secure_storage`
- `sentry_flutter` or the selected observability SDK
- Local path package `packages/adaptive_platform_ui`

Pin versions when scaffolding and record significant substitutions in an ADR.

All product data uses versioned REST endpoints. Real-time updates, chat, presence, and live status use authenticated sockets. REST/OpenAPI is the only client API contract in this template.
