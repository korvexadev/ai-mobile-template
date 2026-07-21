# Mobile Foundation Plan

- [ ] `pending` Create Flutter application and environment flavors.
- [ ] `pending` Add Riverpod generator, immutable model, router, link, secure-storage, REST/OpenAPI, socket, and observability dependencies.
- [ ] `pending` Import/pin `packages/adaptive_platform_ui` and document its provenance.
- [ ] `pending` Build design tokens and wrappers around adaptive app/scaffold/navigation/actions.
- [ ] `pending` Add `ProviderScope`, environment overrides, error boundary, and background bootstrap.
- [ ] `pending` Implement session state and Riverpod-aware `go_router` redirects.
- [ ] `pending` Implement cached effective feature-flag snapshot.
- [ ] `pending` Generate the typed REST client from the backend OpenAPI contract and add domain mappers.
- [ ] `pending` Implement one authenticated socket manager with reconnect, resubscription, and REST reconciliation.
- [ ] `pending` Implement typed dynamic deep-link registry, resolver, coordinator, pending-link store, and telemetry.
- [ ] `pending` Configure Universal Links/App Links and domain verification per environment.
- [ ] `pending` Add cold/warm/auth/flag/offline link tests.
- [ ] `pending` Deliver the first feature vertical slice using the mandated feature structure.
- [ ] `pending` Establish iOS 26+, legacy iOS, and Android visual smoke tests.

## Mobile decisions to record

- REST/OpenAPI client-generation and HTTP-library choice.
- Socket transport, event envelope, and reconnect policy.
- Adaptive package source and upgrade policy.
- Environment/flavor naming.
- Offline cache policy.
- Push notification provider and permission strategy.
