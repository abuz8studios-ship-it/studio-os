# StudioOS Agent Contract

Use this root as the shared collaboration surface.

Rules:
- Do not mutate external service configs unless explicitly requested.
- Treat OpenClaw memory as protected system state.
- Write new briefs, packets, and intermediate outputs inside StudioOS first.
- Prefer `projects/`, `packets/`, and `memory/` over ad-hoc temp files.
- If a task changes production wiring, record the change in `logs/` and update `config/studio_registry.json`.

Preferred sources of truth:
- Production packets: `packets/`
- Shared context: `memory/`
- System registry: `config/studio_registry.json`
- Architecture notes: `docs/`
