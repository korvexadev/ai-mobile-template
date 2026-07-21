# Mobile Agent Workflow

1. Read `AGENTS.md`, `PRODUCT.md`, `ARCHITECTURE.md`, and `PLAN.md`.
2. Define observable acceptance criteria and owned paths.
3. For cross-system work, agree on the OpenAPI endpoint, socket events, flag code, and deep-link target before implementation.
4. Update `PLAN.md`; keep one task in progress per active agent.
5. Implement domain and application behavior before presentation wiring.
6. Generate the REST client; never hand-edit generated files.
7. Add provider, mapper, widget, router/link, and socket tests as applicable.
8. Run formatting, analysis, tests, and platform smoke checks.
9. Handoff changed files, decisions, verification, contract impact, and remaining risks.

Delegate only bounded work with exclusive file ownership. Shared router, generated-client, flag-catalog, and socket-core files have one writer at a time.
